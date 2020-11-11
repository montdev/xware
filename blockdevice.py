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
# blockAdd(Blocks, BlockSize, BlockData, Flags)
# ============================================================
def blockAdd(Blocks, BlockSize, BlockData = "", Flags = 0):
    """Add a new Datablock to the set..."""
    """Create part of CRUD..."""

    """Validate the parameters..."""
    Success = type(Blocks) == str and type(BlockSize) == int\
              and BlockSize > 0 and type(BlockData) == str

    if Success:
        """Test to see if this is Binary or Text..."""
        Binary = byteSniffTest(byteSniff(BlockData), "BINARY")
        if Binary:
            Padding = chr(0)
        else:
            Padding = " "
        """Make sure it's no more than BlockSize And At Least BlockSize..."""
        return Blocks + BlockData[:BlockSize].ljust(BlockSize, Padding)
    """Default Return"""
    return Blocks

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
               + BlockData[:BlockSize].ljust(BlockSize, Padding) \
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
              and type(BlockSize) == int and BlockSize > 0\
              and type(BlockIndex) == int and BlockIndex >= 0
    if Success:
        """Validate the BlockIndex..."""
        Count = blockCount(Blocks, BlockSize)
        Success = between(BlockIndex, 0, Count - 1)
        
    if Success:
        """Do the deed..."""
        BlockStart = BlockIndex * BlockSize
        BlockEnd = BlockStart + BlockSize
        return Blocks[:BlockStart] + Blocks[BlockEnd:]
    
    """Default Return..."""
    return Blocks

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
            """Make sure NewBlock is no more than BlockSize but at least BlockSize..."""
            Block = Block + NewBlock[:BlockSize].ljust(BlockSize, Padding)
            BlockStart = BlockID * BlockSize
            BlockEnd = BlockStart + BlockSize
            return Blocks[:BlockStart] + Block + Blocks[BlockEnd:]
        
    return Blocks

# ============================================================
# blockFind(Blocks, BlockSize, Key)
# ============================================================
def blockFind(Blocks, BlockSize, Key):
    """Find a block based on a Key..."""
    if type(Blocks) == str and type(BlockSize) == int \
        and BlockSize > 0 and type(Key) == str  \
        and len(Key) > 0 and Key.isprintable():
        
        Key = Key.upper()
        KeyLength = len(Key)
        Count = blockCount(Blocks, BlockSize)
        
        for BlockID in range(Count):
            Block = blockGet(Blocks, BlockSize, BlockID)
            if Key == Block[:KeyLength].upper():
                """We have a match..."""
                return BlockID
            
    """Return the default, Not Found..."""
    return 0

# ============================================================
# blockFilter(Blocks, BlockSize, Key)
# ============================================================
def blockFilter(Blocks, BlockSize, Key):
    """Create a filtered set of Key Matches..."""
    Filter = ""
    
    if type(Blocks) == str and type(BlockSize) == int \
        and BlockSize > 0 and type(Key) == str \
        and len(Key) > 0:
        
        Count = blockCount(Blocks, BlockSize)
        Key = Key.upper()
        KeyLength = len(Key)
        
        for BlockID in range(Count):
            Block = blockGet(Blocks, BlockSize, BlockID)
            if Key == Block[:KeyLength].upper():
                Filter = blockAdd(Filter, BlockSize, Block)
                
    return Filter
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

# ============================================================
# field16Count(Data)
# ============================================================
def field16Count(Data):
    """Return a Count of Field Structures..."""
    if type(Data) == str:
        return len(Data)//16
    return 0
    
# ============================================================
# field16Add(Data, Field, Size = None, Flags = None)
# ============================================================
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
            if field16Valid(Field):
                Data = blockAdd(Data, 16, Field)
                
        Data = field16CalcOffsets(Data)
           
    """Return the Unchanged Set..."""
    return Data

# ============================================================
# field16Get(Data, FieldID, Property = None)
# ============================================================
def field16Get(Data, FieldID, Property = None):
    """Get a Field16 Structure from the Set..."""
    if type(Data) == str and field16IdValid(FieldID):
        """Get the Count and Validate the FieldID..."""
        Count = blockCount(Data, 16)
        Index = -1
        
        """FieldID can now be Index or Key..."""
        if type(FieldID) == str:
            """Convert the Key to an Index..."""
            Index = field16Find(Data, FieldID)
        elif type(FieldID) == int :
            Index = FieldID
        
        if between(Index, 0, Count - 1):
            Field = blockGet(Data, 16, Index)
            if Property == None:
                """Just return the field itself..."""
                return Field
            else:
                """Extract the appropriate Field Property..."""
                if Property.upper() in ("NAME", "OFFSET", "SIZE", "FLAGS"):
                    return field16Property(Field, Property)

    """The return would be expected to be integer..."""
    if type(Property) == str \
        and Property.upper() in ("OFFSET", "SIZE", "FLAGS"):
        return -1
    
    """Can't return what isn't there..."""
    return ""

# ============================================================
# field16Put(Data, FieldID, Property, Value)
# ============================================================
def field16Put(Data, FieldID, Property, Value):
    """Put or Replace a Field16 Structure in the Set..."""
    Success = type(Data) == str and field16IdValid(FieldID) \
       and type(Property) == str and len(Property) > 0
    
    if Success:
        """Get the Count..."""
        Count = blockCount(Data, 16)
        Index = -1

        """FieldID can now be Index or Key..."""
        if type(FieldID) == str:
            """Convert the Key to an Index..."""
            Index = field16Find(Data, FieldID)
        elif type(FieldID) == int :
            Index = FieldID
        
        if between(Index, 0, Count - 1):
            """Valid FieldID..."""
            Property = Property.upper()
            Success = CalcOffsets = False
            
            if Property == "FIELD":
                """Put the whole Field..."""
                if field16Valid(Value):
                    Data = blockPut(Data, 16, Index, Value)
                    CalcOffsets = True
            else:
                """Grab the Field in question..."""
                Field = blockGet(Data, 16, Index)
                if Property == "NAME":
                    Success = type(Value) == str \
                                and len(Value) > 0
                elif Property in ("OFFSET", "SIZE", "FLAGS"):
                    Success = type(Value) == int \
                                and Value >= 0
                    
                    if Success and Property == "SIZE":
                        """Size must be greater than Zero..."""
                        Success = Value > 0
                        
                """Update the Field..."""
                if Success:
                    Field = field16Property(Field, Property, Value)
                    if field16Valid(Field):
                        Data = blockPut(Data, 16, Index, Field)
                        CalcOffsets = Property in ("OFFSET","SIZE")
                
            if CalcOffsets:
                Data = field16CalcOffsets(Data)
                    
    return Data
           

# ============================================================
# field16Drop(Data, FieldID)
# ============================================================
def field16Drop(Data, FieldID):
    """Remove a Field16 Structure from the Set..."""
    if type(Data) == str and type(FieldID) == int:
        """Get the Count..."""
        
        Index = -1
        Count = blockCount(Data, 16)

        """FieldID can now be Index or Key..."""
        if type(FieldID) == str:
            """Convert the Key to an Index..."""
            Index = field16Find(Data, FieldID)
        elif type(FieldID) == int :
            Index = FieldID

        if between(Index, 0, Count - 1):
            Data = blockDrop(Data, 16, Index)
            Data = field16CalcOffsets(Data)
            
    return Data

# ============================================================
# field16Insert(Data, FieldID, Field)
# ============================================================
def field16Insert(Data, FieldID, Field):
    """Insert a Field Structure at this point..."""
    if type(Data) == str and type(FieldID) == int \
       and type(Field) == str and len(Field) == 16:
        """Get the Count..."""
        Count = blockCount(Data, 16)
        Index = -1

        """FieldID can now be Index or Key..."""
        if type(FieldID) == str:
            """Convert the Key to an Index..."""
            Index = field16Find(Data, FieldID)
        elif type(FieldID) == int :
            Index = FieldID
        
        if between(Index, 0, Count - 1):
            """Do the Insert here..."""
            if field16Valid(Field):
                Data = blockInsert(Data, 16, Index, Field)
                Data = field16CalcOffsets(Data)
        
    return Data

# ============================================================
# field16Find(Data, Key)
# ============================================================
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
            

# ============================================================
# field16CalcOffsets(Data)
# ============================================================
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

# ============================================================
# field16New(Name, Size, Flags = 0)
# ============================================================
def field16New(Name, Size, Flags = 0):
    """Create a base Field16 Structure..."""
    if type(Name) == str and len(Name) > 0 \
       and Name[:1].isalpha() and Name.isalnum() \
       and type(Size) == int and Size > 0 \
       and type(Flags) == int and Flags >= 0:
        Field = Name[:10].ljust(10, " ") \
                + str(0).rjust(2,"0") \
                + str(Size).rjust(2,"0") \
                + str(Flags).rjust(2,"0")

        return Field

    """Return an Empty Structure..."""
    return ""

# ============================================================
# field16Property(Data, Prop, Value=None)
# ============================================================
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
                

# ============================================================
# field16Valid(Field)
# ============================================================
def field16Valid(Field):
    """Validate a Field16 Structure..."""
    if type(Field) == str and len(Field) == 16 \
       and Field[:1].isalpha() \
       and Field[:10].isalnum() \
       and Field[10:12].isdigit() \
       and Field[12:14].isdigit() \
       and Field[14:16].isdigit():
        return True

    return False

# =============================================
# field16IdValid(FieldID, Type = (int, str))
# =============================================
def field16IdValid(FieldID, Type = (int, str)):
    """Validate a FieldID..."""
    if str(FieldID).isprintable() and len(str(FieldID)) > 0:
        if type(Type) == tuple:
            return type(FieldID) in Type
        elif type(Type) == Type:
            return type(FieldID) == Type
        
    return False
            
# =============================================
# Field16 - Flag Functions...
# =============================================


# ==================================================
# field16FlagGet(Flags, Name, ReturnType="bool")
# ==================================================
def field16FlagGet(Flags, Name, ReturnType="bool"):
    pass

# ==================================================
# field16FlagSet(Flags, Name, Value)
# ==================================================
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

# ==================================================
# between(Value, Min, Max)
# ==================================================
def between(Value, Min, Max):
    if type(Value) == int and type(Min) == int \
       and type(Max) == int:
        return Value >= Min and Value <= Max

    return False
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
            if Base > 36:
                ColValue = Scheme.find(BaseValue[Col])
            else:
                ColValue = Scheme.find(BaseValue.upper()[Col])
            DecValue += ColValue * (Base ** (ColCount - (Col+1)))

        return DecValue
    """Default Return..."""
    return 0

# =============================================================
# Autocall the main() function...
# =============================================================

if __name__ == "__main__":
    main()
