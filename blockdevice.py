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
# Helper Functions...
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


# =============================================================
# Autocall the main() function...
# =============================================================

if __name__ == "__main__":
    main()
