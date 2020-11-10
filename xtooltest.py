# *********************************************************************
# xToolTest.py
# Test Suite for xtool.py...
# *********************************************************************

import xtool
import datetime

def main():
    timetests()
    print("Testing Completed...")

# ====================================================
# Testing Time Based Functions...
# ====================================================
def timetests():
    print("Running Time Tests...")
    
    # TimeTest: 00001 - seconds() Since Midnight
    Result = xtool.seconds()
    assert Result >= 0 and Result <= (3600 * 24), \
           "TimeTest: 00001 - Value should be between 0 and 86400"
    
    # TimeTest: 00002 - duration(0) function
    Result = xtool.duration(0)
    assert Result == "00:00:00", \
           "TimeTest: 00002 - duration(0) should return '00:00:00'"

    # TimeTest: 00003 - duration(30) should return '00:00:30'
    Result = xtool.duration(30)
    assert Result == "00:00:30", \
           "TimeTest: 00003 - duration(30) should return '00:00:30'"

    # TimeTest: 00004 - duration(150) should return '00:02:30'
    Result = xtool.duration(150)
    assert Result == "00:02:30", \
           "TimeTest: 00004 - duration(150) should return '00:02:30'"

    # TimeTest: 00005 - duration(4000) should return '01:06:40'
    Result = xtool.duration(4000)
    assert Result == "01:06:40", \
           "TimeTest: 00005 - duration(4000) should return '01:06:40'"

    # TimeTest: 00006 - duration2Seconds('01:06:40') should return 4000
    Result = xtool.duration2Seconds("01:06:40")
    assert Result == 4000, \
           "TimeTest: 00006 - duration('01:06:40') should return 4000"

    # TimeTest: 00007 - daysInCentury(datetime.date(2020,5,31))
    Result = xtool.daysInCentury(datetime.date(2020,5,31))
    assert Result == 7456, \
           "TimeTest: 00007 - Ref. Date 05/31/2020 should result in 7456"

    # TimeTest: 00008 - secondsInCenturyToMidnight(datetime.date(2020,5,31))
    Result = xtool.secondsInCenturyToMidnight(datetime.date(2020,5,31))
    assert Result == 644198400, \
           "TimeTest: 00008 - Ref. Date 05/31/2020 should result in 644198400"

    # TimeTest: 00009 - secondsInCenturyToMidnight(datetime.date(2020,5,31))
    Result = xtool.secondsInCenturyToMidnight(datetime.date(2020,5,31))
    assert Result == 644198400, \
           "TimeTest: 00009 - Ref. Date 05/31/2020 should result in 644198400"

    # TimeTest: 00010 - dayOfYear(datetime.date(2020,5,31))
    Result = xtool.dayOfYear(datetime.date(2020,5,31))
    assert Result == 151, \
           "TimeTest: 00010 - Ref. Date 05/31/2020 should result in 151"

    # TimeTest: 00011 - weekNum(datetime.date(2020,5,31))
    Result = xtool.weekNum(datetime.date(2020,5,31))
    assert Result == 21, \
           "TimeTest: 00011 - Ref. Date 05/31/2020 should result in 21"

    # TimeTest: 00012 - xtool.quarter(datetime.date(2020,5,31))
    Result = xtool.quarter(datetime.date(2020,5,31))
    assert Result == 2, \
           "TimeTest: 00012 - Ref. Date 05/31/2020 should result in 2"

    # TimeTest: 00013 - validDate(2, 29, 2020)
    Result = xtool.validDate(2, 29, 2020)
    assert Result == True, \
           "TimeTest: 00013 - validDate(2, 29, 2020) Result Should be True"

    # TimeTest: 00014 - validDate(2, 29, 2019)
    Result = xtool.validDate(2, 29, 2019)
    assert Result == False, \
           "TimeTest: 00014 - validDate(2, 29, 2019) Result Should be False"

    # TimeTest: 00015 - monthDays(2, 2020)
    Result = xtool.monthDays(2, 2020)
    assert Result == 29, \
           "TimeTest: 00015 - monthDays(2, 2020) Result Should be 29"

    # TimeTest: 00016 - monthDays(2, 2019)
    Result = xtool.monthDays(2, 2019)
    assert Result == 28, \
           "TimeTest: 00016 - monthDays(2, 2019) Result Should be 28"

    # TimeTest: 00017 - isLeapYear(2019)
    Result = xtool.isLeapYear(2019)
    assert Result == False, \
           "TimeTest: 00017 - isLeapYear(2019) Result Should be False"

    # TimeTest: 00018 - isLeapYear(2020)
    Result = xtool.isLeapYear(2020)
    assert Result == True, \
           "TimeTest: 00018 - isLeapYear(2020) Result Should be True"

    # TimeTest: 00019 - stod("20200531")
    Result = xtool.stod("20200531")
    assert Result == datetime.date(2020, 5, 31), \
           "TimeTest: 00019 - Result Should be datetime.date(2020, 5, 31)"

    # TimeTest: 00020 - dtos(datetime.date(2020, 5, 31))
    Result = xtool.dtos(datetime.date(2020, 5, 31))
    assert Result == "20200531", \
           "TimeTest: 00020 - Result Should be '20200531'"

    # TimeTest: 00021 - dtoc(datetime.date(2020, 5, 31))
    Result = xtool.dtoc(datetime.date(2020, 5, 31))
    assert Result == "05/31/2020", \
           "TimeTest: 00021 - Result Should be '05/31/2020'"

    # TimeTest: 00022 - dtoc(datetime.date(2020, 5, 31), "ISO")
    Result = xtool.dtoc(datetime.date(2020, 5, 31), "ISO")
    assert Result == "2020-05-31", \
           "TimeTest: 00022 - Result Should be '2020-05-31'"

    # TimeTest: 00023 - ctod("05/31/2020")
    Result = xtool.ctod("05/31/2020")
    assert Result == datetime.date(2020, 5, 31), \
           "TimeTest: 00023 - Result Should be datetime.date(2020, 5, 31)"

    # TimeTest: 00024 - ctot("05/31/2020 13:45")
    Result = xtool.ctot("05/31/2020 13:45:00")
    assert Result == datetime.datetime(2020, 5, 31, 13, 45), \
           "TimeTest: 00024 - Result Should be datetime.datetime(2020, 5, 31, 13, 45)"

    # TimeTest: 00025 - dtot(datetime.date(2020, 5, 31))
    Result = xtool.dtot(datetime.date(2020, 5, 31))
    assert Result == datetime.datetime(2020, 5, 31), \
           "TimeTest: 00025 - Result Should be datetime.datetime(2020, 5, 31)"

    # TimeTest: 00026 - ttod(datetime.datetime(2020, 5, 31, 13, 45))
    Result = xtool.ttod(datetime.datetime(2020, 5, 31, 13, 45))
    assert Result == datetime.date(2020, 5, 31), \
           "TimeTest: 00026 - Result Should be datetime.date(2020, 5, 31)"
# ============================================================
# tokenTests()
# ============================================================

def tokenTests():
    
    print("Count Nothing: " + str(tokenCount("", ",")))
    print("Count 1: " + str(tokenCount("Red",",")))
    TokenSet = tokenAdd("Red",",","Green")
    print("Add token to existing: " + TokenSet)
    print("Add 1 and Count 2: " + str(tokenCount(TokenSet,",")))
    print("Split Value: " + str(TokenSet.split(",")))
    print("Get First of Two: " + tokenGet(TokenSet, ",", 1))
    print("Get Second of Two: " + tokenGet(TokenSet, ",", 2))
    TokenSet = tokenPut(TokenSet,",",2,"Blue")
    print("Token Put: " + TokenSet)
    TokenSet = tokenDelete(TokenSet,",",1)
    print("Token Delete: " + TokenSet)
    TokenSet = tokenInsert(TokenSet, ",", 1, "Red")
    print("Token Insert: " + TokenSet)

if __name__ == "__main__":
    main()
if __name__ == "xtooltest":
    print("Loading Module xtooltest...")
    main()
