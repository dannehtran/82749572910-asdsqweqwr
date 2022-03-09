from flask import Flask, request, redirect
from werkzeug.routing import BaseConverter
import secrets
import string
import boto3
from botocore.exceptions import ClientError

app = Flask(__name__)

# Regex class for the url routes
class RegexConverter(BaseConverter):
    def __init__(self, url_map, *items):
        super(RegexConverter, self).__init__(url_map)
        self.regex = items[0]

app.url_map.converters['regex'] = RegexConverter

# AWS Client
AWS_CLIENT = boto3.client('dynamodb')

# Redis Cache
redis_cache = {}

# Web app route to create a shorten url using POST
@app.route('/newurl', methods=['POST'])
def GenerateNewUrl():
    incoming_request = request.get_json()

    # Check to see if the url is in the body
    if 'url' in incoming_request:
        incoming_url = incoming_request['url']
        random_characters = string.ascii_letters + string.digits
        new_url = ''.join(secrets.choice(random_characters) for i in range(9))

        json_data = {"url":incoming_url, "shortenUrl":new_url}
        return SetDynamoDB(json_data)
    else:
        return("No URL in request.")  

# Function to set Dynamo DB Item
def SetDynamoDB(data):
    table_name = 'short-my-url-tf'

    try:
        host = "http:127.0.0.1/"
        response = AWS_CLIENT.put_item(
            TableName=table_name,
            Item={
                'ShortenURL': {
                    'S': data['shortenUrl']
                },
                'OriginalURL': {
                    'S': data['url']
                },
            },
            ConditionExpression='attribute_not_exists(ShortenURL)',
        )

        return {"url":data['url'], "shortenUrl":host+data['shortenUrl']}

    except ClientError as e:
        # Check to see if there's a duplicate, if so generate another url recursively
        if e.response['Error']['Code'] == 'ConditionalCheckFailedException':  
            GenerateNewUrl()

# Function to get the original url from the shorten url and redirect to the original URL with code 304
@app.route('/<regex("[a-zA-Z0-9]{9}"):uid>')
def GetShortenURL(uid):
    table_name = 'short-my-url-tf'
    try:
        response = AWS_CLIENT.query(
            TableName=table_name,
            KeyConditionExpression= 'ShortenURL = :ShortenURL',
            ExpressionAttributeValues={
                ':ShortenURL':{
                    'S': str(uid)
                }
            },
            ConsistentRead=True
        )
        if response['Count'] == 1:
            return redirect(response['Items'][0]['OriginalURL']['S'], code=304)
        else:
            return "Error: /{} does not exist. ".format(str(uid))
    except ClientError as e:
        return "Client Error."