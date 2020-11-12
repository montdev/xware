*&
*& ******************************************************
*& xFile - Generic Low Level File Class
*&
*& This is a Base File class that will be used
*& for all other file implementations...
*& ******************************************************
*&
DEFINE CLASS xFile AS SESSION
	*&
	filepath = ""
	filehandle = 0
	FileAttributes = 0
	*&
	DTHelper = .NULL.
	*&
	*&=================================================
	*& xFile.Init()
	*&
	*& xFile Constructor Event...
	*&=================================================
	*&
	PROCEDURE Init()
		*&
		SET CENTURY ON
		*&
		This.DTHelper = CREATEOBJECT("DTHelper")
		*&
	ENDPROC && Init()
	*&
	*&=================================================
	*& xFile.Destroy()
	*&
	*& xFile Destructor Event...
	*&=================================================
	*&
	PROCEDURE Destroy()
		*&
		This.Close()
		*&
	ENDPROC &&Destroy() 
	*&
	*&
	*&=================================================
	*& xFile.IsFile(pcFile)
	*&
	*& Determine if the indicated file exists...
	*&=================================================
	*&
	PROCEDURE IsFile(pcFile)
		*&
		LOCAL llSuccess
		*&
		IF VARTYPE(pcFile) == "C" AND FILE(pcFile)
			*&
			llSuccess = .T.
			*&
		ELSE 
			*&
			llSuccess = FILE(This.FilePath)
			*&
		ENDIF && VARTYPE(pcFile) == "C" AND FILE(pcFile)
		*&
		RETURN llSuccess
		*&
	ENDPROC && IsFile(pcFile)
	*&
	*&=================================================
	*& xFile.IsOpen()
	*&
	*& Determine if the Current File is Open...
	*&=================================================
	*&
	PROCEDURE IsOpen()
		*&
		LOCAL llSuccess
		*&
		llSuccess = VARTYPE(This.FileHandle) = "N" ;
			AND This.FileHandle > 0
		*&
		RETURN llSuccess
		*&
	ENDPROC && IsOpen()
	*&
	*&=================================================
	*& xFile.IsReadOnly()
	*&
	*& Determine if the Current File is Read Only...
	*&=================================================
	*&
	PROCEDURE IsReadOnly()
		*&
		LOCAL llSuccess
		*&
		llSuccess = VARTYPE(This.FileAttributes) = "N" ;
			AND INLIST(This.FileAttributes,0,10)
		*&
		RETURN llSuccess
		*&
	ENDPROC && IsOpen()
	*&
	*&=================================================
	*& xFile.IsWritable()
	*&
	*& Determine if the Current File is Writable...
	*&=================================================
	*&
	PROCEDURE IsWritable()
		*&
		LOCAL llSuccess
		*&
		llSuccess = VARTYPE(This.FileAttributes) = "N" ;
			AND INLIST(This.FileAttributes,1,2,11,12)
		*&
		RETURN llSuccess
		*&
	ENDPROC && IsOpen()
	*&
	*&=================================================
	*& xFile.Open(pcFile, pnAttribute, plCreate)
	*&
	*& Open the designated file...
	*&=================================================
	*&
	PROCEDURE Open(pcFile, pnAttribute, plCreate)
		*&
		LOCAL llSuccess, lnHandle, lnAttribute, lcFile
		*&
		STORE 0 TO lnHandle, lnAttribute
		STORE "" TO lcFile
		*&
		IF VARTYPE(pnAttribute) = "N"
			*&
			lnAttribute = pnAttribute
			*&
		ENDIF && VARTYPE(pnAttribute) = "N"
		*&
		WITH This
			*&
			IF VARTYPE(pcFile) = "C" AND NOT EMPTY(pcFile)
				*&
				*& --------------------------------
				*& Open the filepath provided...
				*& --------------------------------
				*&
				lcFile = pcFile
				*&
			ELSE
				*&
				*& -----------------------------
				*& Use the current filepath...
				*& -----------------------------
				*&
				lcFile = .FilePath
				*&
			ENDIF && VARTYPE(pcFile) = "C" AND NOT EMPTY(pcFile)
			*&
			IF .IsOpen()
				*&
				*& --------------------------------------------
				*& If a file is already open then close it...
				*& --------------------------------------------
				*&
				.Close()
				*&
			ENDIF && .IsOpen()
			*&
			IF NOT .IsFile(lcFile) AND plCreate
				*&
				*& --------------------------------------------
				*& Go ahead and create the file on the fly...
				*& --------------------------------------------
				*&
				llSuccess = .Create(lcFile)
				*&
				IF llSuccess
					*&
					*& -----------------------------------------------------
					*& Close it now to open with the desired privelidges...
					*& -----------------------------------------------------
					*&
					.Close()
					*&
					*&
				ELSE 
					*&
					*& ----------------------------------------------
					*& If it's not there and I can't create it then
					*& I probably won't be able to open it...
					*& ----------------------------------------------
					*& Well go ahead and just let it fail...
					*& ----------------------------------------------
					*&
				ENDIF && llSuccess
				*&
			ENDIF && NOT .IsFile(lcFile) AND plCreate
			*&
			lnHandle = FOPEN(lcFile,lnAttribute)
			*&
			.FileHandle = lnHandle
			.FilePath = lcFile
			.FileAttributes = lnAttribute
			*&
			llSuccess = lnHandle > 0
			*&
		ENDWITH && This
		*&
		RETURN llSuccess
		*&
	ENDPROC && Open(pcFile, pnAttribute, plCreate)
	*&
	*& -----------------------------
	*& Create the designated file...
	*& -----------------------------
	*&
	PROCEDURE Create(pcFile, pnAttribute)
		*&
		LOCAL llSuccess, lcFile, lnHandle, lnAttribute
		*&
		STORE 0 TO lnHandle, lnAttribute
		STORE "" TO lcFile
		*&
		IF VARTYPE(pnAttribute) = "N"
			*&
			lnAttribute = pnAttribute
			*&
		ENDIF && VARTYPE(pnAttribute) = "N"
		*&
		WITH This
			*&
			IF .IsOpen()
				*&
				*& --------------------------------------------
				*& If a file is already open then close it...
				*& --------------------------------------------
				*&
				.Close()
				*&
			ENDIF && .IsOpen()
			*&
			IF VARTYPE(pcFile) = "C" AND NOT EMPTY(pcFile)
				*&
				*& --------------------------------
				*& Open the filepath provided...
				*& --------------------------------
				*&
				lcFile = pcFile
				*&
			ELSE
				*&
				*& -----------------------------
				*& Use the current filepath...
				*& -----------------------------
				*&
				lcFile = .FilePath
				*&
			ENDIF && VARTYPE(pcFile) = "C" AND NOT EMPTY(pcFile)
			*&
			lnHandle = FCREATE(lcFile,lnAttribute)
			*&
			.FileHandle = lnHandle
			.FilePath = lcFile
			*&
		ENDWITH && This
		*&
		llSuccess = lnHandle > 0
		*&
		RETURN llSuccess
		*&
	ENDPROC && CREATE(pcFile, pnAttribute)
	*&
	*& ---------------------------------------------------------
	*& Close: Close the current file...
	*& ---------------------------------------------------------
	*&
	PROCEDURE Close()
		*&
		LOCAL llSuccess, lnHandle
		*&
		lnHandle = This.FileHandle
		*&
		llSuccess = FCLOSE(lnHandle)
		*&
		IF llSuccess
			*&
			This.FileHandle = 0
			This.FileAttributes = 0
			*&
		ENDIF && llSuccess
		*&
		RETURN llSuccess
		*&
	ENDPROC && Close()
	*&
	*& ---------------------------------------------------------
	*& FileSize: Determine the bytesize of the current file...
	*& ---------------------------------------------------------
	*&
	PROCEDURE FileSize()
		*&
		LOCAL lnOffSet, lnSize
		*&
		*& -------------------------------------
		*& Save the current file postion...
		*& -------------------------------------
		*&
		lnOffSet = This.CurrentOffset()
		*&
		*& -------------------------------------
		*& Get the current File Size...
		*& -------------------------------------
		lnSize = FSEEK(This.FileHandle,0,2)
		*&
		*& -------------------------------------
		*& Restore the original file postion...
		*& -------------------------------------
		This.SeekOffset(lnOffSet,0)
		*&
		RETURN lnSize
		*&
	ENDPROC && FileSize()
	*&
	*& ==================================================
	*& xFile.EndofFile()
	*&
	*& This is a helper method to indicate if the file
	*& pointer address is at the end of file...
	*& ==================================================
	*&
	PROCEDURE EndOfFile()
		*&
		RETURN FEOF(This.FileHandle)
		*&
	ENDPROC && EndOfFile()
	*&
	*& ==================================================
	*& xFile.ChangeSize(pnNewSize)
	*&
	*& This is a helper method to change the size of the
	*& file...  It can be made longer or it can be
	*& truncated to the indicated byteposition...
	*& ==================================================
	*&
	PROCEDURE ChangeSize(pnNewSize)
		*&
		LOCAL lnAttribute, lnSizeOut
		*&
		STORE 0 TO lnAttribute, lnSizeOut
		*&
		WITH This
			*&
			*& ---------------------------
			*& See if it's Read Only...
			*& ---------------------------
			*&
			lnAttribute = .FileAttributes
			*&
			IF INLIST(lnAttribute, 0, 10)
				*&
				*& -------------------
				*& Open to Write...
				*& -------------------
				*&
				.Open(.T.,11)
				*&
			ENDIF && INLIST(lnAttribute, 0, 10)
			*&
			lnSizeOut = FCHSIZE(This.FileHandle,pnNewSize)
			*&
			*& ---------------------------
			*& Restore the Open Mode...
			*& ---------------------------
			*&
			IF INLIST(lnAttribute, 0, 10)
				*&
				.Open(.T.,lnAttribute)
				*&
			ENDIF && INLIST(lnAttribute, 0, 10)
			*&
		ENDWITH && This
		*&
		RETURN lnSizeOut
		*&
	ENDPROC && ChangeSize(pnNewSize)
	*&
	*& ==================================================
	*& xFile.SeekOffset(pnOffset,pnDirection)
	*&
	*& This is a helper method to change the size of the
	*& file...  It can be made longer or it can be
	*& truncated to the indicated byteposition...
	*& ==================================================
	*&
	PROCEDURE SeekOffset(pnOffSet, pnDirection)
		*&
		RETURN FSEEK(This.FileHandle, pnOffSet, pnDirection)
		*&
	ENDPROC && ChangeSize(pnNewSize)
	*&
	*& ==================================================
	*& xFile.CurrentOffset()
	*&
	*& This is a helper method to change the size of the
	*& file...  It can be made longer or it can be
	*& truncated to the indicated byteposition...
	*& ==================================================
	*&
	PROCEDURE CurrentOffset()
		*&
		RETURN FSEEK(This.FileHandle, 0, 1)
		*&
	ENDPROC && CurrentOffset()
	*&
	*& ==================================================
	*& xFile.RelativeOffset(pnTarget)
	*&
	*& This is a helper method will determine what the
	*& relative offset to a target offset from the
	*& current offset pointer...
	*& ==================================================
	*&
	PROCEDURE RelativeOffset(pnTarget)
		*&
		*& ------------------------------------
		*& First validate the TragetOffset...
		*& ------------------------------------
		*&
		LOCAL llSuccess, lnCurrent, lnDistance
		*&
		STORE 0 TO lnCurrent, lnDistance
		*&
		llSuccess = VARTYPE(pnTarget) = "N"
		*&
		IF llSuccess
			*&
			WITH This
				*&
				*& ------------------------------------
				*& Next determine the CurrentOffset...
				*& ------------------------------------
				*&
				*& -------------------------------------------------
				*& Locate where the File Pointer is located...  Then
				*& determine the Relative Record Offset where it
				*& is located to determine where to move if needed
				*& for reading the field value...
				*& -------------------------------------------------
				*& We want to have minimal moveement here...
				*& -------------------------------------------------
				*&
				lnCurrent = .CurrentOffset()
				*&
				*& ------------------------------------------
				*& First determine the Direction to reach...
				*& ------------------------------------------
				*& Then determine the Distance to go...
				*& ------------------------------------------
				*&
				DO CASE
				CASE lnCurrent > pnTarget
					*&
					*& -------------------------------------------
					*& Move left, Relative to Current Position...
					*& -------------------------------------------
					*&
					lnDistance = (lnCurrent - pnTarget) * -1
					*&
				CASE lnCurrent = pnTarget
					*&
					*& ----------------------------------------------
					*& The Current Position is exactly where we need
					*& to be...
					*& ----------------------------------------------
					*&
					lnDistance = 0
					*&
				OTHERWISE 
					*&
					*& -------------------------------------------
					*& Move right, Relative to Current Position...
					*& lnCurrentPos < lnFieldOffset
					*& -------------------------------------------
					*&
					lnDistance = pnTarget - lnCurrent
					*&
				ENDCASE
				*&
			ENDWITH && This
			*&
		ENDIF && llSuccess
		*&
		RETURN lnDistance
		*&
	ENDPROC && RelativeOffset(pnTarget)
	*&
	*& ==================================================
	*& xFile.Read(pnSize)
	*&
	*& This is a helper method really intended to be
	*& used internally.  It will actually read the raw
	*& bytes from the open file from the current offset
	*& position.
	*&
	*& pnSize is the size of bytes to be read.
	*&
	*& ==================================================
	*&
	PROCEDURE Read(pnSize)
		*&
		LOCAL llSuccess, lcString
		*&
		STORE "" TO lcString
		*&
		llSuccess = VARTYPE(pnSize) == "N"
		*&
		IF llSuccess
			*&
			lcString = FREAD(This.FileHandle, pnSize)
			*&
		ENDIF && llSuccess
		*&
		RETURN lcString
		*&
	ENDPROC && Read(pnSize) 
	*&
	*& ==================================================
	*& xFile.ReadPos(pnPos,pnSize)
	*&
	*& This is a helper method really intended to be
	*& used internally.  It will actually read the raw
	*& bytes from the open file from a given offset
	*& position.
	*&
	*& pnPos is the offset the begin reading.
	*& pnSize is the size of bytes to be read.
	*&
	*& ==================================================
	*&
	PROCEDURE ReadPos(pnPos,pnSize)
		*&
		LOCAL llSuccess, lcString, lnReturnVal, lnI, lnOffSet
		*&
		STORE "" TO lcString
		STORE 0 TO lnReturnVal, lnI, lnOffSet
		*&
		llSuccess = VARTYPE(pnPos) == "N"
		*&
		IF llSuccess
			*&
			llSuccess = VARTYPE(pnSize) == "N" ;
				AND NOT EMPTY(pnSize)
			*&
		ENDIF && llSuccess
		*&
		WITH This
			*&
			IF llSuccess
				*&
				*& --------------------------------
				*& Save the current position...
				*& --------------------------------
				*&
				lnOffSet = .CurrentOffSet()
				*&
				*& --------------------------------
				*& Locate the Starting Position...
				*& --------------------------------
				*&
				=FSEEK(.FileHandle,pnPos,0)
				*&
				*& --------------------------------
				*& Read the bytes out...
				*& --------------------------------
				*&
				lcString = FREAD(.FileHandle, pnSize)
				*&
				*& --------------------------------
				*& Restore the original position...
				*& --------------------------------
				*&
				.SeekOffset(lnOffSet,0)
				*&
			ENDIF && llSuccess
			*&
		ENDWITH && This
		*&
		RETURN lcString
		*&
	ENDPROC && ReadPos(pnPos,pnSize)
	*&
	*& ==================================================
	*& xFile.GetString(pnBytes)
	*&
	*& This is a helper method really intended to be
	*& used internally.  It will actually read the raw
	*& bytes from the open file one line at a time up
	*& to a carriage return or the number of bytes that
	*& is passed in...
	*&
	*& ==================================================
	*&
	PROCEDURE GetString(pnBytes)
		*&
		LOCAL lnBytes, lcBytes
		*&
		STORE "" TO lcBytes
		*&
		*& -----------------------------------------------
		*& 8192 is the Maximum number of bytes that this
		*& function will read...
		*& -----------------------------------------------
		*&
		STORE 8192 TO lnBytes
		*&
		IF VARTYPE(pnBytes) = "N"
			*&
			lnBytes = pnBytes
			*&
		ENDIF && VARTYPE(pnBytes) = "N"
		*&
		lcBytes = FGETS(This.FileHandle,lnBytes)
		*&
		RETURN lcBytes
		*&
	ENDPROC && GetString()
	*&
	*& ==================================================
	*& xFile.Write(pcBytes)
	*&
	*& This is a helper method that is intended for
	*& internal use.  It is the opposite of read.
	*& It will write the given bytes from the current
	*& offset position...
	*&
	*& pcBytes is the binary string to be written to the
	*&   file.
	*& ==================================================
	*&
	PROCEDURE Write(pcBytes)
		*&
		LOCAL llSuccess, lnI, lnBytes, lnAttribute
		*&
		STORE 0 TO lnI, lnBytes, lnAttribute
		*&
		llSuccess = VARTYPE(pcBytes) == "C" ;
			AND NOT EMPTY(pcBytes)
		*&
		WITH This
			*&
			IF llSuccess
				*&
				llSuccess = .IsFile() AND .IsOpen()
				*&
			ENDIF && llSuccess
			*&
			IF llSuccess
				*&
				lnAttribute = .FileAttributes
				*&
				*& --------------------------
				*& See if it's Read Only...
				*& --------------------------
				*&
				IF INLIST(lnAttribute,0,10)
					*&
					.Open(.T.,11)
					*&
				ENDIF && INLIST(lnAttribute,0,10)
				*&
				lnBytes = INT(FWRITE(.FileHandle,pcBytes))
				*&
				*& --------------------------
				*& Restore if Read Only...
				*& --------------------------
				*&
				IF INLIST(lnAttribute,0,10)
					*&
					.Open(.T.,lnAttribute)
					*&
				ENDIF && INLIST(lnAttribute,0,10)
				*&
			ENDIF && llSuccess
			*&
		ENDWITH && This
		*&
		RETURN lnBytes
		*&
	ENDPROC && Write(pcBytes)
	*&
	*& ==================================================
	*& xFile.WritePos(pcBytes, pnPos)
	*&
	*& This is a helper method that is intended for
	*& internal use.  It is the opposite of read bytes.
	*&
	*& pcBytes is the binary string to be written to the
	*&   file.
	*& pnPos is the offset to begin writing.
	*& ==================================================
	*&
	PROCEDURE WritePos(pcBytes, pnPos)
		*&
		LOCAL llSuccess, lnI, lnBytes, lnOffSet, lnAttribute
		*&
		STORE 0 TO lnI, lnBytes, lnOffSet, lnAttribute
		*&
		llSuccess = VARTYPE(pcBytes) == "C" ;
			AND NOT EMPTY(LEN(pcBytes))
		*&
		IF llSuccess
			*&
			llSuccess = VARTYPE(pnPos) == "N"
			*&
		ENDIF && llSuccess
		*&
		WITH This
			*&
			IF llSuccess
				*&
				llSuccess = .IsFile() AND .IsOpen()
				*&
			ENDIF && llSuccess
			*&
			IF llSuccess
				*&
				*& -----------------------------
				*& Save the current position...
				*& -----------------------------
				*&
				lnOffSet = .CurrentOffset()
				*&
				*& ---------------------------
				*& See if it's Read Only...
				*& ---------------------------
				*&
				lnAttribute = .FileAttributes
				*&
				IF INLIST(lnAttribute, 0, 10)
					*&
					*& -------------------
					*& Open to Write...
					*& -------------------
					*&
*					.Open(.T.,11)
					=FCLOSE(.FileHandle)
					=FOPEN(.FilePath,11)
					*&
				ENDIF && INLIST(lnAttribute, 0, 10)
				*&
				*& ------------------------------
				*& Locate and Write the Bytes...
				*& ------------------------------
				*&
				=FSEEK(.FileHandle,pnPos,0)
				lnBytes = INT(FWRITE(.FileHandle,pcBytes))
				*&
				*& ---------------------------
				*& Restore the Open Mode...
				*& ---------------------------
				*&
				IF INLIST(lnAttribute, 0, 10)
					*&
*					.Open(.T.,lnAttribute)
					=FCLOSE(.FileHandle)
					=FOPEN(.FilePath,10)
					*&
				ENDIF && INLIST(lnAttribute, 0, 10)
				*&
				*& ----------------------------------
				*& Restore the original position...
				*& ----------------------------------
				*&
				.SeekOffset(lnOffSet,0)
				*&
			ENDIF && llSuccess
			*&
		ENDWITH && This
		*&
		RETURN lnBytes
		*&
	ENDPROC && WritePos(pcBytes, pnPos)
	*&
	*& ==================================================
	*& xFile.PutString(pcBytes, pnBytes)
	*&
	*& This is a helper method really intended to be
	*& used internally.  It will actually read the raw
	*& bytes from the open file one line at a time up
	*& to a carriage return or the number of bytes that
	*& is passed in...
	*&
	*& ==================================================
	*&
	PROCEDURE PutString(pcBytes, pnBytes)
		*&
		LOCAL llSuccess, lnBytes, lcBytes
		*&
		STORE 0 TO lnBytes
		*&
		llSuccess = VARTYPE(pcBytes) = "C"
		*&
		IF llSuccess
			*&
			IF VARTYPE(pnBytes) = "N"
				*&
				STORE pnBytes TO lnBytes
				*&
			ELSE
				*&
				STORE LEN(pcBytes) TO lnBytes
				*&
			ENDIF && VARTYPE(pnBytes) "N"
			*&
			lnBytes = FPUTS(This.FileHandle, pcBytes, lnBytes)
			*&
		ENDIF && llSuccess
		*&
		RETURN lnBytes
		*&
	ENDPROC && PutString(pcBytes, pnBytes)
	*&
	*& ==================================================
	*& xFile.Flush(plForce)
	*&
	*& This is a helper method used to Flush the buffer
	*& to disk if buffering is being used...
	*& ==================================================
	*&
	PROCEDURE Flush(plForce)
		*&
		*& ---------------------------------------------
		*& Flush the contents fo the buffer to disk...
		*& ---------------------------------------------
		*&
		RETURN FFLUSH(This.FilePointer,plForce)
		*&
	ENDPROC && Flush(plForce)
	*&
	PROCEDURE JustExt(pcFileName)
		*&
		IF VARTYPE(pcFileName) = "C"
			*&
			RETURN JUSTEXT(pcFileName)
			*&
		ELSE
			*&
			RETURN JUSTEXT(This.FilePath)
			*&
		ENDIF && VARTYPE(pcFileName) = "C"
		*&
	ENDPROC && JustExt(pcFileName)
	*&
	PROCEDURE JustStem(pcFileName)
		*&
		IF VARTYPE(pcFileName) = "C"
			*&
			RETURN JUSTSTEM(pcFileName)
			*&
		ELSE
			*&
			RETURN JUSTSTEM(This.FilePath)
			*&
		ENDIF && VARTYPE(pcFileName) = "C"
		*&
	ENDPROC && JustStem(pcFileName)
	*&
	PROCEDURE JustFName(pcFileName)
		*&
		IF VARTYPE(pcFileName) = "C"
			*&
			RETURN JUSTFNAME(pcFileName)
			*&
		ELSE
			*&
			RETURN JUSTFNAME(This.FilePath)
			*&
		ENDIF && VARTYPE(pcFileName) = "C"
		*&
	ENDPROC && JustFName(pcFileName)
	*&
	PROCEDURE JustPath(pcFileName)
		*&
		IF VARTYPE(pcFileName) = "C"
			*&
			RETURN JUSTPATH(pcFileName)
			*&
		ELSE
			*&
			RETURN JUSTPATH(This.FilePath)
			*&
		ENDIF && VARTYPE(pcFileName) = "C"
		*&
	ENDPROC && JustPath(pcFileName)
	*&
ENDDEFINE && CLASS xFile
