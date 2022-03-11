#! /usr/bin/env python3

from clfparser import CLFParser
from datetime import datetime

LIMITER_DICT = {}

def RateLimiter(log_tuple):
    # Check to see if IP key is in dict, if not create key and add count and start time
    if log_tuple[0] in LIMITER_DICT:
        if LIMITER_DICT[log_tuple[0]]["ban_status"] == "None":
            request_header = log_tuple[2]
            if "/login" in request_header:
                if LIMITER_DICT[log_tuple[0]]["login_first_seen"] == 0 and LIMITER_DICT[log_tuple[0]]["login_last_seen"] == 0:
                    LIMITER_DICT[log_tuple[0]]["login_first_seen"] = log_tuple[1]
                    LIMITER_DICT[log_tuple[0]]["login_last_seen"] = LIMITER_DICT[log_tuple[0]]["login_first_seen"]
            CheckRateLimiter(log_tuple)
        elif LIMITER_DICT[log_tuple[0]]["ban_status"] == "BAN":
            CheckBanTimer(log_tuple)
            
    else:
        if "/login" in log_tuple[2]:
            LIMITER_DICT[log_tuple[0]] = {"count":0, "counter_20":0, "first_seen": log_tuple[1],"ban_status":"None", "ban_time":0, "last_seen":log_tuple[1],"login_count":0, "login_first_seen":log_tuple[1], "login_last_seen":log_tuple[1]}
        else:
            LIMITER_DICT[log_tuple[0]] = {"count":0, "counter_20":0, "first_seen": log_tuple[1],"ban_status":"None", "ban_time":0, "last_seen":log_tuple[1],"login_count":0, "login_first_seen":0, "login_last_seen":0}

def CheckLoginLimiter(log_tuple):
    ip = log_tuple[0]
    request_header = log_tuple[2]
    login_count = LIMITER_DICT[ip]["login_count"]
    login_first = LIMITER_DICT[ip]["login_first_seen"]
    login_last = LIMITER_DICT[ip]["login_last_seen"]
    latest_request = datetime.timestamp(log_tuple[1])

    if login_count >= 20:
        if "/login" in request_header:
            time_delta_login = login_last - login_first
            if time_delta_login.total_seconds() <= 600:
                LIMITER_DICT[ip]["ban_time"] = latest_request + 7200
                LIMITER_DICT[ip]["ban_status"] = "BAN"
                print("{},{},{}".format(int(latest_request), "BAN", ip))
                print("{},{},{}".format(int(LIMITER_DICT[ip]["ban_time"]), "UNBAN", ip))
            else:
                LIMITER_DICT[ip]["login_first_seen"] = log_tuple[1]
                LIMITER_DICT[ip]["login_last_seen"] = LIMITER_DICT[ip]["login_first_seen"]
                LIMITER_DICT[ip]["login_count"] = 1

def CheckRateLimiter(log_tuple):
    ip = log_tuple[0]
    request_header = log_tuple[2]
    ip_count = LIMITER_DICT[ip]["count"]
    ip_first = LIMITER_DICT[ip]["first_seen"]
    ip_last = LIMITER_DICT[ip]["last_seen"]
    login_count = LIMITER_DICT[ip]["login_count"]
    login_first = LIMITER_DICT[ip]["login_first_seen"]
    login_last = LIMITER_DICT[ip]["login_last_seen"]
    latest_request = datetime.timestamp(log_tuple[1])
    time_delta = ip_last - ip_first

    if ip_count == 20:
        LIMITER_DICT[ip]["counter_20"] = LIMITER_DICT[ip]["counter_20"] + 1
        LIMITER_DICT[ip]["count"] = 0
        
    if LIMITER_DICT[ip]["counter_20"] % 2 == 0 and LIMITER_DICT[ip]["counter_20"] != 0 and ip_count == 0:
        if "/login" in request_header and login_count < 20:
            LIMITER_DICT[ip]["last_seen"] = log_tuple[1]                 
            LIMITER_DICT[ip]["login_last_seen"] = LIMITER_DICT[ip]["last_seen"]
            LIMITER_DICT[ip]["login_count"] = LIMITER_DICT[ip]["login_count"] + 1
            LIMITER_DICT[ip]["count"] = LIMITER_DICT[ip]["count"] + 1 
        else:
            if time_delta.total_seconds() <= 60:
                LIMITER_DICT[ip]["ban_time"] = latest_request + 600
                LIMITER_DICT[ip]["ban_status"] = "BAN"
                print(int(latest_request), "BAN", ip)
                print(int(LIMITER_DICT[ip]["ban_time"]), "UNBAN", ip)
            if time_delta.total_seconds() > 60: 
                if login_count < 20:
                    if LIMITER_DICT[ip]["counter_20"] == 2 and ip_count == 0:
                        LIMITER_DICT[ip]["first_100_seen"] = LIMITER_DICT[ip]["first_seen"]                  
                    LIMITER_DICT[ip]["last_seen"] = log_tuple[1]
                    LIMITER_DICT[ip]["first_seen"] = LIMITER_DICT[ip]["last_seen"]
                    LIMITER_DICT[ip]["count"] = LIMITER_DICT[ip]["count"] + 1  
                if login_count >= 20:
                    CheckLoginLimiter(log_tuple)

    if LIMITER_DICT[ip]["counter_20"] % 5 == 0 and LIMITER_DICT[ip]["counter_20"] != 0 and ip_count == 0:
        if "first_100_seen" in LIMITER_DICT[ip]:
            time_delta = log_tuple[1] - LIMITER_DICT[ip]["first_100_seen"]
        else:
            time_delta = ip_last - ip_first
        if time_delta.total_seconds() <= 600:
            LIMITER_DICT[ip]["ban_time"] = latest_request + 3600
            LIMITER_DICT[ip]["ban_status"] = "BAN"
            if "first_100_seen" in LIMITER_DICT[ip]:
                print(int(latest_request), "BAN", ip)
            else:
                print(int(LIMITER_DICT[ip]["ban_time"]), "UNBAN", ip)
        if time_delta.total_seconds() > 600:
            if login_count < 20:
                LIMITER_DICT[ip]["last_seen"] = log_tuple[1]
                LIMITER_DICT[ip]["first_100_seen"] = LIMITER_DICT[ip]["last_seen"]
                LIMITER_DICT[ip]["count"] = LIMITER_DICT[ip]["count"] + 1
            if login_count >= 20:
                CheckLoginLimiter(log_tuple) 
    
    if ip_count < 20 and login_count < 20:
        if "/login" in request_header:
            LIMITER_DICT[ip]["last_seen"] = log_tuple[1]                 
            LIMITER_DICT[ip]["login_last_seen"] = LIMITER_DICT[ip]["last_seen"]
            LIMITER_DICT[ip]["login_count"] = LIMITER_DICT[ip]["login_count"] + 1
            LIMITER_DICT[ip]["count"] = LIMITER_DICT[ip]["count"] + 1
        else:
            LIMITER_DICT[ip]["last_seen"] = log_tuple[1]
            LIMITER_DICT[ip]["count"] = LIMITER_DICT[ip]["count"] + 1
        
def CheckBanTimer(log_tuple):
    time_stamp_request = datetime.timestamp(log_tuple[1])
    ban_timer = LIMITER_DICT[log_tuple[0]]["ban_time"]

    time_delta = time_stamp_request - ban_timer

    if time_delta >= 0:
        LIMITER_DICT.pop(log_tuple[0])
        RateLimiter(log_tuple)
    else:
        pass

def main():

    log = "TestQ1.log"
    # Open log file for reading
    with open(log, "r+") as logFile:
        for line in logFile:
            # Parse log line using clfparser and only get data we want
            data = CLFParser.logParts(line,'%h %time %r')
            RateLimiter(data)
                

main()