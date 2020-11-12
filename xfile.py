import os
Path = os.path.dirname(os.path.abspath(__file__))
print(__name__, Path)
#print(os.path.abspath("."))

# ================================================
# Get the Xware Path..
# ================================================
def xwarePath():
    """Where is our Application?"""
    return os.path.dirname(os.path.abspath(__file__))

def xfileData(FileName = "xware.xfs"):
    """Where do we want our File?"""
    return xwarePath() + "\\" + FileName
    
def isFile(FileName):
    """Does the file exist?"""
    if type(FileName) == str:
        return os.path.isfile(FileName)

def xfileOpen(FilePath, Mode):
    """Open the file..."""

if __name__ == "__main__":
    main()

