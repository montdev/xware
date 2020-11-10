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


# =============================================================
# Autocall the main() function...
# =============================================================

if __name__ == "__main__":
    main()
