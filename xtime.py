# coding: ascii
# *************************************************************
# xtime.py
# *************************************************************

import math
import datetime
import time
import imp

# =============================================================
# main()
# =============================================================
def main():

    pass
# =============================================================
# seconds() - Seconds Since Midnight...
# =============================================================
def seconds():

    """Get the current time and subtract midnight..."""
    now = datetime.datetime.now()
    
    seconds_since_midnight = \
        (now - now.replace(hour=0, minute=0, second=0, \
        microsecond=0)).total_seconds()
    
    return seconds_since_midnight

# =============================================================
# duration(Seconds)
# =============================================================
def duration(Seconds):

    """Validate the parameter..."""

    if isinstance(Seconds, int):

        """Break out the Time Components..."""
        Hours = Seconds // 3600
        Minutes = (Seconds % 3600) // 60
        Seconds = (Seconds % 3600) % 60

    return str(Hours).zfill(2) + ":" \
           + str(Minutes).zfill(2) + ":" \
           + str(Seconds).zfill(2)

# =============================================================
# duration2Seconds(Duration="00:00:00")
# =============================================================
def duration2Seconds(Duration="00:00:00"):
    """Convert a Duration String to Seconds..."""

    Seconds = 0
    
    if type(Duration) == str and Duration.count(":") == 2 \
       and len(Duration.strip("0123456789:")) == 0:

        Seconds = int(tokenGet(Duration, ":", 1).zfill(2)) * 3600
        Seconds += (int(tokenGet(Duration, ":", 2).zfill(2)) * 60)
        Seconds += (int(tokenGet(Duration, ":", 3).zfill(2)))
        
    return Seconds

# =============================================================
# daysInCentury()
# =============================================================
def daysInCentury(Date = datetime.date.today()):

    Year = str(Date.year)
    Year = int(Year[:len(Year)-2]) * 100

    """How many days since the beginning of the Century..."""
    return (Date - datetime.date(Year, 1, 1)).days

# =============================================================
# secondsInCenturyToMidnight()
# =============================================================
def secondsInCenturyToMidnight(Date = datetime.date.today()):

    """Convert Days to Seconds..."""
    return daysInCentury(Date) * (3600 * 24)

# =============================================================
# secondsInCentury(Date = datetime.date.today())
# =============================================================
def secondsInCentury(Date = datetime.date.today()):
    return secondsInCenturyToMidnight(Date) + seconds()

# =============================================================
# today()
# =============================================================
def today():
    return datetime.date.today()

# =============================================================
# now()
# =============================================================
def now():
    return datetime.datetime.now()

# =============================================================
# dayOfYear()
# =============================================================
def dayOfYear(Date=datetime.date.today()):

    return (Date - datetime.date(Date.year,1,1)).days

# =============================================================
# weekNum(Date=datetime.date.today())
# =============================================================
def weekNum(Date=datetime.date.today()):

    return dayOfYear(Date)//7

# =============================================================
# quarter(Date=datetime.date.today())
# =============================================================
def quarter(Date=datetime.date.today()):

    Month = Date.month

    return ((Month - 1) // 3) + 1

# =============================================================
# validDate(Month, Day, Year)
# =============================================================
def validDate(Month, Day, Year):

    """Validate the Parameters..."""
    Valid = type(Month) == int \
            and type(Day) == int \
            and type(Year) == int

    """Validate the Date Parts..."""

    Valid = Valid and Year in range(1, 9999 + 1)
    Valid = Valid and Month in range(1, 12 + 1)
    Valid = Valid and Day in range(1, monthDays(Month, Year) + 1)

    return Valid

# =============================================================
# monthDays(Month, Day, Year)
# =============================================================
def monthDays(Month, Year=0):

    """Initialize Local Variables..."""
    Days = 0
    
    """Validate the Month..."""
    Valid = type(Month) == int and Month in range(1, 12 + 1)

    if Valid:
        if Month == 2:
            Days = 28
            
            if isLeapYear(Year):
                Days += 1
                
        elif Month in (4, 6, 9, 11):
            Days = 30
            
        else:
            Days = 31

    return Days

# =============================================================
# leapYear(Year)
# =============================================================
def isLeapYear(Year):

    """Initialize Local Variables..."""
    LeapYear = False
    
    """Validate the Parameter..."""
    if type(Year) == int and Year in range(1, 9999):

        """Perform the actual test..."""
        LeapYear = (Year % 4 == 0) \
                   and (Year % 400 == 0 or Year % 100 > 0)

    return LeapYear

# =============================================================
# stod(DateString) String Format: YYYYMMDD
# =============================================================
def stod(DateString):

    """Initialize Local Variables..."""
    Year = Month = Day = 0

    """Verify the DateString..."""
    if isinstance(DateString, str) and len(DateString) == 8:

        """Break out its consituent parts..."""
        Year = int(DateString[:4].strip().zfill(4))
        Month = int(DateString[4:6].strip().zfill(2))
        Day = int(DateString[6:].strip().zfill(2))

    """Validate the Date Parts..."""
    if validDate(Month, Day, Year):

        """Return the Date Value..."""        
        return datetime.date(Year, Month, Day)

    else:

        """Return Nothing..."""
        return None

# =============================================================
# dtos(Date) String Format: YYYYMMDD
# =============================================================
def dtos(Date):

    """Initialize Local Variables..."""
    DateString = ""

    """Validate the parameter..."""
    if isinstance(Date, datetime.date):

        """Break out the constituent parts..."""
        DateString = str(Date.year).zfill(4) \
           + str(Date.month).zfill(2) \
           + str(Date.day).zfill(2)

    return DateString

# =============================================================
# dtoc(Date) American Format: MM/DD/YYYY ISO Format: YYYY-MM-DD
# =============================================================
def dtoc(Date, Format = ""):

    """Initialize Local Variables..."""
    DateString = ""

    """Validate the parameter..."""
    if isinstance(Date, datetime.date):

        """Extract the Date parts..."""        
        Year = Date.year
        Month = Date.month
        Day = Date.day

        if type(Format) == str and Format.upper() == "ISO":
            
            """Build out the ISO Format DateString..."""
            DateString = str(Year).zfill(4) + "-" \
                + str(Month).zfill(2) + "-" \
                + str(Day).zfill(2)

        else:
            
            """Build out the American Format DateString..."""
            DateString = str(Month).zfill(2) + "/" \
                + str(Day).zfill(2) + "/" \
                + str(Year).zfill(4)

    return DateString

# =============================================================
# ctod(DateString) MM/DD/YYYY or 
# =============================================================
def ctod(DateString):
    """Initialize Local Variables..."""
    Month = Day = Year = 0
    DateType = None

    """Valiate the parameter..."""
    if isinstance(DateString, str):

        """Validate the DateString..."""
        Success = len(DateString) == 10 \
                  and len(DateString.strip("0123456789-/ ")) == 0

        """Break out the Date Parts..."""
        if Success:

            """Extract the Date parts..."""

            if DateString.find("/") == 2 and DateString.count("/") == 2:
                """American Format..."""
                Month = int(tokenGet(DateString, "/", 1).strip().zfill(2))
                Day = int(tokenGet(DateString, "/", 2).strip().zfill(2))
                Year = int(tokenGet(DateString, "/",3).strip().zfill(4))

            if DateString.find("-") == 4 and DateString.count("-") == 2:
                """ISO Sortable Format..."""
                Year = int(tokenGet(DateString, "-", 1).strip().zfill(4))
                Month = int(tokenGet(DateString, "-", 2).strip().zfill(2))
                Day = int(tokenGet(DateString, "-", 3).strip().zfill(2))

            if validDate(Month, Day, Year):
                
                DateType = datetime.date(Year, Month, Day)

    """Return Nothing..."""
    return DateType

# =============================================================
# ctot(DateTime) 
# =============================================================
def ctot(DateTime):

    """Initialize Local Variables..."""
    Length = Month = Day = Year = Hours = Minutes = Seconds = 0
    Date = Time = ""
    DateTimeType = None

    """Validate the Parameter..."""

    Success = isinstance(DateTime, str)

    if Success:

        """Extract the Date and the Time Parts..."""
        """If ISO Format strip out the T..."""
        Date = tokenGet(DateTime.replace("T"," "), " ", 1).strip()
        Time = tokenGet(DateTime.replace("T"," "), " ", 2).strip()
    
        Success = len(Date) == 10 \
                  and len(Date.strip("0123456789-/ ")) == 0

        """Break out the Date Parts..."""
        if Success:

            """Extract the Date parts..."""

            if Date.find("/") == 2 and Date.count("/") == 2:
                """American Format..."""
                Month = int(tokenGet(Date, "/", 1).zfill(2))
                Day = int(tokenGet(Date, "/", 2).strip().zfill(2))
                Year = int(tokenGet(Date, "/",3).zfill(4))

            if Date.find("-") == 4 and Date.count("-") == 2:
                """ISO Sortable Format..."""
                Year = int(tokenGet(Date, "-", 1).zfill(4))
                Month = int(tokenGet(Date, "-", 2).strip().zfill(2))
                Day = int(tokenGet(Date, "-", 3).zfill(2))

        if Success and len(Time) >= 8 \
               and len(Time.strip("0123456789:.")) == 0:

            """Break out the Time parts..."""
            Hours = int(tokenGet(Time, ":", 1).zfill(2))
            Minutes = int(tokenGet(Time, ":", 2).strip().zfill(2))
            Seconds = round(float(tokenGet(Time, ":", 3).zfill(2)))

    """Validate the Time parts..."""
    Success = Success and Hours in range(0, 23 + 1)
    Success = Success and Minutes in range(0, 59 + 1)
    Success = Success and Seconds in range(0, 59 + 1)

    """Validate the Date part..."""
    if Success and validDate(Month, Day, Year):

        """Build out the Timestamp..."""
        DateTimeType = datetime.datetime(Year, Month, Day, \
                                    Hours, Minutes, Seconds)

    return DateTimeType

# =============================================================
# dtot(Date)
# =============================================================
def dtot(Date):

    """Validate the parameter..."""
    if isinstance(Date, datetime.date):

        """Break out the Date parts..."""
        Year = Date.year
        Month = Date.month
        Day = Date.day

        return datetime.datetime(Year, Month, Day)

    else:

        """If not valid then return nothing..."""
        return None

# =============================================================
# ttod(DTime)
# =============================================================
def ttod(DateTime):
    """Initialize Local Variables..."""

    Year = Month = Day = 0
    
    """Validate the DateTime..."""
    if isinstance(DateTime, datetime.datetime):

        """Break out the Date parts..."""
        Year = DateTime.year
        Month = DateTime.month
        Day = DateTime.day
        
        return datetime.date(Year, Month, Day)
    
    else:

        """If not valid return nothing..."""        
        return None

# ============================================================
# ttoc(DateTime, Format="")
# ============================================================
def ttoc(DateTime, Format=""):

    """Initialize Local Variables..."""
    DateTimeString = ""

    """Validate the Parameters..."""
    if isinstance(DateTime, datetime.datetime):

        """Test Date Formatting Options..."""
        if type(Format) == str and Format.upper() == "ISO":

            """ISO SortableDate Format..."""
            DateTimeString = str(DateTime.year) + "-" \
                             + str(DateTime.month) + "-" \
                             + str(DateTime.day) + "T"

        else:

            """Default Date Format is American..."""
            DateTimeString = str(DateTime.month) + "/" \
                             + str(DateTime.day) + "/" \
                             + str(DateTime.year) + " "

        """Append the Time Formatting..."""
        DateTimeString = DateTimeString + \
                         + str(DateTime.hour) + ":" \
                         + str(DateTime.minute) + ":" \
                         + str(DateTime.second)

    return DateTimeString        

# =============================================================
# Autocall the main() function...
# =============================================================

if __name__ == "__main__":
    main()
