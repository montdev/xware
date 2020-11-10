# coding: ascii
# *************************************************************
# xtool.py
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
# elapsed(Start, End=0)
# =============================================================
def elapsed(Start, End=0):
    Success = type(Start) in (int, float) \
              and type(End) in (int, float)

    if Success:
        if End > 0:
            return float(End) - float(Start)
        else:
            return float(time.time()) - float(Start)

    return 0

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
    Success = Success and Hours in range(24)
    Success = Success and Minutes in range(60)
    Success = Success and Seconds in range(60)

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

# ============================================================
# blockCount(Blocks, BlockSize)
# ============================================================
def blockCount(Blocks, BlockSize):
    """Count Blocks in a set..."""
    """Initialize Local Variables..."""
    BlockCount = 0
    """Validate the Parameters..."""
    Success = type(Blocks) == str \
              and type(BlockSize) == int
    if Success:
        BlockCount = len(Blocks) // BlockSize
    return BlockCount

# ============================================================
# blockAdd(Blocks, BlockSize, BlockData)
# ============================================================
def blockAdd(Blocks, BlockSize, BlockData):
    """Add a new Datablock to the set..."""
    """Create part of CRUD..."""

    """Validate the parameters..."""
    Success = type(Blocks) == str and type(BlockSize) == int\
              and type(BlockData) == str

    if Success:
        """Test to see if this is Binary or Text..."""
        Binary = byteSniffTest(byteSniff(BlockData), "BINARY")
        if Binary:
            Padding = chr(0)
        else:
            Padding = " "
        return Blocks + BlockData.ljust(BlockSize, Padding)
    """Default Return"""
    return ""

# ============================================================
# blockGet(Blocks, BlockSize, BlockIndex)
# ============================================================
def blockGet(Blocks, BlockSize, BlockIndex):
    """Block Getter... Read part of CRUD..."""
    """Validate parameters..."""
    Success = type(Blocks) == str and type(BlockSize) == int\
              and type(BlockIndex) == int
    if Success:
        Offset = BlockIndex * BlockSize
        return Blocks[Offset:Offset+BlockSize]
    """Default return"""
    return ""

# ============================================================
# blockPut(Blocks, BlockSize, BlockIndex, BlockData)
# ============================================================
def blockPut(Blocks, BlockSize, BlockIndex, BlockData):
    """Block Put... Update part of CRUD..."""
    """Validate parameters..."""
    Success = type(Blocks) == str \
              and type(BlockSize) == int\
              and type(BlockIndex) == int\
              and type(BlockData) == str
    if Success:
        Binary = byteSniffTest(byteSniff(BlockData), "BINARY")
        if Binary:
            Padding = chr(0)
        else:
            Padding = " "

        BlockStart = BlockIndex * BlockSize
        BlockEnd = BlockStart + BlockSize
        return Blocks[:BlockStart] \
               + BlockData.ljust(BlockSize, Padding) \
               + Blocks[BlockEnd:]
    """Default return"""
    return ""

# ============================================================
# blockDelete(Blocks, BlockSize, BlockIndex)
# ============================================================
def blockDelete(Blocks, BlockSize, BlockIndex):
    """Deletes Blocks...  Delete part of CRUD..."""
    """Validate parameters..."""
    Success = type(Blocks) == str\
              and type(BlockSize) == int\
              and type(BlockIndex) == int
    if Success:
        BlockStart = BlockIndex * BlockSize
        BlockEnd = BlockStart + BlockSize
        return Blocks[:BlockStart] + Blocks[BlockEnd:]
    """Default Return..."""
    return ""

# ============================================================
# blockPad(Blocks, BlockSize, PadChar)
# ============================================================
def blockPad(Blocks, BlockSize, PadChar):
    """Add the right amount of padding for the set..."""
    """Validate parameters..."""
    Success = type(Blocks) == str \
              and type(BlockSize) == int \
              and type(PadChar) == str
    if Success:
        Length = len(Blocks)
        if Length % BlockSize > 0:
            return Blocks + (PadChar * (BlockSize - (Length % BlockSize)))
        return Blocks
    """Default Return..."""
    return ""

# ============================================================
# blockSplit(Blocks, BlockSize, Delimiter)
# ============================================================
def blockSplit(Blocks, BlockSize, Delimiter):
    """Convertes a Block Device to a Delimited Device..."""
    """Validate parameters..."""
    Success = type(Blocks) == str \
              and type(BlockSize) == int \
              and type(Delimiter) == str
    if Success:
        Length = len(Blocks)
        Output = ""
        Count = blockCount(Blocks, BlockSize)

        for Block in range(0, Length, BlockSize):
            Output = tokenAdd(Output, Delimiter, \
                              Blocks[Block:Block+BlockSize])
        return Output
    """Default Return..."""
    return ""

# ============================================================
# tokenCount(Set, Delimiter, Key = "")
# ============================================================
def tokenCount(Set, Delimiter, Key = ""):
    """Count the number of tokens in a TokenSet..."""
    """Initialize Local Variables..."""
    Count = 0
    """Validate parameters..."""
    Success = type(Set) == str and type(Delimiter) == str
    
    if Success:
        if len(Set) > 0:
            if type(Key) == str and len(Key) > 0:
                """This is a Filtered Key Count..."""
                Filter = tokenFilter(Set, Delimiter, Key)
                Count = tokenCount(Filter, Delimiter)
            else:
                """The count is always count + 1..."""
                Count = Set.count(Delimiter) + 1
                
    return Count

# ============================================================
# tokenSize(Set, Delimiter, Size)
# Change the Size of a TokenSet...
# ============================================================
def tokenSize(Set, Delimiter, Size):
    """Change the Size of the TokenSet..."""
    Success = type(Set) == str \
              and type(Delimiter) == str \
              and type(Size) == int

    if Success:
        """Initialize Local Variables..."""
        Count = tokenCount(Set, Delimiter)

        if Count > Size:
            """Reduce the Size..."""
            return Set[:at(Set, Delimiter, Size - 1)]
        elif Count < Size:
            """Increase the Size..."""
            return tokenPut(Set, Delimiter, Size, "")

    return ""

# ============================================================
# tokenChangeDelimiter(Set, OldDelimiter, NewDelimiter)
# ============================================================
def tokenChangeDelimiter(Set, OldDelimiter, NewDelimiter):
    """Change the delimiter..."""

    Success = type(Set) == str \
              and type(OldDelimiter) == str \
              and type(NewDelimiter) == str

    if Success:
        return Set.replace(OldDelimiter, NewDelimiter)

    return ""

# ============================================================
# tokenAdd(Set, Delimiter, Token)
# Create part of CRUD...  Append Token to a TokenSet...
# ============================================================
def tokenAdd(Set, Delimiter, Token, Flags=0):
    """ Append a Token to the End of the Set"""
    """ This is the Create Part of CRUD..."""
    """Validate parameters..."""
    Success = type(Set) == str \
              and type(Delimiter) == str \
              and type(Token) == str \
              and type(Flags) == int
    
    if Success:
        if len(Set) == 0:
            """ This will be the first token in the set... """
            return Token
        else:
            if tokenFlagGet(Flags, "SORTED_ORDER"):
                """ Insert in a Sorted Fashion (index=0)... """
                return tokenInsert(Set, Delimiter, 0, Token, Flags)
            elif tokenFlagGet(Flags, "REVERSE_ORDER"):
                """Add to the beginning of the TokenSet..."""
                return Token + Delimiter + Set
            else:
                """ This will be a normal Append Operation... """
                return Set + Delimiter + Token
            
    """Default Return..."""
    return ""

# ============================================================
# tokenGet(Set, Delimiter, TokenID, Flags)
#
# Extract the desired Token Value...
# This is the READ part of CRUD...
#
# Support has been added for Named or Keyed Set Lookups...
# If Keyed Lookup then the Value will have the Key removed...
# ============================================================
def tokenGet(Set, Delimiter, TokenID, Flags = 0):
    """Extract the indicated Token"""
    """First we need to know how many Tokens there are..."""
    
    """This has also been extended to support Named Sets..."""
    """If Keyed, the Key will be removed fromm the Value..."""

    """Initialize Local Variables"""
    Token = 0
    Key = Value = ""

    """Validate parameters..."""
    Success = type(Set) == str \
              and type(Delimiter) == str \
              and type(TokenID) in (int, str) \
              and type(Flags) == int
    
    if Success:
        """Get the Count..."""
        Count = tokenCount(Set, Delimiter)

        """Check to see if a Keyed Lookup is needed..."""
        if type(TokenID) == str:
            if len(TokenID) > 0:
                """Do a Key to Index lookup..."""
                Key = TokenID
                Token = tokenFind(Set, Delimiter, Key, Flags)
        else:
            """This is a Normal Token Index..."""
            Token = TokenID

        """Extract the Token Value..."""
        if Count == 0 or Token == 0 or Token > Count:
            """Can't retrieve what isn't there..."""
            return ""
        
        elif Token == 1:
            """Extract the First Token..."""
            if Count == 1:
                """This is the Only Token..."""
                Value = Set
            else:
                """Locate the first Delimiter"""
                Length = Set.find(Delimiter)
                Value = Set[:Length]
                
        elif Token == Count:
            """Extract the Lsat Token..."""
            Start = Set.rindex(Delimiter) + 1
            Value = Set[Start:]
        else:
            """This is a Middle Token..."""
            Start = at(Set, Delimiter, Token - 2) + 1
            End = Set.find(Delimiter, Start + 1)
            Value = Set[Start:End]

        """If this was a Keyed Lookup, strip out the Key..."""
        if len(Key) > 0:
            """Return the Value without the Key..."""
            Value = Value[len(Key):]
            
    return Value

# ============================================================
# tokenPut(Set, Delimiter, TokenID, Token)
#
# Update portion of CRUD...
#
# Support has been added for Named or Keyed TokenSets...
# ============================================================
def tokenPut(Set, Delimiter, TokenID, Value, Flags = 0):
    """Update the Indicated Token..."""

    """Validate parameters..."""
    Success = type(Set) == str \
              and type(Delimiter) == str \
              and type(TokenID) in (int, str) \
              and type(Value) == str \
              and type(Flags) == int

    if Success:
        """Initialize Local Variables..."""
        Token = 0
        TokenValue = ""
        Count = tokenCount(Set, Delimiter)

        """Check to see if Key to Index lookup is needed..."""
        if type(TokenID) == str:
            if len(TokenID) > 0:
                
                """Do a Key to Index lookup..."""
                Token = tokenFind(Set, Delimiter, TokenID, Flags)
                TokenValue = TokenID + Value
                
        else:
            """This is a normal Token Index..."""
            Token = TokenID
            TokenValue = Value


        """Check to see if this is a Sorted Set..."""
        """However if the Token is Slotted, Sorted won't count..."""
        if Token == 0 and tokenFlagGet(Flags, "SORTED_ORDER"):
            """This is a Sorted Set with an Unslotted Token"""

            """Do a Sorted Insert..."""
            return tokenInsert(Set, Delimiter, 0, TokenValue, Flags)
            
        """Update the Indicated Token..."""
        if Token > Count:
            """The set will have to be expanded to accomodate..."""
            return Set + (Delimiter * (Token - Count)) + TokenValue
        
        elif Token == 1:
            """Update the first token..."""
            if Count == 1:
                """This is the only token in the set..."""
                return TokenValue
            else:
                Length = Set.find(Delimiter)
                return TokenValue + Set[Length:]
            
        elif Token == Count:
            """Update the last token..."""
            Start = Set.rindex(Delimiter) + 1
            return Set[:Start] + TokenValue
        
        else:
            """Update a middle token..."""
            Start = at(Set, Delimiter, Token - 2) + 1
            End = Set.find(Delimiter, Start + 1)
            return Set[:Start] + TokenValue + Set[End:]
        
    """Default Return..."""
    return ""

# ============================================================
# tokenDelete(Set, Delimiter, TokenID, Flags = 0)
#
# Delete portion of CRUD...
#
# Support has been added for Named or Keyed Sets...
# ============================================================
def tokenDelete(Set, Delimiter, TokenID, Flags = 0):
    """Remove the Indicated Token"""
    """Validate parameters..."""
    
    Success = type(Set) == str \
              and type(Delimiter) == str \
              and type(TokenID) in (int. str) \
              and type(Flags) == int
    
    if Success:
        
        """Initialize Local Variables..."""
        Token = 0
        
        if type(TokenID) == str:
            if  len(TokenID) > 0:
                """Perform a Key to ID Lookup..."""
                Token = tokenFind(Set, Delimiter, TokenID)

                """With a Keyed Delete there may be more than 1..."""
                if Token > 0 and \
                   tokenFlagGet(Flags, "DELETE_ALL_MATCHES"):

                    NewSet = Set
                    
                    while Token > 0:
                        NewSet = tokenDelete(NewSet, Delimiter, Token)
                        Token = tokenFind(NewSet, Delimiter, TokenID)

                    return NewSet
        else:
            Token = TokenID
                
        """Determine the Count..."""
        Count = tokenCount(Set, Delimiter)

        """Delete the indicated Token..."""
        if Count == 0 or Token == 0 or Token > Count:
            """Can't delete what isn't there..."""
            return Set
        
        elif Token == 1:
            """Remove the First Token..."""
            if Count == 1:
                """This is the only token, nothing else remains..."""
                return ""
            else:
                End = Set.find(Delimiter) + 1
                return Set[End:]
            
        elif Token == Count:
            """Removing the Last Token..."""
            Start = Set.rindex(Delimiter)
            return Set[:Start]
        
        else:
            """Removing a Middle Token..."""
            Start = at(Set, Delimiter, Token - 2)
            End = Set.find(Delimiter, Start + 1)
            return Set[:Start] + Set[End:]
        
    """Default Return..."""
    return ""

# ============================================================
# tokenInsert(Set, Delimiter, TokenID, NewValue, Flags)
#
# For Sorted Sets use 0 for the Index Slot...
# Support has been added for Keyed or Named TokenSets...
# ============================================================
def tokenInsert(Set, Delimiter, TokenID, NewValue, Flags = 0):
    """Insert a Token to a given slot...  Also provides a
       simple means to perform a sorted insert..."""
    """ Insert is really nothing more than a Get and a Put..."""
    """Validate parameters..."""
    Success = type(Set) == str \
              and type(Delimiter) == str \
              and type(TokenID) in (int, str) \
              and type(NewValue) == str \
              and type(Flags) == int
    
    if Success:

        """Initialize Local Variables..."""
        Token = 0
        NewToken = ""
        
        if type(TokenID) == str:
            if len(TokenID) > 0:
                """This is a Keyed or Named TokenSet..."""
                Token = tokenFind(Set, Delimiter, TokenID, Flags)
                NewToken = TokenID + NewValue
        else:
            Token = TokenID
            NewToken = NewValue
        
        """ The Zero Index is the SORTED or NULL Index..."""
        if Token == 0 and tokenFlagGet(Flags, "SORTED_ORDER"):
            """ This is a Special Sorted Insert..."""

            Count = tokenCount(Set, Delimiter)
            InsertHere = False
            Descending = tokenFlagGet(Flags,"DESCENDING")

            for Item in range(Count):

                """Get the Token for Testing..."""
                TokenValue = tokenGet(Set, Delimiter, Item + 1)
                
                if Descending:
                    """This is a Descending Sort..."""
                    """Insert After and Put..."""
                    if TokenValue < NewToken:
                        """This is the one we're looking for..."""
                        InsertHere = True
                        break
                else:
                    """This is an Ascending Sort..."""
                    """Insert Before and Put..."""

                    if TokenValue > NewToken:
                        """This is the one we're looking for..."""
                        InsertHere = True
                        break

            if InsertHere:
                """So prepare the Insertion Token and Put it in..."""
                TokenValue = NewToken + Delimiter + TokenValue
                return tokenPut(Set, Delimiter, Item + 1, TokenValue)
                
            else:
                """No Match after a full traversal, just Append..."""
                return tokenAdd(Set, Delimiter, NewToken)
        
        else:
            """ Normal Positional Insert"""
            if Token == 0:
                """This may be due to a Named Token Not Found..."""
                """Clearly the SORTED Flag isn't set..."""
                """The Index 0 rule can be affected by this..."""
                """This is also part of why the Flags are in play..."""
                """Make it so the new token will be Inserted at 1..."""
                Token += 1
                
            TokenValue = tokenGet(Set, Delimiter, Token)
            TokenValue = NewToken + Delimiter + TokenValue
            return tokenPut(Set, Delimiter, Token, TokenValue)
        
    """Default Return..."""
    return ""

# ============================================================
# tokenOrder(Set, Delimiter, Flags = 0)
#
# Sort or reverse the order of a TokenSet...
# ============================================================
def tokenOrder(Set, Delimiter, Flags = 0):
    """Sort the current Set..."""
    """Validate parameters..."""
    Success = type(Set) == str \
              and type(Delimiter) == str \
              and type(Flags) == 0
    
    if Success:
        """Initialize Local Variables..."""
        NewSet = ""
        Count = tokenCount(Set, Delimiter)
        Order = ""

        if tokenFlagGet(Flags, "SORTED_ORDER"):
            Order = "SORTED_ORDER"
        elif tokenFlagGet(Flags, "REVERSE_ORDER"):
            Order = "REVERSE_ORDER"

        for Index in range(Count):
            """Extract the Token..."""
            Token = tokenGet(Set, Delimiter, Index + 1)
            
            if Order == "SORTED_ORDER":
                """ Loop through the Tokens and copy to a SortedSet..."""
                NewSet = tokenInsert(NewSet, Delimiter, 0, Token, Flags)

            elif Order == "REVERSE_ORDER":
                """ Loop through Tokens and copy to Reversed Set..."""
                NewSet = tokenAdd(NewSet, Delimiter, Token, Flags)

        return NewSet
    
    """Default Return..."""
    return ""

# ============================================================
# tokenFind(Set, Delimiter, Key, Flags = 0)
#
# Find the Key at the Beginning of a Token...
#
# First step in inplementing Named Token Sets...
# ============================================================
def tokenFind(Set, Delimiter, Key, Flags = 0):
    """Locate the Token that begins with String..."""
    """Validate parameters..."""
    Success = type(Set) == str \
             and type(Delimiter) == str \
             and type(Key) == str \
             and type(Flags) == int
    
    if Success:
        Count = tokenCount(Set, Delimiter)
        for Index in range(Count):
            """ Check to see if this is the Token..."""
            Token = tokenGet(Set, Delimiter, Index + 1)
            """Compare Key with the Token..."""
            if Key.upper() == Token[:len(Key)].upper():
                return Index + 1

    """Default Return..."""
    return 0

# ============================================================
# tokenFilter(Set, Delimiter, Key, Flags = 0)
# ============================================================
def tokenFilter(Set, Delimiter, Key, Flags = 0):
    """Return a Key Filtered Subset..."""

    Success = type(Set) == str \
              and type(Delimiter) == str \
              and type(Key) == str \
              and type(Flags) == int

    if Success:
        Count = tokenCount(Set, Delimiter)
        Filter = ""

        for Index in range(Count):
            """ Check to see if this is the Token..."""
            Token = tokenGet(Set, Delimiter, Index + 1)
            """Compare Key with the Token..."""
            if Key.upper() == Token[:len(Key)].upper():
                Filter = tokenAdd(Filter, Delimiter, Token, Flags)

        return Filter

# ============================================================
# tokenFlagSet(Flags = 0, Property, Enabled = True)
# ============================================================
def tokenFlagSet(Flags = 0, Property ="", Value = 1):
    """Query the Flags for the Given Property Bit..."""

    """Validate the parameters..."""
    if type(Flags) == int \
       and type(Property) == str \
       and len(Property) > 0 \
       and type(Value) == int:
        
        if Property.upper() == "SORTED_ORDER":
            if Value > 0:
                Flags = (Flags | (2**0))
            elif tokenFlagGet(Flags, "SORTED_ORDER"):
                Flags = (Flags ^ (2**0))
                
        elif Property.upper() == "DESCENDING":
            if Value > 0:
                Flags = (Flags | (2**1))
            elif tokenFlagGet(Flags, "DESCENDING"):
                Flags = (Flags ^ (2**1))
            
        elif Property.upper() == "REVERSE_ORDER":
            if Value > 0:
                Flags = (Flags | (2**2))
            elif tokenFlagGet(Flags, "REVERSE_ORDER"):
                Flags = (Flags ^ (2**2))
           
        elif Property.upper() == "DELETE_ALL_MATCHES":
            if Value > 0:
                Flags = (Flags | (2**3))
            elif tokenFlagGet(Flags, "DELETE_ALL_MATCHES"):
                Flags = (Flags ^ (2**3))

    return Flags

# ============================================================
# tokenFlagGet(Flags, Property)
# ============================================================
def tokenFlagGet(Flags, Property, ReturnType = "bool"):
    """Query the Flags for the Given Property Bit..."""

    Value = 0

    """Validate the parameters..."""
    if type(Flags) == int \
       and type(Property) == str \
       and len(Property) > 0:
        
        if Property.upper() == "SORTED_ORDER":
            Value = (Flags & (2**0))
            
        elif Property.upper() == "DESCENDING":
            Value = (Flags & (2**1))

        elif Property.upper() == "REVERSE_ORDER":
            Value = (Flags & (2**2))

        elif Property.upper() == "DELETE_ALL_MATCHES":
            Value = (Flags & (2**3))
           
        """Determine the desired return type..."""
        """If the Return Type is overridden the default is int..."""
        if ReturnType.lower() == "bool":
            """This is the default..."""
            Value = (Value > 0)

    return Value

# =============================================================
# base32Encode(String)
# =============================================================
def base32Encode(String):
    """Encode ASCII Data to base32..."""
    """Validate parameter..."""
    Success = type(String) == str
    if Success:
        """Initialize Local Variables..."""
        Alphabet = baseScheme(32)
        Length = len(String)
        WordSize = 5

        Word = Output = ""
        WordStart = WordLength = Byte = Bits = 0
        Part1 = Part2 = Part3 = Part4 = Part5 \
                = Part6 = Part7 = Part8 = 0

        """Loop through the data and processing"""
        """groups of 5 bytes at a time..."""
        
        for WordStart in range(0, Length, WordSize):
            Word = String[WordStart:WordStart + WordSize]
            WordLength = len(Word)

            """Reset the Part Variables for each iteration..."""
            Part1 = Part2 = Part3 = Part4 = Part5 \
                    = Part6 = Part7 = Part8 = 0

            """ Iterate through the bytes and map the bits..."""
            for Byte in range(WordLength):
                """ Get the bits for this byte..."""
                Bits = ord(Word[Byte])

                """Translate from 5 8-bit words to 8 5-bit words..."""
                if Byte == 0:
                    """11111000 >> 3 = 11111"""
                    Part1 = Bits >> 3
                    """00000111 & 2**3-1 << 2 = 11100"""
                    Part2 = (Bits & (2**3-1)) << 2
                elif Byte == 1:
                    """11000000 >> 6 = 00011"""
                    Part2 = Part2 + (Bits >> 6)
                    """00111110 >> 1 & 2**5-1 = 11111"""
                    Part3 = (Bits >> 1) & (2**5-1)
                    """00000001 & 2**1-1 << 4 = 10000"""
                    Part4 = (Bits & 2**1-1) << 4
                elif Byte == 2:
                    """11110000 >> 4 = 01111"""
                    Part4 = Part4 + (Bits >> 4)
                    """00001111 & 2**4-1 << 1 = 11110"""
                    Part5 = (Bits & (2**4-1)) << 1
                elif Byte == 3:
                    """10000000 >> 7 = 00001"""
                    Part5 = Part5 + (Bits >> 7)
                    """01111100 >> 2 & 2**5-1 = 11111"""
                    Part6 = (Bits >> 2) & (2**5-1)
                    """00000011 & 2**2-1 << 3 = 11000"""
                    Part7 = (Bits & (2**2-1)) << 3
                elif Byte == 4:
                    """11100000 >> 5 = 00111"""
                    Part7 = Part7 + (Bits >> 5)
                    """00011111 & 2**5-1 = 11111"""
                    Part8 = Bits & (2**5-1)

            """Add this group to the output..."""
            Output = Output \
                       + Alphabet[Part1] \
                       + Alphabet[Part2] \
                       + Alphabet[Part3] \
                       + Alphabet[Part4] \
                       + Alphabet[Part5] \
                       + Alphabet[Part6] \
                       + Alphabet[Part7] \
                       + Alphabet[Part8]

        """Trim any Zero's off the end..."""
        return Output.rstrip("0")
    """Default Return..."""
    return ""

# =============================================================
# base32Decode(String)
# =============================================================
def base32Decode(String):
    """Decode Base32 back into ASCII..."""
    """Here we go from 8 5-bit bytes to 5 8-bit bytes..."""
    """Initialize Local Varioables..."""
    Output = ""
    """Validate the parameter..."""
    Success = type(String) == str
    if Success:
        """Initialize Local Variables..."""
        Alphabet = baseScheme(32)
        WordSize = 8 # 8 5-bit words...
        Length = len(String)

        Word = ""
        WordStart = WordLength = Nibble = Bits = 0
        Byte1 = Byte2 = Byte3 = Byte4 = Byte5 = 0

        for WordStart in range(0, Length, WordSize):

            Word = String[WordStart:WordStart + WordSize]
            WordLength = len(Word)
            Byte1 = Byte2 = Byte3 = Byte4 = Byte5 = 0

            for Nibble in range(WordLength):
                Bits = Alphabet.find(Word[Nibble])
                if Nibble == 0:
                    """11111 << 3 = 11111000"""
                    Byte1 = Bits << 3
                elif Nibble == 1:
                    """11100 >> 2 = 00000111"""
                    Byte1 = Byte1 + (Bits >> 2)
                    Output = Output + chr(Byte1)
                    """00011 & 2**2-1 << 6 = 11000000"""
                    Byte2 = (Bits & (2**2-1)) << 6
                elif Nibble == 2:
                    """11111 << 1 = 00111110"""
                    Byte2 = Byte2 + (Bits << 1)
                elif Nibble == 3:
                    """10000 >> 4 = 00000001"""
                    Byte2 = Byte2 + (Bits >> 4)
                    Output = Output + chr(Byte2)
                    """01111 & 2**4-1 << 4 = 11110000"""
                    Byte3 = (Bits & (2**4-1)) << 4
                elif Nibble == 4:
                    """11110 >> 1 = 00001111"""
                    Byte3 = Byte3 + (Bits >> 1)
                    Output = Output + chr(Byte3)
                    """00001 & 2**1-1 << 7 = 10000000"""
                    Byte4 = (Bits & (2**1-1)) << 7
                elif Nibble == 5:
                    """11111 << 2 = 01111100"""
                    Byte4 = Byte4 + (Bits << 2)
                elif Nibble == 6:
                    """11000 >> 3 = 00000011"""
                    Byte4 = Byte4 + (Bits >> 3)
                    Output = Output + chr(Byte4)
                    """00111 & 2**3-1 << 5 = 11100000"""
                    Byte5 = (Bits & (2**3-1)) << 5
                elif Nibble == 7:
                    """11111 = 00011111"""
                    Byte5 = Byte5 + Bits
                    Output = Output + chr(Byte5)
    return Output

# =============================================================
# base64Encode(String)
# =============================================================
def base64Encode(String):
    """Encode string to Base64..."""
    """Validate the parameter..."""
    Success = type(String) == str
    if Success:
        """Initialize Local Variables..."""
        Alphabet = baseScheme(64)
        WordSize = 3
        Length = len(String)

        Word = Output = ""
        WordStart = Byte = Bits = 0
        Nibble1 = Nibble2 = Nibble3 = Nibble4 = 0

        for WordStart in range(0, Length, WordSize):
            Nibble1 = Nibble2 = Nibble3 = Nibble4 = 0

            Word = String[WordStart:WordStart + WordSize]
            WordLength = len(Word)

            for Byte in range(WordLength):
                Bits = ord(Word[Byte])
                if Byte == 0:
                    """11111100 >> 2 = 111111"""
                    Nibble1 = Bits >> 2
                    """00000011 & 2**2-1 << 4 = 110000"""
                    Nibble2 = (Bits & (2**2-1)) << 4
                elif Byte == 1:
                    """11110000 >> 4 = 001111"""
                    Nibble2 = Nibble2 + (Bits >> 4)
                    """00001111 & 2**4-1 << 2 = 111100"""
                    Nibble3 = (Bits & (2**4-1)) << 2
                elif Byte == 2:
                    """11000000 >> 6 = 000011"""
                    Nibble3 = Nibble3 + (Bits >> 6)
                    """00111111 & 2**6-1 = 111111"""
                    Nibble4 = Bits & (2**6-1)

            Output = Output \
                     + Alphabet[Nibble1] \
                     + Alphabet[Nibble2] \
                     + Alphabet[Nibble3] \
                     + Alphabet[Nibble4]

        """Any A's at the end tend to be due to Zeros inherited..."""
        """Also insure that it has the propper padding at the end..."""
        Output = blockPad(Output.rstrip("A"), 4, "=")
        """This is the real output return..."""
        return Output
    """Default Return..."""
    return ""

# =============================================================
# base64Decode(String)
# =============================================================
def base64Decode(String):
    """Decode Base64 back to ASCII..."""
    """Validate the parameter..."""
    Success = type(String) == str
    if Success:
        """Initialize Local Variables..."""
        Word = Output = ""
        WordStart = WordLength = Nibble = Bits = 0
        Byte1 = Byte2 = Byte3 = 0

        Alphabet = baseScheme(64)
        WordSize = 4
        Length = len(String)

        for WordStart in range(0, Length, WordSize):

            """Clear these bytes on each iteration..."""
            Byte1 = Byte2 = Byte3 = 0

            Word = String[WordStart:WordStart + WordSize]
            WordLength = len(Word)

            for Nibble in range(WordLength):

                """If you hit an = then you're at the end..."""
                if Word[Nibble] == "=":
                    break
                
                Bits = Alphabet.find(Word[Nibble])
                if Nibble == 0:
                    """111111 << 2 = 11111100"""
                    Byte1 = Bits << 2
                elif Nibble == 1:
                    """110000 >> 4 = 00000011"""
                    Byte1 = Byte1 + (Bits >> 4)
                    Output = Output + chr(Byte1)
                    """001111 & 2**4-1 << 4 = 11110000"""
                    Byte2 = (Bits & (2**4-1)) << 4
                elif Nibble == 2:
                    """111100 >> 2 = 00001111"""
                    Byte2 = Byte2 + (Bits >> 2)
                    Output = Output + chr(Byte2)
                    """000011 & 2**2-1 << 6 = 11000000"""
                    Byte3 = (Bits & (2**2-1)) << 6
                elif Nibble == 3:
                    """111111 = 00111111"""
                    Byte3 = Byte3 + Bits
                    Output = Output + chr(Byte3)

        """This is the real output..."""
        return Output
    """Default Return..."""
    return ""
# =============================================================
# byteSniff(Data)
# =============================================================
def byteSniff(Data):
    """Byte Sniffer..."""
    """Initialize Local Variables..."""
    Flags = 0
    """Validate the parameter..."""
    Success = type(Data) == str
    if Success:

        Length = len(Data)

        BINARY     = 2**0
        TEXT       = 2**1
        ALPHA      = 2**2
        NUMERIC    = 2**3
        UPPER      = 2**4
        LOWER      = 2**5
        DELIMITED  = 2**6
        NESTED     = 2**7
        WHITESPACE = 2**8
        ROWBASED   = 2**9
        QUOTED     = 2**10

        for Byte in range(Length):

            Bits = ord(Data[Byte])

            if Bits in range(0, 32):
                """Control Codes..."""
                if Bits in range(9, 13 + 1):
                    """White Space - Tabs, CR, LF, FF..."""
                    Flags = Flags | (TEXT + WHITESPACE + DELIMITED)
                    if Bits in (10, 13):
                        Flags = Flags | ROWBASED
                else:
                    """Binary Data..."""
                    Flags = Flags | BINARY
                    if Bits == 0:
                        Flags = Flags | DELIMITED
            elif Bits in range(32, 126 + 1):
                """Printable Characters..."""
                Flags = Flags | TEXT
                if Bits == 32:
                    """Space..."""
                    Flags = Flags | (WHITESPACE | DELIMITED)
                elif Bits in range(48, 57 + 1):
                    """Numeric..."""
                    Flags = Flags | NUMERIC
                elif Bits in range(65, 90 + 1):
                    """Upper Case Letters..."""
                    Flags = Flags | (ALPHA | UPPER)
                elif Bits in range(97, 122 + 1):
                    """Lower Case Letters..."""
                    Flags = Flags | (ALPHA | LOWER)
                elif Bits in ("(", ")", "[", "]", "{", "}", "<", ">"):
                    """Nested Balance Brackets..."""
                    Flags = Flags | NESTED
                elif Bits in ("'", '"'):
                    """Quoted..."""
                    Flags = Flags | QUOTED
                else:
                    """Anything else is punctuation can be delimiters..."""
                    Flags = Flags | DELIMITED
            else:
                """Extended ASCII means Binary Data..."""
                Flags = Flags | BINARY

    return Flags

# =============================================================
# byteSniffTest(Flags, Property)
# =============================================================
def byteSniffTest(Flags, Property):
    """Test the Property Flag..."""

    Success = type(Flags) == int \
              and type(Property) == str \
              and len(Property) > 0

    if Success:

        Value = 0

        if Property.upper() == "BINARY":
            Value = Flags & 2**0
        elif Property.upper() == "TEXT":
            Value = Flags & 2**1
        elif Property.upper() == "ALPHA":
            Value = Flags & 2**2
        elif Property.upper() == "NUMERIC":
            Value = Flags & 2**3
        elif Property.upper() == "UPPER":
            Value = Flags & 2**4
        elif Property.upper() == "LOWER":
            Value = Flags & 2**5
        elif Property.upper() == "DELIMITED":
            Value = Flags & 2**6
        elif Property.upper() == "NESTED":
            Value = Flags & 2**7
        elif Property.upper() == "WHITESPACE":
            Value = Flags & 2**8
        elif Property.upper() == "ROWBASED":
            Value = Flags & 2**9
        elif Property.upper() == "QUOTED":
            Value = Flags & 2**10

    return Value > 0


# =============================================================
# byteSniffMsg(Flags = 0)
# =============================================================
def byteSniffMsg(Flags = 0):
    """Provide a Text Version of the ByteSniff Flags..."""
    
    ShowAll = type(Flags) != int or Flags == 0
    FlagSet = ""
    CRLF = chr(13)+chr(10)

    if ShowAll or Flags & 2**0:
        """Binary..."""
        FlagSet = tokenAdd(FlagSet, CRLF, "Binary")
    if ShowAll or Flags & 2**1:
        """Text..."""
        FlagSet = tokenAdd(FlagSet, CRLF, "Text")
    if ShowAll or Flags & 2**2:
        """Alpha Text..."""
        FlagSet = tokenAdd(FlagSet, CRLF, "Alpha")
    if ShowAll or Flags & 2**3:
        """Numeric..."""
        FlagSet = tokenAdd(FlagSet, CRLF, "Numeric")
    if ShowAll or Flags & 2**4:
        """Upper Case..."""
        FlagSet = tokenAdd(FlagSet, CRLF, "Upper Case")
    if ShowAll or Flags & 2**5:
        """Lower Case..."""
        FlagSet = tokenAdd(FlagSet, CRLF, "Lower Case")
    if ShowAll or Flags & 2**6:
        """Delimited..."""
        FlagSet = tokenAdd(FlagSet, CRLF, "Delimited")
    if ShowAll or Flags & 2**7:
        """Nested..."""
        FlagSet = tokenAdd(FlagSet, CRLF, "Nested")
    if ShowAll or Flags & 2**8:
        """WhiteSpace..."""
        FlagSet = tokenAdd(FlagSet, CRLF, "Whitespace")
    if ShowAll or Flags & 2**9:
        """RowBased..."""
        FlagSet = tokenAdd(FlagSet, CRLF, "RowBased")
    if ShowAll or Flags & 2**10:
        """Quoted"""
        FlagSet = tokenAdd(FlagSet, CRLF, "Quoted")

    return FlagSet

# =============================================================
# xbitCount(Bits)
# =============================================================
def xbitCount(Bits):
    """Count the number of bits..."""
    BitCount = 0
    """Validate the parameter..."""
    Success = type(Bits) in (str, int)
    if Success:
        """Make sure we're working with a Bit String..."""
        if type(Bits) == str:
            if len(Bits) > 0 and len(Bits.strip("01")) == 0:
                BitCount = len(Bits)
        elif type(Bits) == int:
            BitCount = len(dec2Base(Bits, 2))

    return BitCount

# =============================================================
# xbitTest(Bits, Bit)
# =============================================================
def xbitTest(Bits, Bit):
    """Test a given bit in a bitstring..."""
    """Validate the parameters..."""
    Success = type(Bits) in (str, int) and type(Bit) == int
    if Success:
        """Make sure we're working with a Bit String..."""
        BitString = ""
        if type(Bits) == str and len(Bits.strip("01")) == 0:
            BitString = Bits
        elif type(Bits) == int:
            BitString = dec2Base(Bits,2)

        """How many bits are we working with?"""
        BitCount = len(BitString)
        """Test the Bit..."""
        if BitCount > 0:
            return BitString[BitCount - Bit] == "1"

    """Default Return..."""
    return False

# =============================================================
# xbitSet(Bits, Bit)
# =============================================================
def xbitSet(Bits, Bit):
    """Set a Given Bit in the BitString..."""
    """Validate the parameters..."""
    Success = type(Bits) in (str, int) and type(Bit) == int
    if Success:
        """Make sure we're working with a Bit String..."""
        BitString = ""
        if type(Bits) == str and len(Bits.strip("01")) == 0:
            BitString = Bits
        elif type(Bits) == int:
            BitString = dec2Base(Bits,2)
        
        """Execute the Operation..."""
        return xbitOr(BitString, xbitLShift("1", Bit))
    """Default Return..."""
    return ""

# =============================================================
# xbitClear(Bits, Bit)
# =============================================================
def xbitClear(Bits, Bit):
    """Clear a Given Bit in a BitString..."""
    """Validate the parameters..."""
    Success = type(Bits) in (str, int) and type(Bit) == int
    if Success:
        """Initialize Local Variables..."""
        BitString = ""
        """Make sure we're working with a BitString..."""
        if type(Bits) == str and len(Bits.strip("01")) == 0:
            BitString = Bits
        elif type(Bits) == int:
            BitString = dec2Base(Bits,2)

        """This is a BitClear operation not a Bit Toggle..."""
        if xbitTest(Bits, Bit):
            """If it's not set there's nothing to do..."""
            """If not set it will toggle to set..."""
            BitString = xbitXor(BitString, xbitLShift("1", Bit))

        return BitString
    """Default Return..."""
    return ""

# =============================================================
# xbitFlip(Bits, Bit)
# =============================================================
def xbitFlip(Bits, Bit):
    """Clear a Given Bit in a BitString..."""
    """Validate the parameters..."""
    Success = type(Bits) in (str, int) and type(Bit) == int
    if Success:
        """Initialize Local Variables..."""
        BitString = ""
        """Make sure we're working with a BitString..."""
        if type(Bits) == str and len(Bits.strip("01")) == 0:
            BitString = Bits
        elif type(Bits) == int:
            BitString = dec2Base(Bits,2)

        """This is a Bit Flip or Bit Toggle operation..."""
        """If it's set it will be cleared..."""
        """If it's not set it will be..."""
        BitString = xbitXor(BitString, xbitLShift("1", Bit))

        return BitString
    """Default Return..."""
    return ""

# =============================================================
# xbitNot(Bits)
# =============================================================
def xbitNot(Bits):
    """Returns the Bitwise Compliment of the Bits..."""
    """Validate the parameter..."""
    Success = type(Bits) in (str, int)
    if Success:
        """Initialize Local Variables..."""
        BitString = OutBits = ""
        """Make sure we're working with a BitString..."""
        if type(Bits) == str and len(Bits.strip("01")) == 0:
            BitString = Bits
        elif type(Bits) == int:
            BitString = dec2Base(Bits,2)
            
        """How many bits are we working with?"""
        BitCount = len(BitString)
        for Bit in range(BitCount):
            """Flip the state of each bit..."""
            State = BitString[Bit]
            if State == "1":
                OutBits = OutBits + "0"
            else:
                OutBits = OutBits + "1"
            
        return OutBits
    """Default Return..."""
    return ""

# =============================================================
# xbitAnd(BitSet1, BitSet2)
# =============================================================
def xbitAnd(BitSet1, BitSet2):
    """Perform a BitWise AND Operation..."""
    """Validate the parameters..."""
    Success = type(BitSet1) in (str, int) \
              and type(BitSet2) in (str, int)
    if Success:
        """Initialize Local Variables..."""
        Bits1 = Bits2 = OutBits = ""
        """Make sure we're working with two Bit Strings..."""
        if type(BitSet1) == str and len(BitSet1.strip("01")) == 0:
            Bits1 = BitSet1
        elif type(BitSet1) == int:
            Bits1 = dec2Base(BitSet1, 2)
        if type(BitSet2) == str and len(BitSet2.strip("01")) == 0:
            Bits2 = BitSet2
        elif type(Bits2) == int:
            Bits2 = dec2Base(BitSet2, 2)

        """How many bits are we working with?"""
        Count = max(len(Bits1), len(Bits2))
        Bits1 = Bits1.zfill(Count)
        Bits2 = Bits2.zfill(Count)

        """Execute the operation..."""
        for Bit in range(Count):
            Bit1 = Bits1[Bit]
            Bit2 = Bits2[Bit]
            if Bit1 + Bit2 == "11":
                OutBits = OutBits + "1"
            else:
                OutBits = OutBits + "0"
        
        return OutBits
    """Default Return..."""
    return ""

# =============================================================
# xbitOr(BitSet1, BitSet2)
# =============================================================
def xbitOr(BitSet1, BitSet2):
    """Perform a BitWise OR Operation..."""
    """Validate the parameters..."""
    Success = type(BitSet1) in (str, int) \
              and type(BitSet2) in (str, int)
    if Success:
        """Initialize Local Variables..."""
        Bits1 = Bits2 = OutBits = ""

        """Make sure that both Sets are Bit Strings..."""
        if type(BitSet1) == str and len(BitSet1.strip("01")) == 0:
            Bits1 = BitSet1
        elif type(BitSet1) == int:
            Bits1 = dec2Base(BitSet1, 2)
        if type(BitSet2) == str and len(BitSet2.strip("01")) == 0:
            Bits2 = BitSet2
        elif type(BitSet2) == int:
            Bits2 = dec2Base(BitSet2, 2)
            
        """How many bits are we working with?"""
        Count = max(len(Bits1), len(Bits2))
        Bits1 = Bits1.zfill(Count)
        Bits2 = Bits2.zfill(Count)

        """Execute the operation..."""
        for Bit in range(Count):
            Bit1 = Bits1[Bit]
            Bit2 = Bits2[Bit]
            if "1" in (Bit1, Bit2):
                OutBits = OutBits + "1"
            else:
                OutBits = OutBits + "0"
        
        return OutBits
    """Default Return..."""
    return ""

# =============================================================
# xbitXor(BitSet1, BitSet2)
# =============================================================
def xbitXor(BitSet1, BitSet2):
    """Perform a BitWise XOR Operation..."""
    """Validate the parameters..."""
    Success = type(BitSet1) in (str, int) \
              and type(BitSet2) in (str, int)
    if Success:
        """Initialize Local Variables..."""
        Bits1 = Bits2 = OutBits = ""

        """Make sure that both sets are Bit Strings..."""
        if type(BitSet1) == str and len(BitSet1.strip("01")) == 0:
            Bits1 = BitSet1
        elif type(BitSet1) == int:
            Bits1 = dec2Base(BitSet1, 2)

        if type(BitSet2) == str and len(BitSet2.strip("01")) == 0:
            Bits2 = BitSet2
        elif type(BitSet2) == int:
            Bits2 = dec2Base(BitSet2, 2)

        """How many bits are we working with?"""
        Count = max(len(Bits1), len(Bits2))
        Bits1 = Bits1.zfill(Count)
        Bits2 = Bits2.zfill(Count)

        """Execute the Operation..."""
        for Bit in range(Count):
            Bit1 = Bits1[Bit]
            Bit2 = Bits2[Bit]
            if Bit1 + Bit2 in ("01", "10"):
                OutBits = OutBits + "1"
            else:
                OutBits = OutBits + "0"
        return OutBits
    """Default Return..."""
    return ""

# =============================================================
# xbitLShift(BitSet, Places)
# =============================================================
def xbitLShift(BitSet, Places):
    """Perform a BitWise Left Shift Operation..."""
    """Validate the parameters..."""
    Success = type(BitSet) in (str, int) \
              and type(Places) == int
    if Success:
        """Initialize Local Variables..."""
        Bits = ""
        
        """Make sure we're  working with a Bit String..."""
        if type(BitSet) == str and len(BitSet.strip("01")) == 0:
            Bits = BitSet
        elif type(BitSet) == int:
            Bits = dec2Base(BitSet, 2)
            
        """Execute the Shifting Operation..."""
        Bits = Bits + "".zfill(Places)
        return Bits
    """Default Return..."""
    return ""

# =============================================================
# xbitRShift(BitSet, Places)
# =============================================================
def xbitRShift(BitSet, Places):
    """Perform a BitWise RightShift Operation..."""
    """Validate the parameters..."""
    Success = type(BitSet) in (str, int) \
              and type(Places) == int
    if Success:
        """Initialize Local Variables..."""
        Bits = ""
        
        """Make sure we're working with a Bit String..."""
        if type(BitSet) == str and len(BitSet.strip("01")) == 0:
            Bits = BitSet
        elif type(BitSet) == int:
            Bits = dec2Base(BitSet, 2)
            
        """How many bits are we working with?"""
        BitCount = len(Bits)
        """Execute the Shifting Operation..."""
        Bits = "".zfill(Places) + Bits[:BitCount - Places]
        return Bits

    """Default Return..."""
    return ""

# =============================================================
# genSerialNumber(Net, Node, Stamp)
# =============================================================
def genSerialNumber(Net, Node, Stamp, Class = "x-ware"):
    """Generate a Serial Number..."""
    """This is a 64 bit value based on 4 - 16 bit Fields..."""
    Success = type(Net) == str \
              and type(Node) == str \
              and type(Stamp) == str \
              and type(Class) in (str, int)
    if Success:
        """Generate Salt based on SerialNumber class..."""
        if type(Class) == str:
            Salt = checkSum(Class, 10, 16)
        else:
            Salt = Class

        """Encode the various fields..."""
        """Add each field checkSum to the Salt"""
        """and keep them all in a 16 bit range..."""
        NetSum = (checkSum(Net, 10, 16) + Salt) % (2**16-1)
        NodeSum = (checkSum(Node, 10, 16) + Salt) % (2**16-1)
        StampSum = (checkSum(Stamp, 10, 16) + Salt) % (2**16-1)

        """Encode the Serial Number Base into Base16..."""        
        SerialNumber = dec2Base(NetSum, 16) \
                       + dec2Base(NodeSum, 16) \
                       + dec2Base(StampSum, 16)

        """Encode the CheckSum into Base16..."""
        CheckSum = checkSum(SerialNumber, 10, 16) + Salt
        CheckSum = CheckSum % (2**16-1)
        CheckSum = dec2Base(CheckSum, 16)

        """Finalize the SerialNumber..."""
        SerialNumber = blockSplit(SerialNumber + CheckSum, 4, "-")

        return SerialNumber
    """Return the Null Version..."""
    return "0000-0000-0000-0000"

# =============================================================
# isSerialNumber(SerialNumber)
# =============================================================
def isSerialNumber(SerialNumber, Class = "x-ware"):
    """Test validity of a Serial Number"""
    """64 bit value based on 4 - 16 bit Subfields..."""
    Success = type(SerialNumber) == str \
              and type(Class) in (str, int)
    if Success:
        """Strip out the dashes..."""
        Test = SerialNumber.replace("-", "")
        """Should only be Hex Digits..."""
        Success = len(Test.strip(baseScheme(16))) == 0
        """Should be 16 Hex Digits..."""
        Success = Success and len(Test) == 16
        
        """Calculate the Salt Value..."""
        if type(Class) == str:
            Salt = checkSum(Class, 10, 16)
        else:
            Salt = Class
    
        if Success:
            """Recalculate CheckSum with Salt..."""
            CheckSum = checkSum(Test[:12], 10, 16) + Salt
            """Maintain a range of 16 bits..."""
            CheckSum = CheckSum % (2**16-1)
            """Convert to Base16..."""
            CheckSum = dec2Base(CheckSum % (2**16-1), 16)
            """Resolve the Test..."""
            Success = (CheckSum == Test[12:])

    """Default Return..."""
    return Success

# =============================================================
# checkSerialNumber(SerialNumber, Field, Value, Class)
# =============================================================
def checkSerialNumber(SerialNumber, Field, Value, Class = 0):
    """Useful to verify the value of a given field..."""
    Success = type(SerialNumber) == str \
              and type(Field) == int \
              and type(Value) == str \
              and type(Class) in (str, int)
    Success = Success and isSerialNumber(SerialNumber, Class)
    if Success:
        """Generate a Salt based on the Class..."""
        if type(Class) == str:
            Salt = checkSum(Class, 10, 16)
        else:
            Salt = Class

        """Calculate the indicated value..."""
        Test = (checkSum(Value, 10, 16) + Salt) % (2**16-1)
        """Convert to Hex..."""
        Test = dec2Base(Test, 16)

        Success = Test == tokenGet(SerialNumber, "-", Field)

    return Success    

# =============================================================
# checkSum(String, Base = 10, Bits = 16)
# =============================================================
def checkSum(String, Base = 10, Bits = 16):
    """Fletcher 16/32 bit Checksum..."""
    """Legal Base = (10,16)... Legal Bits = (16,32)"""
    Success = type(String) == str \
              and type(Base) == int \
              and type(Bits) == int
    if Success:
        """Initialize Local Variables..."""
        Sum0 = Sum1 = 0
        Length = len(String)
        Mod = 2**(Bits//2)-1
        Shift = Bits//2
        Fill = Bits//4
        """Test the Data and Generate the CheckSum..."""
        for char in range(Length):
            Sum0 = (Sum0 + ord(String[char])) % Mod
            Sum1 = (Sum1 + Sum0) % Mod

        Sum = Sum1 << Shift | Sum0
            
        if Base == 16:
            """Convert to Hex String..."""
            Sum = dec2Base(Sum, 16).zfill(Fill)
        return Sum
    """Default Return..."""
    return -1

"""
Generating Check Bytes...
uint16_t csum;
uint8_t c0,c1,f0,f1;

csum = Fletcher16(data, length);
f0 = csum & 0xff;
f1 = (csum >> 8) & 0xff;
c0 = 0xff - ((f0 + f1) % 0xff);
c1 = 0xff - ((f0 + c0) % 0xff);
"""

# =============================================================
# relicEncode(Message, Key = 0, Flags = 0, CipherSize = 36)
# =============================================================
def relicEncode(Data, Key = 0, Flags = 0, CipherSize = 36):
    """ReLiC Encoder..."""
    """
    There are currently 3 Levels of Encoding...
    Level 0 - Headerless with Base Cipher Mutation...
    Level 1 - Cipher Permution Mode...
    Level 2 - Time Based Cipher Mutation Mode...
    """

    """Validate the Parameters..."""
    Success = type(Data) == str and len(Data) > 0 \
              and type(Key) in (str, int) \
              and type(Flags) == int \
              and type(CipherSize) == int \
              and CipherSize in (36, 64, 256)

    if Success:
        """Initialize Local Variables..."""
        Level = Length = Seed = Index = Byte = CipherBase = 0
        Level2 = TimeShift = 0
        Message = Header = Output = Char = Level2 = ""
        
        """Handle Key to Seed Generation..."""
        if type(Key) == str and isSerialNumber(Key):
            """It's a , convert to a seed..."""
            """Strip out the Dashes..."""
            SerialNumber = Key.replace("-","")

            """Fold the Key onto itself with XOR for the Seed..."""
            Seed = base2Dec(SerialNumber[:8], 16)
            Seed = Seed ^ base2Dec(SerialNumber[8:], 16)
            
        elif type(Key) == str:
            """Just convert the string to a 32 bit value..."""
            Seed = checkSum(Key, 10, 32)

        else:
            """So the Key must be an Integer just use that..."""
            Seed = Key

        """Generate the Alphabet and the Base Cipher..."""
        Alphabet = baseScheme(CipherSize)
        Cipher = scramble(Alphabet, Seed)
        
        if Flags > 0:
            """Initialize the ReLiC Header..."""
            """Seed the Engine with a Purely Random Symbol..."""
            """Use the 5 least significant bits from Flags..."""
            Index = Flags & (2**5-1)
            Header = scramble(Alphabet, Seed * -1)[Index]
            Header += Alphabet[Index]

            """bits 0 and 1 represent the Level..."""
            Level = (Index & (2**2-1))

            """Bits 2-4 provide the CipherBase for Spinup..."""
            CipherBase = (Index >> 2) & (2**3-1)
            
            if CipherBase > 0:
                for Index in range(CipherBase):
                    """Randomly select up to 7 chars..."""
                    Cipher = scramble(Cipher, (Seed + Index + 1) * -1)
                    Header += Cipher[Index]

            if Level > 1:

                """Check Level2 Settings..."""
                Level2 = (Flags >> 5) & (2**5-1)

                """Add the Level2 Settings to the Header..."""
                Header += Alphabet[Level2]
                       
        """Reset the base cipher..."""
        Cipher = scramble(Alphabet, Seed)

        """Encode the message..."""
        Message += Data
        Length = len(Message)

        for Byte in range(Length):

            """Retrieve a Character for Encoding..."""
            Char = Message[Byte]
            Index = Alphabet.find(Char)

            """Test for TimeShift..."""
            if Level > 1 and Byte == (CipherBase + 3):

                """The whole point is to Shift the Cipher Seed..."""
                """Note that this Char is based on base Alphabet..."""
                Level2 = baseScheme(CipherSize).find(Char)

                """Extract the TimeShift Factor..."""
                TimeShift = Level2 & (2**3-1)

                """Apply the TimeShift..."""
                Seed += relicTimeWarp(TimeShift)
            
            """Get the next encoded character..."""
            Output += Cipher[Index]
            
            """Update the Environment for the next Byte..."""
            """Index needs to be 1 based as it applies to Seed..."""
            Seed += (Index + 1)
            Alphabet = Cipher
            Cipher = scramble(Cipher, Seed)
        
        return Output

    return ""

# =============================================================
# relicDecode(Message, Key = 0, Flags = 0, CipherSize = 36)
# =============================================================
def relicDecode(Data, Key=0, Flags=0, CipherSize=36):
    """Decode a ReLiC Message..."""
    """Validate the Parameters..."""
    Success = type(Data) == str and len(Data) > 0 \
              and type(Key) in (str, int) \
              and type(Flags) == int \
              and type(CipherSize) == int \
              and CipherSize in (36, 64, 256)
    
    if Success:
        """Initialize Local Variables..."""
        Level = Index = Byte = CipherBase = Start = 0
        Header = Output = Char = Level1 = Level2 = ""
        EndOfHeader = False

        Message = Data
        Length = len(Message)

        """Convert Key to Initial Seed..."""
        if type(Key) == str and isSerialNumber(Key):
            """It's a SerialNumber, convert to a seed..."""
            """Strip out the Dashes..."""
            SerialNumber = Key.replace("-","")

            """Fold the Key onto itself with XOR for the Seed..."""
            Seed = base2Dec(SerialNumber[:8], 16)
            Seed = Seed ^ base2Dec(SerialNumber[8:], 16)
            
        elif type(Key) == str:
            """Just convert the string to a 32 bit value..."""
            Seed = checkSum(Key, 10, 32)

        else:
            """So the Key must be an Integer just use that..."""
            Seed = Key

        """Generate the Alphabet and the Base Cipher..."""
        Alphabet = baseScheme(CipherSize)
        Cipher = scramble(Alphabet, Seed)

        if Flags > 0:
            """Header Loop..."""
            """Decode and Process the Header Bytes..."""
            for Byte in range(Length):

                """Decode the Header Bytes..."""
                Char = Message[Byte]
                Index = Cipher.find(Char)
                Char = Alphabet[Index]

                if Byte == 1:
                    """This is the Level 1 Header Byte..."""
                    Level_1 = baseScheme(CipherSize).find(Char)

                    """Determine the Coding Level..."""
                    Level = Level_1 & (2**2-1)

                    """Extract the CipherBase..."""
                    CipherBase = (Level_1 >> 2) & (2**3-1)

                elif Level > 1 and Byte == CipherBase + 3:
                    """Extract the Level 2 Header..."""
                    Level_2 = baseScheme(CipherSize).find(Char)

                    """Extract TimeShift and Apply to Seed..."""
                    TimeShift = Level_2 & (2**3-1)
                    Seed += relicTimeWarp(TimeShift)

                    """This completes Header Processing..."""
                    EndOfHeader = True

                """Update the Environment for the next Byte..."""
                """Indexes need to be 1 based as applies to Seed..."""
                Seed += (Index + 1)
                Alphabet = Cipher
                Cipher = scramble(Cipher, Seed)

                if EndOfHeader:
                    """Increment the Byte for the Message Loop..."""
                    Byte += 1
                    """Exit the Loop..."""
                    Break
                    
        """Main Message Loop..."""
        for Byte in range(Byte, Length):
            
            """Retrieve a Character for Decoding..."""
            Char = Message[Byte]
            Index = Cipher.find(Char)
            Output += Alphabet[Index]

            """Update the Environment for the next Byte..."""
            """Indexes need to be 1 based as applies to Seed..."""
            Seed += (Index + 1)
            Alphabet = Cipher
            Cipher = scramble(Cipher, Seed)
        
        return Output

    """Default Return..."""
    return ""

# =============================================================
# relicTimeWarp(TimeShift)
# =============================================================
def relicTimeWarp(TimeShift):

    TimeWarp = 0
    Now = now()

    if type(TimeShift) == int \
       and TimeShift in range(1, 8):

        """TimeWarp is based on the Current Year..."""
        TimeWarp = Now.year

        if TimeShift == 1:
            """TimeShift on the minute..."""
            TimeWarp += Now.minute
        elif TimeShift == 2:
            """TimeShift on the Hour..."""
            TimeWarp += Now.hour
        elif TimeShift == 3:
            """TimeShift on the Day..."""
            TimeWarp += dayOfYear()
        elif TimeShift == 4:
            """TimeShift on the Week..."""
            TimeWarp += weekNum()
        elif TimeShift == 5:
            """TimeShift on the Month"""
            TimeWarp += Now.month
        elif TimeShift == 6:
            """TimeShift on the Quarter"""
            TimeWarp += quarter()

    return TimeWarp

# =============================================================
# scramble(String, Seed)
# =============================================================
def scramble(String, Seed):
    """Scramble a String based on a PRNG Seed..."""
    Success = type(String) == str and type(Seed) == int
    if Success:
        """Initialize Local Variables..."""
        Size = len(String)
        State = Seed
        Sorted = True
        TokenSet = ""
        Delim = ","
        Output = ""

        for Char in range(Size):
            """Generate a new Randomizer State..."""
            State = xrandGen(State)
            """Assign new Value to a Character..."""
            Token = xrandVal(State,2) + String[Char]
            """Add to the set..."""
            Flags = tokenFlagSet(0, "SORTED_ORDER")
            TokenSet = tokenAdd(TokenSet, Delim, Token, Flags)

        """Build a new scramble set..."""
        for Char in range(Size):
            Token = tokenGet(TokenSet, Delim, Char + 1)
            """Grab the 3rd byte for the symbol..."""
            """The first 2 bytes represent the Sorted Value"""
            """from the PRNG..."""
            Output += Token[2]
        return Output
    
    """DefaultReturn..."""
    return ""

# =============================================================
# xrandgen(State=-1)
#
# This is a special sort of Stateless PRNG...
# This is the Generator...
# =============================================================
def xrandGen(State = -1):
    """Generate a new State..."""
    Success = type(State) in (int, float)
    if Success:
        if State < 0:
            State = (State * -1) + time.time()
        return ((State * 1.123456789) + 1.2345) % (2**32)
    """Default Return..."""
    return 0

# =============================================================
# xrandval(State, Digits=2)
#
# This is a special sort of Stateless PRNG...
# This is the Random Number Extractor...
# =============================================================
def xrandVal(State, Digits = 2):
    """Extract the random number from the state..."""
    Success = type(State) == float
    if Success:
        Value = "{0}".format(State)
        Offset = Value.find(".") + 1
        return Value[Offset:Offset + Digits]
    """Default Return..."""
    return 0

# =============================================================
# base2Base(BaseValue, Base1, Base2)
# =============================================================
def base2Base(BaseVal, Base1, Base2):
    """Convert any Base to any Base, from 2-36..."""
    Success = type(BaseVal) == str \
              and type(Base1) == int \
              and type(Base2) == int
    if Success:
        return dec2Base(base2Dec(BaseVal, Base1), Base2)
    """Default Return..."""
    return ""

# =============================================================
# dec2Base(DecValue, Base)
# =============================================================
def dec2Base(DecValue, Base):
    """Convert Decimal Value to Indicated Base..."""
    Success = type(DecValue) == int \
              and type(Base) == int
    if Success:
        """Initialize Local Variables..."""
        Output = ""
        Scheme = baseScheme(Base)
        Div = DecValue
        """Execute the Operation..."""
        while Div > 0:
            Rem = Div % Base
            Div = Div // Base

            Output = Scheme[Rem] + Output

        return Output
    """Default Return..."""
    return ""

# =============================================================
# base2Dec(BaseValue, Base)
# =============================================================
def base2Dec(BaseValue, Base):
    """Convert from one base to Decimal..."""
    Success = type(BaseValue) == str \
              and type(Base) == int
    if Success:
        """Initialize Local Variables..."""
        ColCount = len(BaseValue)
        Scheme = baseScheme(Base)
        DecValue = 0
        """Execute the Operation..."""
        for Col in range(ColCount):
            ColValue = Scheme.find(BaseValue.upper()[Col])
            DecValue += ColValue * (Base ** (ColCount - (Col+1)))

        return DecValue
    """Default Return..."""
    return 0

# =============================================================
# baseScheme(Base)
# =============================================================
def baseScheme(Base):
    """Define a BaseScheme..."""
    Success = type(Base) == int
    if Success:
        """Initialize Local Variables..."""
        Scheme = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        Base64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" \
                 "abcdefghijklmnopqrstuvwxyz0123456789+/"
        if type(Base) == int:
            """Valid Base..."""
            if Base in range(36):
                """Typical Numeric Scheme up to 36 Symbols..."""
                Scheme = Scheme[:Base]
            elif Base == 64:
                """Standard Base64 Scheme..."""
                Scheme = Base64
            elif Base in (128, 256):
                """Build a Scheme based on the ASCII set..."""
                Scheme = ""
                for ASCIIVal in range(Base):
                    Scheme = Scheme + chr(ASCIIVal)
        return Scheme
    """Default Return..."""
    return ""

# ============================================================
# at(Str, Sub, Nth=0)
#
# Helper wrapper function...
# ============================================================
def at(Str, Sub, Nth=0):
    """Determine the Position of the Desired Occurrence..."""
    Success = type(Str) == str \
              and type(Sub) == str \
              and type(Nth) == int
    if Success:
        """Initialize Local Variables..."""
        Offset = Str.find(Sub)
        if Offset > 0:
            """Loop through each instance till we find it..."""
            for Instance in range(Nth):
                Offset = Str.find(Sub, Offset+1)
        return Offset
    """Default Return..."""
    return -1

# =============================================================
# Autocall the main() function...
# =============================================================

if __name__ == "__main__":
    main()
