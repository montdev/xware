# coding: ascii
# *************************************************************
# TokenSet.py
# *************************************************************
print(__name__)
#import math
#import datetime
#import time
#import imp

# ************************************************************
# TokenSet Class...
# ************************************************************
class TokenSet:
    def __init__(self, data="", fields=""):
        # Initialize the TokenSet...
        self.data = data
        self.fields = fields
        
    # TokenSet Functions...
    def TokenCount(self):
        # Get the Token Count...
        Data = self.data
        Delimiter = tokenGet(self.fields, ";", "Delimiter=")
        if len(Delimiter) > 0:
            return tokenCount(Data, Delimiter)
        return 0

    def AddToken(self, Token = ""):
        # Add a Token to the Dataset...
        if type(Token) == str:
            Data = self.data
            Fields = self.fields
            Delimiter = tokenGet(Fields,";","Delimiter=")
            if len(Delimiter) > 0:
                Flags = tokenFlags(tokenGet(Fields,";","Flags="))
                self.data = tokenAdd(Data, Delimiter, Token, Flags)
                return True
        return False

    def GetToken(self, TokenID):
        # Get a Token from the TokenSet...
        if tokenIdValid(TokenID):
            Data = self.data
            Fields = self.fields
            Delimiter = tokenGet(Fields,";","Delimiter=")
            if len(Delimiter) > 0:
                Flags = tokenFlags(tokenGet(Fields,";","Flags="))
                return tokenGet(Data, Delimiter, TokenID, Flags)
        return ""

    def PutToken(self, TokenID, Value):
        # Update a given Token Value...
        if tokenIdValid(TokenID) and type(Value) == str:
            Data = self.data
            Fields = self.fields
            Delimiter = tokenGet(Fields, ";", "Delimiter=")
            if len(Delimiter) > 0:
                Flags = tokenFlags(tokenGet(Fields,";","Flags="))
                self.data = tokenPut(Data, Delimiter, TokenID, Value, Flags)
                return True
        return False

    def DropToken(self, TokenID):
        # Drop a given Token...
        if tokenIdValid(TokenID):
            Data = self.data
            Fields = self.fields
            Delimiter = tokenGet(Fields,";","Delimiter=")
            if len(Delimiter) > 0:
                Flags = tokenFlags(tokenGet(Fields,";","Flags="))
                self.data = tokenDrop(Data, Delimiter, TokenID, Flags)
                return True
        return False

    def InsertToken(self, TokenID, Token):
        # Insert a Token...
        if TokenID in (int, str) and type(Token) == str:
            Data = self.data
            Fields = self.fields
            Delimiter = tokenGet(Fields,";","Delimiter=")
            if len(Delimiter) > 0:
                Flags = tokenFlags(tokenGet(Fields,";","Flags="))
                self.data = tokenInsert(Data, Delimiter, TokenID, Token, Flags)
                return True
        return False

    def FindToken(self, Key):
        # Convert a Key to an Index...
        if tokenIdValid(Key, str):
            Data = self.data
            Fields = self.fields
            Delimiter = tokenGet(Fields,";","Delimiter=")
            if len(Delimiter) > 0:
                Flags = tokenFlags(tokenGet(Fields, ";", "Flags="))
                return tokenFind(Data, Delimiter, Key, Flags)
        return 0

    def IsToken(self, Key):
        # Check for the presence of a Key...
        return bool(self.FindToken(Key))
        
    # FieldSet Functions...

    def GetField(self, Field):
        # Get a Field Value from the Property Bag...
        if tokenIdValid(Field, str):
            Field = Field + "="
            return tokenGet(self.fields, ";", Field)
        return ""

    def PutField(self, Field, Value):
        # Update a Field Value...
        if tokenIdValid(Field, str) and type(Value) == str:
            Field = Field + "="
            self.fields = tokenPut(self.fields, ";", Field, Value)

            """Check if this Field has any Impact..."""            
            if Field.upper() == "DELIMITER=":
                Delimiter = tokenGet(self.Fields, ";", Field)
                if bool(Delimiter) and Delimiter != Value:
                    self.data = tokenDelimiter(self.data, Delimiter, Value)
            return True
        return False

    # FlagSet Functions...

    def GetFlag(self, Flag):
        # Get a Flag Value
        if tokenIdValid(Flag, str):
            Fields = self.fields
            Flags = tokenGet(Fields, ";", "Flags=")
            return tokenFlagGet(Flags, Flag)
        return False

    def SetFlag(self, Flag, Value):
        # Set a Flag Value...
        if tokenIdValid(Flag, str) and type(Value) in (int, bool):
            Fields = self.fields
            Delimiter = tokenGet(Fields, ";", "Delimiter=")
            if len(Delimiter) > 0:
                Flags = tokenFlags(tokenGet(Fields, ";", "Flags="))
                Flags = tokenFlagSet(Flags, Flag, Value)
                self.fields = tokenPut(Fields, ";", "Flags=", Flags)
                if Flag.upper() in ("SORTED", "DESCENDING", "REVERSE"):
                    self.data = tokenOrder(self.data, Delimiter, Flags)
                return True
        return False

# ************************************************************
# End of TokenSet Class...
# ************************************************************


# ============================================================
# ************************************************************
# TokenSet Functions...
# ************************************************************
# ============================================================

# ============================================================
# tokenCount(Set, Delimiter, Key = "", Flags = 0)
# ============================================================
def tokenCount(Set, Delimiter, Key = "", Flags = 0):
    """Count the number of tokens in a TokenSet..."""
    """Initialize Local Variables..."""
    Count = 0
    """Validate parameters..."""
    Success = type(Set) == str \
              and type(Delimiter) == str \
              and len(Delimiter) > 0 
    
    if Success:
        if len(Set) > 0:
            if type(Key) == str and len(Key) > 0:
                """This is a Filtered Key Count..."""
                Filter = tokenFilter(Set, Delimiter, Key, Flags)
                Count = tokenCount(Filter, Delimiter)
            else:
                """The count is always count + 1..."""
                Count = Set.count(Delimiter) + 1
                
    return Count

# ============================================================
# tokenAdd(Set, Delimiter, Token, Flags=0)
# Create part of CRUD...  Append Token to a TokenSet...
# ============================================================
def tokenAdd(Set, Delimiter, Token, Flags=0):
    """ Append a Token to the End of the Set"""
    """ This is the Create Part of CRUD..."""
    
    """Validate parameters..."""
    Success = type(Set) == str \
              and type(Delimiter) == str \
              and len(Delimiter) > 0 \
              and type(Token) == str

    """Test related Flags..."""
    NoNulls = tokenFlagGet(Flags, "NO_NULL_TOKENS")
    Unique = tokenFlagGet(Flags, "UNIQUE")
    Sorted = tokenFlagGet(Flags, "SORTED")
    Reverse = tokenFlagGet(Flags, "REVERSE")
    
    if Success:
        """Test the Local Flag Rules..."""
        if NoNulls and len(Token) == 0:
            """Insure Token isn't NULL..."""
            return Set
        elif Unique and tokenFound(Set, Delimiter, Token, Flags):
            """Unique Tokens Only..."""
            return Set
        elif len(Set) == 0:
            """Don't Sweat the Small Stuff..."""
            if len(Token) == 0:
                """Make it look like a Size of One..."""
                return " "
            else:
                """This is the only Token..."""
                return Token
        elif Sorted:
            """Insert in a Sorted Fashion (index=0)... """
            return tokenInsert(Set, Delimiter, 0, Token, Flags)
        elif Reverse:
            """Prepend to the beginning of the TokenSet..."""
            return Token + Delimiter + Set
        else:
            """This will be a normal Append Operation... """
            return Set + Delimiter + Token
        
    """Default Return the Set unchanged..."""
    return Set

# ============================================================
# tokenGet(Set, Delimiter, TokenID, Flags = 0)
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

    Count = tokenCount(Set, Delimiter)
    KeyLength = 0
    Value = ""

    if Count > 0 and tokenIdValid(TokenID):
        
        """Check to see if a Keyed Lookup is needed..."""
        if type(TokenID) == str:
            """Do a Key to Index lookup..."""
            """Convert the Key to an Index..."""
            Token = tokenFind(Set, Delimiter, TokenID, Flags)
            if Token > 0:
                """Get KeyLength to indicate Key Search..."""
                KeyLength = len(TokenID)
                
            else:
                """This is a Normal Token Index..."""
                Token = TokenID
            
        """Extract the Token Value..."""
        if Token == 0 or Token > Count:
            """Can't retrieve what isn't there..."""
            Value ""
        
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
            """Extract the Last Token..."""
            Start = Set.rindex(Delimiter) + len(Delimiter)
            Value = Set[Start:]
            
        else:
            """This is a Middle Token..."""
            Start = tokenAt(Set, Delimiter, Token - 2) + len(Delimiter)
            Length = Set.find(Delimiter, Start + 1)
            Value = Set[Start:Length]

        """If this was a Keyed Lookup, strip out the Key..."""
        if KeyLength > 0:
            """Return the Value without the Key..."""
            Value = Value[KeyLength:]
            
    return Value

# ============================================================
# tokenPut(Set, Delimiter, TokenID, Value, Flags = 0)
#
# Update portion of CRUD...
#
# Support has been added for Named or Keyed TokenSets...
# ============================================================
def tokenPut(Set, Delimiter, TokenID, Value, Flags = 0):
    """Update the Indicated Token..."""
    
    """Test related Flags..."""
    NoNulls = tokenFlagGet(Flags, "NO_NULL_TOKENS")

    if NoNulls and type(Value) == str \
       and len(Value) == 0:
        """Do not allow a Null Value..."""
        return Set
    
    """Get the count..."""
    Count = tokenCount(Set, Delimiter)
    
    if Count >= 0 \
       and tokenIdValid(TokenID) \
       and type(Value) == str:
    
        """Validate parameters..."""
        Success =  type(Value) == str
        
        if Success:
            
            """Initialize Local Variables..."""
            Token = Head = Tail = 0
            TokenValue = ""

            """Check to see if Key to Index lookup is needed..."""
            if type(TokenID) == str:
                    
                """Do a Key to Index lookup..."""
                Token = tokenFind(Set, Delimiter, TokenID, Flags)
                TokenValue = TokenID + Value
                    
            else:
                """This is a normal Token Index..."""
                Token = TokenID
                TokenValue = Value

            """Check Flags for Unique Requirement..."""
            if tokenFlagGet(Flags, "UNIQUE"):
                if tokenFind(Set, Delimiter, TokenValue, Flags) > 0:
                    """Token already exists..."""
                    """Return the Unchanged Set..."""
                    return Set
                
            """Check to see if this is a Sorted Set..."""
            Sorted = tokenFlagGet(Flags, "SORTED")
            if Sorted and (type(TokenID) == int or Token == 0):
                """If Key based and not Slotted it should be inserted anyway
                   but if it's Index based it won't be sorted after
                   changing it so it should be dropped and inserted..."""
                if Token > 0:
                    Set = tokenDrop(Set, Delimiter, Token)
                return tokenInsert(Set, Delimiter, 0, TokenValue, Flags)
                
            elif Token == 0:
                """Just append the Unslotted Value to the End..."""
                return tokenAdd(Set, Delimiter, TokenValue, Flags)
                
            elif Token > Count and AllowNulls:
                """The set will have to be expanded to accomodate..."""
                
                return Set + (Delimiter * ((Token - 1) - Count)) + TokenValue
            
            elif Token == 1:
                """Update the first token..."""
                if Count in (0,1):
                    """This is the only token in the set..."""
                    """It should put it though if count is 0 or 1..."""
                    return TokenValue
                else:
                    Tail = Set.find(Delimiter)
                    return TokenValue + Set[Tail:]
                
            elif Token == Count:
                """Update the last token..."""
                Head = Set.rindex(Delimiter) + len(Delimiter)
                return Set[:Head] + TokenValue
            
            else:
                """Update a middle token..."""
                Head = tokenAt(Set, Delimiter, Token - 2) + len(Delimiter)
                Tail = Set.find(Delimiter, Head + 1)
                return Set[:Head] + TokenValue + Set[Tail:]
    
    return Set

# ============================================================
# tokenDrop(Set, Delimiter, TokenID, Flags = 0)
#
# Delete portion of CRUD...
#
# Support has been added for Named or Keyed Sets...
# ============================================================
def tokenDrop(Set, Delimiter, TokenID, Flags = 0):
    """Remove the Indicated Token"""
    """Validate parameters..."""
    
    """Determine the Count..."""
    Count = tokenCount(Set, Delimiter)
        
    if Count > 0 and tokenIdValid(TokenID):
        
        """Initialize Local Variables..."""
        Token = Head = Tail = 0
        
        if type(TokenID) == str:
            """Perform a Key to ID Lookup..."""
            Token = tokenFind(Set, Delimiter, TokenID, Flags)

            """With a Keyed Delete there may be more than 1..."""
            if Token > 0 and tokenFlagGet(Flags, "ALL_MATCHES"):
                    
                while Token > 0:
                    """Drop this token..."""
                    Set = tokenDrop(Set, Delimiter, Token)
                    """Find the next token to drop..."""
                    Token = tokenFind(Set, Delimiter, TokenID, Flags)
                    
                return Set
        else:
            Token = TokenID
        
        """Delete the indicated Token..."""
        if Token == 0 or Token > Count:
            """Can't delete what isn't there..."""
            return Set
        
        elif Token == 1:
            """Remove the First Token..."""
            if Count == 1:
                """This is the only token, nothing else remains..."""
                return ""
            else:
                Tail = Set.find(Delimiter) + len(Delimiter)
                return Set[Tail:]
            
        elif Token == Count:
            """Removing the Last Token..."""
            Tail = Set.rindex(Delimiter)
            return Set[:Tail]
        
        else:
            """Removing a Middle Token..."""
            Head = tokenAt(Set, Delimiter, Token - 2)
            Tail = Set.find(Delimiter, Head + 1)
            return Set[:Head] + Set[Tail:]
        
    """Default Return the Unchanged Set..."""
    return Set

# ============================================================
# tokenInsert(Set, Delimiter, TokenID, NewValue, Flags = 0)
#
# For Sorted Sets use 0 for the Index Slot...
# Support has been added for Keyed or Named TokenSets...
# ============================================================
def tokenInsert(Set, Delimiter, TokenID, NewValue, Flags = 0):
    """Insert a Token to a given slot...  Also provides a
       simple means to perform a sorted insert..."""
    """ Insert is really nothing more than a Get and a Put..."""
    """Validate parameters..."""

    Count = tokenCount(Set, Delimiter)
    NoNulls = tokenFlagGet("NO_NULL_TOKENS")

    if type(NewValue) == str:
        if NoNulls and len(NewValue) == 0:
            return Set
    else:
        return Set

    if Count > 0 and tokenIdValid(TokenID):

        """Initialize Local Variables..."""
        Token = 0
        NewToken = TokenValue = ""
        Sorted = False

        """Check Flags for Unique Requirement..."""
        if tokenFlagGet(Flags, "UNIQUE"):
            if tokenFound(Set, Delimiter, NewValue, Flags):
                """Return the Unchanged Set..."""
                return Set
            
        """Sort is implemented in the Insert Function..."""
        Sorted = tokenFlagGet(Flags, "SORTED")
        
        """Check to see if this is a Key or Index Operation..."""        
        if type(TokenID) == str:
            """This is a Keyed or Named TokenSet..."""
            """Convert Token Key to Index..."""
            Token = tokenFind(Set, Delimiter, TokenID, Flags)
            NewToken = NewValue

        else:
            Token = TokenID
            NewToken = NewValue
            """ The Zero Index is the SORTED or NULL Index..."""
            Sorted = Sorted or Token == 0

        if Token > Count:
            return Set
        
        if Sorted:
            """ This is a Special Sorted Insert..."""
            
            Descending = tokenFlagGet(Flags, "DESCENDING")
            InsertHere = False

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
                Token = 1

            """Insert before the indicated slot..."""
            TokenValue = tokenGet(Set, Delimiter, Token)
            TokenValue = NewToken + Delimiter + TokenValue
            return tokenPut(Set, Delimiter, Token, TokenValue)
        
    """Default Return the Unchanged Set..."""
    return Set

# ============================================================
# tokenOrder(Set, Delimiter, Flags = 0)
#
# Sort or reverse the order of a TokenSet...
# ============================================================
def tokenOrder(Set, Delimiter, Flags = 0):
    """Sort the current Set..."""
    """Validate parameters..."""

    Count = tokenCount(Set, Delimiter)

    if Count > 0:

        if tokenFlagGet(Flags, "SORTED"):
            Order = "SORTED"
        elif tokenFlagGet(Flags, "REVERSE"):
            Order = "REVERSE"
        else:
            """No Order to Set, Return it Unchanged..."""
            return Set

        """Define a NewSet for the Ordered Set..."""
        NewSet = ""
        
        """Perform the Reorder Operation..."""
        for Index in range(Count):
            
            """Extract the Token..."""
            Token = tokenGet(Set, Delimiter, Index + 1)
            
            if Order == "SORTED":
                """Loop through the Tokens and copy to a SortedSet..."""
                NewSet = tokenInsert(NewSet, Delimiter, 0, Token, Flags)
                
            elif Order == "REVERSE":
                """Loop through Tokens and copy to Reversed Set..."""
                NewSet = tokenAdd(NewSet, Delimiter, Token, Flags)

        """Return the Resulting Set..."""
        return NewSet

    """Default Return the unchanged Set..."""
    return Set

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
    Success = type(Set) == str and type(Delimiter) == str \
             and len(Delimiter) > 0 and tokenIdValid(Key, str) \
             and type(Flags) == int
    
    if Success:
        """Check for Flags Affecting this Operation..."""
        ContainedIn = tokenFlagGet(Flags, "CONTAINED_IN")
        CaseSensitive = tokenFlagGet(Flags, "CASE_SENSITIVE")
        if CaseSensitive == False:
            Key = Key.upper()
        
        Count = tokenCount(Set, Delimiter)
        
        KeyLength = len(Key)

        """Find First Match for Key..."""
        for Index in range(Count):
            """ Check to see if this is the Token..."""
            Token = tokenGet(Set, Delimiter, Index + 1)
            
            """Compare Key with the Token..."""
            if CaseSensitive == False:
                Token = Token.upper()

            """If ContainedIn is in play then it can be anywhere..."""
            if ContainedIn:
                if Token.Find(Key) >= 0:
                    return Index + 1
            else:
                """If ContainedIn isn't in play then it's the Key at the Front..."""
                if Key == Token[:KeyLength]:
                    return Index + 1

    """Default Return..."""
    return 0

# ============================================================
# tokenFound(Set, Delimiter, Key, Flags = 0)
# ============================================================
def tokenFound(Set, Delimiter, Key, Flags = 0):
    if tokenFind(Set, Delimiter, Key, Flags) > 0:
        return True
    else:
        return False

# ============================================================
# tokenFilter(Set, Delimiter, Key, Flags = 0)
# ============================================================
def tokenFilter(Set, Delimiter, Key, Flags = 0):
    """Return a Key Filtered Subset..."""

    Success = type(Set) == str and type(Delimiter) == str \
              and len(Delimiter) > 0 and tokenIdValid(Key, str) \
              and type(Flags) == int

    Filter = ""
    
    if Success:

        """Check for Flags that affect this Operation..."""
        ContainedIn = tokenFlagGet(Flags, "CONTAINED_IN")
        CaseSensitive = tokenFlagGet(Flags, "CASE_SENSITIVE")
        
        if CaseSensitive == False:
            Key = Key.upper()
            
        KeyLength = len(Key)

        Count = tokenCount(Set, Delimiter)

        for Index in range(Count):
            """ Check to see if this is the Token..."""
            Token = tokenGet(Set, Delimiter, Index + 1)
            
            """Compare Key with the Token..."""
            
            if CaseSensitive:
                TokenTest = Token
            else:
                TokenTest = Token.upper()

            Match = False
            
            if ContainedIn:
                if TokenTest.Find(Key) >= 0:
                    Match = True
            else:
                if Key == TokenTest[:KeyLength]:
                    Match = True
                
            if Match:
                """Add the unmodified Token..."""
                Filter = tokenAdd(Filter, Delimiter, Token, Flags)


    return Filter

# ============================================================
# tokenIsKey(Set, Delimiter, Key, Flags = 0)
# ============================================================
def tokenIsKey(Set, Delimiter, Key, Flags = 0):
    """Test to see if a Key Value can be found..."""
    Token = tokenFind(Set, Delimiter, Key, Flags)
    return bool(Token)

# ============================================================
# tokenGetKey(Set, Delimiter, Index, Terminator, Flags = 0)
# ============================================================
def tokenGetKey(Set, Delimiter, Index, Terminator, Flags = 0):
    """Used to request a Key from an Index..."""
    if type(Set) == str and type(Delimiter) == str \
        and len(Delimiter) > 0 and tokenIdValid(Index, int) \
        and type(Terminator) == str and len(Terminator) > 0 \
        and type(Flags) == int:
        """Extract the Token for the Index..."""
        Token = tokenGet(Set, Delimiter, Index)
        """Return the first part..."""
        return tokenGet(Token, Terminator, 1) + Terminator
    
    """Return the default for did not find..."""
    return ""

# ============================================================
# tokenSetCount(Set, Delimiter, Size, Flags = 0)
# Change the Size of a TokenSet...
# ============================================================
def tokenSetCount(Set, Delimiter, Size, Flags = 0):
    """Change the Size of the TokenSet..."""
    Success = type(Set) == str and type(Delimiter) == str \
              and len(Delimiter) > 0 and type(Size) == int \
              and Size >= 0

    if Success:
        
        """Initialize Local Variables..."""
        Count = tokenCount(Set, Delimiter)

        """Prevent Operations resulting in Null Tokens..."""        
        NoNulls = tokenFlagGet(Flags, "NO_NULL_TOKENS")

        if Size == 0:
            """Clear it to none..."""
            return ""
        elif Size == 1 and Count == 0:
            """Make sure it's 1 even if none..."""
            if NoNulls:
                return ""
            else:
                return " "
        elif Size == 1:
            """We're only going to have the first one left..."""
            return tokenGet(Set, Delimiter, 1)
        elif Count > Size:
            """Reduce the Size..."""
            return Set[:tokenAt(Set, Delimiter, Size - 1)]
        elif Count < Size:
            """Increase the Size..."""
            if NoNulls:
                return Set
            return tokenPut(Set, Delimiter, Size, "")

    return ""

# ============================================================
# tokenDelimiter(Set, OldDelimiter, NewDelimiter)
# ============================================================
def tokenDelimiter(Set, OldDelimiter, NewDelimiter):
    """Change the delimiter..."""

    Success = type(Set) == str \
              and type(OldDelimiter) == str \
              and len(OldDelimiter) > 0 \
              and type(NewDelimiter) == str

    if Success:
        return Set.replace(OldDelimiter, NewDelimiter)

    return Set

# ============================================================
# Abstract Data Type Inspired Methods...
# ************************************************************
# (LISP Type List Functions, Stack, Queue)
# ============================================================

# ============================================================
# tokenHead(Set, Delimiter)
# Return only the first Token in the Set...
# ============================================================
def tokenHead(Set, Delimiter):
    """Return only the First Token in the Set..."""
    return tokenGet(Set, Delimiter, 1)

# ============================================================
# tokenTail(Set, Delimiter)
# Return all but the first Token in the Set...
# ============================================================
def tokenTail(Set, Delimiter):
    """Return all but the First Token in the Set..."""
    return tokenDrop(Set, Delimiter, 1)

# ============================================================
# tokenPush(Set, Delimiter, Token):
# Push Token onto Top of Stack...
# ============================================================
def tokenPush(Set, Delimiter, Token):
    """Push Token onto Top of Stack..."""
    return tokenInsert(Set, Delimiter, 1, Token)

# ============================================================
# tokenPop(Set, Delimiter):
# Pop Token off of Top of Stack...
# ============================================================
def tokenPop(Set, Delimiter):
    """Pop Token off of Top of Stack..."""
    return tokenDrop(Set, Delimiter, 1)

# ============================================================
# tokenEnqueue(Set, Delimiter, Token):
# Add Token to End of Queue...
# ============================================================
def tokenEnqueue(Set, Delimiter, Token):
    """Add Token to End of Queue..."""
    return tokenAdd(Set, Delimiter, Token)

# ============================================================
# tokenDequeue(Set, Delimiter):
# Pop Token off of Top of Stack...
# ============================================================
def tokenDequeue(Set, Delimiter):
    """Add Token to End of Queue..."""
    return tokenDrop(Set, Delimiter, 1)


# ============================================================
# ************************************************************
# TokenSet Flag Functions...
# ************************************************************
# ============================================================
# ============================================================
# tokenFlagGet(Flags, Property, ReturnType = "bool")
# ============================================================

def tokenFlagGet(Flags, Property, ReturnType = "bool"):
    """Query the Flags for the Given Property Bit..."""

    Value = 0

    """Validate the parameters..."""
    if type(Flags) == int and tokenIdValid(Property):

        """Make this a Non Case Sensitive Search..."""
        Property = Property.upper()
        
        if Property == "SORTED":
            Value = (Flags & (2**0))
            
        elif Property == "DESCENDING":
            Value = (Flags & (2**1))

        elif Property == "REVERSE":
            Value = (Flags & (2**2))

        elif Property == "ALL_MATCHES":
            Value = (Flags & (2**3))
        
        elif Property == "UNIQUE":
            Value = (Flags & (2**4))
        
        elif Property == "NO_NULL_TOKENS":
            Value = (Flags & (2**5))
        
        elif Property == "CASE_SENSITIVE":
            Value = (Flags & (2**6))
        
        elif Property == "CONTAINED_IN":
            Value = (Flags & (2**7))
           
        """Determine the desired return type..."""
        """If the Return Type is overridden the default is int..."""
        if ReturnType.lower() == "bool":
            """This is the default..."""
            Value = bool(Value)

    return Value

# ============================================================
# tokenFlagSet(Flags, Property, Value = 1)
# ============================================================
def tokenFlagSet(Flags, Property, Value = 1):
    """Query the Flags for the Given Property Bit..."""

    """Validate the parameters..."""
    if type(Flags) == int and type(Value) in (int, bool) \
       and tokenIdValid(Property):

        """Make this a Non Case Sensitive Search..."""
        Property = Property.upper()

        """We either set it with an Or or we can use
        the Exclusive Or as a toggle if it's not
        already set..."""

        if Property == "SORTED":
            if Value > 0:
                Flags = (Flags | (2**0))
            elif tokenFlagGet(Flags, Property):
                Flags = (Flags ^ (2**0))
                
        elif Property == "DESCENDING":
            if Value > 0:
                Flags = (Flags | (2**1))
            elif tokenFlagGet(Flags, Property):
                Flags = (Flags ^ (2**1))
            
        elif Property == "REVERSE":
            if Value > 0:
                Flags = (Flags | (2**2))
            elif tokenFlagGet(Flags, Property):
                Flags = (Flags ^ (2**2))
           
        elif Property == "ALL_MATCHES":
            if Value > 0:
                Flags = (Flags | (2**3))
            elif tokenFlagGet(Flags, Property):
                Flags = (Flags ^ (2**3))
        
        elif Property == "UNIQUE":
            if Value > 0:
                Flags = (Flags | (2**4))
            elif tokenFlagGet(Flags, Property):
                Flags = (Flags ^ (2**4))
        
        elif Property == "NO_NULL_TOKENS":
            if Value > 0:
                Flags = (Flags | (2**5))
            elif tokenFlagGet(Flags, Property):
                Flags = (Flags ^ (2**5))
        
        elif Property == "CASE_SENSITIVE":
            if Value > 0:
                Flags = (Flags | (2**6))
            elif tokenFlagGet(Flags, Property):
                Flags = (Flags ^ (2**6))

        elif Property == "CONTAINED_IN":
            if Value > 0:
                Flags = (Flags | (2**7))
            elif tokenFlagGet(Flags, Property):
                Flags = (Flags ^ (2**7))
           
    return Flags

# ============================================================
# ************************************************************
# TokenGroup Functions...
# ************************************************************
# ============================================================

# ============================================================
# tokenGroupCount(Set, Delimiter, Key, Flags)
# ============================================================
def tokenGroupCount(Set, Delimiter, Key, Flags):
    """Count the Group Headers..."""
    if type(Set) == str and type(Delimiter) == str \
        and len(Delimiter) > 0 and tokenIdValid(Key, str):
        return tokenCount(Set, Delimiter, Key, Flags)
    return 0 

# ============================================================
# tokenGroupList(Set, Delimiter, Key, Flags)
# ============================================================
def tokenGroupList(Set, Delimiter, Key, Flags):
    """TokenGroups look like INIFile Sections..."""
    if type(Set) == str and type(Delimiter) == str \
        and len(Delimiter) > 0 and tokenIdValid(Key, str):
        """Extract a list of Group Headers..."""
        return tokenFilter(Set, Delimiter, Key, Flags)
    return ""

# ============================================================
# tokenGroupGet(Set, Delimiter, TokenGroup, Flags)
# ============================================================
def tokenGroupGet(Set, Delimiter, Group, Flags = 0):

    """Initialize a Result Set to be Returned..."""
    Result = ""

    """Validate the Parameters..."""
    if type(Set) == str and \
        type(Delimiter) == str \
        and len(Delimiter > 0) \
        and tokenIdValid(Group, str):
        
        """Locate the indicated TokenGroup..."""
        Header = tokenFind(Set, Delimiter, Group, Flags)
        if Header > 0:
            """Now Extract tokens till next GroupHead..."""
            Index = Header + 1
            Count = tokenCount(Set, Delimiter)
            while True:
                """Get the Next Token..."""
                Token = tokenGet(Set, Delimiter, Index)
                
                """Test to see if we've reached the end of the Group..."""
                if Token[:1] == Group[:1]:
                    """We've reached the Next Group..."""
                    break
                else:
                    """Add the Token to the Result Set..."""
                    Result = tokenAdd(Result, Delimiter, Token, Flags)
                    
                    if Index == Count:
                        """Reached the End of the Set..."""
                        break
                    else:
                        """Advance the Index up to the Count..."""
                        Index += 1

    """Return the Empty Value..."""
    return Result

# ====================================================================
# tokenGroupPut(Set, Delimiter, TokenGroup, GroupData, Flags)
# ====================================================================
def tokenGroupPut(Set, Delimiter, Group, Data, Flags = 0):

    """Validate the Parameters..."""
    if type(Set) == str \
        and type(Delimiter) == str \
        and len(Delimiter) > 0 \
        and tokenIdValid(Group, str) \
        and type(Data) == str \
        and type(Flags) == 0:
        
        """Locate the TokenGroup..."""
        Header = tokenFind(Set, Delimiter, Group, Flags)
        if Header > 0:
            Index = Header + 1
            Count = tokenCount(Set, Delimiter)
        
            """Loop through the Tokens in the Group..."""
            """Strip out all the Tokens in this Group..."""
            """Insert or Add the New Group afterwards..."""
            while True:
                """Get the Next Token..."""
                Token = tokenGet(Set, Delimiter, Index)
                
                """Test to see if we've reached the end of the Group..."""
                if Token[:1] == Group[:1]:
                    """This is the Next Group..."""
                    """Insert the NewGroup Here..."""
                    Set = tokenInsert(Set, Delimiter, Index, Data)
                    break
                elif Index == Count:
                    """We're at the end of the Set..."""
                    """Append the Group Data Here..."""
                    Set = tokenAdd(Set, Delimiter, Data)
                    break
                else:
                    """Drop this Token..."""
                    """The index won't change..."""
                    Set = tokenDrop(Set, Delimiter, Index)
                    """Reduce the Count by 1..."""
                    Count = Count - 1
        else:
            """The Group doesn't appear to exist..."""
            """Just append the Group to the End..."""
            Data = Group + Delimiter + Data
            Set = tokenAdd(Set, Delimiter, Data)

    return Set

# ====================================================================
# tokenGroupDrop(Set, Delimiter, TokenGroup, Flags)
# ====================================================================
def tokenGroupDrop(Set, Delimiter, Group, Flags = 0):
    if type(Set) == str and \
        type(Delimiter) == str \
        and len(Delimiter > 0) \
        and tokenIdValid(Group, str) \
        and type(Flags) == int:
        
        """Locate the indicated TokenGroup..."""
        Header = tokenFind(Set, Delimiter, Group, Flags)
        if Header > 0:
            """Now Drop Everything in the Group..."""
            Index = Header + 1
            Count = tokenCount(Set, Delimiter)
            while True:
                """Get the Next Token..."""
                Token = tokenGet(Set, Delimiter, Index)
                
                """Test to see if we've reached the end of the Group..."""
                if Token[:1] == Group[:1] or Header == Count:
                    """We're done, Drop the Group Header..."""
                    Set = tokenDrop(Set, Delimiter, Header)
                    break
                else:
                    """Drop this Token from the Group..."""
                    Set = tokenDrop(Set, Delimiter, Index)
                    Count = Count - 1

    """Return the Empty Value..."""
    return Set

# ====================================================================
# tokenGroupKeyFind(Set, Delimiter, Group, Key)
# ====================================================================
def tokenGroupKeyFind(Set, Delimiter, Group, Key):
    if type(Set) == str and type(Delimiter) == str \
        and len(Delimiter) > 0 and tokenIdValid(Group, str) \
        and tokenIdValid(Key, str):
        
        """Find the Group Header..."""
        Header = tokenFind(Set, Delimiter, Group)
        if Header > 0:
            """Locate the Group Key..."""
            Index = Header + 1
            Count = tokenCount(Set, Delimiter)
            Key = Key.upper()
            KeyLength = len(Key)
            while True:
                Token = tokenGet(Set, Delimiter, Index)
                
                if Key == Token[:KeyLength].upper():
                    """Key Match..."""
                    return Index
                elif Token[:1] == Group[:1] or Index == Count:
                    """Next Group Match, or the
                       End of the Set..."""
                    break
                else:
                    Index += 1
                
    """Return the Default for not found..."""
    return 0

# ====================================================================
# tokenGroupKeyExists(Set, Delimiter, Group, Key)
# ====================================================================
def tokenGroupKeyExists(Set, Delimiter, Group, Key):
    Index = tokenGroupKeyFind(Set, Delimiter, Group, Key)
    return Index > 0

# ====================================================================
# tokenGroupKeyGet(Set, Delimiter, Group, Key)
# ====================================================================
def tokenGroupKeyGet(Set, Delimiter, Group, Key):
    """Find the Group Key..."""
    Index = tokenGroupKeyFind(Set, Delimiter, Group, Key)
    if Index > 0:
        """The Group Key has been found..."""
        KeyLength = len(Key)
        Token = tokenGet(Set, Delimiter, Index)
        return Token[KeyLength:]
    else:
        """Return the default for Not Found..."""
        return ""

# ====================================================================
# tokenGroupKeyPut(Set, Delimiter, Group, Key, Value)
# ====================================================================
def tokenGroupKeyPut(Set, Delimiter, Group, Key, Value):
    if type(Set) == str \
        and type(Delimiter) == str \
        and len(Delimiter) > 0 \
        and tokenIdValid(Group, str) \
        and tokenIdValid(Key, str) \
        and type(Value) == str:
        """Find the Group Key..."""
        Header = tokenFind(Set, Delimiter, Group)
        if Header > 0:
            """The Group Key has been found..."""
            Index = Header + 1
            Count = tokenCount(Set, Delimiter)
            Key = Key.upper()
            KeyLength = len(Key)
            Value = Key + Value
            while True:
                Token = tokenGet(Set, Delimiter, Index)
                
                if Key == Token[:KeyLength].upper():
                    """Key Match..."""
                    Set = tokenPut(Set, Delimiter, Index, Value)
                    break
                elif Token[:1] == Group[:1]:
                    """Next Group Header Match..."""
                    Set = tokenInsert(Set, Delimiter, Index, Value)
                    break
                elif Index == Count
                    """End of the Set..."""
                    Set = tokenAdd(Set, Delimiter, Value)
                    break
                else:
                    Index += 1
                    
    else:
        """Group doesn't exist..."""
        """Append Group and Data to the End..."""
        Group = Group + Delimiter + Key + Value
        Set = tokenAdd(Set, Delimiter, Group)

    """Return the default for Not Found..."""
    return Set

# ====================================================================
# tokenGroupKeyDrop(Set, Delimiter, Group, Key)
# ====================================================================
def tokenGroupKeyDrop(Set, Delimiter, Group, Key):
    """Find the Group Key..."""
    Index = tokenGroupKeyFind(Set, Delimiter, Group, Key)
    if Index > 0:
        """The Group Key has been found..."""
        Set = tokenDrop(Set, Delimiter, Index)
        
    """Return the default for Not Found..."""
    return Set


# ============================================================
# ************************************************************
# Helper Functions...
# ************************************************************
# ============================================================

# ============================================================
# tokenAt(Str, Sub, Nth=0)
#
# Helper wrapper function...
# ============================================================
def tokenAt(Str, Sub, Nth=0):
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

# ============================================================
# tokenIsTrue(Value)
# ============================================================
def tokenIsTrue(Value):
    return bool(Value) == True

# ============================================================
# tokenIsFalse(Value)
# ============================================================
def tokenIsFalse(Value):
    return bool(Value) == False

# ============================================================
# tokenFlags(Flags)
# Helper function to take a string based Flags value and then
# convert it into a useful integer...
# ============================================================
def tokenFlags(Flags):
    if type(Flags) == str and Flags.isdigit():
        return int(Flags)
    elif type(Flags) == int:
        return Flags
    """Default to return an empty Flag Set..."""
    return 0

# ============================================================
# tokenIdValid(TokenID, Type = (int, str))
# ============================================================
def tokenIdValid(TokenID, Type=(int, str)):
    if bool(TokenID) and str(TokenID).isprintable():
        if type(Type) == tuple:
            return type(TokenID) in Type
        elif type(Type) == type:
            return type(TokenID) == Type

    return False

# ============================================================
# tokenIsQuoted(Token, Head = "", Tail = "")
# ============================================================
def tokenIsQuoted(Token, Head = "", Tail = ""):
    """Determine if the Token is Quoted..."""
    Quoted = False
    
    if len(Head) > 0 and len(Tail) == 0:
        Length = len(Head)
        if Token[:Length] ==  Token[(Length*-1):]:
            Quoted = True
    elif len(Head) > 0 and len(Tail) > 0:
        Length1 = len(Head)
        Length2 = len(Tail)
        if Token[:Length1] ==  Head and Token[Length2*-1:] == Tail:
            Quoted = True
    else:
        # Head Quotes are ',",[,{,(,<
        Head = Token[:1]
        Tail = Token[-1:]
        
        if Head == "(" and Tail == ")":
            Quoted = True
        elif Head == "[" and Tail == "]":
            Quoted = True
        elif Head == "{" and Tail == "}":
            Quoted = True
        elif Head == "<" and Tail == ">":
            Quoted = True
        elif Head == Tail and Head.isprintable() \
             and Head.isalnum() == False:
            Quoted = True
        
    return Quoted

# ============================================================
# tokenQuoteHead(Token)
# ============================================================
def tokenQuoteHead(Token):
    return Token[:1]

# ============================================================
# tokenQuoteTail(Token)
# ============================================================
def tokenQuoteTail(Token):
    return Token[-1:]

# ============================================================
# tokenQuote(Token, Head = "", Tail = "")
# ============================================================
def tokenQuote(Token, Head = "", Tail = ""):
    if len(Head) == 0:
        return "'" + Token + "'"
    if len(Head) > 0 and len(Tail) == 0:
        """Use the Head for both ends..."""
        return Head + Token + Head
    else:
        return Head + Token + Tail

# ============================================================
# tokenUnquote(Token)
# ============================================================
def tokenUnquote(Token):
    if tokenIsQuoted(Token):
        while tokenIsQuoted(Token):
            Length = len(Token) - 1
            Token = Token[1:Length]

    return Token

# =============================================================
# Autocall the main() function...
# =============================================================
def main():

    pass

if __name__ == "__main__":
    main()
