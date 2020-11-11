*& =============================================================
*& xfile.prg
*&
*& =============================================================
*& 
*& ***************************************************
*& Class Definition: xFile
*& ***************************************************
DEFINE CLASS xFile as Session
*&
FilePath = ""
*&
*& ================================================
*& xFile.FilePath_ASSIGN(cPath)
*& ------------------------------------------------
*& Abstract method needs to be overridden if the
*& underlying file class cannot handle the path...
*& ------------------------------------------------
*& The default behavior here will be to accept
*& any file path be it valid or not.
*& ------------------------------------------------
*& Keep in mind that this class may be used by a
*& File that is about to be created...
*& ------------------------------------------------
*& The only rule is that the cPath that is passed 
*& in is a character type.  It may be empty which is
*& to say the filepath should be blanked and indicate
*& that the class points to no file or the null
*& file...
*& ================================================
*&
PROCEDURE FilePath_ASSIGN(cPath)
	*&
	LOCAL llSuccess
	*&
	llSuccess = VARTYPE(cPath) == "C"
	*&
	WITH This
		*&
		IF llSuccess
			*&
			.FilePath = cPath
			*&
		ENDIF && llSuccess
		*&
	ENDWITH && This
	*&
ENDPROC && FilePath_ASSIGN(cPath)
*&
*& ================================================
*& xFile.IsFile(cPath)
*& ------------------------------------------------
*& This is a two way helper method.  If a parameter
*& is passed then it is an override for this call
*& to indicate if that arbitrary file is present.
*& If the parameter is not passed, then the behavior
*& is to indicate if the currently set FilePath is
*& present or not...
*& ================================================
*&
PROCEDURE IsFile(cPath)
	*&
	LOCAL llSuccess
	*&
	WITH This
		*&
		IF VARTYPE(cPath) == "C"
			*&
			*& ------------------------------------
			*& Use the parameter as an override...
			*& ------------------------------------
			*&
			llSuccess = FILE(cPath)
			*&
		ELSE
			*&
			*& ------------------------------------
			*& Run based on the currently selected
			*& filepath, as a default...
			*& ------------------------------------
			*&
			llSuccess = FILE(.FilePath)
			*&
		ENDIF && VARTYPE(cPath) == "C"
		*&
		*&
	ENDWITH && This
	*&
	RETURN llSuccess
	*&
ENDPROC && IsFile(cPath)
*&
*& ================================================
*& xFile.DecToHex(nValue)
*& ------------------------------------------------
*& This is a simple helper method.  That will take
*& an Integer and convert it to it's hexidecimal
*& value in a character form...
*& ================================================
*&
PROCEDURE DecToHex(nValue)
	*&
	LOCAL llSuccess, lcHexValue
	*&
	STORE "" TO lcHexValue
	*&
	llSuccess = VARTYPE(nValue) == "N"
	*&
	IF llSuccess
		*&
		lcHexValue = TRANSFORM(nValue,"@0")
		*&
	ENDIF && llSuccess
	*&
	RETURN lcHexValue
	*&
ENDPROC && DecToHex(nValue)
*&
ENDDEFINE && CLASS xFile as Session
*&
