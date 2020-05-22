*& *************************************************************************
*& XTool Workbench...
*& This is a Scratch area or Sandbox to play in...  Any functions that are
*& needed should be provided below...
*& *************************************************************************
*&
*& ---------------------------------------------
*& Let's clean up our environment for now...
*& ---------------------------------------------
*&
SET CENTURY ON 
SET EXCLUSIVE OFF
SET MULTILOCKS ON 
SET SAFETY OFF 
SET PROCEDURE TO xtool.prg
*DO C
*&
*&
*& ------------------------------------------------------------------
*& For starters we'll need a Serial Number...
*& ------------------------------------------------------------------
*& So for our serial number we'll need the following values...
*& ------------------------------------------------------------------
*& This Serial Number will be used to Seed the necessary Ciphers...
*& ------------------------------------------------------------------
*&
lcNet = "Overlay Darknet"
lcNode = "Bob"
lcTimeStamp = "2004-09-14 00:00:00"
*&
lcSerialNumber = SerialNumber(lcNet, lcNode, lcTimeStamp)
*&
*& ---------------------------------------------------
*& So we'll need an Alphabet to work with...
*& ---------------------------------------------------
*&
lcAlphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
lcCipherbet = Scramble(lcAlphabet, lcSerialNumber)
lcTest = "RELIC"
*&
*& ----------------------------------------
*& Now lets see what we have so far...
*& ----------------------------------------
*&
?"Network:", lcNet
?"Node:", lcNode
?"Timestamp:", lcTimeStamp
?"Serial Number:", lcSerialNumber
*&
?"Null Serial No.:", SerialNumber(.null.)
*&
?"Alphabet:", lcAlphabet
?"Cipherbet:", lcCipherbet
?
?"Relic Alphabet:", Scramble(lcAlphabet, lcSerialNumber)
?"Test String:", lcTest
lcEncoded = RelicEncode(lcTest, lcSerialNumber)
?"Encoded Output:", lcEncoded
lcDecoded = RelicDecode(lcEncoded, lcSerialNumber)
?"Decoded Output:", lcDecoded
*&
?
*&
*&
*& *************************************************************************
*& BlockSplit(pcString, pnSize, pcSeparator)
*& =========================================================================
*& Split a Block String into equal groups with a common separator...
*& *************************************************************************
*&
FUNCTION BlockSplit(pcString, pnSize, pcSeparator)
	*&
	LOCAL llSuccess, lcOutput
	*&
	STORE "" TO lcOutput
	*&
	llSuccess = VARTYPE(pcString) = "C" AND VARTYPE(pnSize) = "N" ;
		AND VARTYPE(pcSeparator) = "C"
	*&
	IF llSuccess
		*&
		FOR lnGroup = 1 TO LEN(pcString) STEP pnSize
			*&
			IF LEN(lcOutput) > 0
				*&
				lcOutput = lcOutput + pcSeparator
				*&
			ENDIF && LEN(lcOutput) > 0
			*&
			lcOutput = lcOutput + SUBSTR(pcString, lnGroup, pnSize)
			*&
		ENDFOR && lnGroup = 1 TO LEN(pcString) STEP 5
		*&
	ENDIF && llSuccess
	*&
	RETURN lcOutput
	*&
ENDFUNC && BlockSplit(pcString, pnSize, pcSeparator)
*&
*& **************************************************************
*& BlockPad(pcBlocks, pnBlockSize, pcChar)
*&
*& Pads a Block to a divisible BlockSize...
*&
*& These Block Indexes have to be a Zero Based index for this
*& to work...
*&
*& An effort to map a demonstration of the BlockDevice concept
*& into a set of functions much like the similarly related but
*& very different TokenSet...
*& **************************************************************
*&
FUNCTION BlockPad(pcBlocks, pnBlockSize, pcChar)
	*&
	LOCAL llSuccess, lcBlocks, lnLength
	*&
	llSuccess = VARTYPE(pcBlocks) = "C" ;
		AND VARTYPE(pnBlockSize) = "N" ;
		AND pnBlockSize > 0 ;
		AND VARTYPE(pcChar) = "C" ;
		AND LEN(pcChar) = 1
	*&
	IF llSuccess
		*&
		lnLength = LEN(pcBlocks)
		*&
		IF MOD(lnLength, pnBlockSize) > 0
			*&
			lcBlocks = pcBlocks + REPLICATE(pcChar, pnBlockSize - MOD(lnLength, pnBlockSize))
			*&
		ENDIF && MOD(LEN(pcBlocks), pnBlockSize) > 0
		*&
	ENDIF && llSuccess
	*&
	RETURN lcBlocks
	*&
ENDFUNC && BlockPad(pcBlocks, pnBlockSize, pcChar)
*&
*& **************************************************************
*& BlockDelete(pcBlocks, pnBlockSize, pnBlock)
*&
*& Delete the Indicated Block...
*&
*& These Block Indexes have to be a Zero Based index for this
*& to work...
*&
*& An effort to map a demonstration of the BlockDevice concept
*& into a set of functions much like the similarly related but
*& very different TokenSet...
*& **************************************************************
*&
FUNCTION BlockDelete(pcBlocks, pnBlockSize, pnBlock)
	*&
	LOCAL llSuccess, lcBlocks
	*&
	llSuccess = VARTYPE(pcBlocks) = "C" ;
		AND VARTYPE(pnBlockSize) = "N" ;
		AND pnBlockSize > 0 ;
		AND VARTYPE(pnBlock) = "N" ;
		AND pnBlock >= 0
	*&
	IF llSuccess
		*&
		lcBlocks = STUFF(pcBlocks, pnBlock * pnBlockSize, pnBlockSize, "")
		*&
	ENDIF && llSuccess
	*&
	RETURN lcBlocks
	*&
ENDFUNC && BlockDelete(pcBlocks, pnBlockSize, pnBlock)
*&
*& **************************************************************
*& BlockPut(pcBlocks, pnBlockSize, pnBlock, pcBlock)
*&
*& Updates the Requested Block...
*&
*& These Block Indexes have to be a Zero Based index for this
*& to work...
*&
*& An effort to map a demonstration of the BlockDevice concept
*& into a set of functions much like the similarly related but
*& very different TokenSet...
*& **************************************************************
*&
FUNCTION BlockPut(pcBlocks, pnBlockSize, pnBlock, pcBlock)
	*&
	LOCAL llSuccess, llBinary, lcBlocks
	*&
	llSuccess = VARTYPE(pcBlocks) = "C" ;
		AND VARTYPE(pnBlockSize) = "N" ;
		AND pnBlockSize > 0 ;
		AND VARTYPE(pnBlock) = "N" ;
		AND pnBlock >= 0 ;
		AND pcBlock = "C"
	*&
	IF llSuccess
		*&
		llBinary = BITTEST(ByteSniff(pcBlock), 0)
		*&
		lcBlocks = STUFF(pcBlocks, pnBlock * pnBlockSize, pnBlockSize, ;
			PADR(pcBlock, pnBlockSize, IIF(llBinary, CHR(0), " ")))
		*&
	ENDIF && llSuccess
	*&
	RETURN lcBlocks
	*&
ENDFUNC && BlockPut(pcBlocks, pnBlockSize, pnBlock, pcBlock)
*&
*& **************************************************************
*& BlockGet(pcBlocks, pnBlockSize, pnBlock)
*&
*& Retrieves the Requested Block...
*&
*& These Block Indexes have to be a Zero Based index for this
*& to work...
*&
*& An effort to map a demonstration of the BlockDevice concept
*& into a set of functions much like the similarly related but
*& very different TokenSet...
*& **************************************************************
*&
FUNCTION BlockGet(pcBlocks, pnBlockSize, pnBlock)
	*&
	LOCAL llSuccess, lcBlock
	*&
	llSuccess = VARTYPE(pcBlocks) = "C" ;
		AND VARTYPE(pnBlockSize) = "N" ;
		AND pnBlockSize > 0 ;
		AND VARTYPE(pnBlock) = "N" ;
		AND pnBlock >= 0
	*&
	IF llSuccess
		*&
		*& ------------------------------------------------------
		*& Add 1 to the offset here for the position since with
		*& VFP Substr function uses a 1 based index...
		*& ------------------------------------------------------
		*&
		lcBlock = SUBSTR(pcBlocks, pnBlock * pnBlocksSize + 1, pnBlockSize)
		*&
	ENDIF && llSuccess
	*&
	RETURN lcBlock
	*&
ENDFUNC && BlockGet(pcBlocks, pnBlockSize, pnBlock)
*&
*& **************************************************************
*& BlockAdd(pcBlocks, pnBockSize, pcPadding, pcBlock)
*&
*& Appends a Block at the end...
*&
*& These Block Indexes have to be a Zero Based index for this
*& to work...
*&
*& An effort to map a demonstration of the BlockDevice concept
*& into a set of functions much like the similarly related but
*& very different TokenSet...
*& **************************************************************
*&
FUNCTION BlockAdd(pcBlocks, pnBockSize, pcBlock)
	*&
	LOCAL llSuccess, llBinary, lcBlocks
	*&
	llSuccess = VARTYPE(pcBlocks) = "C" ;
		AND VARTYPE(pnBlockSize) = "N" ;
		AND pnBlockSize > 0 ;
		AND VARTYPE(pcBlock) = "C"
 	*&
 	IF llSuccess
 		*&
 		llBinary = BITTEST(ByteSniff(pcBlock),0)
 		*&
 		lcBlocks = pcBlocks + PADR(pcBlock, pnBlockSize, IIF(llBinary, CHR(0), " "))
 		*&
 	ENDIF && llSuccess
	*&
	RETURN lcBlocks
	*&
ENDFUNC && BlockAdd(pcBlocks, pnBockSize, pcPadding, pcBlock)
*&
*& **************************************************************
*& BlockCount(pcBlocks, pnBlockSize)
*&
*& Returns the number of blocks contained in the set...
*&
*& An effort to map a demonstration of the BlockDevice concept
*& into a set of functions much like the similarly related but
*& very different TokenSet...
*& **************************************************************
*&
FUNCTION BlockCount(pcBlocks, pnBlockSize)
	*&
	LOCAL llSuccess, lnBlocks
	*&
	llSuccess = VARTYPE(pcBlocks) = "C" ;
		AND VARTYPE(pnBlockSize) = "N" ;
		AND pnBlockSize > 0
	*&
	IF llSuccess
		*&
		lnBlocks = INT(LEN(pcBlocks) / pnBlockSize)
		*&
	ENDIF && llSuccess
	*&
	RETURN lnBlocks
	*&
ENDFUNC && BlockCount(pcBlocks, pnBlockSize)
*&
*&
*& **************************************************************
*& ByteSniffMsg(pnFlags)
*&
*& Using the Resulting Flags from ByteSniff this
*& function will create a Row Based Tokenset of
*& the Bit Descriptions...
*& **************************************************************
*&
FUNCTION ByteSniffMsg(pnFlags)
	*&
	LOCAL llShowAll, lcSet, lcCRLF
	*&
	STORE "" TO lcSet
	lcCRLF = CHR(13)+CHR(10)
	*&
	llShowAll = VARTYPE(pnFlags) <> "N" OR pnFlags = 0
	*&
	IF llShowAll OR BITTEST(pnFlags, 0)
		*&
		lcSet = TokenAdd(lcSet, lcCRLF, "0 - Binary")
		*&
	ENDIF && llShowAll OR BITTEST(pnFlags, 0)
	*&
	IF llShowAll OR BITTEST(pnFlags, 1)
		*&
		lcSet = TokenAdd(lcSet, lcCRLF, "1 - Text")
		*&
	ENDIF && llShowAll OR BITTEST(pnFlags, 1)
	*&
	IF llShowAll OR BITTEST(pnFlags, 2)
		*&
		lcSet = TokenAdd(lcSet, lcCRLF, "2 - Alpha")
		*&
	ENDIF && llShowAll OR BITTEST(pnFlags, 2)
	*&
	IF llShowAll OR BITTEST(pnFlags, 3)
		*&
		lcSet = TokenAdd(lcSet, lcCRLF, "3 - Numeric")
		*&
	ENDIF && llShowAll OR BITTEST(pnFlags, 3)
	*&
	IF llShowAll OR BITTEST(pnFlags, 4)
		*&
		lcSet = TokenAdd(lcSet, lcCRLF, "4 - Upper Case")
		*&
	ENDIF && llShowAll OR BITTEST(pnFlags, 4)
	*&
	IF llShowAll OR BITTEST(pnFlags, 5)
		*&
		lcSet = TokenAdd(lcSet, lcCRLF, "5 - Lower Case")
		*&
	ENDIF && llShowAll OR BITTEST(pnFlags, 5)
	*&
	IF llShowAll OR BITTEST(pnFlags, 6)
		*&
		lcSet = TokenAdd(lcSet, lcCRLF, "6 - Delimited")
		*&
	ENDIF && llShowAll OR BITTEST(pnFlags, 6)
	*&
	IF llShowAll OR BITTEST(pnFlags, 7)
		*&
		lcSet = TokenAdd(lcSet, lcCRLF, "7 - Nested")
		*&
	ENDIF && llShowAll OR BITTEST(pnFlags, 7)
	*&
	IF llShowAll OR BITTEST(pnFlags, 8)
		*&
		lcSet = TokenAdd(lcSet, lcCRLF, "8 - WhiteSpace")
		*&
	ENDIF && llShowAll OR BITTEST(pnFlags, 8)
	*&
	IF llShowAll OR BITTEST(pnFlags, 9)
		*&
		lcSet = TokenAdd(lcSet, lcCRLF, "9 - RowBased")
		*&
	ENDIF && llShowAll OR BITTEST(pnFlags, 9)
	*&
	IF llShowAll OR BITTEST(pnFlags, 10)
		*&
		lcSet = TokenAdd(lcSet, lcCRLF, "10 - Quoted")
		*&
	ENDIF && llShowAll OR BITTEST(pnFlags, 10)
	*&
	RETURN lcSet
	*&
ENDFUNC && ByteSniffMsg(pnFlags)
*&
*& ***************************************************************
*& ByteSniff(pcData)
*&
*& Sniff out the characteristics of the provided Bytes...
*&
*&  0 - Binary
*&  1 - Text
*&  2 - Alpha
*&  3 - Numeric
*&  4 - Upper
*&  5 - Lower
*&  6 - Delimited
*&  7 - Nested
*&  8 - WhiteSpace
*&  9 - RowBased
*& 10 - Quoted
*&
*& ***************************************************************
*&
FUNCTION ByteSniff(pcData)
	*&
	#DEFINE cbBINARY		2^0
	#DEFINE cbTEXT			2^1
	#DEFINE cbALPHA			2^2
	#DEFINE cbNUMERIC		2^3
	#DEFINE cbUPPER			2^4
	#DEFINE cbLOWER			2^5
	#DEFINE cbDELIMITED		2^6
	#DEFINE cbNESTED		2^7
	#DEFINE cbWHITESPACE	2^8
	#DEFINE cbROWBASED		2^9
	#DEFINE cbQUOTED		2^10
	*&
	LOCAL lnFlags, lnByte, lnLength, lnASCII
	*&
	STORE 0 TO lnFlags, lnByte, lnLength, lnASCII
	*&
	IF VARTYPE(pcData) = "C"
		*&
		FOR lnByte = 1 TO lnLength
			*&
			*& --------------------------------------------
			*& It's really all about the ASCII Values...
			*& --------------------------------------------
			*&
			lnASCII = ASC(SUBSTR(pcData, lnByte, 1))
			*&
			DO CASE 
			CASE BETWEEN(lnASCII, 0, 31)
				*&
				*& ------------------------------------
				*& Control Codes...
				*& ------------------------------------
				*&
				IF BETWEEN(9, 13)
					*&
					*& --------------------------------------------------------------
					*& White Space - Tabs, Carriage Return, Line Feed, Form Feed...
					*& --------------------------------------------------------------
					*&
					lnFlags = BITOR(lnFlags, cbTEXT + cbWHITESPACE + cbDELIMITED)
					*&
					IF INLIST(lnASCII, 10, 13)
						*&
						lnFlags = BITOR(lnFlags, cbROWBASED)
						*&
					ENDIF && INLIST(lnASCII, 10, 13)
					*&
				ELSE
					*&
					*& ------------------------------------
					*& Binary Data...
					*& ------------------------------------
					*&
					lnFlags = BITOR(lnFlags, cbBINARY)
					*&
					IF lnASCII = 0
						*&
						lnFlags = BITOR(lnFlags, cbDELIMITED)
						*&
					ENDIF && lnASCII = 0
					*&
				ENDIF && BETWEEN(9, 13)
				*&
			CASE BETWEEN(lnASCII, 32, 126)
				*&
				*& ---------------------------------------------
				*& Printable Characters (7 Bit - Net ASCII)...
				*& ---------------------------------------------
				*&
				lnFlags = BITOR(lnFlags, cbTEXT)
				*&
				DO CASE
				CASE lnASCII = 32
					*&
					*& ------------------------------------
					*& Space...
					*& ------------------------------------
					*&
					lnFlags = BITOR(lnFlags, cbWHITESPACE + cbDELIMITED)
					*&
				CASE BETWEEN(lnASCII, 48, 57)
					*&
					*& ------------------------------------
					*& Numbers...
					*& ------------------------------------
					*&
					lnFlags = BITOR(lnFlags, cbNUMERIC)
					*&
				CASE BETWEEN(lnASCII, 65, 90)
					*&
					*& ------------------------------------
					*& Upper Case Letters...
					*& ------------------------------------
					*&
					lnFlags = BITOR(lnFlags, cbALPHA + cbUPPER)
					*&
				CASE BETWEEN(lnASCII, 97, 122)
 					*&
					*& ------------------------------------
					*& Lower Case Letters...
					*& ------------------------------------
					*&
					lnFlags = BITOR(lnFlags, cbALPHA + cbLOWER)
					*&
				CASE INLIST(CHR(lnASCII), "(", ")", "[", "]", "{", "}", "<", ">")
					*&
					*& ------------------------------------
					*& Nestable Balanced Brackets...
					*& ------------------------------------
					*&
					lnFlags = BITOR(lnFlags, cbNESTED)
					*&
				CASE INLIST(CHR(lnASCII), "'", '"')
					*&
					*& ------------------------------------
					*& Quotes...
					*& ------------------------------------
					*&
					lnFlags = BITOR(lnFlags, cbQUOTED)
					*&
				OTHERWISE
					*&
					*& ------------------------------------
					*& Anything else can be a Delimiter...
					*& ------------------------------------
					*&
					lnFlags = BITOR(lnFlags, cbDELIMITED)
					*&
				ENDCASE
				*&
			OTHERWISE 
				*&
				*& -----------------------------------------------------------------
				*& Extended 8 Bit ASCII Characters...
				*&
				*& Not Really part of the Standard Set of Printable Characters that
				*& one finds in a Text File...
				*& -----------------------------------------------------------------
				*&
				lnFlags = BITOR(lnFlags, cbBINARY)
				*&
			ENDCASE 
			*&
		ENDFOR && lnByte = 1 TO lnLength
		*&
	ENDIF && VARTYPE(pcData) = "C"
	*&
	RETURN lnFlags
	*&
ENDFUNC && ByteSniff(pcData)
*&
*& ***************************************************************
*& NamedTokenDelete(pcTokens, pcDelimiter, pcName)
*&
*& Deletes a Named Token from a TokenSet...
*& ***************************************************************
*&
FUNCTION NamedTokenDelete(pcTokens, pcDelimiter, pcName)
	*&
	*& ------------------------------------
	*& Initialize Local Variables...
	*& ------------------------------------
	*&
	LOCAL llSuccess, lcTokens, lnToken
	*&
	STORE "" TO lcTokens
	STORE 0 TO lnToken
	*&
	*& ------------------------------------
	*& Validate the Parameters...
	*& ------------------------------------
	*&
	llSuccess = VARTYPE(pcTokens) = "C" ;
		AND VARTYPE(pcDelimiter) = "C" ;
		AND LEN(pcDelimiter) > 0 ;
		AND VARTYPE(pcName) = "C" ;
		AND LEN(pcName) > 0
	*&
	IF llSuccess
		*&
		*& --------------------------------------------------
		*& Locate the Token to be Removed...
		*& --------------------------------------------------
		*&
		lnToken = TokenFind(pcTokens, pcDelimiter, pcName)
		*&
		IF lnToken > 0
			*&
			*& --------------------------------------------------------
			*& The Token of Interest has been located so delete it...
			*& --------------------------------------------------------
			*&
			lcTokens = TokenDelete(pcTokens, pcDelimiter, lnToken)
			*&
		ENDIF && lnToken > 0
		*&
	ENDIF && llSuccess
	*&
	RETURN lcTokens
	*&
ENDFUNC && NamedTokenDelete(pcTokens, pcDelimiter, pcName)
*&
*& ***************************************************************
*& NamedTokenPut(pcTokens, pcDelimiter, pcName, pcValue)
*&
*& Updates the Value of a Given Named Token...
*& ***************************************************************
*&
FUNCTION NamedTokenPut(pcTokens, pcDelimiter, pcName, pcValue, plSorted)
	*&
	*& ----------------------------------
	*& Initialize Local Variables...
	*& ----------------------------------
	*&
	LOCAL llSuccess, lcTokens, lnTokens, lnToken
	*&
	STORE "" TO lcTokens
	STORE 0 TO lnTokens, lnToken
	*&
	*& ----------------------------------
	*& Validate the Parameters...
	*& ----------------------------------
	*&
	llSuccess = VARTYPE(pcTokens) = "C" ;
		AND VARTYPE(pcDelimiter) = "C" ;
		AND LEN(pcDelimiter) > 0 ;
		AND VARTYPE(pcName) = "C" ;
		AND LEN(pcName) > 0 ;
		AND VARTYPE(pcValue) = "C"
	*&
	IF llSuccess
		*&
		*& ----------------------------------
		*& Locate the indicated Token...
		*& ----------------------------------
		*&
		lnToken = TokenFind(pcTokens, pcDelimiter, pcName)
		*&
		*& ---------------------------------------------------------
		*& If the Token was found then it will be greater than 0...
		*& ---------------------------------------------------------
		*&
		IF lnToken > 0
			*&
			*& ---------------------------------------------------
			*& Update this Token with the new value...
			*& ---------------------------------------------------
			*&
			lcTokens = TokenPut(pcTokens, pcDelimiter, lnToken, pcName + pcValue)
			*&
		ELSE
			*&
			*& ---------------------------------------------------
			*& The Named Token Wasn't Found so we simply append
			*& a new Named Token to the end of the TokenSet...
			*& ---------------------------------------------------
			*&
			lcTokens = TokenAdd(pcTokens, pcDelimiter, pcName + pcValue, plSorted)
			*&
		ENDIF && lnToken > 0
		*&
	ENDIF && llSuccess
	*&
	RETURN lcTokens
	*&
ENDFUNC && NamedTokenPut(pcTokens, pcDelimiter, pcName, pcValue, plSorted)
*&
*& ***************************************************************
*& NamedTokenGet(pcTokens, pcDelimiter, pcName)
*&
*& Retrieves a Token based on a Token Name...
*& ***************************************************************
*&
FUNCTION NamedTokenGet(pcTokens, pcDelimiter, pcName)
	*&
	*& ----------------------------------
	*& Initialize Local Variables...
	*& ----------------------------------
	*&
	LOCAL llSuccess, lnToken, lnTokens, lcToken
	*&
	STORE 0 TO lnToken, lnTokens
	STORE "" TO lcToken
	*&
	*& ----------------------------------
	*& Validate the Parameters...
	*& ----------------------------------
	*&
	llSuccess = VARTYPE(pcTokens) = "C" ;
		AND VARTYPE(pcDelimiter) = "C" ;
		AND LEN(pcDelimiter) > 0 ;
		AND VARTYPE(pcName) = "C" ;
		AND LEN(pcName) > 0
	*&
	IF llSuccess
		*&
		*& ----------------------------------
		*& Locate the Token of Interest...
		*& ----------------------------------
		*&
		lnToken = TokenFind(pcTokens, pcDelimiter, pcName)
		*&
		*& ----------------------------------------------------
		*& If the Token is 0, then the Token wasn't found...
		*& ----------------------------------------------------
		*&
		IF lnToken > 0
			*&
			*& ----------------------------------------------
			*& Extract the Value of the Idenfified Token...
			*& ----------------------------------------------
			*&
			lcToken = TokenGet(pcTokens, pcDelimiter, lnToken)
			lcToken = SUBSTR(lcToken, LEN(pcName) + 1)
			*&
		ENDIF && lnToken > 0
		*&
	ENDIF && llSuccess
	*&
	RETURN lcToken
	*&
ENDFUNC && NamedTokenGet(pcTokens, pcDelimiter, pcName)
*&
*& ***************************************************************
*& TokenFind(pcTokens, pcDelimiter, pcString)
*&
*& Locate a Token based on a String...  This is imlemented as not
*& being Case Sensitive Search...
*& ***************************************************************
*&
FUNCTION TokenFind(pcTokens, pcDelimiter, pcString)
	*&
	*& ----------------------------------
	*& Initialize Local Variables...
	*& ----------------------------------
	*&
	LOCAL llSuccess, lnTokens, lnToken, lcToken
	*&
	STORE 0 TO lnTokens, lnToken
	STORE "" TO lcToken
	*&
	*& ----------------------------------
	*& Validate the Parameters...
	*& ----------------------------------
	*&
	llSuccess = VARTYPE(pcTokens) = "C" ;
		AND VARTYPE(pcDelimiter) = "C" ;
		AND LEN(pcDelimiter) > 0 ;
		AND VARTYPE(pcString) = "C" ;
		AND LEN(pcString) > 0
	*&
	IF llSuccess
		*&
		*& ------------------------------------------
		*& Iterate through the Token Set until the
		*& String is found if present...
		*& ------------------------------------------
		*&
		lnTokens = TokenCount(pcTokens, pcDelimiter)
		*&
		FOR lnToken = 1 TO lnTokens
			*&
			lcToken = TokenGet(pcTokens, pcDelimiter, lnToken)
			*&
			*& ----------------------------------------------
			*& Make it so that this isn't Case Sensitive...
			*& ----------------------------------------------
			*&
			IF UPPER(pcString) == UPPER(LEFT(lcToken, LEN(pcString)))
				*&
				*& --------------------------------
				*& Return the Found Token...
				*& --------------------------------
				*&
				RETURN lnToken
				*&
			ENDIF && UPPER(pcString) == UPPER(LEFT(lcToken, LEN(pcString)))
			*&
		ENDFOR && lnToken = 1 TO lnTokens
		*&
	ENDIF && llSuccess
	*&
	*& --------------------------------------------------------------
	*& The Token wasn't found if you make it to here...
	*& --------------------------------------------------------------
	*&
	RETURN 0
	*&
ENDFUNC && TokenFind(pcTokens, pcDelimiter, pcString)
*&
*& ***************************************************************
*& TokenSort(pcTokens, pcDelimiter)
*&
*& Quick, Simple, Cheap, and Dirty Token Set Sorting routine...
*& ***************************************************************
*&
FUNCTION TokenSort(pcTokens, pcDelimiter)
	*&
	*& -----------------------------------
	*& Initialize Local Variables...
	*& -----------------------------------
	*&
	LOCAL llSuccess, lcToken, lcTokens, lnToken, lnTokens
	*&
	STORE "" TO lcToken, lcTokens
	STORE 0 TO lnToken, lnTokens
	*&
	*& -----------------------------------
	*& Validate the Parameters...
	*& -----------------------------------
	*&
	llSuccess = VARTYPE(pcTokens) = "C" ;
		AND VARTYPE(pcDelimiter) = "C" ;
		AND LEN(pcDelimiter) > 0
	*&
	IF llSuccess
		*&
		*& ---------------------------------------------------
		*& Loop through each of the Tokens in the Source Set
		*& and Insert them into a New Sorted Set...
		*& ---------------------------------------------------
		*&
		lnTokens = TokenCount(pcTokens, pcDelimiter)
		*&
		FOR lnToken = 1 TO lnTokens
			*&
			lcToken = TokenGet(pcTokens, pcDelimiter, lnToken)
			*&
			lcTokens = TokenInsert(lcTokens, pcDelimiter, 0, lcToken)
			*&
		ENDFOR && lnToken = 1 TO lnTokens
		*&
	ENDIF && llSuccess
	*&
	RETURN lcTokens
	*&
ENDFUNC && TokenSort(pcTokens, pcDelimiter)
*&
*& ***************************************************************
*& TokenInsert(pcTokens, pcDelimiter, pnBefore, pcValue)
*&
*& Inserts one Token before another token...
*& 
*& Essentially this is an extension of the original functions...
*& first you take an input...  Then do a Get and then Append the
*& inserted value along with a new Delimiter in front of the 
*& original value...  Thos leaves a Put on that value to result
*& in the putting of Two Values...
*& ***************************************************************
*&
FUNCTION TokenInsert(pcTokens, pcDelimiter, pnToken, pcValue)
	*&
	*& ------------------------------------
	*& Initialize Local Variables...
	*& ------------------------------------
	*&
	LOCAL llSuccess, lcTokens, lnTokens, lnToken, lcToken
	*&
	STORE "" TO lcTokens, lcToken
	STORE 0 TO lnTokens, lnToken
	*&
	*& ------------------------------------
	*& Validate the Parameters...
	*& ------------------------------------
	*&
	llSuccess = VARTYPE(pcTokens) = "C" ;
		AND VARTYPE(pcDelimiter) = "C" ;
		AND LEN(pcDelimiter) > 0 ;
		AND VARTYPE(pnToken) = "N" ;
		AND pnToken >= 0 ;
		AND VARTYPE(pcValue) = "C"
	*&
	IF llSuccess
		*&
		*& --------------------------------------------
		*& Determine the current number of Tokens...
		*& --------------------------------------------
		*&
		lnTokens = TokenCount(pcTokens, pcDelimiter)
		*&
		DO CASE 
		CASE pnToken = 0
			*&
			*& -----------------------------------------------------------
			*& Ths is an elegant hack for Adding to Sorted Token Sets...
			*& -----------------------------------------------------------
			*& If inserting at Token 0 which technically doesn't exist, it
			*& appears as though you do not know where to insert which may
			*& imply a sorted list insertion...
			*& -----------------------------------------------------------
			*&
			FOR lnToken = 1 TO lnTokens
				*&
				*& ----------------------------------------------------------------
				*& Find a Token that compares as Greater Than, to insert with...
				*& ----------------------------------------------------------------
				*&
				lcToken = TokenGet(pcTokens, pcDelimiter, lnToken)
				*&
				IF lcToken > pcValue
					*&
					*& ---------------------------------------------
					*& This is where we want to do the insert...
					*& ---------------------------------------------
					*&
					lcToken = pcValue + pcDelimiter + lcToken
					*&
					lcTokens = TokenPut(pcTokens, pcDelimiter, lnToken, lcToken)
					*&
					EXIT
					*&
				ELSE 
					*&
					*& -----------------------------------------------------
					*& If this is the last one then it's now or never...
					*& -----------------------------------------------------
					*&
					IF lnToken = lnTokens
						*&
						*& --------------------------------------------------------------
						*& This is the last one so apparently pcValue goes last...
						*& --------------------------------------------------------------
						*& Note that at this point it's an explicit append operation...
						*& --------------------------------------------------------------
						*&
						lcTokens = TokenAdd(pcTokens, pcDelimiter, pcValue)
						*&
					ENDIF && lnToken = lnTokens
					*&
				ENDIF && lcToken > pcValue
				*&
			ENDFOR && lnToken = 1 TO lnTokens
			*&
		CASE BETWEEN(pnToken, 1, lnTokens)
			*&
			*& -----------------------------------------------------
			*& Standard Insert Before a Given Token...
			*& -----------------------------------------------------
			*& Get the Token of Interest...
			*& -----------------------------------------------------
			*& Then prepend the new token to it and put it back...
			*& -----------------------------------------------------
			*&
			lcToken = pcValue + pcDelimiter + TokenGet(pcTokens, pcDelimiter, pnToken)
			*&
			lcTokens = TokenPut(pcTokens, pcDelimiter, pnToken, lcToken)
			*&
		ENDCASE 
		*&
	ENDIF && llSuccess
	*&
	RETURN lcTokens
	*&
ENDFUNC && TokenInsert(pcTokens, pcDelimiter, pnBefore, pcValue)
*&
*& ***************************************************************
*& TokenDelete(pcTokens, pcDelimiter, pnToken)
*&
*& Deletes a given Token in the Tokenset and then it Returns the 
*& Resulting Tokenset...
*&
*& This is the Delete part of CRUD...
*& ***************************************************************
*&
FUNCTION TokenDelete(pcTokens, pcDelimiter, pnToken)
	*&
	*& ------------------------------------
	*& Initialize Local Variables...
	*& ------------------------------------
	*&
	LOCAL llSuccess, lcTokens, lnTokenCount, lnTokenHead, lnTokenTail
	*&
	STORE "" TO lcTokens
	STORE 0 TO lnTokenCount, lnTokenHead, lnTokenTail
	*&
	*& ------------------------------------
	*& Validate the Parameters...
	*& ------------------------------------
	*&
	llSuccess = VARTYPE(pcTokens) = "C" ;
		AND VARTYPE(pcDelimiter) = "C" ;
		AND LEN(pcDelimiter) > 0 ;
		AND VARTYPE(pnToken) = "N" ;
		AND pnToken > 0
	*&
	IF llSuccess
		*&
		*& --------------------------------------------------
		*& First determine the current number of tokens...
		*& --------------------------------------------------
		*&
		lnTokenCount = TokenCount(pcTokens, pcDelimiter)
		*&
		DO CASE 
		CASE lnTokenCount = 0 OR pnToken > lnTokenCount
			*&
			*& --------------------------------------------------------
			*& Can't delete something that isn't there...
			*& --------------------------------------------------------
			*& So the TokenSet doesn't change...
			*& --------------------------------------------------------
			*&
		CASE pnToken = 1
			*&
			*& ----------------------------------------
			*& This is the first Token...
			*& ----------------------------------------
			*&
			IF lnTokenCount = 1
				*&
				*& --------------------------------------------------------------
				*& This is the only Token so there is nothing left to return...
				*& --------------------------------------------------------------
				*&
				lcTokens = ""
				*&
			ELSE 
				*&
				*& ----------------------------------------------------------
				*& Determine the Parameters for the First Token...
				*& ----------------------------------------------------------
				*& Set the New Token Start...
				*& ----------------------------------------------------------
				*&
				lnTokenHead = AT(pcDelimiter, pcTokens) + LEN(pcDelimiter)
				*&
				*& ----------------------------------------------------------
				*& Just drop the beginning includng tbe First Delimiter...
				*& ----------------------------------------------------------
				*&
				lcTokens = SUBSTR(pcTokens, lnTokenHead)
				*&
			ENDIF && INLIST(lnTokenCount, 0, 1)
			*&
		CASE pnToken = lnTokenCount
			*&
			*& --------------------------------------------------
			*& This will be the Parameters for the Last Token...
			*& --------------------------------------------------
			*& Set the New TokenSet End to include removal of 
			*& it's preceding delimiter...
			*& --------------------------------------------------
			*&
			lnTokenTail = AT(pcDelimiter, pcTokens, pnToken - 1) - 1
			*&
			lcTokens = LEFT(pcTokens, lnTokenTail)
			*&
		OTHERWISE
			*&
			*& --------------------------------------------------
			*& This will be Parameters for a Middle Token...
			*& --------------------------------------------------
			*& Eliminate the preceeding delimiter and retain the
			*& following delimiter...
			*& --------------------------------------------------
			*&
			lnTokenHead = AT(pcDelimiter, pcTokens, pnToken - 1) - 1
			lnTokenTail = AT(pcDelimiter, pcTokens, pnToken) - 1
			*&
			lcTokens = LEFT(pcTokens, lnTokenHead) + SUBSTR(pcTokens, lnTokenTail)
			*&
		ENDCASE 
		*&
	ENDIF && llSuccess AND TokenCount(pcTokens, pcDelimiter) > 0
	*&
	RETURN lcTokens
	*&
ENDFUNC && TokenDelete(pcTokens, pcDelimiter, pnToken)
*&
*& ***************************************************************
*& TokenPut(pcTokens, pcDelimiter, pnToken, pcValue)
*&
*& Updates a given Token in the Tokenset by replacing it's value
*& with a new value and Returns the New Tokenset...
*&
*& This is the Update part of CRUD...
*& ***************************************************************
*&
FUNCTION TokenPut(pcTokens, pcDelimiter, pnToken, pcValue)
	*&
	*& -----------------------------------
	*& Initialize Local Variables...
	*& -----------------------------------
	*&
	LOCAL llSuccess, lcTokens, lnTokenCount, lnTokenHead, lnTokenTail
	*&
	STORE "" TO lcTokens
	STORE 0 TO lnTokenCount, lnTokenHead, lnTokenTail
	*&
	*& -----------------------------------
	*& Validate the Parameters...
	*& -----------------------------------
	*&
	llSuccess = VARTYPE(pcTokens) = "C" ;
		AND VARTYPE(pcDelimiter) = "C" ;
		AND LEN(pcDelimiter) > 0 ;
		AND VARTYPE(pnToken) = "N" ;
		AND pnToken > 0 ;
		AND VARTYPE(pcValue) = "C"
	*&
	IF llSuccess
		*&
		*& --------------------------------------------------
		*& First determine the current number of tokens...
		*& --------------------------------------------------
		*&
		lnTokenCount = TokenCount(pcTokens, pcDelimiter)
		*&
		DO CASE 
		CASE pnToken = 1
			*&
			*& ----------------------------------------
			*& This will be the first Token...
			*& ----------------------------------------
			*&
			IF lnTokenCount <= 1
				*&
				*& --------------------------------------------------
				*& This will be the only Token in the set...
				*& --------------------------------------------------
				*&
				lcTokens = pcValue
				*&
			ELSE 
				*&
				*& --------------------------------------------------
				*& Determine the Parameters for the First Token...
				*& --------------------------------------------------
				*& Note that the token starts at position 1...
				*& --------------------------------------------------
				*&
				lnTokenTail = AT(pcDelimiter, pcTokens) - 1
				*&
				lcTokens = pcValue + SUBSTR(pcTokens, lnTokenTail)
				*&
			ENDIF && lnTokenCount <= 1
			*&
		CASE pnToken > pnTokenCount
			*&
			*& --------------------------------------------------------
			*& Going Expando...
			*& --------------------------------------------------------
			*& First we will need to increase the number of Tokens in
			*& order to provide for the indicated slot...
			*& --------------------------------------------------------
			*&
			lcTokens = pcTokens + REPLICATE(pcDelimiter, pnToken - lnTokenCount) + pcValue
			*&
		CASE pnToken = lnTokenCount
			*&
			*& --------------------------------------------------
			*& This will be the Parameters for the Last Token...
			*& --------------------------------------------------
			*&
			lnTokenHead = AT(pcDelimiter, pcTokens, pnToken - 1) + LEN(pcDelimiter)
			lcTokens = LEFT(pcTokens, lnTokenHead) + pcValue
			*&
		OTHERWISE
			*&
			*& --------------------------------------------------
			*& This will be Parameters for a Middle Token...
			*& --------------------------------------------------
			*&
			lnTokenHead = AT(pcDelimiter, pcTokens, pnToken - 1) + LEN(pcDelimiter)
			lnTokenTail = AT(pcDelimiter, pcTokens, pnToken) - 1
			*&
			lcTokens = LEFT(pcTokens, lnTokenHead) + pcValue + SUBSTR(pcTokens, lnTokenTail)
			*&
		ENDCASE 
		*&
	ENDIF && llSuccess AND TokenCount(pcTokens, pcDelimiter) > 0
	*&
	RETURN lcTokens
	*&
ENDFUNC && TokenPut(pcTokens, pcDelimiter, pnToken, pcValue)
*&
*&
*& ***************************************************************
*& TokenGet(pcTokens, pcDelimiter, pnToken)
*&
*& Retrieves a specific Token from a Tokenset...
*&
*& This is the Read part of CRUD...
*& ***************************************************************
*&
FUNCTION TokenGet(pcTokens, pcDelimiter, pnToken)
	*&
	*& -----------------------------------
	*& Initialize Local Variables...
	*& -----------------------------------
	*&
	LOCAL llSuccess, lcToken, lnTokenCount, lnTokenStart, lnTokenLength
	*&
	STORE "" TO lcToken
	STORE 0 TO lnTokenCount, lnTokenStart, lnTokenLength
	*&
	*& -----------------------------------
	*& Validate the Parameters...
	*& -----------------------------------
	*&
	llSuccess = VARTYPE(pcTokens) = "C" ;
		AND VARTYPE(pcDelimiter) = "C" ;
		AND LEN(pcDelimiter) > 0 ;
		AND VARTYPE(pnToken) = "N" ;
		AND pnToken > 0
	*&
	IF llSuccess
		*&
		*& --------------------------------------------------
		*& First determine the current number of tokens...
		*& --------------------------------------------------
		*&
		lnTokenCount = TokenCount(pcTokens, pcDelimiter)
		*&
		DO CASE 
		CASE pnTokenCount = 0 OR pnToken > pnTokenCount
			*&
			*& ----------------------------------------
			*& Can't Read what isn't there...
			*& ----------------------------------------
			*&
		CASE pnToken = 1
			*&
			*& ----------------------------------------
			*& Looking for the first Token...
			*& ----------------------------------------
			*&
			IF lnTokenCount = 1
				*&
				*& ---------------------------------------
				*& This is the only Token in the set...
				*& ---------------------------------------
				*&
				lcToken = pcTokens
				*&
			ELSE 
				*&
				*& --------------------------------------------------
				*& Determine the Parameters for the First Token...
				*& --------------------------------------------------
				*&
				lnTokenStart = 1
				lnTokenLength = AT(pcDelimiter, pcTokens) - 1
				*&
				lcToken = SUBSTR(pcTokens, lnTokenStart, lnTokenLength)
				*&
			ENDIF && lnTokenCount = 0
			*&
		CASE pnToken = lnTokenCount
			*&
			*& --------------------------------------------------
			*& Looking for the Last Token...
			*& --------------------------------------------------
			*&
			lnTokenStart = AT(pcDelimiter, pcTokens, pnToken - 1) + LEN(pcDelimiter)
			*&
			lcToken = SUBSTR(pcTokens, lnTokenStart)
			*&
		OTHERWISE && Token is Middle...
			*&
			*& --------------------------------------------------
			*& This will be Parameters for a Middle Token...
			*& --------------------------------------------------
			*&
			lnTokenStart = AT(pcDelimiter, pcTokens, pnToken - 1) + LEN(pcDelimiter)
			lnTokenLength = AT(pcDelimiter, pcTokens, pnToken) - lnTokenStart
			*&
			lcToken = SUBSTR(pcTokens, lnTokenStart, lnTokenLength)
			*&
		ENDCASE 
		*&
	ENDIF && llSuccess AND TokenCount(pcTokens, pcDelimiter) > 0
	*&
	RETURN lcToken
	*&
ENDFUNC && TokenGet(pcTokens, pcDelimiter, pnToken)
*&
*& ***************************************************************
*& TokenAdd(pcTokens, pcDelimiter, pcToken)
*&
*& Appends a new Token to the end of a Tokenset...
*&
*& This is the Create part of CRUD...
*& ***************************************************************
*&
FUNCTION TokenAdd(pcTokens, pcDelimiter, pcToken, plSorted)
	*&
	*& --------------------------------
	*& Initialize Local Variables...
	*& --------------------------------
	*&
	LOCAL llSuccess, lcTokens
	*&
	STORE "" TO lcTokens
	*&
	*& --------------------------------
	*& Validate the Parameters...
	*& --------------------------------
	*&
	llSuccess = VARTYPE(pcTokens) = "C" ;
		AND VARTYPE(pcDelimiter) = "C" ;
		AND LEN(pcDelimiter) > 0 ;
		AND VARTYPE(pcToken) = "C"
	*&
	IF llSuccess
		*&
		IF LEN(pcTokens = 0)
			*&
			*& ------------------------------------------------------
			*& This will be the only Token in the Set...
			*& ------------------------------------------------------
			*&
			lcTokens = pcToken
			*&
		ELSE
			*&
			*& ------------------------------------------------------
			*& We simply add 1 Delimiter and the New Token Value to
			*& the end of the TokenSet...
			*& ------------------------------------------------------
			*&
			IF  plSorted
				*&
				*& -----------------------------------------------------
				*& Special hack for Sorted Token Sets...
				*& -----------------------------------------------------
				*& This is indicated by the position of the insertion 
				*& point being before 0...  
				*& -----------------------------------------------------
				*& The first token is 1...
				*& -----------------------------------------------------
				*&
				lcTokens = TokenInsert(pcTokens, pcDelimiter, 0, pcToken)
				*&
			ELSE 
				*&
				*& -----------------------------------------------------
				*& Standard Append...
				*& -----------------------------------------------------
				*&
				lcTokens = pcTokens + pcDelimiter + pcToken
				*&
			ENDIF && plSorted
			*&
		ENDIF && LEN(pcTokens > 0)
		*&
	ENDIF && llSuccess
	*&
	RETURN lcTokens
	*&
ENDFUNC && TokenAdd(pcTokens, pcDelimiter, pcToken, plSorted)
*&
*& ***************************************************************
*& TokenCount(pcTokens, pcDelimiter)
*&
*& Returns a count of the number of Tokens in a Tokenset...
*& ***************************************************************
*&
FUNCTION TokenCount(pcTokens, pcDelimiter)
	*&
	*& ------------------------------------
	*& Initialize Local Variables...
	*& ------------------------------------
	*&
	LOCAL llSuccess, lnTokens
	*&
	STORE 0 TO lnTokens
	*&
	*& ------------------------------------
	*& Validate the Parameters...
	*& ------------------------------------
	*&
	llSuccess = VARTYPE(pcTokens) = "C" ;
		and VARTYPE(pcDelimiter) = "C" ;
		and LEN(pcDelimiter) > 0
	*&
	*& --------------------------------------
	*& If the Length is 0 the count is 0...
	*& --------------------------------------
	*&
	IF llSuccess AND LEN(pcTokens) > 0
		*&
		*& ----------------------------------------
		*& Return the number of Delimiters + 1...
		*& ----------------------------------------
		*&
		lnTokens = OCCURS(pcDelimiter, pcTokens) + 1
		*&
	ENDIF && llSuccess AND LEN(pcTokens) > 0
	*&
	RETURN lnTokens
	*&
ENDFUNC && TokenCount(pcTokens, pcDelimiter)
*&
*& ***************************************************************
*& XBitRShift(pvBits, pnPlaces)
*&
*& Effectively this is a divide by 2 for as many digits to be
*& shifted to the right...  This is accomplishe by removing how
*& many digits from the right as they slide off, and then replace
*& the same number of digits to the left...
*& ***************************************************************
*&
FUNCTION XBitRShift(pvBits, pnPlaces)
	*&
	LOCAL lcBits, lnBits
	*&
	STORE "" TO lcBits
	STORE 0 TO lnBits
	*&
	DO CASE 
	CASE VARTYPE(pvBits) = "C"
		*&
		*&
		lcBits = pvBits
		*&
	CASE VARTYPE(pvBits) = "N"
		*&
		*&
		lcBits = Dec2Base(pvBits, 2)
		*&
	ENDCASE 
	*&
	lnBits = LEN(lcBits)
	*&
	lcBits = REPLICATE("0", pnPlaces) + SUBSTR(lcBits, 1, lnBits - pnPlaces)
	*&
	RETURN lcBits
	*&
ENDFUNC && XBitRShift(pvBits, pnPlaces)
*&
*& ***************************************************************
*& XBitLShift(pvBits, pnPlaces)
*&
*& Effectively this is a Multiply by 2 for as many digits to be
*& shifted to the left...  This is accomplishe by simply adding as
*& many 0's on the right pushing everything else to the left, and 
*& then replace the same number of digits to the left...
*& ***************************************************************
*&
FUNCTION XBitLShift(pvBits, pnPlaces)
	*&
	LOCAL lcBits
	*&
	STORE "" TO lcBits
	*&
	DO CASE 
	CASE VARTYPE(pvBits) = "C"
		*&
		*&
		lcBits = pvBits
		*&
	CASE VARTYPE(pvBits) = "N"
		*&
		*&
		lcBits = Dec2Base(pvBits, 2)
		*&
	ENDCASE 
	*&
	*&
	lcBits = lcBits + REPLICATE("0", pnPlaces)
	*&
	RETURN lcBits
	*&
ENDFUNC && XBitLShift(pvBits, pnPlaces)
*&
*& ***************************************************************
*& XBitXor(pvBits1, pvBits2)
*&
*& Compare the bits so that the resulting bit will be set if only
*& 1 instance of the other two are set, but not both...
*& ***************************************************************
*&
FUNCTION XBitXor(pvBits1, pvBits2)
	*&
	LOCAL lcBits1, lcBits2, lcBit1, lcBit2, lcOutBits, lnBits1, lnBits2, lnBit
	*&
	STORE "" TO lcBits1, lcBits2, lcBit1, lcBit2, lcOutBits
	STORE 0 TO lnBits1, lnBits2, lnBit
	*&
	DO CASE 
	CASE VARTYPE(pvBits1) = "C"
		*&
		*&
		lcBits1 = pvBits1
		*&
	CASE VARTYPE(pvBits1) = "N"
		*&
		*&
		lcBits1 = Dec2Base(pvBits1, 2)
		*&
	ENDCASE 
	*&
	DO CASE 
	CASE VARTYPE(pvBits2) = "C"
		*&
		*&
		lcBits2 = pvBits2
		*&
	CASE VARTYPE(pvBits2) = "N"
		*&
		*&
		lcBits2 = Dec2Base(pvBits2, 2)
		*&
	ENDCASE 
	*&
	lnBits1 = LEN(lcBits1)
	lnBits2 = LEN(lcBits2)
	*&
	lcBits1 = PADL(lcBits1, MAX(lnBits1, lnBits2), "0")
	lcBits2 = PADL(lcBits2, MAX(lnBits1, lnBits2), "0")
	*&
	lnBits1 = LEN(lcBits1)
	*&
	FOR lnBit = 1 TO lnBits1
		*&
		lcBit1 = CharNum(lcBits1, lnBit)
		lcBit2 = CharNum(lcBits2, lnBit)
		*&
		lcOutBits = lcOutBits + IIF(INLIST(lcBit1 + lcBit2, "01", "10"), "1", "0")
		*&
	ENDFOR && lnBit = 1 TO lnBits
	*&
	RETURN lcOutBits
	*&
ENDFUNC && XBitXor(pvBits1, pvBits2)
*&
*& *****************************************************************
*& XBitOr(pvBits1, pvBits2)
*&
*& Compare the bits so that the resulting bit will be set if either
*& of the compared bits are set...
*& *****************************************************************
*&
FUNCTION XBitOr(pvBits1, pvBits2)
	*&
	LOCAL lcBits1, lcBits2, lcBit1, lcBit2, lcOutBits, lnBits1, lnBits2, lnBit
	*&
	STORE "" TO lcBits1, lcBits2, lcBit1, lcBit2, lcOutBits
	STORE 0 TO lnBits1, lnBits2, lnBit
	*&
	DO CASE 
	CASE VARTYPE(pvBits1) = "C"
		*&
		*&
		lcBits1 = pvBits1
		*&
	CASE VARTYPE(pvBits1) = "N"
		*&
		*&
		lcBits1 = Dec2Base(pvBits1, 2)
		*&
	ENDCASE 
	*&
	DO CASE 
	CASE VARTYPE(pvBits2) = "C"
		*&
		*&
		lcBits2 = pvBits2
		*&
	CASE VARTYPE(pvBits2) = "N"
		*&
		*&
		lcBits2 = Dec2Base(pvBits2, 2)
		*&
	ENDCASE 
	*&
	lnBits1 = LEN(lcBits1)
	lnBits2 = LEN(lcBits2)
	*&
	lcBits1 = PADL(lcBits1, MAX(lnBits1, lnBits2), "0")
	lcBits2 = PADL(lcBits2, MAX(lnBits1, lnBits2), "0")
	*&
	lnBits1 = LEN(lcBits1)
	*&
	FOR lnBit = 1 TO lnBits1
		*&
		lcBit1 = CharNum(lcBits1, lnBit)
		lcBit2 = CharNum(lcBits2, lnBit)
		*&
		lcOutBits = lcOutBits + IIF(INLIST("1", lcBit1, lcBit2), "1", "0")
		*&
	ENDFOR && lnBit = 1 TO lnBits
	*&
	RETURN lcOutBits
	*&
ENDFUNC && XBitOr(pvBits1, pvBits2)
*&
*& *****************************************************************
*& XBitAnd(pvBits1, pvBits2)
*&
*& Compare the bits so that the resulting bit will be set if both
*& of the compared bits are the same value...
*& *****************************************************************
*&
FUNCTION XBitAnd(pvBits1, pvBits2)
	*&
	LOCAL lcBits1, lcBits2, lcBit1, lcBit2, lcOutBits, lnBits1, lnBits2, lnBit
	*&
	STORE "" TO lcBits1, lcBits2, lcBit1, lcBit2, lcOutBits
	STORE 0 TO lnBits1, lnBits2, lnBit
	*&
	DO CASE 
	CASE VARTYPE(pvBits1) = "C"
		*&
		*&
		lcBits1 = pvBits1
		*&
	CASE VARTYPE(pvBits1) = "N"
		*&
		*&
		lcBits1 = Dec2Base(pvBits1, 2)
		*&
	ENDCASE 
	*&
	DO CASE 
	CASE VARTYPE(pvBits2) = "C"
		*&
		*&
		lcBits2 = pvBits2
		*&
	CASE VARTYPE(pvBits2) = "N"
		*&
		*&
		lcBits2 = Dec2Base(pvBits2, 2)
		*&
	ENDCASE 
	*&
	lnBits1 = LEN(lcBits1)
	lnBits2 = LEN(lcBits2)
	*&
	lcBits1 = PADL(lcBits1, MAX(lnBits1, lnBits2), "0")
	lcBits2 = PADL(lcBits2, MAX(lnBits1, lnBits2), "0")
	*&
	lnBits1 = LEN(lcBits1)
	*&
	FOR lnBit = 1 TO lnBits1
		*&
		lcBit1 = CharNum(lcBits1, lnBit)
		lcBit2 = CharNum(lcBits2, lnBit)
		*&
		lcOutBits = lcOutBits + IIF(lcBit1 = lcBit2, "1", "0")
		*&
	ENDFOR && lnBit = 1 TO lnBits
	*&
	RETURN lcOutBits
	*&
ENDFUNC && XBitAnd(pvBits1, pvBits2)
*&
*& *****************************************************************
*& XBitNot(pvBits)
*&
*& Swap the State for all bits to be of the inverse state...
*& *****************************************************************
*&
FUNCTION XBitNot(pvBits)
	*&
*	SET STEP ON 
	LOCAL lcBits, lcOutBits, lnBits, lnBit
	*&
	STORE "" TO lcBits, lcOutBits
	STORE 0 TO lnBits, lnBit
	*&
	DO CASE 
	CASE VARTYPE(pvBits) = "C"
		*&
		*&
		lcBits = pvBits
		*&
	CASE VARTYPE(pvBits) = "N"
		*&
		*&
		lcBits = Dec2Base(pvBits, 2)
		*&
	ENDCASE 
	*&
	lnBits = LEN(lcBits)
	*&
	FOR lnBit = 1 TO lnBits
		*&
		lcOutBits = lcOutBits + IIF(CharNum(lcBits, lnBit) = "1", "0", "1")
		*&
	ENDFOR && lnBit = 1 TO lnBits
	*&
	RETURN lcOutBits
	*&
ENDFUNC && XBitNot(pvBits)
*&
*& *****************************************************************
*& XBitClear(pvBits, pnBit)
*&
*& Clear a particular bit so that it is no longer set...
*& *****************************************************************
*&
FUNCTION XBitClear(pvBits, pnBit)
	*&
	LOCAL lcBits, lnBits, lcMask
	*&
	STORE "" TO lcBits, lcMask
	STORE 0 TO lnBits
	*&
	DO CASE 
	CASE VARTYPE(pvBits) = "C"
		*&
		*&
		lcBits = pvBits
		*&
	CASE VARTYPE(pvBits) = "N"
		*&
		*&
		lcBits = Dec2Base(pvBits, 2)
		*&
	ENDCASE 
	*&
	*& ---------------------------------------------
	*& First check to see if it's actually set... 
	*& ---------------------------------------------
	*&
	IF XBitTest(lcBits, pnBit)
		*&
		*& ----------------------------------
		*& Only clear if it's already set...
		*& ----------------------------------
		*&
		lcBits = XBitXor(lcBits, XBitLShift("1", pnBit))
		*&
	ENDIF && XBitTest(lcBits, pnBit)
	*&
*!*		lnBits = LEN(lcBits)
*!*		lcMask = XBitXor(REPLICATE("1", lnBits), XBitLShift("1", pnBit))
*!*		lcBits = XBitAnd(lcBits, lcMask)
	*&
	*& --------------------------------------------------------
	*& So as long as we know it's set and want it cleared we
	*& can simply do it with an XOR...
	*& --------------------------------------------------------
	*&
	*& lcBits = XBitXor(lcBits, XBitLShift("1", pnBit))
	*&
	RETURN lcBits
	*&
ENDFUNC && XBitClear(pvBits, pnBit)
*&
*& *****************************************************************
*& XBitSet(pvBits, pnBit)
*&
*& Set a particular bit...
*& *****************************************************************
*&
FUNCTION XBitSet(pvBits, pnBit)
	*&
	LOCAL lcBits, lnBits
	*&
	STORE 0 TO lnBits
	*&
	DO CASE 
	CASE VARTYPE(pvBits) = "C"
		*&
		*&
		lcBits = pvBits
		*&
	CASE VARTYPE(pvBits) = "N"
		*&
		*&
		lcBits = Dec2Base(pvBits, 2)
		*&
	ENDCASE 
	*&
	lnBits = LEN(lcBits)
	*&
	*& ------------------------------------------------------
	*& We'll go with the Stuff Function for now however
	*& when the other functions are done, then this should
	*& be changed ib order to reflect the proper method...
	*& ------------------------------------------------------
	*&
	lcBits = XBitOr(lcBits, XBitLShift("1", pnBit))
	*&
	RETURN lcBits
	*&
ENDFUNC && XBitSet(pvBits, pnBit)
*&
*& *****************************************************************
*& XBitTest(pvBits, pnBit)
*&
*& Test a particular bit to determine if it's set or not...
*& *****************************************************************
*&
FUNCTION XBitTest(pvBits, pnBit)
	*&
	LOCAL llSuccess, llTest, lcBits, lnBits
	*&
	STORE "" TO lcBits
	*&
	llSuccess = INLIST(VARTYPE(pvBits),"C","N") ;
		AND VARTYPE(pnBit) = "N"
	*&
	IF llSuccess
		*&
		DO CASE 
		CASE VARTYPE(pvBits) = "C"
			*&
			lcBits = pvBits
			*&
		CASE VARTYPE(pvBits) = "N"
			*&
			*& ---------------------------------------------------
			*& Allow use of a standard number by just converting
			*& it into a Bit String...
			*& ---------------------------------------------------
			*&
			lcBits = Dec2Base(pvBits, 2)
			*&
		ENDCASE 
		*&
		lnBits = LEN(lcBits)
		*&
		*& -----------------------------------------------
		*& Extract the bit and test it...
		*& -----------------------------------------------
		*&
		llTest = (CharNum(lcBits, lnBits - pnBit) == "1")
		*&
		*& -------------------------------------------------------
		*& Another more novel and perhaps more practical method
		*& mathmatically would be as such...
		*& -------------------------------------------------------
		*&
		*& lcBit = XBitLShift(1, pnBits)
		*& lcBit = XBitAnd(lcBits, lcBit)
		*& llTest = CHRTRAN(XBitRShift(lcBit, pnBits), "0", "") = "1"
		*&
	ENDIF && llSuccess
	*&
	RETURN llTest
	*&
ENDFUNC && XBitTest(pcBits, pnBit)
*&
*& *****************************************************************
*& XBitCount(pvBits)
*&
*& Count the number of bits represented by the value...
*& *****************************************************************
*&
FUNCTION XBitCount(pvBits)
	*&
	LOCAL lnBits
	*&
	lnBits = 0
	*&
	DO CASE 
	CASE VARTYPE(pvBits) = "C"
		*&
		lnBits = LEN(pvBits)
		*&
	CASE VARTYPE(pvBits) = "N"
		*&
		lnBits = LEN(Dec2Base(pvBits, 2))
		*&
	ENDCASE 
	*&
	RETURN lnBits
	*&
ENDFUNC && XBitCount(pvBits)
*&
*& *****************************************************************
*& Base2Base(pcValue, pnBase1, pnBase2)
*&
*& Convert a value from one base numbering system to another.  
*& Works with any Number Base from 2 to 36...
*& *****************************************************************
*&
FUNCTION Base2Base(pcValue, pnBase1, pnBase2)
	*&
	LOCAL lnValue
	*&
	lnValue = Base2Dec(pcValue, pnBase1)
	RETURN Dec2Base(lnValue, pnBase2)
	*&
ENDFUNC && Base2Base(pcValue, pnBase1, pnBase2)
*&
*& *****************************************************************
*& Dec2Base(pnValue, pnBase)
*&
*& Convert a Decimal Value to another Base Numbering system...
*& Works with any Number Base from 2 to 36...
*& *****************************************************************
*&
FUNCTION Dec2Base(pnValue, pnBase)
	*&
	LOCAL lcOutput, lcScheme, lnDiv, lnRem
	*&
	STORE "" TO lcOutput
	*&
	lcScheme = GetBaseScheme(pnBase)
	*&
	lnDiv = pnValue
	*&
	DO WHILE FLOOR(lnDiv) > 0
		*&
		lnRem = lnDiv % pnBase
		lnDiv = FLOOR(lnDiv / pnBase)
		*&
		lcOutput = CharNum(lcScheme, lnRem + 1) + lcOutput
		*&
	ENDDO && WHILE FLOOR(lnDiv) > 0
	*&
	RETURN IIF(LEN(lcOutput) > 0, lcOutput, "0")
	*&
ENDFUNC && Dec2Base(pnValue, pnBase)
*&
*& *****************************************************************
*& Base2Dec(pcValue, pnBase)
*&
*& Convert any Base Numbering System to Decimal Values...
*& Works with any Number Base from 2 to 36...
*& *****************************************************************
*&
FUNCTION Base2Dec(pcValue, pnBase)
	*&
	LOCAL lnCol, lnCols, lnValue, lnColValue, lcScheme
	*&
	STORE 0 TO lnCol, lnValue, lnColValue
	*&
	lcScheme = GetBaseScheme(pnBase)
	lnCols = LEN(pcValue)
	*&
	FOR lnCol = 1 TO lnCols
		*&
		lnColValue = Charat(CharNum(UPPER(pcValue), lnCol), lcScheme) - 1
		lnValue = lnValue + (lnColValue * (pnBase ^ (lnCols - lnCol)))
		*&
	ENDFOR && lnCol = 1 TO lnCols
	*&
	RETURN INT(lnValue)
	*&
ENDFUNC && Base2Dec(pcValue, pnBase)
*&
*&
*& *************************************************************************
*& RelicEncode(pcString, pcKey, pnFlags)
*& *************************************************************************
*&
FUNCTION RelicEncode(pcString, pcKey, pnFlags, pnCipherSize)
	*&
	*& --------------------------------------------------
	*& We need to setup a mapping for the flags...
	*& --------------------------------------------------
	*& Level Zero (0) is flags = 0 or Non Numeric...
	*& --------------------------------------------------
	*& There are actually two sets of Flags...
	*& 00011 - Defines Level 0-3...  Here Levels 1 and 
	*&         are the main things that apply...
	*& 11100 - Defines the number of Chars to establish
	*&         Cipher Permutation Selection...
	*&
	*& Then if Level 2 there is another Byte that defines
	*& the next 5 bits...
	*&
	*& 00111 - Defines the Time Shift Factor...
	*& 11000 - Unused Reserved Bits...
	*& --------------------------------------------------
	*&
	*& --------------------------------
	*& Initialize Local Variables...
	*& --------------------------------
	*&
	LOCAL llSuccess, lcKey, lnSeed, lcHeader, lcAlphabet, lcCipher, lcMessage, lcOutput, ;
		lcCheckSum, lnLength, lnCharIn, lnCharOut, lcCharIn, lcCharOut, lnCipherSize, ;
		lnLevel, lnCipherBase, lnTimeWarp, lnYear, lnMonth, lnWeek, lnDay
	*&
	STORE 0 TO lnSeed, lnLength, lnCharIn, lnCharOut, lnLevel, lnCipherBase, lnTimeWarp, ;
		lnYear, lnMonth, lnWeek, lnDay
	*&
	STORE "" TO lcKey, lcAlphabet, lcCipher, lcMessage, lcOutput, lcCharIn, lcCharOut, lcHeader, ;
		lcCheckSum
	*&
	*& ------------------------------------------------------------
	*& Test to see if there is an override for the Cipher Size...
	*& The Default is 36...
	*& ------------------------------------------------------------
	*&
	lnCipherSize = 36
	*&
	IF VARTYPE(pnCipherSize) = "N" AND pnCipherSize > 0
		*&
		*& --------------------------------------------------------
		*& This is primarily to support a Cipherbet and Alphabet
		*& that is compatible with Base64 Encoding and even the
		*& Full ASCII Characterset...  Expected values are 36, 64,
		*& and 256...  36 is the Default...
		*& --------------------------------------------------------
		*&
		IF INLIST(pnCipherSize, 36, 64, 256)
			*&
			*& ------------------------------------
			*& Set the Override...
			*& ------------------------------------
			*&
			lnCipherSize = pnCipherSize
			*&
		ELSE
			*&
			*& ----------------------------------------------------
			*& This is a failure...  36, 64, and 256 are the only
			*& valid values for this parameter...
			*& ----------------------------------------------------
			*&
			RETURN ""
			*&
		ENDIF && INLIST(pnCipherSize, 36, 64, 256)
		*&
	ENDIF && VARTYPE(pnCipherSize) = "N" AND pnCipherSize > 0
	*&
	*& --------------------------------------------
	*& Initialize the Cipher Seed...
	*& --------------------------------------------
	*&
	DO CASE
	CASE VARTYPE(pcKey) = "C"
		*&
		*& -----------------------------------------------------
		*& Strip out the dashes if this is a Serial Number...
		*& -----------------------------------------------------
		*&
		lcKey = UPPER(StripChar(pcKey, "-"))
		*&
		*& --------------------------------------------------------
		*& Check to see if the Key is actually a Serial Number...
		*& --------------------------------------------------------
		*&
		IF LEN(lcKey) = 16 AND LEN(CHRTRAN(lcKey, GetBaseScheme(16), "")) = 0 ;
				AND Checksum(LEFT(lcKey, 12), 16, 16) == RIGHT(lcKey, 4)
			*&
			*& -----------------------------------
			*& Just XOR the two halves...
			*& -----------------------------------
			*&
			lnSeed = BITXOR(INT(VAL("0x" + LEFT(lcKey, 8))), INT(VAL("0x" + RIGHT(lcKey, 8))))
			*&
		ELSE 
			*&
			*& --------------------------------------------------
			*& Take whatever it is and simply convert it into
			*& a 32 bit number as is...
			*& --------------------------------------------------
			*&
			lnSeed = CheckSum(pcKey)
			*&
		ENDIF && LEN(lcKey) = 16 AND LEN(CHRTRAN(lcKey, GetBaseScheme(16), "")) = 0...
		*&
	CASE VARTYPE(pcKey) = "N"
		*&
		*& --------------------------------------------------------
		*& Obviously a Preconceived Seed Value, just use as is...
		*& --------------------------------------------------------
		*&
		lnSeed = pcKey
		*&
	OTHERWISE 
		*&
		*& -----------------------------------
		*& These are not valid paramerers...
		*& -----------------------------------
		*&
		RETURN ""
		*&
	ENDCASE 
	*&
	*& --------------------------------------------
	*& Initialize the Alphabet and Cipherbet...
	*& --------------------------------------------
	*&
	lcAlphabet = GetBaseScheme(lnCipherSize)
	lcCipher = Scramble(lcAlphabet, lnSeed)
	*&
	*& --------------------------------------------
	*& Encode the message from 8 bit characters to 
	*& 5 bit characters...  
	*& --------------------------------------------
	*& This may need to be moved outside as an 
	*& Implementation Detail...  This is for any
	*& consideration of using a variable cipher
	*& size option to include 64, 128, and 256 size
	*& Ciphers...
	*& --------------------------------------------
	*&
	IF VARTYPE(pnCipherSize) <> "N"
		*&
		*& --------------------------------------------------------
		*& If using the default make sure that the message fits the 
		*& Alphabet...
		*& --------------------------------------------------------
		*& Note that this would probably not be used with
		*& Level 0 Encoding which would typically use Base256...
		*& --------------------------------------------------------
		*& Level 0 was reserved for Zero Header and Zero Extra than
		*& the restricted amount of storage space that would have
		*& already been allocated...
		*& --------------------------------------------------------
		*&
		lcMessage = Base32Encode(pcString)
		*&
	ELSE
		*&
		*& ---------------------------------------------------
		*& Assume the Message has been pre-prepared...
		*& ---------------------------------------------------
		*&
		lcMessage = pcString
		*&
	ENDIF && VARTYPE(pnCipherSize) <> "N"
	*&
	*& --------------------------------------------------------
	*& Level 0 has no header...  This is for Level 1 Encoding 
	*& and above...  
	*& --------------------------------------------------------
	*& Typically Level 0 is reserved for fixed or restricted 
	*& allocation environments...  Typically this would most 
	*& likely be using the Base256 Encoding for Field Level and 
	*& Block Level Encoding...
	*& --------------------------------------------------------
	*& Level 0 won't go into this condition...
	*& --------------------------------------------------------
	*&
	IF VARTYPE(pnFlags) = "N" AND pnFlags > 0
		*&
		*& -------------------------------------------------------------
		*& This is for applying a Header which means Level 1 or above...
		*& -------------------------------------------------------------
		*& So the 2 Least Significant Bits represent the level...
		*& 00000011 will be mapped to 00011 in a 5 bit unit...
		*& -------------------------------------------------------------
		*& Level 0 has no header...
		*&
		*& 00 + 1 = Level 1 Cipher Permutations...
		*& 01 + 1 = Level 2 Time Mutation and Checksum...
		*& 10 + 1 = Level 3 Not Yet Defined...
		*& 11 + 1 = Level 4 Not Yet Defined...
		*&
		*& The next 3 bits represent the number of Chars to be added to
		*& the header for spinning up the cipher permutations...
		*& 3 bits represent 0-7 chars...
		*&
		*& 00011100 will be mapped to 11100 in a 5 bit unit...
		*&
		*& -------------------------------------------------------------
		*& Then if used, the Time Mutation Option would be as such...
		*& -------------------------------------------------------------
		*& 11100000 will be mapped to a 00111 5 bit unit...  This would
		*& represent the Level 2 bits after the Level 1 Header...
		*& -------------------------------------------------------------
		*&
		*& -------------------------------------------
		*& Build up the Message Header...
		*& -------------------------------------------
		*& So if we're doing base36, then the 5 least
		*& significant bits are the first byte in the
		*& header...  Then  the 3 bits on the left are
		*& used to define the number of characters 
		*& that will follow...
		*& -------------------------------------------
		*&
		*& ----------------------------------------
		*& Define the first 5 bits to extract the
		*& Header Information from the Flags...
		*& ----------------------------------------
		*&
		*& ----------------------------------------------------
		*& Add the Header Byte 1 to the Message Header...
		*& ----------------------------------------------------
		*& Extract those 5 bits from the Flags...
		*&
		*& 00011 - Level Indicator
		*& 00 - Level 1 Cipher Mutation Groups
		*& 01 - Level 2 Time Mutation Enabled
		*& 10 - Level 3 Not Defined
		*& 11 - Level 4 Not Defined
		*&
		*& 11100 - Cipher Mutation Group Base
		*& 000 - None (1 Cipher per message)
		*& 001 - 1 Char (36 Ciphers per message)
		*& 010 - 2 Chars (1,296 Ciphers per Message)
		*& 011 - 3 Chars (46,656 Ciphers per Message)
		*& 100 - 4 Chars (1,679,616 Ciphers per Message)
		*& 101 - 5 Chars (60,466,176 Ciphers per Message)
		*& 110 - 6 Chars (2,176,782,336 Ciphers per Message)
		*& 111 - 7 Chars (78,364,164,096 Ciphers per Message)
		*& ----------------------------------------------------
		*&
		lnCharIn = BITAND(pnFlags, 2^5-1)
		*&
		lcHeader = CharNum(lcAlphabet, lnCharIn)
		*&
		*& -------------------------------------------
		*& Determine the Encoding Level Settings...
		*& -------------------------------------------
		*& Level 1 defines Cipher Permutations...
		*& -------------------------------------------
		*&
		lnLevel = BITAND(lnCharIn, 2^2-1) + 1
		lnCipherBase = BITAND(BITRSHIFT(lnCharIn, 2), 2^3-1)
		*&
		IF lnCipherBase > 0
			*&
			*& ------------------------------------------------
			*& We need this to be zero the first time in since
			*& it's additive...
			*& ------------------------------------------------
			*&
			lnCharIn = 0
			*&
			FOR lnCharOut = 1 TO lnCipherBase
				*&
				*& --------------------------------------------
				*& Add this number of chars to the header...
				*& --------------------------------------------
				*& These just have to be selected on a purely 
				*& random basis...
				*& --------------------------------------------
				*&
				lnCharIn = MOD(XRand((lnSeed + lnCharIn) * -1), lnCipherSize) + 1
				lcHeader = lcHeader + CharNum(lcAlphabet, lnCharIn)
				*&
			ENDFOR && lnCharOut = 1 TO lnCipherBase
			*&
		ENDIF && lnCipherBase > 0
		*&
		*& -----------------------------------------------
		*& This is where we check to see if we're using
		*& a Time Modification on the Mutation Factor...
		*& -----------------------------------------------
		*& In other words the Cipher is going to Die...
		*& -----------------------------------------------
		*&
		IF lnLevel > 1
			*&
			*& -----------------------------------------------------
			*& This calls for an additional Byte being added to
			*& the header in order to define the Time Factor that
			*& has been selected...
			*& -----------------------------------------------------
			*& 00111 - Time Interval 0-7 
			*& 000 (0) - None
			*& 001 (1) - Minutes
			*& 010 (2) - Hours
			*& 011 (3) - Days
			*& 100 (4) - Weeks
			*& 101 (5) - Months
			*& 110 (6) - Quarters
			*& 111 (7) - Years
			*&
			*& 11000 - Reserved Bits Remaining...
			*& 
			*& -----------------------------------------------------
			*&
			lnCharIn = BITAND(BITRSHIFT(pnFlags, 5), 2^5-1)
			*&
			lcHeader = lcHeader + CharNum(lcAlphabet, lnCharIn)
			*&
			lnTimeWarp = BITAND(lnCharIn, 2^3-1)
			*&
			lcCheckSum = CheckSum(lcMessage, 16, 16)
			*&
			lcMessage = lcMessage + lcCheckSum
			*&
		ENDIF && lnLevel > 1
		*&
		*& --------------------------------------------------------
		*& Prepend the Message with the Message Header...
		*& --------------------------------------------------------
		*&
		lcMessage = lcHeader + lcMessage
		*&
	ENDIF && VARTYPE(pnFlags) = "N" AND pnFlags > 0
	*&
	*& -----------------------------------------------
	*& Get the length to represent the padding...
	*& -----------------------------------------------
	*&
	lnLength = LEN(lcMessage)
	*&
	*& ----------------------------------------------
	*& Pad with X characters to be equal blocks of
	*& 5 character blocks...  Base 32 only goes up
	*& to V so X is an obvious and convenient padding 
	*& character to use for this purpose...
	*& ----------------------------------------------
	*& If using the default where forcing the message
	*& through the Base32 Filter...  This allows for
	*& support for expanded capabilities...
	*& ----------------------------------------------
	*& The other main scenarios are supporting the
	*& Encryption of Base64 and Base256 sets...
	*& ----------------------------------------------
	*&
	IF VARTYPE(pnCipherSize) <> "N" AND MOD(lnLength, 5) > 0
		*&
		*& -----------------------------------------------
		*& Add enough X's in order to make it an equally
		*& divisible by 5...  We want 5 digit code groups
		*& when we're done...
		*& -----------------------------------------------
		*&
		lcMessage = lcMessage + REPLICATE("X", 5 - MOD(lnLength, 5))
		*&
		*& -----------------------------------------------
		*& Update the length to represent the padding...
		*& -----------------------------------------------
		*&
		lnLength = LEN(lcMessage)
		*&
	ENDIF && VARTYPE(pnCipherSize) <> "N" AND MOD(lnLength, 5) > 0
	*&
	*& -----------------------------
	*& Scan the Message...
	*& -----------------------------
	*&
	FOR lnCharIn = 1 TO lnLength
		*&
		*& ----------------------------------------
		*& Fetch this char from the message...
		*& ----------------------------------------
		*&
		lcCharIn = CharNum(lcMessage, lnCharIn)
		*&
		*& ----------------------------------------
		*& Locate this character in the Alphabet...
		*& ----------------------------------------
		*& This value will also provide for the
		*& mutation of the cipher by this char...
		*& ----------------------------------------
		*&
		lnCharOut = CharAt(lcCharIn, lcAlphabet)
		*&
		*& ------------------------------
		*& Check for Header Mods...
		*& ------------------------------
		*&
		IF lnLevel > 1 AND lnTimeWarp > 0 AND lnCharIn = lnCipherBase + 2
			*&
			*& --------------------------------------------------------------
			*& This would be the Time Shift Option on this character...
			*& --------------------------------------------------------------
			*& This is where we modify the seed for the Time Shift Option...
			*& --------------------------------------------------------------
			*&
			lnYear = YEAR(DATE())
			lnMonth = MONTH(DATE())
			lnDay = (DATE() - DATE(YEAR(DATE()), 1, 1)) + 1
			lnWeek = FLOOR(lnDay / 7)
			*&
			DO CASE
			CASE lnTimeWarp = 1
				*&
				*& -------------------------------
				*& Only good for this Minute...
				*& -------------------------------
				*&
				lnSeed = lnSeed + lnTimeWarp + lnYear + lnDay + FLOOR(SECONDS()/60)
				*&
			CASE lnTimeWarp = 2
				*&
				*& -------------------------------
				*& Only good for this Hour...
				*& -------------------------------
				*&
				lnSeed = lnSeed + lnTimeWarp + lnYear + lnDay + FLOOR(SECONDS()/3600)
				*&
			CASE lnTimeWarp = 3
				*&
				*& -------------------------------
				*& Only good for Today...
				*& -------------------------------
				*&
				lnSeed = lnSeed + lnTimeWarp + lnYear + lnDay
				*&
			CASE lnTimeWarp = 4
				*&
				*& -------------------------------
				*& Only good for this Week...
				*& -------------------------------
				*&
				lnSeed = lnSeed + lnTimeWarp + lnYear + lnWeek
				*&
			CASE lnTimeWarp = 5
				*&
				*& -------------------------------
				*& Only good for this Month...
				*& -------------------------------
				*&
				lnSeed = lnSeed + lnTimeWarp + lnYear + lnMonth
				*&
			CASE lnTimeWarp = 6
				*&
				*& -------------------------------
				*& Only good for this Quarter...
				*& -------------------------------
				*&
				DO CASE 
				CASE BETWEEN(lnMonth, 1, 3)
					*&
					lnSeed = lnSeed + lnTimeWarp + lnYear + 1
					*&
				CASE BETWEEN(lnMonth, 4, 6)
					*&
					lnSeed = lnSeed + lnTimeWarp + lnYear + 2
					*&
				CASE BETWEEN(lnMonth, 7, 9)
					*&
					lnSeed = lnSeed + lnTimeWarp + lnYear + 3
					*&
				CASE BETWEEN(lnMonth, 10, 12)
					*&
					lnSeed = lnSeed + lnTimeWarp + lnYear + 4
					*&
				ENDCASE 
				*&
			CASE lnTimeWarp = 7
				*&
				*& -------------------------------
				*& Only good for this year...
				*& -------------------------------
				*&
				lnSeed = lnSeed + lnTimeWarp + lnYear
				*&
			ENDCASE 
			*&
		ENDIF && lnLevel > 1 AND lnTimeWarp > 0 AND lnCharIn = lnCipherBase + 2
		*&
		*& ----------------------------------------
		*& Retrieve this char from the Cipher...
		*& ----------------------------------------
		*&
		lcCharOut = CharNum(lcCipher, lnCharOut)
		*&
		*& ----------------------------------------
		*& Append to the output...
		*& ----------------------------------------
		*&
		lcOutput = lcOutput + lcCharOut
		*&
		*& --------------------------------------------------------
		*& Now update the Cipher for the next round...
		*& --------------------------------------------------------
		*& The Cipher provides Substitution but the Scrambled up
		*& Alphabet also provides Diffusion...
		*& --------------------------------------------------------
		*&
		lnSeed = lnSeed + lnCharOut
		*&
		*& --------------------------------------------------------
		*& Now mutate the Alphabet and the Cipherbet for Confusion
		*& and Diffusion...
		*& --------------------------------------------------------
		*&
		lcAlphaBet = lcCipher
		lcCipher = Scramble(lcCipher, lnSeed)
		*&
	ENDFOR && lnChar = 1 TO lnLength
	*&
	*& ----------------------------------
	*& Return the output string...
	*& ----------------------------------
	*&
	RETURN lcOutput
	*&
ENDFUNC && RelicEncode(pcString, pcKey, pnFlags, pnCipherSize)
*&
*& *************************************************************************
*& RelicDecode(pcString, pcKey)
*& *************************************************************************
*&
FUNCTION RelicDecode(pcString, pcKey, pnFlags, pnCipherSize)
	*&
	*& --------------------------------
	*& Initialize Local Variables...
	*& --------------------------------
	*&
	LOCAL llSuccess, lnSeed, lcAlphabet, lcCipher, lcMessage, lcOutput, ;
		lnLength, lnStart, lnCharIn, lnCharOut, lcCharIn, lcCharOut, ;
		lnCipherSize, lnLevel, lnCipherBase, lnTimeWarp, lnYear, lnDay, ;
		lnMonth, lnWeek, lcCheckSum
	*&
	STORE 0 TO lnSeed, lnLength, lnCharIn, lnCharOut, lnLevel, lnCipherBase, ;
		lnTimeWarp, lnYear, lnDay, lnMonth, lnWeek
	*&
	STORE "" TO lcAlphabet, lcCipher, lcMessage, lcOutput, lcCharIn, lcCharOut, ;
		lcCheckSum
	*&
	*& ------------------------------------------------------------
	*& Test to see if there is an override for the Cipher Size...
	*& The Default is 36...
	*& ------------------------------------------------------------
	*&
	lnCipherSize = 36
	*&
	IF VARTYPE(pnCipherSize) = "N" AND pnCipherSize > 0
		*&
		*& --------------------------------------------------------
		*& This is primarily to support a Cipherbet and Alphabet
		*& that is compatible with Base64 Encoding and even the
		*& Full ASCII Characterset...  Expected values are 36, 64,
		*& and 256...  36 is the Default...
		*& --------------------------------------------------------
		*&
		IF INLIST(pnCipherSize, 36, 64, 256)
			*&
			*& ------------------------------------
			*& Set the Override...
			*& ------------------------------------
			*&
			lnCipherSize = pnCipherSize
			*&
		ELSE
			*&
			*& ----------------------------------------------------
			*& This is a failure...  36, 64, and 256 are the only
			*& valid values for this parameter...
			*& ----------------------------------------------------
			*&
			RETURN ""
			*&
		ENDIF && INLIST(pnCipherSize, 36, 64, 256)
		*&
	ENDIF && VARTYPE(pnCipherSize) = "N" AND pnCipherSize > 0
	*&
	*& --------------------------------------------------------
	*& Establish the Tracking Position of the pointer into the
	*& message string to seek out the end of the header...
	*& --------------------------------------------------------
	*&
	lnStart = 1
	*&
	*& --------------------------------------------
	*& Initialize the Cipher Seed...
	*& --------------------------------------------
	*&
	DO CASE
	CASE VARTYPE(pcKey) = "C"
		*&
		*& -----------------------------------------------------
		*& Strip out the dashes if this is a Serial Number...
		*& -----------------------------------------------------
		*&
		lcKey = UPPER(StripChar(pcKey, "-"))
		*&
		*& --------------------------------------------------------
		*& Check to see if the Key is actually a Serial Number...
		*& --------------------------------------------------------
		*&
		IF LEN(lcKey) = 16 AND LEN(CHRTRAN(lcKey, GetBaseScheme(16), "")) = 0 ;
				AND Checksum(LEFT(lcKey, 12), 16, 16) == RIGHT(lcKey, 4)
			*&
			*& -----------------------------------
			*& Just XOR the two halves...
			*& -----------------------------------
			*&
			lnSeed = BITXOR(INT(VAL("0x" + LEFT(lcKey, 8))), INT(VAL("0x" + RIGHT(lcKey, 8))))
			*&
		ELSE 
			*&
			*& --------------------------------------------------
			*& Take whatever it is and simply convert it into
			*& a 32 bit number as is...
			*& --------------------------------------------------
			*&
			lnSeed = CheckSum(pcKey)
			*&
		ENDIF && LEN(lcKey) = 16 AND LEN(CHRTRAN(lcKey, GetBaseScheme(16), "")) = 0...
		*&
	CASE VARTYPE(pcKey) = "N"
		*&
		*& --------------------------------------------------------
		*& Obviously a Preconceived Seed Value, just use as is...
		*& --------------------------------------------------------
		*&
		lnSeed = pcKey
		*&
	OTHERWISE 
		*&
		*& -----------------------------------
		*& These are not valid paramerers...
		*& -----------------------------------
		*&
		RETURN ""
		*&
	ENDCASE 
	*&
	*& --------------------------------------------------------
	*& Initialize the Alphabet and Cipherbet...
	*& --------------------------------------------------------
	*&
	lcAlphabet = GetBaseScheme(lnCipherSize)
	lcCipher = Scramble(lcAlphabet, lnSeed)
	*&
	*& --------------------------------------------------------
	*& Test the first character for the Encoding Level of the
	*& message...
	*& --------------------------------------------------------
	*&
	IF VARTYPE(pnFlags) = "N" AND pnFlags > 0
		*&
		*& ---------------------------------------------
		*& This is not Level 0...
		*& ---------------------------------------------
		*& Locate the first character in the message
		*& ---------------------------------------------
		*&
		lcCharIn = CharNum(pcString, 1)
		lnCharIn = CharAt(lcCharIn, lcCipher)
		*&
		lnLevel = BITAND(lnCharIn, 2^2-1) + 1
		lnCipherBase = BITAND(BITRSHIFT(lnCharIn,2), 2^3-1)
		*&
		*& --------------------------------------------------------
		*& Of course each encoded character affects the Seeding...
		*& --------------------------------------------------------
		*&
		lnSeed = lnSeed + lnCharIn
		*&
		*& --------------------------------------------------------
		*& Now update the Cipher for the next round...
		*& --------------------------------------------------------
		*& The Cipher provides Substitution but the Scrambled up
		*& Alphabet also provides Diffusion...
		*& --------------------------------------------------------
		*&
		lcAlphaBet = lcCipher
		lcCipher = Scramble(lcCipher, lnSeed)
		*&
		*& ------------------------------------------------------------------
		*& Start with whatever offset remains after treating the header...
		*& ------------------------------------------------------------------
		*&
		lnStart = lnStart + 1
		*&
		IF lnLevel > 0
			*&
			*& -----------------------------------------------
			*& Unravel the CipherBase...
			*& -----------------------------------------------
			*&
			IF lnCipherBase > 0
				*&
				FOR lnStart = 2 TO lnCipherBase + 1
					*&
					*& ---------------------------------------------
					*& This is used to spin up the Cipher Count...
					*& ---------------------------------------------
					*&
					lcCharIn = CharNum(pcString, lnStart)
					lnCharIn = CharAt(lcCharIn, lcCipher)
					*&
					lnSeed = lnSeed + lnCharIn
					*&
					lcAlphaBet = lcCipher
					lcCipher = Scramble(lcCipher, lnSeed)
					*&
				ENDFOR && lnStart = 2 TO lnCipherBase + 1
				*&
			ENDIF && lnCipherBase > 0
			*&
			lnStart = lnStart + 1
			*&
			IF lnLevel > 1
				*&
				*& -------------------------------
				*& Check the TimeWarp setting...
				*& -------------------------------
				*&
				lcCharIn = CharNum(pcString, lnStart)
				lnCharIn = CharAt(lcCharIn, lcCipher)
				*&
				*& --------------------------------------------------------
				*& We need the original position from the Alphabet in order 
				*& to determine the actual Timewarp value...
				*& --------------------------------------------------------
				*& After all this was actually determined from the actual
				*& Alphabet prior to encoding...
				*& --------------------------------------------------------
				*&
				lcCharIn = CharNum(lcCipher, lnCharIn)
				lnCharIn = CharAt(lcCharIn, GetBaseScheme(lnCipherSize))
				*&
				lnTimeWarp = BITAND(lnCharIn, 2^3-1)
				*&
				*& ---------------------------------------------------------
				*& Restore these values back to the Cipher Values as it 
				*& was used to affect the seed in the original encoding...
				*& ---------------------------------------------------------
				*&
				lcCharIn = CharNum(pcString, lnStart)
				lnCharIn = CharAt(lcCharIn, lcCipher)
				*&
				*& -------------------------------------------
				*& Establish Timewarp Parameters...
				*& -------------------------------------------
				*&
				lnYear = YEAR(DATE())
				lnMonth = MONTH(DATE())
				lnDay = (DATE() - DATE(lnYear, 1, 1)) + 1
				lnWeek = FLOOR(lnDay / 7)
				*&
				DO CASE
				CASE lnTimeWarp = 1
					*&
					*& -------------------------------
					*& Only good for this Minute...
					*& -------------------------------
					*&
					lnSeed = lnSeed + lnTimeWarp + lnYear + lnDay + FLOOR(SECONDS()/60)
					*&
				CASE lnTimeWarp = 2
					*&
					*& -------------------------------
					*& Only good for this Hour...
					*& -------------------------------
					*&
					lnSeed = lnSeed + lnTimeWarp + lnYear + lnDay + FLOOR(SECONDS()/3600)
					*&
				CASE lnTimeWarp = 3
					*&
					*& -------------------------------
					*& Only good for Today...
					*& -------------------------------
					*&
					lnSeed = lnSeed + lnTimeWarp + lnYear + lnDay
					*&
				CASE lnTimeWarp = 4
					*&
					*& -------------------------------
					*& Only good for this Week...
					*& -------------------------------
					*&
					lnSeed = lnSeed + lnTimeWarp + lnYear + lnWeek
					*&
				CASE lnTimeWarp = 5
					*&
					*& -------------------------------
					*& Only good for this Month...
					*& -------------------------------
					*&
					lnSeed = lnSeed + lnTimeWarp + lnYear + lnMonth
					*&
				CASE lnTimeWarp = 6
					*&
					*& -------------------------------
					*& Only good for this Quarter...
					*& -------------------------------
					*&
					DO CASE 
					CASE BETWEEN(lnMonth, 1, 3)
						*&
						lnSeed = lnSeed + lnTimeWarp + lnYear + 1
						*&
					CASE BETWEEN(lnMonth, 4, 6)
						*&
						lnSeed = lnSeed + lnTimeWarp + lnYear + 2
						*&
					CASE BETWEEN(lnMonth, 7, 9)
						*&
						lnSeed = lnSeed + lnTimeWarp + lnYear + 3
						*&
					CASE BETWEEN(lnMonth, 10, 12)
						*&
						lnSeed = lnSeed + lnTimeWarp + lnYear + 4
						*&
					ENDCASE 
					*&
				CASE lnTimeWarp = 7
					*&
					*& -------------------------------
					*& Only good for this year...
					*& -------------------------------
					*&
					lnSeed = lnSeed + lnTimeWarp + lnYear
					*&
				ENDCASE 
				*&
				lnSeed = lnSeed + lnCharIn
				*&
				lcAlphabet = lcCipher
				lcCipher = Scramble(lcCipher, lnSeed)
				*&
				lnStart = lnStart + 1
				*&
			ENDIF && lnLevel > 1
			*&
		ENDIF && lnLevel > 0
		*&
	ENDIF && VARTYPE(pnFlags) = "N" AND pnFlags > 0
	*&
	*& -----------------------------
	*& Scan the Message...
	*& -----------------------------
	*&
	lnLength = LEN(pcString)
	*&
	FOR lnCharIn = lnStart TO lnLength
		*&
		*& ----------------------------------------------
		*& Fetch this e-char from the message...
		*& ----------------------------------------------
		*&
		lcCharIn = CharNum(pcString, lnCharIn)
		*&
		*& ----------------------------------------------
		*& Locate this character in the Cipher...
		*& ----------------------------------------------
		*&
		lnCharOut = CharAt(lcCharIn, lcCipher)
		*&
		*& ----------------------------------------------
		*& Retrieve this character from the Alphabet...
		*& ----------------------------------------------
		*&
		lcCharOut = CharNum(lcAlphabet, lnCharOut)
		*&
		*& ----------------------------------------------
		*& Append to the output...
		*& ----------------------------------------------
		*&
		lcOutput = lcOutput + lcCharOut
		*&
		*& --------------------------------------------------------
		*& Now update the Cipher for the next round...
		*& --------------------------------------------------------
		*& The Cipher provides Substitution but the Scrambled up
		*& Alphabet also provides Diffusion...
		*& --------------------------------------------------------
		*&
		lnSeed = lnSeed + lnCharOut
		*&
		lcAlphaBet = lcCipher
		lcCipher = Scramble(lcAlphabet, lnSeed)
		*&
	ENDFOR && lnChar = 1 TO lnLength
	*&
	IF VARTYPE(pnCipherSize) <> "N"
		*&
		*& ----------------------------------------------
		*& Decode the message from 5 bit characters to 
		*& 8 bit characters...
		*& ----------------------------------------------
		*& First strip out any X's as they were just
		*& used for padding to be 5 digit code groups...
		*& ----------------------------------------------
		*&
		lcOutput = Base32Decode(StripChar(lcOutput,"X"))
		*&
	ENDIF && VARTYPE(pnCipherSize) <> "N"
	*&
	IF lnLevel > 1
		*&
		*& -----------------------------------------------
		*& There should be a 4 Character Checksum at the
		*& end that should match the message.  This is an
		*& integrity check to determine if the cipher had
		*& been expired...
		*& -----------------------------------------------
		*&
		lcCheckSum = RIGHT(lcOutput, 4)
		lcOutput = LEFT(lcOutput, LEN(lcOutput) - 4)
		*&
		llSuccess = CheckSum(lcOutput, 16, 16) == lcCheckSum
		*&
		IF NOT llSuccess
			*&
			*& -------------------------------------------------
			*& No sense in returning what should obviously be
			*& just a bunch of gobbledy goop...
			*& -------------------------------------------------
			*&
			RETURN ""
			*&
		ENDIF && NOT llSuccess
		*&
	ENDIF && lnLevel > 1
	*&
	RETURN lcOutput
	*&
ENDFUNC && RelicDecode(pcString, pcKey, pnFlags, pnCipherSize)
*&
*& *************************************************************************
*& Base32Encode(pcString)
*&
*& Takes a string and Encodes to Base32...  This is a Bit Word translation
*& using a 40 bit word.  Encoding takes an 8 bit per byte using 5 bytes, to 
*& a 5 bit per byte word using a an 8 byte word...
*& *************************************************************************
*& Either word is comprised of a 40 bit word...
*& *************************************************************************
*&
FUNCTION Base32Encode(pcString)
	*&
	*& -------------------------------
	*& Initialize Local Variables...
	*& -------------------------------
	*&
	LOCAL llSuccess, lnLength, lcOutput, lcAlphabet, lnWordStart, lcWord, lnWordSize, ;
		lnWordLength, lnByte, lBits, lnNibble1, lnNibble2, lnNibble3, lnNibble4, lnNibble5, ;
		lnNibble6, lnNibble7, lnNibble8
	*&
	STORE "" TO lcOutput, lcWord
	*&
	STORE 0 TO lnLength, lnWordStart, lnWordSize, lnWordLength, lnByte, lnBits, lnNibble1, ;
		lnNibble2, lnNibble3, lnNibble4, lnNibble5, lnNibble6, lnNibble7, lnNibble8
	*&
	lcAlphabet = GetBaseScheme(32)
	lnWordSize = 5 && 5 - 8 Bit Bytes...
	*&
	llSuccess = VARTYPE(pcString) = "C" AND NOT EMPTY(pcString)
	*&
	IF llSuccess
		*&
		lnLength = LEN(pcString)
		*&
		*& --------------------------
		*& Encode the string...
		*& --------------------------
		*&
		FOR lnWordStart = 1 TO lnLength STEP lnWordSize
			*&
			*& ----------------------------------------------------------------------------
			*& So we're going from 8 bits a word to 5 bits a word, 5 bytes at a time in
			*& Groups of 40 bits each...
			*& ----------------------------------------------------------------------------
			*&
			*& ------------------------------------------------
			*& These need to be reset on each iteration...
			*& ------------------------------------------------
			*&
			STORE 0 TO lnNibble1, lnNibble2, lnNibble3, lnNibble4, lnNibble5, lnNibble6, ;
				lnNibble7, lnNibble8
			*&
			*& ------------------------------------------------------
			*& These will be 40 bit words up the 5 bytes each...
			*& ------------------------------------------------------
			*&
			lcWord = SUBSTR(pcString, lnWordStart, lnWordSize)
			lnWordLength = LEN(lcWord)
			*&
			*& -----------------------------------------------------
			*& This should produce 8 5 bit words... (8*5=40 bits)
			*& -----------------------------------------------------
			*&
			FOR lnByte = 1 TO lnWordLength
				*&
				*& ----------------------------------------
				*& Grab the bits for each Byte...
				*& ----------------------------------------
				*&
				lnBits = ASC(CharNum(lcWord, lnByte))
				*&
				DO CASE 
				CASE lnByte = 1
					*&
					*& ---------------------------------------------
					*& 11111000 >> 3 = 11111
					*& ---------------------------------------------
					*&
					lnNibble1 = BITRSHIFT(lnBits, 3)
					*&
					*& ---------------------------------------------
					*& 00000111 && 2^3-1 << 2 = 11100
					*& ---------------------------------------------
					*&
					lnNibble2 = BITLSHIFT(BITAND(lnBits, 2^3-1), 2)
					*&
				CASE lnByte = 2
					*&
					*& ---------------------------------------------
					*& 11000000 >> 6 = 00011
					*& ---------------------------------------------
					*&
					lnNibble2 = lnNibble2 + BITRSHIFT(lnBits, 6)
					*&
					*& ---------------------------------------------
					*& 00111110 >> 1 && 2^5-1 = 11111
					*& ---------------------------------------------
					*&
					lnNibble3 = BITAND(BITRSHIFT(lnBits, 1), 2^5-1)
					*&
					*& ---------------------------------------------
					*& 00000001 && 2^1-1 << 4 = 10000
					*& ---------------------------------------------
					*&
					lnNibble4 = BITLSHIFT(BITAND(lnBits, 2^1-1), 4)
					*&
				CASE lnByte = 3
					*&
					*& ---------------------------------------------
					*& 11110000 >> 4 = 01111
					*& ---------------------------------------------
					*&
					lnNibble4 = lnNibble4 + BITRSHIFT(lnBits, 4)
					*&
					*& ---------------------------------------------
					*& 00001111 && 2^4-1 << 1 = 11110
					*& ---------------------------------------------
					*&
					lnNibble5 = BITLSHIFT(BITAND(lnBits, 2^4-1), 1)
					*&
				CASE lnByte = 4
					*&
					*& ---------------------------------------------
					*& 10000000 >> 7 = 00001
					*& ---------------------------------------------
					*&
					lnNibble5 = lnNibble5 + BITRSHIFT(lnBits, 7)
					*&
					*& ---------------------------------------------
					*& 01111100 >> 2 && 2^5-1 = 11111
					*& ---------------------------------------------
					*&
					lnNibble6 = BITAND(BITRSHIFT(lnBits, 2), 2^5-1)
					*&
					*& ---------------------------------------------
					*& 00000011 && 2^2-1 << 3 = 11000
					*& ---------------------------------------------
					*&
					lnNibble7 = BITLSHIFT(BITAND(lnBits, 2^2-1), 3)
					*&
				CASE lnByte = 5
					*&
					*& ---------------------------------------------
					*& 11100000 >> 5 = 00111
					*& ---------------------------------------------
					*&
					lnNibble7 = lnNibble7 + BITRSHIFT(lnBits, 5)
					*&
					*& ---------------------------------------------
					*& 00011111 && 2^5-1 = 11111
					*& ---------------------------------------------
					*&
					lnNibble8 = BITAND(lnBits, 2^5-1)
					*&
				ENDCASE 
				*&
			ENDFOR && lnByte = 1 TO lnWordLength
			*&
			*& -------------------------------------------------------------
			*& Now we should have 8 5 bit values...  So extract those from
			*& our 5 bit Alphabet...
			*& -------------------------------------------------------------
			*& Also keep in mind that we're working with 0 based index, but
			*& the string we're addressng has a 1 based index...
			*& -------------------------------------------------------------
			*&
			lcOutput = lcOutput + CharNum(lcAlphabet, lnNibble1 + 1) ;
				+ CharNum(lcAlphabet, lnNibble2 + 1) ;
				+ CharNum(lcAlphabet, lnNibble3 + 1) ;
				+ CharNum(lcAlphabet, lnNibble4 + 1) ;
				+ CharNum(lcAlphabet, lnNibble5 + 1) ;
				+ CharNum(lcAlphabet, lnNibble6 + 1) ;
				+ CharNum(lcAlphabet, lnNibble7 + 1) ;
				+ CharNum(lcAlphabet, lnNibble8 + 1)
			*&
		ENDFOR && lnWordStart = 1 TO lnLength STEP lnWordSize
		*&
		*& ---------------------------------------------------------------
		*& Now for a bit of Encoding Cleanup...
		*& ---------------------------------------------------------------
		*& Change any "0" to Space and Trim off the end...  Then put 
		*& any internal " " back to "0" the way it was...
		*& ---------------------------------------------------------------
		*&
		lcOutput = TRIM(STRTRAN(lcOutput, "0", " "))
		lcOutput = STRTRAN(lcOutput, " ", "0")
		*&
	ENDIF && llSuccess
	*&
	RETURN lcOutput
	*&
ENDFUNC && Base32Encode(pcString)
*&
*& *************************************************************************
*& Base32Decode(pcString)
*&
*& Takes a string and Decodes from Base32 back to ASCII text...
*& *************************************************************************
*& This will take a 5 bit byte for 8 bytes and translates it to an 8 bit 
*& byte for 5 bytes, either of which forms a 40 bit word...
*& *************************************************************************
*&
FUNCTION Base32Decode(pcString)
	*&
	*& ----------------------------------------------
	*& Initialize Local Variables...
	*& ----------------------------------------------
	*&
	LOCAL llSuccess, lcOutput, lnLength, lcAlphabet, lnWordStart, lcWord, lnWordSize, ;
		lnWordLength, lnNibble, lnBits, lnByte1, lnByte2, lnByte3, lnByte4, lnByte5
	*&
	STORE "" TO lcOutput, lcWord
	STORE 0 TO lnLength, lnWordStart, lnWordSize, lnWordLength, lnNibble, lnBits, lnByte1, ;
		lnByte2, lnByte3, lnByte4, lnByte5
	*&
	lcAlphabet = GetBaseScheme(32)
	lnWordSize = 8 && 8 Bytes...
	*&
	*& ----------------------------------------------
	*& Validate the Parameter...
	*& ----------------------------------------------
	*&
	llSuccess = VARTYPE(pcString) = "C" AND LEN(pcString) > 0
	*&
	IF llSuccess
		*&
		lnLength = LEN(pcString)
		*&
		FOR lnWordStart = 1 TO lnLength STEP lnWordSize
			*&
			lcWord = SUBSTR(pcString, lnWordStart, lnWordSize)
			lnWordLength = LEN(lcWord)
			*&
			FOR lnNibble = 1 TO lnWordLength
				*&
				*& -----------------------------------------------------------------
				*& Locate this character in the Alphabet and get it's position...
				*& -----------------------------------------------------------------
				*& The Encoder goes from Bytes to Parts...  This is just the 
				*& reverse going from Parts back into Bytes...
				*& -----------------------------------------------------------------
				*&
				*& -----------------------------------------------------------------
				*& Subtract 1 to convert from 1 based to Zero Based Indexing...
				*& -----------------------------------------------------------------
				*&
				lnBits = AT(CharNum(lcWord, lnNibble), lcAlphabet) - 1
				*&
				*& ----------------------------------------------------------------
				*& Working with 40 bit Words...  This time going from 5 bit words
				*& to 8 bit words...
				*& ----------------------------------------------------------------
				*&
				DO CASE
				CASE lnNibble = 1
					*&
					*& -------------------------------------------------------
					*& 11111 << 3 = 11111000
					*& -------------------------------------------------------
					*&
					lnByte1 = BITLSHIFT(lnBits, 3)
					*&
				CASE lnNibble = 2
					*&
					*& -------------------------------------------------------
					*& 11100 >> 2 = 00000111
					*& -------------------------------------------------------
					*&
					lnByte1 = lnByte1 + BITRSHIFT(lnBits, 2)
					*&
					lcOutput = lcOutput + CHR(lnByte1)
					*&
					*& -------------------------------------------------------
					*& 00011 && 2^2-1 << 6 = 11000000
					*& -------------------------------------------------------
					*&
					lnByte2 = BITLSHIFT(BITAND(lnBits, 2^2-1), 6)
					*&
				CASE lnNibble = 3
					*&
					*& -------------------------------------------------------
					*& 11111 << 1 = 00111110
					*& -------------------------------------------------------
					*&
					lnByte2 = lnByte2 + BITLSHIFT(lnBits, 1)
					*&
				CASE lnNibble = 4
					*&
					*& -------------------------------------------------------
					*& 10000 >> 4 = 00000001
					*& -------------------------------------------------------
					*&
					lnByte2 = lnByte2 + BITRSHIFT(lnBits, 4)
					*&
					lcOutput = lcOutput + CHR(lnByte2)
					*&
					*& -------------------------------------------------------
					*& 01111 && 2^4-1 << 4 = 11110000
					*& -------------------------------------------------------
					*&
					lnByte3 = BITLSHIFT(BITAND(lnBits, 2^4-1), 4)
					*&
				CASE lnNibble = 5
					*&
					*& -------------------------------------------------------
					*& 11110 >> 1 = 00001111
					*& -------------------------------------------------------
					*&
					lnByte3 = lnByte3 + BITRSHIFT(lnBits, 1)
					*&
					lcOutput = lcOutput + CHR(lnByte3)
					*&
					*& -------------------------------------------------------
					*& 00001 && 2^1-1 << 7 = 10000000
					*& -------------------------------------------------------
					*&
					lnByte4 = BITLSHIFT(BITAND(lnBits, 2^1-1), 7)
					*&
				CASE lnNibble = 6
					*&
					*& -------------------------------------------------------
					*& 11111 << 2 = 01111100
					*& -------------------------------------------------------
					*&
					lnByte4 = lnByte4 + BITLSHIFT(lnBits, 2)
					*&
				CASE lnNibble = 7
					*&
					*& -------------------------------------------------------
					*& 11000 >> 3 = 00000011
					*& -------------------------------------------------------
					*&
					lnByte4 = lnByte4 + BITRSHIFT(lnBits, 3)
					*&
					lcOutput = lcOutput + CHR(lnByte4)
					*&
					*& -------------------------------------------------------
					*& 00111 && 2^3-1 << 5 = 11100000
					*& -------------------------------------------------------
					*&
					lnByte5 = BITLSHIFT(BITAND(lnBits, 2^3-1), 5)
					*&
				CASE lnNibble = 8
					*&
					*& -------------------------------------------------------
					*& 11111 = 00011111
					*& -------------------------------------------------------
					*&
					lnByte5 = lnByte5 + lnBits
					*&
					lcOutput = lcOutput + CHR(lnByte5)
					*&
				ENDCASE 
				*&
			ENDFOR && lnI = 1 TO lnWordLength
			*&
		ENDFOR && lnWordStart = 1 TO lnLength STEP lnWordSize
		*&
	ENDIF && llSuccess
	*&
	RETURN lcOutput
	*&
ENDFUNC && Base32Decode(pcString)
*&
*& *************************************************************************
*& Base64Encode(pcString)
*&
*& So this is an Encoder for 24 bit words that Translates from a 3 Byte
*& word being 8 bits per byte to a 4 Byte word at 6 bits per byte...
*& 
*& This is a 24 bit Bit Word Translation either way...
*& *************************************************************************
*&
FUNCTION Base64Encode(pcString)
	*&
	*& ------------------------------------
	*& Initialize Local Variables...
	*& ------------------------------------
	*&
	LOCAL llSuccess, lcOutput, lcAlphabet, lnLength, lnWordStart, lnWordSize, lcWord, ;
		lnWordLength, lnByte, lnBits, lnNibble1, lnNibble2, lnNibble3, lnNibble4
	*&
	STORE "" TO lcOutput, lcAlphabet, lcWord
	STORE 0 TO lnLength, lnWordStart, lnWordSize, lnWordLength, lnByte, lnBits, ;
		lnNibble1, lnNibble2, lnNibble3, lnNibble4
	*&
	lcAlphabet = GetBaseScheme(64)
	lnWordSize = 3 && 3 - 8 Bit Bytes...
	*&
	*& ------------------------------------
	*& Validate the Parameters...
	*& ------------------------------------
	*&
	llSuccess = VARTYPE(pcString) = "C" AND LEN(pcString) > 0
	*&
	IF llSuccess
		*&
		*& ------------------------------------------------------------------------------
		*& So with Base64 we are dealing with 24 bit Words which are 3 - 8 bit bytes in 
		*& ASCII as compared to 4 - 6 bit bytes in Base64...
		*& ------------------------------------------------------------------------------
		*& 
		lnLength = LEN(pcString)
		*& 
		FOR lnWordStart = 1 TO lnLength STEP lnWordSize
			*&
			STORE 0 TO lnNibble1, lnNibble2, lnNibble3, lnNibble4
			*&
			lcWord = SUBSTR(pcString, lnWordStart, lnWordSize)
			lnWordLength = LEN(lcWord)
			*&
			FOR lnByte = 1 TO lnWordLength
				*&
				lnBits = ASC(CharNum(lcWord, lnByte))
				*&
				DO CASE 
				CASE lnByte = 1
					*&
					*& ------------------------------------------------
					*& 11111100 >> 2 = 111111
					*& ------------------------------------------------
					*&
					lnNibble1 = BITRSHIFT(lnBits, 2)
					*&
					*& ------------------------------------------------
					*& 00000011 && 2^2-1 << 4 = 110000
					*& ------------------------------------------------
					*&
					lnNibble2 = BITLSHIFT(BITAND(lnBits, 2^2-1), 4)
					*&
				CASE lnByte = 2
					*&
					*& ------------------------------------------------
					*& 11110000 >> 4 = 001111
					*& ------------------------------------------------
					*&
					lnNibble2 = lnNibble2 + BITRSHIFT(lnBits, 4)
					*&
					*& ------------------------------------------------
					*& 00001111 && 2^4-1 << 2 = 111100
					*& ------------------------------------------------
					*&
					lnNibble3 = BITLSHIFT(BITAND(lnBits, 2^4-1), 2)
					*&
				CASE lnByte = 3
					*&
					*& ------------------------------------------------
					*& 11000000 >> 6 = 000011
					*& ------------------------------------------------
					*&
					lnNibble3 = lnNibble3 + BITRSHIFT(lnBits, 6)
					*&
					*& ------------------------------------------------
					*& 00111111 && 2^6 = 111111
					*& ------------------------------------------------
					*&
					lnNibble4 = BITAND(lnBits, 2^6-1)
					*&
				ENDCASE 
				*&
			ENDFOR && lnByte = 1 TO lnWordLength
			*&
			lcOutput = lcOutput + CharNum(lcAlphabet, lnNibble1 + 1) ;
				+ CharNum(lcAlphabet, lnNibble2 + 1) ;
				+ CharNum(lcAlphabet, lnNibble3 + 1) ;
				+ CharNum(lcAlphabet, lnNibble4 + 1) 
			*&
		ENDFOR && lnWordStart = 1 TO lnLength STEP lnWordSize
		*&
		*& --------------------------------------
		*& Now for a bit of Encoding Cleanup...
		*& --------------------------------------
		*& Change any "A" / 0 to Space and Trim
		*& off the end...  Then put any internal
		*& "A" / 0 back to the way it was...
		*& --------------------------------------
		*&
		lcOutput = TRIM(STRTRAN(lcOutput, "A", " "))
		lcOutput = STRTRAN(lcOutput, " ", "A")
		*&
		*& ---------------------------------
		*& Add any Padding if necessary...
		*& ---------------------------------
		*&
		lnPadding = MOD(LEN(lcOutput), 4)
		*&
		IF lnPadding > 0
			lcOutput = lcOutput + REPLICATE("=", 4 - lnPadding)
		ENDIF && lnPadding > 0
		*&
	ENDIF && llSuccess
	*&
	RETURN lcOutput
	*&
ENDFUNC && Base64Encode(pcString)
*&
*& *************************************************************************
*& Base64Decode(pcString)
*&
*& So this will convert Base64 Encoding back into ASCII Text.  This means
*& that we go from 4 bytes at 6 bits back to 3 bytes at 8 bits...  This is 
*& a 24 Bit Word Translation either way...
*& *************************************************************************
*&
FUNCTION Base64Decode(pcString)
	*&
	*& -----------------------------------
	*& Initialize Local Variables...
	*& -----------------------------------
	*&
	LOCAL llSuccess, lcOutput, lcAlphabet, lnLength, lnWordStart, lnWordSize, lcWord, ;
		lnWordLength, lnByte1, lnByte2, lnByte3, lnByte4, lnNibble, lnBits
	*&
	STORE "" TO lcOutput, lcWord, lcAlphabet
	STORE 0 TO lnLength, lnWordStart, lnWordSize, lnWordLength, ;
		lnByte1, lnByte2, lnByte3, lnByte4, lnNibble, lnBits
	*&
	lcAlphabet = GetBaseScheme(64)
	lnWordSize = 4 && 4 - 6 Bit Bytes...
	*&
	*& -----------------------------------
	*& Validate the Parameters...
	*& -----------------------------------
	*&
	llSuccess = VARTYPE(pcString) = "C" AND LEN(pcString) > 0
	*&
	IF llSuccess
		*&
		*& -----------------------------------------------------
		*& So in this case we're dealing with a 24 bit Word...
		*& -----------------------------------------------------
		*& We'll be going from a 6 bit byte to an 8 bit byte...
		*& -----------------------------------------------------
		*&
		lnLength = LEN(pcString)
		*&
		FOR lnWordStart = 1 TO lnLength STEP lnWordSize
			*&
			STORE 0 TO lnByte1, lnByte2, lnByte3
			*&
			lcWord = SUBSTR(pcString, lnWordStart, lnWordSize)
			*&
			*& -------------------------------------------------
			*& Strip out any = symbols as they are really only
			*& there for looks...
			*& -------------------------------------------------
			*&
			lcWord = STRTRAN(lcWord, "=", "")
			*&
			lnWordLength = LEN(lcWord)
			*&
			FOR lnNibble = 1 TO lnWordLength
				*&
				*& -------------------------------------------
				*& Determine the Bit Value for this Part...
				*& -------------------------------------------
				*&
				lnBits = AT(CharNum(lcWord, lnNibble), lcAlphabet) - 1
				*&
				DO CASE 
				CASE lnNibble = 1
					*&
					*& --------------------------------------------------
					*& 111111 << 2 = 11111100
					*& --------------------------------------------------
					*&
					lnByte1 = BITLSHIFT(lnBits, 2)
					*&
				CASE lnNibble = 2
					*&
					*& --------------------------------------------------
					*& 110000 >> 4 = 00000011
					*& --------------------------------------------------
					*&
					lnByte1 = lnByte1 + BITRSHIFT(lnBits, 4)
					*&
					lcOutput = lcOutput + CHR(lnByte1)
					*&
					*& --------------------------------------------------
					*& 001111 && 2^4-1 << 4 = 11110000...
					*& --------------------------------------------------
	 				*&
	 				lnByte2 = BITLSHIFT(BITAND(lnBits, 2^4-1), 4)
					*&
				CASE lnNibble = 3
					*&
					*& --------------------------------------------------
					*& 111100 >> 2 = 00001111...
					*& --------------------------------------------------
					*&
					lnByte2 = lnByte2 + BITRSHIFT(lnBits, 2)
					*&
					lcOutput = lcOutput + CHR(lnByte2)
					*&
					*& --------------------------------------------------
					*& 000011 && 2^2-1 << 6 = 11000000...
					*& --------------------------------------------------
					*&
					lnByte3 = BITLSHIFT(BITAND(lnBits, 2^2-1),6)
					*&
				CASE lnNibble = 4
					*&
					*& --------------------------------------------------
					*& 111111 = 00111111...
					*& --------------------------------------------------
					*&
					lnByte3 = lnByte3 + lnBits
					*&
					lcOutput = lcOutput + CHR(lnByte3)
					*&
				ENDCASE 
				*&
			ENDFOR && lnNibble = 1 TO lnWordLength
			*&
		ENDFOR && lnWord = 1 TO lnLength STEP 4
		*&
	ENDIF && llSuccess
	*&
	RETURN lcOutput
	*&
ENDFUNC && Base64Decode(pcString)
*&
*& *************************************************************************
*& Scramble(pcString, pvSeed)
*&
*& So now it would appear that I need a scrambler...
*& *************************************************************************
*&
FUNCTION Scramble(pcString, pvSeed)
	*&
	*& ----------------------------------
	*& Initialize Local Variables...
	*& ----------------------------------
	*&
	LOCAL llSuccess, lcOutput, lnLength, lnChar, lnSeed
	*&
	STORE "" TO lcOutput
	STORE 0 TO lnLength, lnChar
	*&
	llSuccess = VARTYPE(pcString) = "C"
	*&
	IF llSuccess
		*&
		*& -------------------------------------------------
		*& Create a Temporary Data Structure for Sorting...
		*& -------------------------------------------------
		*&
		CREATE CURSOR cTemp (Char c(1), Sequence c(2))
		*&
		lnLength = LEN(pcString)
		*&
		*& ----------------------------------
		*& Seed the Randomizer...
		*& ----------------------------------
		*&
		lnSeed = XRand(pvSeed)
		*&
		*& ----------------------------------
		*& Establish a new sequence...
		*& ----------------------------------
		*&
		FOR lnChar = 1 TO lnLength
			*&
			*& ----------------------------------------
			*& Populate the Sorting Structure...
			*& ----------------------------------------
			*&
			m.Char = SUBSTR(pcString, lnChar, 1)
			m.Sequence = PADL(lnSeed, 2, "0")
			*&
			INSERT INTO cTemp FROM MEMVAR 
			*&
			*& ----------------------------------------
			*& Get the next value in the sequence...
			*& ----------------------------------------
			*&
			lnSeed = PADL(XRand(), 2, "0")
			*&
		ENDFOR && lnChar = 1 TO lnLength
		*&
		*& ----------------------------------
		*& Sort on Sequence...
		*& ----------------------------------
		*&
		INDEX on Sequence TAG Sequence
		*&
		SCAN 
			*&
			*& ----------------------------------
			*& Rebuild the Scrambled String...
			*& ----------------------------------
			*&
			lcOutput = lcOutput + Char
			*&
		ENDSCAN 
		*&
	ENDIF && llSuccess
	*&
	RETURN lcOutput
	*&
ENDFUNC && Scramble(pcString, pvSeed)
*&
*& *************************************************************************
*& GetBaseScheme(pnBase)
*& =========================================================================
*& Get a string representing all the values in a base...
*& *************************************************************************
*&
FUNCTION GetBaseScheme(pnBase)
	*&
	LOCAL lcBase, lnI
	*&
	lnI = 0
	lcBase = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	*&
	DO CASE 
	CASE VARTYPE(pnBase) <> "N"
		*&
		lcBase = ""
		*&
	CASE BETWEEN(pnBase, 2, 36)
		*&
		lcBase = LEFT(lcBase, pnBase)
		*&
	CASE pnBase = 64
		*&
		lcBase = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		*&
	CASE INLIST(pnBase, 128. 256)
		*&
		*& Build a full ASCII table...
		*&
		FOR lnI = 1 TO pnBase
			*&
			lcBase = lcBase + CHR(lnI - 1)
			*&
		ENDFOR && lnI = 1 TO pnBase
		*&
	ENDCASE 
	*&
	RETURN lcBase
	*&
ENDFUNC && GetBaseScheme(pnBase)
*&
*& *************************************************************************
*& CharAt(pcChar, pcString)
*& =========================================================================
*& Determine the position within the string...
*& *************************************************************************
*&
FUNCTION CharAt(pcChar, pcString)
	*&
	RETURN AT(pcChar, pcString)
	*&
ENDFUNC && CharAt(pcChar, pcString)
*&
*& *************************************************************************
*& CharNum(pcString, pnChar)
*& =========================================================================
*& Extract Nth Char from a string...
*& *************************************************************************
*&
FUNCTION CharNum(pcString, pnChar)
	*&
	RETURN SUBSTR(pcString, pnChar, 1)
	*&
ENDFUNC && CharNum(pcString, pnChar)
*&
*& *************************************************************************
*& StripChar(pcString, pcChar)
*& =========================================================================
*& Determine the position within the string...
*& *************************************************************************
*&
FUNCTION StripChar(pcString, pcChar)
	*&
	RETURN CHRTRAN(pcString, pcChar, "")
	*&
ENDFUNC && StripChar(pcString, pcChar)
*&
*& *************************************************************************
*& SplitString(pcString, 5, pcSeparator)
*& =========================================================================
*& Split a string into equal groups with a common separator...
*& *************************************************************************
*&
FUNCTION SplitString(pcString, pnSize, pcSeparator)
	*&
	LOCAL llSuccess, lcOutput
	*&
	STORE "" TO lcOutput
	*&
	llSuccess = VARTYPE(pcString) = "C" AND VARTYPE(pnSize) = "N" ;
		AND VARTYPE(pcSeparator) = "C"
	*&
	IF llSuccess
		*&
		FOR lnGroup = 1 TO LEN(pcString) STEP pnSize
			*&
			IF LEN(lcOutput) > 0
				*&
				lcOutput = lcOutput + pcSeparator
				*&
			ENDIF && LEN(lcOutput) > 0
			*&
			lcOutput = lcOutput + SUBSTR(pcString, lnGroup, pnSize)
			*&
		ENDFOR && lnGroup = 1 TO LEN(pcString) STEP 5
		*&
	ENDIF && llSuccess
	*&
	RETURN lcOutput
	*&
ENDFUNC && SplitString(pcString, 5, pcSeparator)
*&
*& *************************************************************************
*& StringSum(pcString)
*& =========================================================================
*& Convert a String to a Number...
*& *************************************************************************
*&
FUNCTION StringSum(pcString)
	*&
	*& -------------------------------
	*& Initialize Local Variables...
	*& -------------------------------
	*&
	LOCAL lnValue, lnLength, lnChar
	*&
	STORE 0 TO lnValue, lnLength, lnChar
	*&
	IF VARTYPE(pcString) = "C" AND LEN(pcString) > 0
		*&
		lnLength = LEN(pcString)
		*&
		FOR lnChar = 1 TO lnLength
			*&
			lnValue = lnValue + ASC(SUBSTR(pcString, lnChar, 1))
			*&
		ENDFOR && lnChar = 1 TO lnLength
		*&
		lnValue = lnValue + lnLength
		*&
	ENDIF && VARTYPE(pcString) = "C" AND LEN(pcString) > 0
	*&
	RETURN lnValue
	*&
ENDFUNC && StringSum(pcString)
*&
*& *************************************************************************
*& CheckSum(pcString, pnBase, pnBits)
*& =========================================================================
*& Convert a String to a Number with a Spcific Options.  Primarily useful
*& to determine if a String has changed...
*& *************************************************************************
*&
FUNCTION CheckSum(pcString, pnBase, pnBits)
	*&
	*& --------------------------------------
	*& Initialize Local Variables...
	*& --------------------------------------
	*&
	LOCAL llSuccess, lnValue, lnBitNess, lnBits
	*&
	STORE 0 TO lnValue, lnBitNess, lnBits
	*&
	llSuccess = INLIST(VARTYPE(pcString), "C", "N")
	*&
	IF llSuccess
		*&
		IF VARTYPE(pcString) = "C"
			*&
			*& -----------------------------------------
			*& Get it into a number and Cube it up...
			*& -----------------------------------------
			*&
			lnValue = StringSum(pcString) ^ 3
			*&
		ELSE 
			*&
			lnValue = pcString
			*&
		ENDIF && VARTYPE(pcString) = "C"
		*&
		*& --------------------------------
		*& Bitness Defaults to 32 bits...
		*& --------------------------------
		*&
		lnBitNess = IIF(VARTYPE(pnBits) = "N" AND pnBits = 16, 16, 32)
		*&
		lnBits = BitSize(lnValue) 
		*&
		IF lnBits > lnBitness
			*&
			lnValue = MOD(lnValue, 2 ^ lnBitness)
			*&
		ENDIF && lnBits > lnBitness
		*&
		*& --------------------------------------------
		*& Make sure we're working with an Integer...
		*& --------------------------------------------
		*&
		lnValue = INT(lnValue)
		*&
		IF VARTYPE(pnBase) = "N" AND pnBase = 16
			*&
			*& ------------------------------------------------------
			*& This will be in Hex and will actually be a string...
			*& ------------------------------------------------------
			*&
			lnValue = SUBSTR(TRANSFORM(lnValue, "@0"), 3)
			*&
			IF lnBitness = 16
				*&
				*& ------------------------------------------
				*& We only need the right most 4 digits...
				*& ------------------------------------------
				*&
				lnValue = RIGHT(lnValue, 4)
				*&
			ENDIF && lnBitness = 16
			*&
		ENDIF && VARTYPE(pnBase) = "N" AND pnBase = 16
		*&
	ENDIF && llSuccess
	*&
	RETURN lnValue
	*&
ENDFUNC && CheckSum(pcString, pnBase, pnBits)
*&
*& *************************************************************************
*& SerialNumber(pcGroup, pcEntity, pcTimeStamp)
*& =========================================================================
*& Takes a series of values and converts them to a Serial Number...
*& *************************************************************************
*&
*& ------------------------------------------------------------
*& Generate a Serial Number based on appropriate inputs...
*& ------------------------------------------------------------
*& Each field is based on a Base 16 (Hex) and 16 Bit Values
*& having a combined value of 64 bits in 16 digits...
*& ------------------------------------------------------------
*&
FUNCTION SerialNumber(pcGroup, pcNode, pcTimeStamp)
	*&
	LOCAL lcSN, lnSalt, lnGroup, lnNode, lnStamp, lnCheckSum
	*&
	IF PCOUNT() = 0 OR ISNULL(pcGroup)
		*&
		*& -----------------------------------
		*& Return the NULL Serial Number...
		*& -----------------------------------
		*&
		RETURN "0000-0000-0000-0000"
		*&
	ENDIF && PCOUNT() = 0 OR ISNULL(pcGroup)
	*&
	lnSalt = StringSum("Morton Salt")
	lnGroup = CheckSum(pcGroup) + lnSalt
	lnNode = CheckSum(pcNode) + lnSalt
	lnTimeStamp = CheckSum(pcTimeStamp) + lnSalt
	*&
	lcSN = CheckSum(lnGroup, 16, 16) + "-" ;
		+ CheckSum(lnNode, 16, 16) + "-" ;
		+ CheckSum(lnTimeStamp, 16, 16)
	*&
	*& ---------------------------------------------
	*& Strip out the dashes for the checksum...
	*& ---------------------------------------------
	*&
	lnCheckSum = CheckSum(STRTRAN(lcSN, "-", "")) + lnSalt
	*&
	lcSN = lcSN + "-" + CheckSum(lnCheckSum, 16, 16)
	*&
	RETURN lcSN
	*&
ENDFUNC && SerialNumber(pcGroup, pcEntity, pcTimeStamp)
*&
*& *************************************************************************
*& Password(pcPassword, pcRules, pnBits, pnBase, pcTitle)
*& =========================================================================
*& Converts a Password to a storable and comparable value...
*& *************************************************************************
*&
FUNCTION Password(pcPassWord, pcRules, pnBits, pnBase, pcTitle)
	*&
	*&
	*& ----------------------------------------
	*& Initialize Local Variables...
	*& ----------------------------------------
	*&
	LOCAL llSuccess, lnPassword
	*&
	STORE 0 TO lnPassword
	*&
	IF VARTYPE(pcPassword) = "C"
		*&
		*& ------------------------------------------
		*& Validate any applied rules...
		*& ------------------------------------------
		*&
		llSuccess = PasswordRules(pcPassWord, pcRules, pcTitle)
		*&
		IF llSuccess
			*&
			*& ------------------------------------------
			*& Convert it into a number...
			*& ------------------------------------------
			*&
			lnPassword = StringSum(pcPassWord)
			*&
		ENDIF && llSuccess
		*&
	ENDIF && VARTYPE(pcPassword) = "C"
	*&
	IF llSuccess
		*&
		*& ------------------------------------------------------------
		*& Do any post processing on how the value is to be stored...
		*& ------------------------------------------------------------
		*& Default values are Base 10 and 32 Bit...
		*& ------------------------------------------------------------
		*&
		lnPassword = CheckSum(lnPassword, pnBase, pnBits)
		*&
	ELSE 
		*&
		*& -------------------------------------------------------
		*& If we don't have a successful password, don't return
		*& a password value...
		*& -------------------------------------------------------
		*&
		lnPassword = 0
		*&
	ENDIF &&  llSuccess
	*&
	RETURN lnPassword
	*&
ENDFUNC && Password(pcPassWord, pcRules, pnBits, pnBase, pcTitle)
*&
*& *************************************************************************
*& PasswordRules(pcPassWord, pcRules, pcTitle)
*& =========================================================================
*& Provides for establishing rules for the construction of a Password...
*& *************************************************************************
*&
*& --------------------------------------------------------------------
*& Simple implementation for handling Password Construction Rules...
*& --------------------------------------------------------------------
*& pcRules should be a string of rules indicating any minimum size
*& at the beginning, then upper case "U", "L", "N", "S" which are the
*& standard rules that people like to implement...
*& --------------------------------------------------------------------
*& You can say no rules by simply passing in an empty string...
*& --------------------------------------------------------------------
*&
FUNCTION PasswordRules(pcPassWord, pcRules, pcTitle)
	*&
	*& -------------------------------
	*& Initialize Local Variables...
	*& -------------------------------
	*&
	LOCAL llSuccess, llHasRules, llAlpha, llUpper, llLower, llNumber, llSpecial, ;
		lnMinLength, lnLength, lnChar, lnASCII
	*&
	STORE 0 TO lnMinLength, lnChar, lnLength, lnASCII
	*&
	*& ----------------------------------------------
	*& Assume Success of no rules are provided...
	*& ----------------------------------------------
	*&
	llSuccess = VARTYPE(pcPassWord) = "C"
	*&
	llHasRules = VARTYPE(pcRules) = "C" AND LEN(pcRules) > 0
	*&
	IF llSuccess AND NOT llHasRules
		*&
		*& ------------------------------------------------
		*& We don't have any rules so all is well...
		*& ------------------------------------------------
		*&
		RETURN .T.
		*&
	ENDIF && llSuccess AND VARTYPE(pcRules) <> "C"
	*&
	IF llSuccess
		*&
		*& ---------------------------------------------------------
		*& Possible Rules are:
		*& ---------------------------------------------------------
		*& M - Minimum Number of Digits... (Replace M with Number)
		*& A - Alpha - Case Doesn't Matter...
		*& U - Upper Case
		*& L - Lower Case
		*& N - Numeric
		*& S - Special, Punctuation or Other Characters
		*& Q - Quiet Mode... Suppress the MessageBox...
		*& ---------------------------------------------------------
		*& Example: "8ULNS" or "8ANS"
		*& ---------------------------------------------------------
		*&
		*& ------------------------------------------------------------
		*& Make sure the minimum length is satisfied if indicated...
		*& ------------------------------------------------------------
		*&
		lnLength = LEN(pcPassWord)
		*&
		lnMinLength = INT(VAL(pcRules))
		*&
		llSuccess = lnLength >= lnMinLength
		*&
		IF llSuccess
			*&
			FOR lnPos = 1 TO LEN(pcPassWord)
				*&
				lnASCII = ASC(SUBSTR(pcPassPhrase, lnChar, 1))
				*&
				DO CASE
				CASE BETWEEN(lnASCII,48, 57)
					*&
					*& ---------------------------------------------
					*& Numeric Characters (0-9)...
					*& ---------------------------------------------
					*&
					llNumber = .T.
					*&
				CASE BETWEEN(lnASCII, 65, 90)
					*&
					*& ---------------------------------------------
					*& Upper Case Alphabet (A-Z)...
					*& ---------------------------------------------
					*&
					llAlpha = .T.
					llUpper = .T.
					*&
				CASE BETWEEN(lnASCII,97, 122)
					*&
					*& ---------------------------------------------
					*& Lower Case Alphabet (a-z)...
					*& ---------------------------------------------
					*&
					llAlpha = .T.
					llLower = .T.
					*&
				CASE BETWEEN(lnASCII,32, 47) OR BETWEEN(lnASCII,58, 64) ;
					OR BETWEEN(lnASCII, 123, 126)
					*&
					*& ---------------------------------------------
					*& Special, Punctuation, or Other Characters...
					*& ---------------------------------------------
					*&
					llSpecial = .T.
					*&
				ENDCASE 
				*&
				*& -----------------------------------------------------------
				*& Test for Specific Character Rules...
				*& -----------------------------------------------------------
				*& At this point Assume Success...  If any of the conditions
				*& are not met, then it will be set right back to False...
				*& -----------------------------------------------------------
				*&
				llSuccess = .T.
				*&
				llSuccess = IIF("A" $ pcRules, llSuccess AND llAlpha, llSuccess)
				llSuccess = IIF("U" $ pcRules, llSuccess AND llUpper, llSuccess)
				llSuccess = IIF("L" $ pcRules, llSuccess AND llLower, llSuccess)
				llSuccess = IIF("N" $ pcRules, llSuccess AND llNumber, llSuccess)
				llSuccess = IIF("S" $ pcRules, llSuccess AND llSpecial, llSuccess)
				*&
				*& -------------------------------------------------------
				*& If all of the conditions are met, we're done here...
				*& -------------------------------------------------------
				*&
				IF llSuccess
					*&
					EXIT 
					*&
				ENDIF && llSuccess
				*&
			ENDFOR && lnPos = 1 TO LEN(pcPassPhrase)
			*&
		ENDIF && llSuccess
		*&
		*& --------------------------------------------------------
		*& You can include a Q for Quiet in the Rules in order to
		*& suppress the message...
		*& --------------------------------------------------------
		*&
		IF NOT llSuccess AND AT("Q", pcRules) = 0
			*&
			*& ---------------------------------------------------
			*& Display a message regarding the applied rules...
			*& ---------------------------------------------------
			*& Q is a special constraint meaning Quiet Mode...
			*& ---------------------------------------------------
			*&
			MESSAGEBOX(PW_RuleMsg(pcRules), 48, ;
				IIF(VARTYPE(pcTitle) = "C", pcTitle, "Password Rules"))
			*&
		ENDIF && NOT llSuccess AND AT("Q", pcRules) = 0
		*&
	ENDIF && llSuccess
	*&
	RETURN llSuccess
	*&
ENDFUNC && PasswordRules(pcPassPhrase, pcRules)
*&
*& *************************************************************************
*& PW_RuleMsg(pcRules)
*& =========================================================================
*& Takes a Rule String and converts to user friendly text...
*& *************************************************************************
*&
*& ----------------------------------------------------
*& Generate a Message representing Password Rules...
*& ----------------------------------------------------
*&
FUNCTION PW_RuleMsg(pcRules)
	*&
	*& ---------------------------------
	*& Initialize Local Variables...
	*& ---------------------------------
	*&
	LOCAL lcMessage, lnMinLength, llAlpha, llUpper, llLower, llNumber, llSpecial, lcCRLF
	*&
	STORE "" TO lcMessage
	STORE 0 TO lnMinLength
	STORE CHR(13)+CHR(10) TO lcCRLF
	*&
	IF VARTYPE(pcRules) = "C"
		*&
		*& ---------------------------------------------
		*& Below are the currently definable rules...
		*& ---------------------------------------------
		*& There is also a potential Quiet Mode simply
		*& by adding a Q at the end of the string...
		*& ---------------------------------------------
		*&
		lnMinLength = INT(VAL(pcRules))
		llAlpha = "A" $ pcRules
		llUpper = "U" $ pcRules
		llLower = "L" $ pcRules
		llNumber = "N" $ pcRules
		llSpecial = "S" $ pcRules
		*&
		lcMessage = "The following Password Rules have been applied:" + lcCRLF
		*&
		lcMessage = lcMessage + IIF(lnMinLength > 0, CHR(9) + "Minimum " ;
			+ TRANSFORM(lnMinLength) + " Character" + IIF(lnMinLength=1,"","s") ;
			+ lcCRLF,"")
		*&
		lcMessage = lcMessage + IIF(llAlpha, CHR(9) + "Alpha Characters" + lcCRLF,"")
		lcMessage = lcMessage + IIF(llUpper, CHR(9) + "Uppercase Characters" + lcCRLF,"")
		lcMessage = lcMessage + IIF(llLower, CHR(9) + "Lowercase Characters" + lcCRLF,"")
		lcMessage = lcMessage + IIF(llNumber, CHR(9) + "Numeric Characters" + lcCRLF,"")
		lcMessage = lcMessage + IIF(llSpecial, CHR(9) ;
			+ "Special, Punctuation, or Other Characters" + lcCRLF,"")
		*&
	ENDIF && VARTYPE(pcRules) = "C"
	*&
	RETURN lcMessage
	*&
ENDFUNC && PW_RuleMsg(pcRules, pcTitle)
*&
FUNCTION XRand2(pvSeed, pnDigits)
*&
*& -----------------------------------------------------
*& Define a couple of constants for the Randomizer...
*& -----------------------------------------------------
*&
#define cnCONST_1	1.123456789
#define cnCONST_2	1.2345
*&
*& ----------------------------------------------------------
*& Initialize a Public Variable for the Randomizer State...
*&
*& This should only be needed once...
*& ----------------------------------------------------------
*&
IF TYPE("_RAND_STATE") <> "N"
	*&
	RELEASE _RAND_STATE
	PUBLIC _RAND_STATE
	*&
	STORE 0 TO _RAND_STATE
	*&
ENDIF && TYPE("_RAND_STATE") <> "N"
*&
*& ------------------------------------
*& Initialize Local Variables...
*& ------------------------------------
*&
LOCAL lnSeed, lnDigits, lcDigits
*&
lnSeed = -1
lnDigits = 2
*&
STORE "" TO lcDigits
*&
IF VARTYPE(pnDigits) = "N" AND pnDigits > 0
	*&
	lnDigits = pnDigits
	*&
ENDIF && VARTYPE(pnDigits) = "N" AND pnDigits > 0
*&
*& --------------------------------------------------
*& Check for any Seedlings...
*& --------------------------------------------------
*&
DO CASE 
CASE VARTYPE(pvSeed) = "C"
	*&
	*& --------------------------------------------------
	*& Generate a Salted Seed from the given string...
	*& --------------------------------------------------
	*&
	lnSeed = StringSum(pvSeed) + StringSum("Pink Salt")
	*&
	_RAND_STATE = lnSeed
	*&
CASE VARTYPE(pvSeed) = "N"
	*&
	IF pvSeed < 0
		*&
		*& ------------------------------------------------------------
		*& Take the seed back into positive form plus the number of
		*& days since the beginning of the century and the number of
		*& seconds since midnight...
		*& ------------------------------------------------------------
		*&
		lnSeed = (pvSeed * -1) + (DATE() - CTOD("10/01/2000")) + SECONDS()
		*&
	ELSE
		*&
		lnSeed = pvSeed
		*&
	ENDIF && pvSeed < 0
	*&
	_RAND_STATE = lnSeed
	*&
OTHERWISE 
	*&
	*&
ENDCASE 
*&
*& -------------------------------------------------
*& Randomize the Current State into a New State...
*& -------------------------------------------------
*&
_RAND_STATE = (_RAND_STATE * cnCONST_1) + cnCONST_2
*&
*& -------------------------------------------------
*& Extract the Desired number of Digits...
*& -------------------------------------------------
*&
lcDigits = PADL(SUBSTR(TRANSFORM(_RAND_STATE - FLOOR(_RAND_STATE)), 3, lnDigits), lnDigits, "0")
*&
RETURN lcDigits
*&
ENDFUNC && XRand2(lvSeed, pnDigits)
*&
*& *************************************************************************
*& XRand(lvSeed)
*& =========================================================================
*& Generates a random sequence of values based on a seed...
*& *************************************************************************
*&
FUNCTION XRand(lvSeed)
	*&
	*& -----------------------------------------------
	*& xRand - Simple PRNG Engine...
	*& -----------------------------------------------
	*&
	*& The basic rules for this PRNG are as follows:
	*&
	*& 1. Return a positive value between 0 and 1 
	*&    (the value shall always be greater than
	*&    0.00 but less than 1.00).
	*& 2. Do not return the same value back to back.
	*& 3. Allow seeding with either numeric value or
	*&    string value.  Strings are converted to a
	*&    16bit CRC Checksum for the seed.
	*&
	*& -----------------------------------------------
	*&
	*& -------------------------------------------------
	*& Check to see if _Rand needs to be initialized...
	*& -------------------------------------------------
	*&
	IF TYPE("_RAND_SEED") = "U"
		*&
		PUBLIC _RAND_SEED
		*&
	endIF && TYPE("_RAND_SEED") = "U"
	*&
	IF TYPE("_RAND_START") <> "N"
		*&
		PUBLIC _RAND_START
		*&
	ENDIF && TYPE("_RAND_START") <> "N"
	*&
	IF TYPE("_RAND_OUT") <> "N"
		*&
		PUBLIC _RAND_OUT
		STORE 0 TO _RAND_OUT
		*&
	ENDIF && TYPE("_RAND_OUT") <> "N"
	*&
	IF TYPE("_RAND") <> "N"
		*&
		*& ----------------------
		*& Set the Base seed...
		*& ----------------------
		*&
		RELEASE _RAND
		PUBLIC "_RAND"
		*&
		*& ------------------------------
		*& Initialize Default seed...
		*& ------------------------------
		*&
		_RAND = 10001
		_RAND_SEED = _RAND
		_RAND_START = _RAND
		*&
	ENDIF && TYPE("_RAND") = "U"
	*&
	*& -------------------------------
	*& Initialize local variables...
	*& -------------------------------
	*&
	LOCAL lnRand, lnPass, llSame, lnLen, lnPos
	store 0 to lnRand, lnPass, lnLen, lnPos
	*&
	*& ---------------------------------
	*& Test for a User Defined Seed...
	*& ---------------------------------
	*&
	DO CASE 
	CASE TYPE("lvSeed") = "C"
		*&
		*& ------------------------
		*& Use a 32 bit Integer...
		*& ------------------------
		*&
		_RAND = CheckSum(lvSeed, 10, 32)
		*&
		_RAND_OUT = 0
		_RAND_SEED = _RAND
		_RAND_START = _RAND
		*&
	CASE TYPE("lvSeed") = "N"
		*&
		*& -----------------------
		*& Use the seed as is...
		*& -----------------------
		*&
		_RAND_OUT = 0
		*&
		IF lvSeed < 0
			*&
			*& ------------------------------------------------------------
			*& This is a request for something that is actually random...
			*& ------------------------------------------------------------
			*& For simplicity here we will use the number of seconds since
			*& midnight Jan 1, 2000...
			*& ------------------------------------------------------------
			*&
			_RAND = (DTOT(DATE()) - CTOT("01/01/2000")) + SECONDS()
			*&
			*& ------------------------------------------------------------
			*& Add in whatever was provided by the seed itself...
			*& ------------------------------------------------------------
			*&
			_RAND = _RAND + (lvSeed * -1)
			*&
		ELSE
			*&
			*& ------------------------------
			*& Use what was provided...
			*& ------------------------------
			*&
			_RAND = lvSeed
			*&
		ENDIF && lvSeed < 0
		*&
		_RAND_SEED = _RAND
		_RAND_START = _RAND
		*&
	ENDCASE 
	*&
	DO WHILE EMPTY(lnRand) OR llSame
		*&
		IF lnPass > 0 AND NOT llSame
			*&
			*& -------------------------------------
			*& Increment the seed and reprocess...
			*& -------------------------------------
			*&
			_RAND_SEED = _RAND_SEED + 1
			_RAND = _RAND_SEED
			*&
		ENDIF && lnPass > 0
		*&
		*& ---------------------
		*& Randomize...
		*& ---------------------
		*&
		_RAND = (_rand * 1.103515245) + 12345
		*&
		*& -----------------------------------------
		*& Extract the 2 decimal places desired...
		*& -----------------------------------------
		*&
		lnRand = INT(VAL(SUBSTR(STR(_rand - INT(_RAND),4,2),3)))
		*&
		*& -------------------------------------------------
		*& Do not generate the same value twice in a row...
		*& -------------------------------------------------
		*&
	 	llSame = (lnRand == _RAND_OUT)
		*&
		IF llSame
			*&
			LOOP
			*&
		ELSE 
			*&
			_RAND_OUT = lnRand
			*&
		ENDIF && llSame
		*&
		*& ------------------------------------------
		*& Setup the loop to handle 00 values which
		*& are not desired...
		*& ------------------------------------------
		*&
		lnPass = 1
		*&
	ENDDO && WHILE EMPTY(lnRand)
	*&
	*& ----------------------------------------
	*& Extract the product with the decimal...
	*& ----------------------------------------
	*&
	lnRand = VAL(STR(_rand - INT(_RAND),4,2))
	*&
	*& -----------------------------------
	*& Insure the value is positive...
	*& -----------------------------------
	*&
	IF lnRand < 0
		*&
		lnRand = lnRand * -1
		*&
	ENDIF && lnRand < 0
	*&
	lnRand = INT(VAL(SUBSTR(TRANSFORM(lnRand),3)))
	*&
	RETURN lnRand
	*&
ENDFUNC && XRand(lvSeed)
*&
FUNCTION Cube(pnNumber)
	*&
	RETURN INT(pnNumber ^ 3)
	*&
ENDFUNC && Cube(pnNumber)
*&
*& *************************************************************************
*& Percent(pnValue)
*& 
*& Convert Percentage Value to User Friendly Representation...
*& *************************************************************************
*&
FUNCTION Percent(pnValue)
	*&
	LOCAL lcPercent
	STORE "" TO lcPercent
	*&
	IF pnValue = 100
		*&
		lcPercent =  PADL(ALLTRIM(STR(pnValue, 6, 2)) + "%", 7)
		*&
	ELSE 
		*&
		lcPercent =  SPACE(1) + PADL(ALLTRIM(STR(pnValue, 6, 2)) + "%", 6, "0")
		*&
	ENDIF && pnValue = 100
	*&
	RETURN lcPercent
	*&
ENDFUNC && Percent(pnValue)
*&
*& *************************************************************************
*& GetTime(pdDateTime)
*& 
*& Convert or Generate a Time Value in the special Numeric Format...
*& *************************************************************************
*&
FUNCTION GetTime(pdDateTime)
	*&
	*& -------------------------------------------------------
	*& Timestamps in this context need the granularity of
	*& the Seconds and Milliseconds since Midnight, but...
	*&
	*& They also need the date context in order to survive 
	*& a process that runs past Midnight...
	*&
	*& For this purpose and for convenience rather than using
	*& the UNIX EPOCH of Jan. 1, 1970, here we will use the
	*& beginning of the Century...
	*& -------------------------------------------------------
	*& Get the number of seconds since Midnight, Jan. 1, 2000
	*& -------------------------------------------------------
	*& This routine will return a number that represents time
	*& during a day or it may be expanded to include the date
	*& information as well in order to survive midnight...
	*& -------------------------------------------------------
	*&
	LOCAL ldDate, lnTime
	*&
	ldDate = DATE()
	lnTime = SECONDS()
	*&
	IF INLIST(VARTYPE(pdDateTime),"D","T","C")
		*&
		IF VARTYPE(pdDateTime) == "C"
			*&
			*& ----------------------------------------------
			*& Convert from String Format to actual Date...
			*& ----------------------------------------------
			*&
			DO CASE 
			CASE LEN(pdDateTime) = 19 AND OCCURS("-", pdDateTime) = 2 ;
				AND SPACE(1) $ pdDateTime
				*&
				*& -----------------------------------------
				*& Sortable DateTime Format...
				*& -----------------------------------------
				*& Add the T to make it convert easier...
				*& -----------------------------------------
				*&
				ldDate = CTOT(STRTRAN(pdDateTime," ","T"))
				*&
			CASE LEN(pdDateTime) = 10 AND OCCURS("-", pdDateTime) = 2 ;
				AND OCCURS("T", pdDateTime) = 0
				*&
				*& ----------------------------------------------
				*& Sortable Date Format without the Time...
				*& ----------------------------------------------
				*& Add the T to get it back into a DateTime...
				*& ----------------------------------------------
				*&
				ldDate = CTOT(pdDateTime + "T")
				*&
			CASE LEN(pdDateTime) = 8 AND OCCURS(":", pdDateTime) = 2
				*&
				*& ----------------------------------------------------
				*& This is really just a Time Span value... HH:MM:SS
				*& ----------------------------------------------------
				*&
				lnTime = (INT(VAL(GETWORDNUM(pdDateTime, 1, ":"))) * 3600) ;
					+ (INT(VAL(GETWORDNUM(pdDateTime, 2, ":"))) * 60) ;
					+ (INT(VAL(GETWORDNUM(pdDateTime, 3, ":"))))
				*&
				*& --------------------------------------------------
				*& Special Case here...
				*& --------------------------------------------------
				*& Only one that does not have a Date...
				*& --------------------------------------------------
				*& This will return seconds since midnight without
				*& the date...  Essentially a value less than 86400
				*& which is 3600 * 24...  Seconds since Midnight...
				*& --------------------------------------------------
				*&
				RETURN lnTime
				*&
			OTHERWISE 
				*&
				*& ------------------------------------------------------------
				*& Should be a standard Date/DateTime String...
				*& ------------------------------------------------------------
				*& Convert the DateTime string into the DateTime Datatype...
				*& ------------------------------------------------------------
				*&
				ldDate = CTOT(pdDateTime)
				*&
			ENDCASE 
			*&
		ELSE
			*&
			*& ------------------------------------------------
			*& Take it as it is (D or T)...
			*& ------------------------------------------------
			*& If it's a D, make sure it has a time element...
			*& ------------------------------------------------
			*&
			ldDate = IIF(VARTYPE(pdDate)="D", DTOT(pdDate), ldDate)
			*&
		ENDIF && VARTYPE(pdDate) == "C"
		*&
		*& -------------------------------------------
		*& This is to convert a provided context...
		*& -------------------------------------------
		*& No matter what it should be in a DateTime
		*& format by now... T Type date with Time...
		*& -------------------------------------------
		*&
		lnTime = ldDate - CTOT("01/01/2000")
		*&
	ELSE 
		*&
		*& -------------------------------------------
		*& No Parameter...
		*& -------------------------------------------
		*& This is to generate the Now Time...
		*& -------------------------------------------
		*&
		lnTime = (DTOT(ldDate) - CTOT("01/01/2000")) + lnTime
		*&
	ENDIF && INLIST(VARTYPE(pdDate),"D","T")
	*&
	*& ----------------------------------------------------------
	*& This returns a Numeric Time Value that includes a Date...
	*& ----------------------------------------------------------
	*& Use with TimeStamp(nTime) to get a sortable string...
	*& ----------------------------------------------------------
	*&
	RETURN lnTime
	*&
ENDFUNC && GetTime()
*&
*& *************************************************************************
*& TimeStamp(pnTime)
*& 
*& Get a User Friendly / Log Friendly Sortable Timestamp...
*& *************************************************************************
*&
FUNCTION TimeStamp(pnTime)
	*&
	*& ----------------------------------------------------------------------
	*& Check to see if it is just Time or if it includes a Date...
	*& ----------------------------------------------------------------------
	*&
	LOCAL lcTime
	*&
	lcTime = ""
	*&
	DO CASE 
	CASE VARTYPE(pnTime) = "N" AND pnTime > 86400
		*&
		*& -----------------------------------------------------------
		*& This value contains a date for Midnight Survivability...
		*& -----------------------------------------------------------
		*&
		lcTime = STRTRAN(TTOC(CTOT("01/01/2000") + pnTime, 3),"T"," ")
		*&
	CASE VARTYPE(pnTime) = "N" AND pnTime >= 0
		*&
		*& -------------------------------------------------------------
		*& pnTime should be a normal seconds since midnight format...
		*& -------------------------------------------------------------
		*&
		lcTime = LEFT(TTOC(DATE(),3), 10) + SPACE(1) + TimeSpan(pnTime)
		*&
	OTHERWISE 
		*&
		*& -------------------------------------------------------------
		*& Fetch a fresh time for this TimeStamp...
		*& -------------------------------------------------------------
		*&
		lcTime = LEFT(TTOC(DATE(),3), 10) + SPACE(1) + TimeSpan(SECONDS())
		*&
	ENDCASE 
	*&
	*&
	RETURN lcTime
	*&
ENDFUNC && TimeStamp()
*&
*& *************************************************************************
*& TimeSpan(pnSeconds)
*& 
*& Convert seconds to a user friendly representation of a period of time...
*& *************************************************************************
*&
FUNCTION TimeSpan(pnSeconds)
	*&
	LOCAL lcDuration, lnHours, lnMinutes, lnSeconds
	*&
	STORE 0 TO lnHours, lnMinutes, lnSeconds
	*&
	lcDuration = "00:00:00"
	*&
	DO CASE 
	CASE VARTYPE(pnSeconds) <> "N"
		*&
		*& Do Nothing...
		*&
	CASE pnSeconds > 86400
		*&
		*& -----------------------------------------------
		*& More than a day...
		*& -----------------------------------------------
		*& This is a Time value that includes a date...
		*& -----------------------------------------------
		*& Just convert to a TimeStamp and strip out the
		*& Time portion...
		*& -----------------------------------------------
		*&
		lcDuration = SUBSTR(TimeStamp(pnSeconds),12)
		*&
*	CASE pnSeconds >= 3600
	OTHERWISE 
		*&
		*& ---------------------------------------------
		*& Standard Seconds since Midnight format...
		*& Just pack up the values HH:MM:SS...
		*& ---------------------------------------------
		*&
		lnHours = FLOOR(pnSeconds / 3600)
		lnMinutes = MOD(pnSeconds, 3600)
		lnSeconds = INT(MOD(lnMinutes, 60))
		lnMinutes = INT(lnMinutes / 60)
		*&
		lcDuration = TRANSFORM(lnHours)
		lcDuration = IIF(LEN(lcDuration) = 1, PADL(lcDuration, 2, "0"), lcDuration)
		lcDuration = lcDuration + ":" + PADL(lnMinutes, 2, "0") + ":" + PADL(lnSeconds, 2, "0")
		*&
	ENDCASE  
	*&
	RETURN lcDuration
	*&
ENDFUNC && TimeSpan(pnSeconds)
*&
*& ------------------------------------------------------
*& Simply append the message to the end of the file...
*& ------------------------------------------------------
*&
FUNCTION WriteLine(pcMessage, pcFile)
	*&
	*& ------------------------------------------------------
	*& Take the Message and Append it to the given File...
	*& ------------------------------------------------------
	*&
	lnBytes = STRTOFILE(pcMessage + CHR(13)+CHR(10), pcFile, .T.)
	*&
	RETURN lnBytes
	*&
ENDFUNC && WriteLine(pcMessage, pcFile)
*&
*& ---------------------------------------------
*& Cleanup Procedure, Clears the workbench...
*& ---------------------------------------------
*&
PROCEDURE C
	*&
	CLEAR ALL
	CLOSE ALL 
	RELEASE ALL 
	CLEAR 
	*&
ENDPROC && C
*&
*!*	FUNCTION rw_montecarlo()
*!*		*&
*!*		lnNumberOfWalks = 10000
*!*		*&
*!*		*& Run again later for 20000
*!*		*& Determine longest waslk with 50 percent chance of walking home...
*!*		*& average 22 walks...
*!*		*&
*!*		*& Find the Longest Random Walk which will, on average,
*!*		*& leave you less than  blocks from home...
*!*		*&
*!*		FOR lnWalk_Length = 1 TO 31
*!*			*&
*!*			*& ---------------------------------------------
*!*			*& No of walks 4 or fewer blocks from home...
*!*			*& ---------------------------------------------
*!*			*&
*!*			lnNo_Transportw = 0
*!*			*&
*!*			FOR lnI = 1 TO lnNumberofWalks
*!*				*&
*!*				(x,y) = random_walk_2(lnWalk_Length)
*!*				*&
*!*				distance = ABS(x) + ABS(y)
*!*				*&
*!*				IF distance <= 4
*!*					*&
*!*					lnNo_Transport = lnNo_Transport + 1
*!*					*&
*!*				ENDIF && distance <= 4
*!*				*&
*!*			ENDFOR && lnI = 1 TO lnNumberofWalks
*!*			*&
*!*			lnNo_Transport_Percentage = (lnNo_Transport / lnNumberofWalks) * 100
*!*			*&
*!*			?" ", "Walk size = ", lnWalk_Length, " / % of no transport = ", lnNo_Transport_Percentage
*!*			*&
*!*		ENDFOR && lnWalk_Length = 1 TO 31
*!*		*&
*!*	ENDFUNC && rw_montecarlo()
*!*	*&
*!*	FUNCTION walk2()
*!*		*&
*!*		FOR lnI = 1 TO 25
*!*			*&
*!*			walk = randomwalk2(10)
*!*			?" ", walk, "Distance from home = ", ABS(walk[0] + ABS(walk[1]))
*!*			*&
*!*		ENDFOR && lnI = 1 TO 25
*!*		*&
*!*	ENDFUNC && walk2()
*!*	*&
*!*	FUNCTION RandomWalk2(n)
*!*		*&
*!*		*& -----------------------------------------------------
*!*		*& Return coordinates after 'n' block random walk...
*!*		*& -----------------------------------------------------
*!*		*&
*!*		STORE 0 TO x, y 
*!*		*&
*!*		FOR i IN range(n):
*!*			*&
*!*			(dx, dy) = random.choice([(0,1), (0, -1), (1, 0), (-1, 0)])
*!*			*&
*!*			x = x + dx
*!*			y = y + dy
*!*			*&
*!*		ENDFOR && i IN range(n):
*!*		*&
*!*		RETURN (x, y)
*!*		*&
*!*	ENDFUNC && RandomWalk2(n)
*!*	*&
*!*	*& **************************************************************
*!*	*& RandomWalk()
*!*	*& **************************************************************
*!*	*&
*!*	FUNCTION walk()
*!*		*&
*!*		FOR i IN range(25):
*!*			*&
*!*			walk = random_walk(10)
*!*			?" ", walk, "Distance from home = ", ABS(walk[0]) + ABS(walk[1])
*!*			*&
*!*		ENDFOR && i IN range(25):
*!*		*&
*!*	ENDFUNC && walk()
*!*	*&
*!*	FUNCTION RandomWalk(n)
*!*		*&
*!*		*& -------------------------------------------------------------
*!*		*& Max Blocks Away from home 4...  Then buy transport home...
*!*		*& -------------------------------------------------------------
*!*		*&
*!*		x = 0
*!*		y = 0
*!*		*&
*!*		FOR i IN range(n):
*!*			*&
*!*			step = random.choice(["N", "S", "E", "W"])
*!*			*&
*!*			DO CASE
*!*			CASE Step = "N"
*!*				*&
*!*				y = y + 1
*!*				*&
*!*			CASE Step = "S"
*!*				*&
*!*				y = y - 1
*!*				*&
*!*			CASE Step = "E"
*!*				*&
*!*				x = x + 1
*!*				*&
*!*			CASE Step = "W"
*!*				*&
*!*				x = x - 1
*!*				*&
*!*			ENDCASE 
*!*			*&
*!*		ENDFOR && i IN range(n):
*!*		*&
*!*		RETURN (x,y)
*!*		*&
*!*		*&
*!*	ENDFUNC && RandomWalk(n)
