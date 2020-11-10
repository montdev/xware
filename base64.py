# coding: ascii
# *************************************************************
# xblockset.py
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
# base64Encode(String)
# =============================================================
def base64Encode(String):
    """Encode string to Base64..."""
    """Validate the parameter..."""
    Success = type(String) == str
    if Success:
        """Initialize Local Variables..."""
        Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" \
                 "abcdefghijklmnopqrstuvwxyz0123456789+/"
        WordSize = 3
        Length = len(String)

        Word = Output = ""
        WordStart = Byte = Bits = 0
        Nibble1 = Nibble2 = Nibble3 = Nibble4 = 0

        for WordStart in range(0, Length, WordSize):
            Nibble1 = Nibble2 = Nibble3 = Nibble4 = 0

            Word = String[WordStart:WordStart + WordSize]
            WordLength = len(Word)

            for Byte in range(0, WordLength):
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

            for Nibble in range(0, WordLength):

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
# Autocall the main() function...
# =============================================================

if __name__ == "__main__":
    main()
