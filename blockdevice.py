# coding: ascii
# *************************************************************
# blockdevice.py
# *************************************************************
print(__name__)
#import math
#import datetime
#import time
#import imp

# =============================================================
# main()
# =============================================================
def main():

    pass
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
# blockAdd(Blocks, BlockSize, NewBlock, Flags)
# ============================================================
def blockAdd(Blocks, BlockSize, BlockData = "", Flags = 0):
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
              and BlockSize > 0 and type(BlockIndex) == int \
              and BlockIndex >= 0

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
              and type(BlockSize) == int and BlockSize > 0 \
              and type(BlockIndex) == int and BlockIndex >= 0 \
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
# blockDrop(Blocks, BlockSize, BlockIndex)
# ============================================================
def blockDrop(Blocks, BlockSize, BlockIndex):
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
# blockInsert(Blocks, BlockSize, BlockIndex, NewBlock)
# ============================================================
def blockInsert(Blocks, BlockSize, BlockID, NewBlock):
    """Insert a Block at this location..."""
    Success = type(Blocks) == str and type(BlockSize) == int \
              and type(BlockID) == int and type(NewBlock) == str

    Success = Success and BlockSize > 0 and BlockID >= 0
        
    if Success:

        Binary = byteSniffTest(byteSniff(NewBlock), "BINARY")
        if Binary:
            Padding = chr(0)
        else:
            Padding = " "

        Count = blockCount(Blocks, BlockSize)
        if between(BlockID, 0, Count - 1):
            Block = blockGet(Blocks, BlockSize, BlockID)
            Block = Block + blockPad(NewBlock, BlockSize, Padding)
            BlockStart = BlockID * BlockSize
            BlockEnd = BlockStart + BlockSize
            Blocks = Blocks[:BlockStart] + Block \
                     + Blocks[BlockEnd:]

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

# *************************************************************
# Field16 Field Set Functions...
# *************************************************************
def field16Count(Data):
    """Return a Count of Field Structures..."""
    if type(Data) == str:
        return len(Data)/16
    return 0
    
def field16Add(Data, Field, Size = None, Flags = None):
    """Add a base Field16 Structure to the Field Set..."""
    if type(Data) == str and type(Field) == str:
        """See if this is Field Object or Field Name..."""
        if Size == None and Flags == None \
           and len(Field) == 16:
            """This is a Field Object..."""
            if field16Valid(Field):
                """Write the Field to the Set..."""
                Data = blockAdd(Data, 16, Field)
        elif type(Size) == int and Size > 0 \
             and type(Flags) == int and Flags >= 0:
            """Create a new field and add that..."""
            Field = field16New(Field, Size, Flags)
            Data = blockAdd(Data, 16, Field)
        Data = field16CalcOffsets(Data)
           
    """Return the Unchanged Set..."""
    return Data

def field16Get(Data, FieldID, Property = None):
    """Get a Field16 Structure from the Set..."""
    if type(Data) == str:
        """Get the Count and Validate the FieldID..."""
        Count = blockCount(Data, 16)
        
        if type(FieldID) == int \
           and between(FieldID, 0, Count - 1):
            Field = blockGet(Data, 16, FieldID)
            if Property == None:
                return Field
            else:
                Property = Property.upper()
                if Property == "NAME":
                    return field16Property(Field, "NAME")
                elif Property == "OFFSET":
                    return field16Property(Field, "OFFSET")
                elif Property == "SIZE":
                    return field16Property(Field, "SIZE")
                elif Property == "FLAGS":
                    return field16Property(Field, "FLAGS")
        else:
            """The return would be expected to be integer.."""
            if type(Property) == str \
               and Property.upper() in ("OFFSET", "SIZE", "FLAGS"):
                return -1
    
    """Can't return what isn't there..."""
    return ""

def field16Put(Data, FieldID, Property, Value):
    """Put or Replace a Field16 Structure in the Set..."""
    Success = type(Data) == str and type(FieldID) == int \
       and type(Property) == str and len(Property) > 0
    
    if Success:
        """Get the Count..."""
        Count = blockCount(Data, 16)
        if between(FieldID, 0, Count - 1):
            """Valid FieldID..."""
            Property = Property.upper()
            Success = CalcOffsets = False
            
            if Property == "FIELD":
                """Put the whole Field..."""
                if field16Valid(Value):
                    Data = blockPut(Data, 16, Value)
                    CalcOffsets = True
            else:
                """Grab the Field in question..."""
                Field = blockGet(Data, 16, FieldID)
                if Property == "NAME":
                    Success = type(Value) == str \
                                and len(Value) > 0
                elif Property in ("OFFSET", "SIZE", "FLAGS"):
                    Success = type(Value) == int \
                                and Value >= 0
                    CalcOffsets = Property in ("OFFSET","SIZE")
                        
                """Update the Field..."""
                if Success:
                    Field = field16Property(Field, Property, Value)
                    if field16Valid(Field):
                        Data = blockPut(Data, 16, Field)
                
            if CalcOffsets:
                Data = field16CalcOffsets(Data)
                    
    return Data
           

def field16Drop(Data, FieldID):
    """Remove a Field16 Structure from the Set..."""
    if type(Data) == str and type(FieldID) == int:
        """Get the Count..."""
        Count = blockCount(Data, 16)
        if between(FieldID, 0, Count - 1):
            Data = blockDrop(Data, FieldID)
            Data = field16CalcOffsets(Data)
            
    return Data

def field16Insert(Data, InsertPoint, Field):
    """Insert a Field Structure at this point..."""
    if type(Data) == str and type(InsertionPoint) == int \
       and type(Field) == str and len(Field) == 16:
        Count = blockCount(Data, 16)
        if between(InsertionPoint, 0, Count - 1):
            """We have a good InsertionPoint..."""
            Data = blockInsert(Data, 16, InsertionPoint, Field)
            Data = field16CalcOffsets(Data)
        
    return Data

def field16Find(Data, Key):
    """Find a Field16 based on Name..."""
    if type(Data) == str and type(Key) == str \
       and bool(Key) and Key.isprintable():
        Count = blockCount(Data, 16)
        Key = Key.upper()
        KeyLength = len(Key)
        for BlockID in range(Count):
            Block = blockGet(Data, 16, BlockID)
            if Block[:KeyLength].upper() == Key:
                """We found a match..."""
                return BlockID
            
    """Block Not Found..."""
    return -1
            

def field16CalcOffsets(Data):
    """Scan through the Fields and Calculate Offsets..."""
    if type(Data) == str:
        Offset = 0
        Count = blockCount(Data, 16)
        for BlockID in range(Count):
            Block = blockGet(Data, 16, BlockID)
            Block = field16Property(Block, "Offset", Offset)
            Offset = Offset + field16Property(Block, "Size")
            Data = blockPut(Data, 16, BlockID, Block)

    return Data

# =============================================
# Field16 - Field Specific Functions...
# =============================================

def field16New(Name, Size, Flags = 0):
    """Create a base Field16 Structure..."""
    if type(Name) == str and len(Name) > 0 \
       and Name[:1].isalpha() and Name.isprintable() \
       and type(Size) == int and Size > 0 \
       and type(Flags) == int and Flags >= 0:
        Field = Name[:10].ljust(10, " ") \
                + str(0).rjust(2,"0") \
                + str(Size).rjust(2,"0") \
                + str(Flags).rjust(2,"0")

        return Field

    """Return an Empty Structure..."""
    return ""

def field16Property(Data, Prop, Value=None):
    if type(Data) == str and len(Data) == 16 \
       and type(Prop) == str:
        Prop = Prop.upper()
        if Prop == "NAME":
            if Value == None:
                """Get Name Value"""
                return Data[:10].strip()
            elif type(Value) == str:
                """Put Name Value"""
                return Value[:10].ljust(10," ") \
                       + Data[10:]
        elif Prop == "OFFSET":
            if Value == None:
                """Get Offset Value"""
                return int(Data[10:12])
            elif type(Value) == int:
                """Put Offset Value"""
                return Data[:10] + str(Value)[:2].rjust(2,"0") \
                       + Data[12:]
        elif Prop == "SIZE":
            if Value == None:
                """Get Size Value"""
                return int(Data[12:14])
            elif type(Value) == int:
                """Put Size Value"""
                return Data[:12] + str(Value)[:2].rjust(2,"0") \
                       + Data[14:]
        elif Prop == "FLAGS":
            if Value == None:
                """Get Flags Value"""
                return int(Data[14:])
            elif type(Value) == int:
                """Put Flags Value"""
                return Data[:14] + str(Value)[:2].rjust(2,"0")
                

def field16Valid(Field):
    """Validate a Field16 Structure..."""
    if type(Field) == str and len(Field) == 16 \
       and Field[:10].isprintable() \
       and Field[10:12].isdigit() \
       and Field[12:14].isdigit() \
       and Field[14:16].isdigit():
        return True

    return False

# =============================================
# Field16 - Flag Functions...
# =============================================
def field16FlagGet(Flags, Name, ReturnType="bool"):
    pass

def field16FlagSet(Flags, Name, Value):
    pass


# *************************************************************
# Helper Sniffer Functions...
# *************************************************************

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

        Property = Property.upper()

        Value = 0

        if Property == "BINARY":
            Value = Flags & 2**0
        elif Property == "TEXT":
            Value = Flags & 2**1
        elif Property == "ALPHA":
            Value = Flags & 2**2
        elif Property == "NUMERIC":
            Value = Flags & 2**3
        elif Property == "UPPER":
            Value = Flags & 2**4
        elif Property == "LOWER":
            Value = Flags & 2**5
        elif Property == "DELIMITED":
            Value = Flags & 2**6
        elif Property == "NESTED":
            Value = Flags & 2**7
        elif Property == "WHITESPACE":
            Value = Flags & 2**8
        elif Property == "ROWBASED":
            Value = Flags & 2**9
        elif Property == "QUOTED":
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

# *************************************************************
# Other Helper Functions...
# *************************************************************

def between(Value, Min, Max):
    if type(Value) == int and type(Min) == int \
       and type(Max) == int:
        return Value >= Min and Value <= Max

    return False
    

# =============================================================
# Autocall the main() function...
# =============================================================

if __name__ == "__main__":
    main()
