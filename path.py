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

def xwareData(FileName = "xware.xfs"):
    """Where do we want our File?"""
    return xwarePath() + "\\" + FileName
    
def isFile(FileName):
    """Does the file exist?"""
    if type(FileName) == str:
        return os.path.isfile(FileName)
    else:
        return False

def isDir(Path):
    """Is the path a Directory?"""
    return os.path.isDir(Path)

def addBS(Path):
    return Path + "\\"
    
def justPath(Path):
    """Get just the Path Part..."""
    return os.path.dirname(Path)

def forcePath(FileName, Path):
    return addBS(Path) + FileName

if __name__ == "__main__":
    main()

