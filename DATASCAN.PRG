#DEFINE TOP "TOP"
*& *******************************************************************
*& dbfFile prototype...
*& *******************************************************************
*&
LPARAMETERS pcFileMask, pcScanType
*SET STEP ON 
*&
*& ----------------------------------
*& Initialize Exit/Cancel routine...
*& ----------------------------------
*&
RELEASE glRunning
PUBLIC glRunning
STORE .T. TO glRunning
*&
SET CENTURY ON
SET SAFETY OFF
SET MULTILOCKS ON
SET EXCLUSIVE OFF
SET ESCAPE OFF
*&
set proc to prgs/progbar.prg additive
*&
SYS(3050,1,10000000)
SYS(3050,2,10000000)
*&
*& One of the original purposes for reworking the dbf
*& File Class is to have an optimized method for scanning
*& a table(s) to be used as the engine for the data scanner...
*&
*& There are a number of tests that need to be performed
*& and subsequently logged.  This can be ran in the
*& background and serve as an alert tool to let us know
*& when there is an issue with a datafile that has been
*& detected...
*& *******************************************************************
*&
*& -------------------------------
*& Tests to be performed...
*& -------------------------------
*& 1 - Structure Integrity Test
*& 2 - Valid Deleted Flags
*& 3 - Data corruption
*& 4 - FTP Missing or Corruption
*& 5 - CDX Issues
*&
*& * Initially Issues will be logged to a logfile
*& * Potentially add a Socket Client to submit Log Entries
*&   to a server such as SysLog...
*& * Perhaps add ability to send reports via Email...
*& ******************************************************
*&
*SET STEP ON 
LOCAL loDS
*&
*& ---------------------------------------------
*& If it's just a Directory, then scan *.DBF in
*& that directory...
*& ---------------------------------------------
*&
IF DIRECTORY(pcFileMask)
	*&
	pcFileMask = FORCEPATH("*.DBF",pcFileMask)
	*&
ENDIF && DIRECTORY(pcFileMask)
*&
*& --------------------------
*& Select a folder to scan
*& --------------------------
*&
IF EMPTY(pcFileMask)
	*&
	* pcFileMask = GETDIR()
	pcFileMask = GETFILE("DBF", "Select a DBF to Scan...")
	*&
ENDIF && EMPTY(pcFileMask)
*&
*& -----------------------------------------------------
*& Default to all DBF Files in the selected folder...
*& -----------------------------------------------------
*&
IF EMPTY(pcFileMask)
	*&
	*& -----------------------------------------
	*& Positive Coding Style, Nothing to do...
	*& -----------------------------------------
	*&
ELSE 
	*&
	loDS = CREATEOBJECT("DataScanner")
	*&
	pcFileMask  = FULLPATH(pcFileMask)
	*&
	DO CASE
	CASE VARTYPE(pcFileMask) <> "C"
		*&
		*& -----------------
		*& Do nothing...
		*& -----------------
		*&
	CASE FILE(pcFileMask)
		*&
		*& ------------------------
		*& Scan the given file...
		*& ------------------------
		*&
		loDS.ScanFile(pcFileMask, pcScanType)
		*&
	CASE FILE(FORCEPATH(SYS(2000,pcFileMask),JUSTPATH(pcFileMask)))
		*&
		*& ----------------------
		*& Scan the FileMask...
		*& ----------------------
		*&
		loDS.ScanFiles(pcFileMask, pcScanType)
		*&
	OTHERWISE 
		*&
		MESSAGEBOX(pcFileMask,48,"Nothing to scan...")
		*&
	ENDCASE
	*&
	*&
	*&
ENDIF && NOT EMPTY(lcFileMask)
*&
RETURN
*&
DEFINE CLASS DataScanner AS Session
	*&
	*& -------------------------------------------------
	*& Datascanner.ScanFiles(pcFileMask, pcScanType)...
	*&
	*& Provide a File Skeleton and scan all the files
	*& that match the given skeleton...
	*& -------------------------------------------------
	*&
	PROCEDURE ScanFiles(pcFileMask, pcScanType)
		*&
		*& ----------------------------------
		*& Initialize Exit/Cancel routine...
		*& ----------------------------------
		*&
		RELEASE glRunning
		PUBLIC glRunning
		STORE .T. TO glRunning
		*&
		LOCAL llSuccess, lcFile, lcPath
		*&
		STORE "" TO lcFile, lcPath
		*&
		llSuccess = VARTYPE(pcFileMask) = "C" and not EMPTY(pcFileMask)
		*&
		IF llSuccess
			*&
			*& -----------------------------------------
			*& This is going to scan the files using a 
			*& Wildard Filemask...
			*& -----------------------------------------
			*&
			lcPath = JUSTPATH(pcFileMask)
			*&
			lcFile = SYS(2000,pcFileMask)
			*&
			*& --------------------------------------
			*& As long as there is a file to scan...
			*& Scan it...
			*& --------------------------------------
			*&
			DO WHILE FILE(FORCEPATH(lcFile,lcPath)) AND glRunning
				*&
				IF LASTKEY() = 27 OR NOT glRunning
					*&
					RETURN
					*&
				ENDIF && LASTKEY() = 27 OR NOT glRunning
				*&
				This.ScanFile(FORCEPATH(lcFile,lcPath), pcScanType)
				*&
				*& ----------------------------------
				*& Get the next file in the list...
				*& ----------------------------------
				*&
				lcFile = SYS(2000,pcFileMask,1)
				*&
			ENDDO && WHILE FILE(lcFile)
			*&
		ENDIF && llSuccess
		*&
	ENDPROC && ScanFiles(pcFileMask, pcScanType)
	*&
	*& -------------------------------
	*& Datascanner.ScanFile(pcFile,pcScanType)
	*& Scan a given DBF file...
	*& -------------------------------
	*&
	PROCEDURE ScanFile(pcFile, pcScanType)
		*&
		*& ----------------------------------
		*& Initialize Exit/Cancel routine...
		*& ----------------------------------
		*&
		RELEASE glRunning
		PUBLIC glRunning
		STORE .T. TO glRunning
		*&
		*& ----------------------------------
		*& Initialize Local Variables...
		*& ----------------------------------
		*&
		LOCAL llSuccess, llFixit, llRecordScan
		LOCAL loDBF, loLog
		LOCAL lnFileSize, lnRecord, lnMemoType, lnDataSession
		LOCAL lcPath, lcField, lcBytes, lnSize
		*&
		STORE .NULL. TO loDBF, loLog
		STORE 0 TO lnFileSize, lnRecord, lnMemoType, lnSize
		STORE "" TO lcPath, lcField, lcBytes
		*&
		llSuccess = VARTYPE(pcFile) = "C" and FILE(pcFile)
		*&
		IF llSuccess
			*&
			*& --------------------------------------------------------
			*& Determine the Scan Type...
			*& --------------------------------------------------------
			*& Header/Quick Scan
			*& Record/Full Scan
			*& Fix Problems or Not
			*& --------------------------------------------------------
			*& The Rules are simple...  No matter what it will Scan
			*& the Header...  Including the word Full or Record will
			*& result in a Full Record Scan.  Including the word Fix
			*& will cause any problems encountered to be fixed if it
			*& can be fixed...  (Not Case Sensitive)
			*& --------------------------------------------------------
			*&
			IF VARTYPE(pcScanType) = "C"
				*&
				llRecordScan = (ATC("FULL",pcScanType) > 0) OR (ATC("RECORD",pcScanType) > 0)
				llFixit = ATC("FIX",pcScanType) > 0
				*&
			ENDIF && VARTYPE(pcScanType) = "C"
			*&
			loDBF = CREATEOBJECT("dbfFile")
			*&
			loLog = CREATEOBJECT("Logger")
			loLog.AppName = "DataScan." + JUSTSTEM(pcFile)
			*&
			*& -------------------------------------------------
			*& Just leave the logfile in the default folder...
			*& -------------------------------------------------
			*&
			lcPath = FULLPATH("")
			*&
			loLog.FilePath = FORCEPATH(FORCEEXT("DataScan_" + DTOS(DATE()),"log"),lcPath)
			*&
			WITH loDBF
				*&
				*& --------------------------------------
				*& I may need to set it to the default
				*& DataSession so I can directly see the
				*& FieldInfo Cursor here...
				*& --------------------------------------
				*&
				lnDataSession = .DataSessionID
				.DataSessionID = This.DataSessionID
				*&
				*& --------------------------------
				*& Open Read-Only (Unbuffered)...
				*& --------------------------------
				*& It has been opening Read-Only
				*& Buffered, perhaps that is why
				*& the memory is getting so big when
				*& running a while...  Need to watch
				*& for memory leaks...
				*& --------------------------------
				*&
				IF .Open(pcFile,10)
					*&
					*& ------------------------------
					*& Verify it is a DBF file...
					*& ------------------------------
					*&
					loLog.WriteLn("OPEN: " + pcFile)
					.FileType = .GetHeader("DBFTYPE")
					*&
					*& ---------------------------------
					*& 0x30 is a Visual Foxpro DBF...
					*& ---------------------------------
					*&
					llSuccess = INLIST(.FileType,0x30, 0x31, 0x42, 0xFA)
					*&
					IF llSuccess
						*&
						*& ----------------------------------------------------
						*& Determine the filesize based on the file system...
						*& ----------------------------------------------------
						*&
						lnFileSize = .FileSize()
						*&
						loLog.WriteLn("INFO: " + "HS=" + TRANSFORM(.HeaderSize) ;
							+ " RS=" + TRANSFORM(.RecordSize) ;
							+ " RC=" + TRANSFORM(.RecordCount) ;
							+ " FS=" + TRANSFORM(lnFileSize))
						*&
						*& ----------------------------------------------------
						*& Verify the Logical File Size and the Record Count...
						*& ----------------------------------------------------
						*&
						*& There are two issues to look for...
						*&
						*& 1) The record count in the header doesn't match the
						*&    actual records present...
						*& 2) The logical size doesn't add up due to a truncated
						*&    record at the end...
						*&
						*& ----------------------------------------------------
						*&
						*& -------------------------------------------------------------
						*& First eheck the record count...
						*& lnRecCount = INT(FLOOR((lnFileSize-lnHeaderSize)/lnRecSize))
						*& -------------------------------------------------------------
						*&
						IF INT(FLOOR((lnFileSize-.HeaderSize)/.RecordSize)) = .RecordCount
							*&
							*& ----------------------------------
							*& The RecordCount matches...
							*& ----------------------------------
							*&
							loLog.WriteLn("OK: Record Count Matches Header Count")
							*&
						ELSE
							*&
							*& ----------------------------------
							*& The RecordCount doesn't match...
							*& ----------------------------------
							*&
							*& -----------------------------------------------
							*& Here if fixing the file we should update the
							*& record count in the header to match the true
							*& count of records in the file.  This still
							*& doesn't mean that the logical file size is
							*& correct either...  
							*& -----------------------------------------------
							*& Also remember that currently the file is 
							*& currently open for Read Only...
							*& -----------------------------------------------
							*&
							loLog.WriteLn("ERROR: Record Count Does not Match Header Count")
							*&
							IF llFixit
								*&
								*& ---------------------------------------------------------
								*& Update the Header Record Count to match the Logical 
								*& Record Count to the Header so there is a Logical Match...
								*& ---------------------------------------------------------
								*&
								.RecordCount = INT(FLOOR((lnFileSize-.HeaderSize)/.RecordSize))
								*&
								IF .PutHeader("RECORDCOUNT",.RecordCount)
									*&
									*& -------------------------
									*& Success... Do Nothing...
									*& -------------------------
									*&
									loLog.WriteLn("FIXED: Record COUNT - " + TRANSFORM(.RecordCount))
									*&
								ELSE
									*&
									*& ------------------------------------------
									*& Not able to update the Record Count...
									*& This is a Failed Fixit...
									*& ------------------------------------------
									*&
									loLog.WriteLn("ERROR: Fixit Failed to Correct Logical Record Count (" ;
										+ TRANSFORM(.RecordCount) + ")")
									*&
									*& --------------------------------------
									*& Restore the Original Record Count...
									*& --------------------------------------
									*&
									.RecordCount = .GetHeader("RECORDCOUNT")
									*&
								ENDIF && .PutHeader("RECORDCOUNT",INT(FLOOR((lnFileSize-.HeaderSize)/.RecordSize)))
								*&
							ENDIF && llFixit
							*&
						ENDIF && llSuccess
						*&
						*& --------------------------------------------
						*& Now test the overall logical filesize...
						*& --------------------------------------------
						*&
						llSuccess = (lnFileSize = (.HeaderSize ;
							+ IIF(.RecordCount > 0,(.RecordCount * .RecordSize) + 1,0)))
						*&
						IF llSuccess
							*&
							*& -----------------------------------------------------
							*& Here we can tell not only is the record size correct 
							*& but the overall logical size as well...
							*& -----------------------------------------------------
							*&
							loLog.WriteLn("OK: Logical File Size is Correct")
							*&
						ELSE
							*&
							*& -----------------------------------------------------
							*& There is a structural problem...
							*& -----------------------------------------------------
							*& Do the record counts match up or is it just the 
							*& logical file size (truncated record)
							*& -----------------------------------------------------
							*&
							loLog.WriteLn("ERROR: Logical File Size is Wrong")
							*&
							IF llFixit
								*&
								*& -------------------------------------------
								*& Increase the Filesize to match the Logical
								*& Record Count...
								*& -------------------------------------------
								*&
								lnFileSize = (.HeaderSize + IIF(.RecordCount > 0,(.RecordCount * .RecordSize) + 1,0))
								*&
								IF .ChangeSize(lnFileSize) = lnFileSize
									*&
									*& ------------------------------------
									*& Success... Do Nothing...
									*& ------------------------------------
									*&
									loLog.WriteLn("FIXED: Logical File Size - " + TRANSFORM(lnFileSize))
									*&
								ELSE
									*&
									*& --------------------------------------
									*& Alert the failure and reset the actual
									*& Filesize...
									*& --------------------------------------
									*&
									loLog.WriteLn("ERROR: Fixit Failed to Correct Logical Filesize (" ;
										+ TRANSFORM(lnFileSize) + ")")
									*&
									lnFileSize = .FileSize()
									*&
								ENDIF && .ChangeSize(lnFileSize) = lnFileSize
								*&
							ENDIF && llFixit
							*&
						ENDIF && llSuccess
						*&
						*& ---------------------------------------------
						*& Perform Record Level Tests...
						*& ---------------------------------------------
						*& Scan through the records...
						*& 1) First check the deleted flag
						*& 2) Scan across the fields checking for...
						*&   a) Odd characters in text fields
						*&   b) Bad links into the FPT file for Memos
						*&
						*& ---------------------------------------------
						*&
						*& ------------------------------------------------------
						*& There are basically two ways to traverse the file...
						*&
						*& 1) Iterate via Record Number by seeking each Record 
						*&    Offset...
						*&
						*& 2) Fast-Scan by not using seeks and just read the 
						*&    records sequentially straight through...
						*&
						*& ------------------------------------------------------
						*&    This battery will use the Fast-Scan method to be an 
						*&    optimal scan...
						*& ------------------------------------------------------
						*&
						*& -----------------------------------------------------------
						*& Go ahead and provide the basic field structure information 
						*& in  the log as well...
						*& -----------------------------------------------------------
						*&
						loLog.WriteLn("INFO: FieldCount(" + TRANSFORM(RECCOUNT()) + ")")
						*&
						SELECT FieldInfo
						*&
						SCAN WHILE glRunning
							*&
							loLog.WriteLn("INFO: Field" + PADL(TRANSFORM(RECNO()),LEN(TRANSFORM(RECCOUNT())),"0") ;
								+ " Name: " + Name ;
								+ " Type: " + Type ;
								+ " Offset: " + PADL(TRANSFORM(Offset),LEN(TRANSFORM(.RecordSize)),"0") ;
								+ " Length: " + PADL(TRANSFORM(Length),3," ") ;
								+ " Decimal: " + TRANSFORM(Decimal) ;
								+ " Flags: 0x" + RIGHT(TRANSFORM(Flags,"@0"),2) ;
								+ " AutoNext: " + TRANSFORM(AutoNext) ;
								+ " AutoStep: " + TRANSFORM(AutoStep))
							*&
						ENDSCAN && WHILE glRunning
						*&
						IF llRecordScan
							*&
							loLog.WriteLn("Record Scan Begin...")
							*&
							*& -----------------------------------
							*& Initialize to the first record...
							*& -----------------------------------
							*&
							=Progress("DataScan","Caption","Table Scan [" + justfname(pcFile) + "]")
							=Progress("DataScan","SHOWALLSTATS")
							=Progress("DataScan","ENABLECANCEL")
							=Progress("DataScan","Max",.RecordCount)
							*&
							.SeekOffset(.HeaderSize,0)
							*&
							DO WHILE glRunning AND NOT .EndOfFile()
								*&
								IF lnRecord = .RecordCount
									*&
									EXIT
									*&
								ENDIF && lnRecord = lnRecCount
								*&
								*& -----------------------------------------------------------
								*& We'll iterate through each of the fields later...
								*& -----------------------------------------------------------
								*& For now we just want to test the Deleted Flag and possibly 
								*& fix it on the fly...  This is theoretically as simple a 
								*& fix as the  RecCount is...
								*& -----------------------------------------------------------
								*&
								IF Progress("DataScan","CANCELED")
									*&
									EXIT
									*&
								ENDIF && Progress("DataScan","CANCELED")
								*&
								lnRecord = lnRecord + 1
								*&
								IF lnRecord = 1 OR EMPTY(MOD(lnRecord,MIN(.RecordCount,1000)))
									*&
									=Progress("DataScan","Message",pcFile + CHR(13) + CHR(10) ;
										+ "Records Processed: " + transform(lnRecord) ;
										+ " of " + transform(.RecordCount) + " records.")
									=Progress("DataScan","Value",lnRecord)
									*&
								ENDIF && EMPTY(MOD(lnRecord,MIN(.RecordCount,1000)))
								*&
								*& ---------------------------
								*& Test the Deleted Flag...
								*& ---------------------------
								*&
								lcField = .Read(1)
								*&
								llSuccess = INLIST(lcField," ", "*")
								*&
								IF llSuccess
									*&
									*& ------------------------------------
									*& This is a Valid Deletion Flag...
									*& ------------------------------------
									*&
*!*										loLog.WriteLn("OK: Delete Flag - Record " ;
*!*											+ PADL(TRANSFORM(lnRecord),LEN(TRANSFORM(.RecordCount)),"0") ;
*!*											+ " " + lcField)
									*&
								ELSE
									*&
									*& ------------------------------------
									*& This is an Invalid Deletion Flag...
									*& ------------------------------------
									*&
									loLog.WriteLn("ALERT: Delete Flag - Record " ;
										+ PADL(TRANSFORM(lnRecord),LEN(TRANSFORM(.RecordCount)),"0") ;
										+ " " + "0x" + RIGHT(TRANSFORM(ASC(lcField),"@0"),2))
									*&
									IF llFixit
										*&
										*& ---------------------------------------------
										*& Since the record will not be seen as deleted
										*& correct it to have the correct value of a
										*& Space...
										*& ---------------------------------------------
										*& Move the pointer back one and write a Space
										*& to this position...
										*& ---------------------------------------------
										*&
										IF .WritePos(" ",.CurrentOffset() - 1) = 1
											*&
											*& ---------------------------
											*& Success...  Do Nothing...
											*& ---------------------------
											*&
										ELSE
											*&
											*& ----------------------------------
											*& Alert the Log to this failure...
											*& ----------------------------------
											*&
											loLog.WriteLn("ALERT: Fixit Failed to Correct Deleted Flag")
											*&
										ENDIF && (.Write(" ") = 1)
										*&
									ENDIF && llFixit
									*&
								ENDIF && llSuccess
								*&
								*& -----------------------------------------------------
								*& Traverse the remainder of the record to be at the
								*& beginning of the next record...  Leave it located
								*& ready to read the next Deleted Flag...
								*& -----------------------------------------------------
								*&
								SELECT FieldInfo
								*&
								SCAN WHILE glRunning
									*&
									IF INLIST(FieldInfo.Type,"L","C","M","N","F","D")
										*&
										*& --------------------------------------
										*& This is something that will need the
										*& contents of the field scanned...
										*& --------------------------------------
										*&
										IF FieldInfo.Type = "M"
											*&
											*&
										ENDIF && FieldInfo.Type = "M"
										*&
										lcField = .Read(FieldInfo.Length)
										*&
										DO CASE
										CASE FieldInfo.Type = "M"
											*&
											*& ---------------------------------------------------------
											*& Pull the data from the FPT File...
											*& ---------------------------------------------------------
											*& This should be a Block Pointer into the FPT file...
											*& One test will be is the Type a valid Type to indicate if 
											*& the Memo has been slammed by a stale NextBlockPointer
											*& possibly I think the result of a failed Header Lock to 
											*& update...  Similar to the Recno Issue in DBF Files...
											*& ---------------------------------------------------------
											*&
											lcField = .DTHelper.Bytes2Int(lcField)
											*&
											IF EMPTY(lcField)
												*&
												*& ---------------------------
												*& This is an empty field...
												*& ---------------------------
												*&
												LOOP
												*&
											ELSE
												*&
												*& ---------------------------------------
												*& This must be a valid Block Pointer...
												*& ---------------------------------------
												*& Trap to test the Type...
												*& ---------------------------------------
												*&
												*& -----------------------------------------------------
												*& Check the Type to insure that it is a valid value...
												*& -----------------------------------------------------
												*&
												*& These are Valid Types...
												*& 0. = Picture
												*& 1. = Text
												*&
												*& Currently we are only set to perform tests for the
												*& Text type...  Picture will need more work to perform
												*& any validation on that.
												*& -----------------------------------------------------
												*&
												lnMemoType = .FPTFile.BlockInfo(lcField,"Type")
												*&
												IF INLIST(lnMemoType,0,1)
													*&
													*& ----------------------------------------------
													*& Currently we can only peform test on Type 1...
													*& ----------------------------------------------
													*&
													IF lnMemoType = 1
														*&
														*& ------------------
														*& Memo Text Data...
														*& ------------------
														*&
														IF FieldInfo.Name = "SVDC_DOC"
															*&
															*& --------------------------------------------
															*& This memo contains Compressed Word Docs...
															*& --------------------------------------------
															*& Every Single One of them will get Flagged...
															*& --------------------------------------------
															*& Due to being Binary Data there's nothing to 
															*& be fixed here...
															*& --------------------------------------------
															*&
															LOOP
															*&
														ENDIF && FieldInfo.Name = "SVDC_DOC"
														*&
														lcField = .FPTFile.GetData(lcField)
														*&
													ELSE
														*&
														*& ---------------------------------------------------------------------
														*& Memo Picture Data...
														*& Will need to Parse OLE Linking and Embedding Structure for these...
														*& ---------------------------------------------------------------------
														*&
														LOOP
														*&
													ENDIF && lnMemoType = 1
													*&
												ELSE
													*&
													*& ------------------------------------------
													*& This is not a valid Type...
													*& ------------------------------------------
													*& A Log Entry should be made here to
													*& indicate the Invalid Memo Type...
													*& ------------------------------------------
													*& In theory this can be fixed by simply
													*& changing the field block pointer value
													*& to 0 and just orphan the invalid data...
													*& ------------------------------------------
													*&
													loLog.WriteLn("ERROR: Invalid Memo Type - Record: " ;
														+ PADL(TRANSFORM(lnRecord),LEN(TRANSFORM(.RecordCount)),"0") ;
														+ " Field: " + FieldInfo.Name ;
														+ " Type: " + FieldInfo.Type ;
														+ " Block: " + TRANSFORM(lcField) ;
														+ " MemoType: " + TRANSFORM(lnMemoType))
													*&
													IF llFixit
														*&
														*& -------------------------------------------
														*& Zero out the Fields Block Pointer Value...
														*& -------------------------------------------
														*&
														IF .WritePos(REPLICATE(CHR(0),4), .CurrentOffset() - FieldInfo.Length)
															*&
															loLog.WriteLn("FIXED: Record: " ;
																+ PADL(TRANSFORM(lnRecord),LEN(TRANSFORM(.RecordCount)),"0") ;
																+ " Field: " + FieldInfo.Name + " Invalid Memo Type")
															*&
														ELSE
															*&
															loLog.WriteLn("ERROR: Fixit Failed to fix Invalid Memo Type Record: " ;
																+ PADL(TRANSFORM(lnRecord),LEN(TRANSFORM(.RecordCount)),"0") ;
																+ " Field: " + FieldInfo.Name + " Invalid Memo Type")
															*&
														ENDIF && .WritePos(REPLICATE(CHR(0),4), .CurrentOffset() - FieldInfo.Length)
														*&
													ENDIF && llFixit
													*&
													LOOP
													*&
												ENDIF && INLIST(.FPTFile.BlockInfo(lcField,"Type"))
												*&
											ENDIF && EMPTY(lcField)
											*&
											*& -----------------------------------------------------
											*& We need to Trap the Memo Type and verify the general
											*& integrity of the field data...
											*& -----------------------------------------------------
											*&
										ENDCASE
										*&
										*& --------------------------------------------------
										*& Scan the Data from the field to see if there is 
										*& anything that needs to be reported or logged...
										*& --------------------------------------------------
										*&
										lcBadChars = This.ScanData(lcField)
										*&
										IF EMPTY(lcBadChars)
											*&
											*& ---------------------------------------------
											*& There doesn't seem to be anything wrong with
											*& this field...
											*& ---------------------------------------------
											*&
										ELSE
											*&
											*& ---------------------------------------------
											*& There's something wrong with this field...
											*& This will need to be logged...
											*& ---------------------------------------------
											*&
											loLog.WriteLn("ALERT: Record: " ;
												+ PADL(TRANSFORM(lnRecord),LEN(TRANSFORM(.RecordCount)),"0") ;
												+ " Field: " + FieldInfo.Name ;
												+ " Type: " + FieldInfo.Type + " BadChars: " + lcBadChars)
											*&
										ENDIF && EMPTY(lcBadChars)
										*&
										IF LEN(lcBadChars) > 0 
										ENDIF && LEN(lcBadChars) > 0 
										*&
										IF llFixit AND LEN(lcBadChars) > 0 AND INLIST(FieldInfo.Type,"L","C","M")
											*&
											*& ---------------------------------------------
											*& This is where we'll attempt to correct the
											*& current field...
											*& ---------------------------------------------
											*& Note: Only the following types can currently
											*& be corrected in this manner!
											*& L, C, M...
											*& ---------------------------------------------
											*& Currently cannot make assumptions about a
											*& valid replacement value for N, F, D where the
											*& only plausible fix would be to consider the 
											*& whole value as invalid and just blank out the
											*& field...  Theoretically we could just blank
											*& out the field, but there are probably some
											*& ramifications or remediation that must be
											*& done if this approach is taken...
											*& ---------------------------------------------
											*& This is example of DeleteFlag or Logical fix...
											*& .WritePos(" ",.CurrentOffset() - 1) = 1
											*& ---------------------------------------------
											*& First loop through each byte in the data
											*& and strip out each of the BadChars...
											*& ---------------------------------------------
											*&
											FOR lnI = 1 TO GETWORDCOUNT(lcBadChars,",")
												*&
												lcField = STRTRAN(lcField,CHR(EVALUATE(GETWORDNUM(lcBadChars, lnI, ","))),"")
												*&
											ENDFOR && lnI = 1 TO GETWORDCOUNT(lcBadChars,",")
											*&
											IF FieldInfo.Type = "M"
												*&
												*& --------------------------------------------
												*& Memo fix will be written to the FPTFile...
												*& --------------------------------------------
												*& Hold off on implementing this fix as there
												*& will be cases that we will still need to
												*& trap for given how documents are stored in
												*& the Document Warehouse...  This could 
												*& potentially corrupt and ruin documents such
												*& as in the Document Warehouse and possibly
												*& other similar areas...
												*& --------------------------------------------
												*&
												loLog.WriteLn("ALERT: Fixit Not Yet Implemented for Memo Text")
												*&
											ELSE
												*&
												*& ---------------------------------------------
												*& Make sure the data matches the length of the
												*& field and write to the field position...
												*& ---------------------------------------------
												*&
												lcField = PADR(lcField,FieldInfo.Length," ")
												*&
												IF .WritePos(lcField, .CurrentOffset() - FieldInfo.Length) = FieldInfo.Length
													*&
													*& -------------------------------
													*& Success...  Do Nothing...
													*& -------------------------------
													*&
													loLog.WriteLn("FIXED: Record: " ;
														+ PADL(TRANSFORM(lnRecord),LEN(TRANSFORM(.RecordCount)),"0") ;
														+ " Field: " + FieldInfo.Name + " Type: " + FieldInfo.Type)
													*&
												ELSE
													*&
													*& -------------------------------
													*& Fixit Failed to Write...
													*& -------------------------------
													*&
													loLog.WriteLn("ALERT: Fixit Failed to Update Field")
													*&
												ENDIF && .WritePos(lcField, .CurrentOffset() - FieldInfo.Length) = FieldInfo.Length
												*&
											ENDIF && FieldInfo.Type = "M"
											*&
										ENDIF && llFixit AND LEN(lcBadChars) > 0
										*&
									ELSE
										*&
										*& ----------------------------------------
										*& Just move on over to the next field...
										*& Skip this field...
										*& ----------------------------------------
										*&
										.SeekOffset(FieldInfo.Length,1)
										LOOP
										*&
									ENDIF && INLIST(FieldInfo.Type,"C","M")
									*&
								ENDSCAN && while glRunning && FieldInfo
								*&
							ENDDO && WHILE glRunning AND NOT .EndOfFile()
							*&
							loLog.WriteLn("Record Scan Complete...")
							*&
							=Progress("DataScan","Release")
							*&
						ENDIF && llRecordScan
						*&
						loLog.WriteLn("DONE: Testing Complete!")
						*&
					ELSE && INLIST(.FileType,0x30, 0x31, 0x42, 0xFA)
						*&
						*& -------------------------------
						*& Not A Table...
						*& -------------------------------
						*&
						loLog.WriteLn("ERROR: Not A Valid FoxPro Table!" ;
							+ " FileType: 0x" + RIGHT(TRANSFORM(.FileType,"@0"),2) ;
							+ " FileName: " + TRANSFORM(JUSTFNAME(pcFile)))
						*&
					ENDIF && llSuccess
					*&
				ELSE
					*&
					*& ------------------------------
					*& Unable to open the file...
					*& ------------------------------
					*&
					loLog.WriteLn("ALERT: Unable to open the file...")
					*&
				ENDIF && .Open(pcFile)
				*&
				.DataSessionID = lnDataSession
				*&
			ENDWITH && loDBF
			*&
		ENDIF && llSuccess
		*&
		STORE .null. TO loDBF, loLog
		*&
	ENDPROC && ScanFile(pcFile, pcScanType)
	*&
	*& ========================================================================
	*& DataScanner.ScanData(pcData)
	*&
	*& This routine scans the contents of a data field to determine if there 
	*& are any invalid characters that may represent corruption or anything 
	*& else unseemly that needs to alert someones attention...
	*&
	*& The return value will be any values from the data that should bring 
	*& cause to alarm...
	*& ========================================================================
	*&
	PROCEDURE ScanData(pcData)
		*&
		LOCAL lcBadChars, lnChar, lcChar
		*&
		STORE "" TO lcBadChars, lcChar
		*&
		IF VARTYPE(pcData) == "C"
			*&
			FOR lnChar = 1 TO LEN(pcData)
				*&
				*& --------------------------------------------------------
				*& The various cases will trap for acceptable characters
				*& and the otherwise will trap the bad ones...
				*& --------------------------------------------------------
				*& Some characters are dependent on the Datatype and others
				*& may be dependent on the field name...
				*& --------------------------------------------------------
				*&
				lcChar = SUBSTR(pcData,lnChar,1)
				*&
				DO CASE
				CASE INLIST(UPPER(ALLTRIM(FieldInfo.Name)),"WEBPASS", "ACTI_CODE")
					*&
					*& ------------------------------------------------
					*& This is an encrypted field, expect anything...
					*& ------------------------------------------------
					*&
					RETURN ""
					*&
				CASE (UPPER(ALLTRIM(FieldInfo.Name)) == "BK_ACCTNO") AND BETWEEN(ASC(lcChar),135,137)
					*&
					*& --------------------------------------------------------------------
					*& These are special characters expected for a Bank Account number...
					*& --------------------------------------------------------------------
					*&
				CASE lcChar = " "
					*&
					*& --------------------------------------------
					*& Space should be okay for any field type...
					*& --------------------------------------------
					*&
				CASE INLIST(lcChar,"T","F") AND FieldInfo.Type = "L"
					*&
					*& -------------------------------
					*& Valid values for a Logical...
					*& -------------------------------
					*&
				CASE BETWEEN(ASC(lcChar),48,57) AND NOT FieldInfo.Type = "L"
					*&
					*& ------------------------------------------------
					*& 0-9...
					*& Number, Float, Char, Memo, and Date...
					*& ------------------------------------------------
					*&
				CASE INLIST(lcChar,".","-") AND INLIST(FieldInfo.Type,"N","F")
					*&
					*& ------------------------------------------------
					*& Decimal and Negative for Numeric and Floats...
					*& ------------------------------------------------
					*&
				CASE INLIST(ASC(lcChar), 13, 10, 9) AND FieldInfo.Type = "M"
					*&
					*& -------------------------------------
					*& White space chars CR, LF, and TAB...
					*& -------------------------------------
					*&
				CASE BETWEEN(ASC(lcChar),65,90) AND INLIST(FieldInfo.Type,"C","M")
					*&
					*& --------------------------
					*& A-Z
					*& --------------------------
					*&
				CASE BETWEEN(ASC(lcChar),97,122) AND INLIST(FieldInfo.Type,"C","M")
					*&
					*& --------------------------
					*& a-z
					*& --------------------------
					*&
				CASE INLIST(ASC(lcChar),ASC("("),ASC(")"),ASC("["),ASC("]"),ASC("{"),ASC("}"),ASC("<"),ASC(">")) ;
					AND INLIST(FieldInfo.Type,"C","M")
					*&
					*& ------------------
					*& Bracket Chars...
					*& ------------------
					*&
				CASE INLIST(ASC(lcChar),ASC("-"),ASC(" "),ASC("&"),ASC("."),ASC(","),ASC("'")) ;
					AND INLIST(FieldInfo.Type,"C","M")
					*&
					*& -----------------------------------
					*& Common punctuation marks...
					*& -----------------------------------
					*&
				CASE INLIST(ASC(lcChar),ASC("/"),ASC("\"),ASC("_"),ASC("#"),ASC("$")) AND INLIST(FieldInfo.Type,"C","M")
				CASE INLIST(ASC(lcChar),ASC(":"),ASC(";"),ASC("%"),ASC("^"),ASC("|")) AND INLIST(FieldInfo.Type,"C","M")
				CASE INLIST(ASC(lcChar),ASC("?"),ASC('"'),ASC("*"),ASC("+"),ASC("~")) AND INLIST(FieldInfo.Type,"C","M")
				CASE INLIST(ASC(lcChar),ASC("@"),ASC("%"),ASC("="),ASC("@")) AND INLIST(FieldInfo.Type,"C","M")
				CASE INLIST(ASC(lcChar),ASC("="),ASC("!")) AND INLIST(FieldInfo.Type,"C","M")
				CASE INLIST(ASC(lcChar), 0x60, 0x92, 0xA0) AND INLIST(FieldInfo.Type,"C","M")
					*&
					*& --------------------------------
					*& 0x60 = Grave Accent
					*& 0x92 = Acute Accent
					*& 0xA0 = NBSP (Non Breaking Space
					*& --------------------------------
					*&
				CASE INLIST(ASC(lcChar), 0xE1, 0xE8, 0xE9, 0xea, 0xED, 0xF1, 0xF3, 0xFA) AND INLIST(FieldInfo.Type,"C","M")
				CASE INLIST(ASC(lcChar),0xBD, 0x96, 0x99) AND INLIST(FieldInfo.Type,"C","M")
					*&
					*& ------------------
					*& Spanish Chars...
					*& ------------------
					*&
					*& aei0u with acute accents and the n with the tilde...
				CASE INLIST(ASC(lcChar), 0xC1, 0xC9, 0xCD, 0xD1, 0xD3, 0xDA) AND INLIST(FieldInfo.Type,"C","M")
				CASE INLIST(ASC(lcChar), 0x9F,0xFF) AND INLIST(FieldInfo.Type,"C","M")
					*&
				OTHERWISE
					*&
					*& ------------------------------------
					*& This would be a bad character...
					*& ------------------------------------
					*&
					lcChar = "0x" + RIGHT(TRANSFORM(ASC(lcChar),"@0"),2)
					*&
					IF NOT lcChar $ lcBadChars
						*&
						lcBadChars = lcBadChars + IIF(EMPTY(lcBadChars),"",",") + lcChar
						*&
					ENDIF && NOT lcChar $ lcBadChars
					*&
				ENDCASE
				*&
			ENDFOR && lnChar = 1 TO LEN(lcData)
			*&
			RETURN lcBadChars
			*&
		ENDIF && VARTYPE(FIELD(lnJ)) == "C"
		*&
		RETURN lcBadChars
		*&
	ENDPROC && ScanData(pcData)
	*&
ENDDEFINE && CLASS DataScanner as Session
*&
*& ******************************************************
*& dbfFile
*& ******************************************************
*& The dbfFile will extend the xFile to support 
*& the characteristics and properties of the 
*& dbf file structure...
*& ******************************************************
*&
DEFINE CLASS dbfFile as xFile
	*&
	HeaderSize = 0
	RecordSize = 0
	RecordCount = 0
	*&
	FileType = 0
	LastUpdate = CTOD("")
	HasMemo = .F.
	*&
	FPTFile = .NULL.
	*&
	*& ==========================================
	*& dbfFile.Open()
	*&
	*& Initialize the Header Data...
	*&
	*& 1) Initialise the Base Header Properties
	*& 2) Intialize the Fields
	*& 3) Initialize the Record Pointer
	*& ==========================================
	*&
	PROCEDURE Open(pcFile, pnAttribute, plCreate)
		*&
		IF DODEFAULT(pcFile, pnAttribute, plCreate)
*!*			IF DODEFAULT(pcFile, pnAttribute, plCreate) ;
*!*				AND VARTYPE(pcFile) = "C" AND FILE(pcFile)
			*&
			This.InitHeader()
			*&
		ENDIF && DODEFAULT(pcFile, pnAttribute, plCreate)
		*&
	ENDPROC && Open(pcFile, pnAttribute, plCreate)
	*&
	*& ==========================================
	*& dbfFile.Close()
	*&
	*& Closing down the file and performing
	*& basic cleanup...
	*& ==========================================
	*&
	PROCEDURE Close()
		*&
		IF DODEFAULT()
			*&
			WITH This
				*&
				IF .HasMemo
					*&
					*& ---------------------------
					*& Close out the FPT File...
					*& ---------------------------
					*&
					IF TYPE("This.FPTFile") = "O" AND NOT ISNULL(.FPTFile)
						*&
						.FPTFile.Close()
						*&
						STORE .NULL. TO .FPTFile
						*&
					ENDIF && TYPE("This.FPTFile") = "O" AND NOT ISNULL(This.FPTFile)
					*&
				ENDIF && .HasMemo
				*&
				.HeaderSize = 0
				.RecordSize = 0
				.RecordCount = 0
				*&
				.FileType = 0
				.LastUpdate = CTOD("")
				.HasMemo = .F.
				*&
			ENDWITH && This
			*&
		ENDIF && DODEFAULT()
		*&
	ENDPROC && Close()
	*&
	*& ==========================================
	*& dbfFile.InitHeader()
	*&
	*& Initialize the Header Data...
	*&
	*& 1) Initialise the Base Header Properties
	*& 2) Intialize the Fields
	*& 3) Initialize the Record Pointer
	*& ==========================================
	*&
	PROCEDURE InitHeader()
		*&
		*& ------------------------------
		*& Initialize the Properties...
		*& ------------------------------
		*&
		WITH This
			*&
			*& --------------------------------------------
			*& Headersize and RecordSize won't change...
			*& RecordCount Can Change...
			*& --------------------------------------------
			*&
			.HeaderSize = .GetHeader("HEADERSIZE")
			.RecordSize = .GetHeader("RECORDSIZE")
			.RecordCount = .GetHeader("RECORDCOUNT")
			*&
			*& --------------------------------------------
			*& DBFType and HasMemo won't change...
			*& LastUpdate Can Change...
			*& --------------------------------------------
			*&
			.FileType = .GetHeader("DBFTYPE")
			.LastUpdate = .GetHeader("LASTUPDATE")
			.HasMemo = .GetHeader("HASMEMO")
			*&
			IF .HasMemo
				*&
				.FPTFile = CREATEOBJECT("fptFile")
				*&
				.FPTFile.Open(FORCEEXT(.FilePath,"fpt"),.FileAttributes)
				*&
				IF .FPTFile.IsOpen()
					*&
					*& --------------------------------------------
					*& May or may not need to do something here...
					*& It doesn't really require any other real
					*& initialization as long as it's open and
					*& readable (If Reading)...
					*& --------------------------------------------
					*&
					*&
				ELSE
					*&
					*& --------------------------------------------
					*& The file may be missing or for some reason
					*& was not able to open it...
					*& --------------------------------------------
					*&
					IF .FPTFile.IsFile()
						*&
						*& ---------------------------
						*& It just Failed to Open...
						*& ---------------------------
						*&
					ELSE
						*&
						*& --------------------------------
						*& The FPT is Definitely Missing...
						*& --------------------------------
						*&
					ENDIF && .FPTFile.IsFile()
					*&
				ENDIF && .FPTFile.IsOpen()
				*&
				*&
			ENDIF && .HasMemo
			*&
			*& --------------------------------
			*& Initialize the Fields Array...
			*& --------------------------------
			*&
			.InitFields()
			*&
			*& --------------------------------
			*& Seek the Start of Data...
			*& --------------------------------
			*&
			.SeekOffset(.HeaderSize,0)
			*&
		ENDWITH && This
		*&
	ENDPROC && Init()
	*&
	*& =================================================
	*& dbfFile GetHeader(pcField)
	*&
	*& Returns the value of a Field from the Header...
	*& =================================================
	*&
	PROCEDURE GetHeader(pcField)
		*&
		LOCAL lnOffSet, lnSize, lcBytes, lvValue
		*&
		STORE 0 TO lnOffSet, lnSize
		STORE "" TO lcBytes
		*&
		WITH THIS
			*&
			DO CASE
			CASE UPPER(pcField) = "DBFTYPE"
				*&
				lcBytes = .ReadPos(0,1)
				lvValue = ASC(lcBytes)
				*&
			CASE UPPER(pcField) = "LASTUPDATE"
				*&
				lcBytes = .ReadPos(1,3)
				*&
				*& YMD --> MDY (6 digit year - no century)
				*& 123     231
				lvValue = PADL(ASC(SUBSTR(lcBytes,2,1)),2,"0") + "/"
				lvValue = lvValue + PADL(ASC(SUBSTR(lcBytes,3,1)),2,"0") + "/"
				lvValue = lvValue + PADL(ASC(SUBSTR(lcBytes,1,1)),2,"0")
				*&
				*& Convert to a real date value...
				*&
				lvValue = CTOD(lvValue)
				*&
			CASE UPPER(pcField) = "RECORDCOUNT"
				*&
				lcBytes = .ReadPos(4,4)
				lvValue = .DTHelper.Bytes2Int(lcBytes)
				*&
			CASE UPPER(pcField) = "HEADERSIZE"
				*&
				lcBytes = .ReadPos(8,2)
				lvValue = .DTHelper.Bytes2Int(lcBytes)
				*&
			CASE UPPER(pcField) = "RECORDSIZE"
				*&
				lcBytes = .ReadPos(10,2)
				lvValue = .DTHelper.Bytes2Int(lcBytes)
				*&
			CASE UPPER(pcField) = "TABLEFLAGS"
				*&
				lcBytes = .ReadPos(28,1)
				lvValue = .DTHelper.Bytes2Int(lcBytes)
				*&
			CASE UPPER(pcField) = "HASCDX"
				*&
				lcBytes = .ReadPos(28,1)
				lvValue = BITTEST(.DTHelper.Bytes2Int(lcBytes),0)
				*&
			CASE UPPER(pcField) = "HASMEMO"
				*&
				lcBytes = .ReadPos(28,1)
*				lvValue = .DTHelper.Bytes2Int(lcBytes)
				lvValue = BITTEST(.DTHelper.Bytes2Int(lcBytes),1)
				*&
			CASE UPPER(pcField) = "ISDBC"
				*&
				lcBytes = .ReadPos(28,1)
*				lvValue = .Bytes2Int(lcBytes)
				lvValue = BITTEST(.DTHelper.Bytes2Int(lcBytes),2)
				*&
			CASE UPPER(pcField) = "BACKLINK"
				*&
				*& ------------------------------
				*& First need the Headersize...
				*& ------------------------------
				*&
				lcBytes = .ReadPos(8,2)
				lvValue = .DTHelper.Bytes2Int(lcBytes)
				*&
				*& ---------------------------------------------
				*& Now get the BackLink, strip out the nulls...
				*& ---------------------------------------------
				*&
				lvValue = STRTRAN(.ReadPos(lvValue - 263,263),CHR(0),"")
				*&
			ENDCASE
			*&
		ENDWITH && THIS
		*&
		RETURN lvValue
		*&
	ENDPROC && GetHeader(pcField)
	*&
	*& =================================================
	*& dbfFile PutHeader(pcField, pvValue)
	*&
	*& Updates a Header Field...
	*& =================================================
	*&
	PROCEDURE PutHeader(pcField, pvValue)
		*&
		*&
		LOCAL llSuccess, lnOffSet, lnSize, lcBytes, lvValue
		*&
		STORE 0 TO lnOffSet, lnSize
		STORE "" TO lcBytes
		*&
		WITH THIS
			*&
			DO CASE
			CASE UPPER(pcField) = "DBFTYPE"
				*&
				llSuccess = (VARTYPE(pvValue) = "N") AND BETWEEN(pvValue,0,255)
				*&
				IF llSuccess
					*&
					lnSize = .WritePos(CHR(pvValue),0)
					*&
				ENDIF && llSuccess
				*&
				llSuccess = (lnSize = 1)
				*&
			CASE UPPER(pcField) = "LASTUPDATE"
				*&
				llSuccess = (VARTYPE(pvValue) = "D") AND NOT EMPTY(pvValue)
				*&
				IF llSuccess
					*&
					lcBytes = CHR(SUBSTR(DTOS(pvValue),1,2))
					lcBytes = lcBytes + CHR(SUBSTR(DTOS(pvValue),5,2))
					lcBytes = lcBytes + CHR(SUBSTR(DTOS(pvValue),7,2))
					*&
					lnSize = .WritePos(lcBytes,1)
					*&
					llSuccess = (lnSize = 3)
					*&
				ENDIF && llSuccess
				*&
			CASE UPPER(pcField) = "RECORDCOUNT"
				*&
				llSuccess = (VARTYPE(pvValue) = "N")
				*&
				IF llSuccess
					*&
					lcBytes = .DTHelper.Int2Bytes(pvValue,4)
					lnSize = .WritePos(lcBytes,4)
					*&
					llSuccess = (lnSize = 4)
					*&
				ENDIF && llSuccess
				*&
			CASE UPPER(pcField) = "HEADERSIZE"
				*&
				llSuccess = (VARTYPE(pvValue) = "N")
				*&
				IF llSuccess
					*&
					lcBytes = .DTHelper.Int2Bytes(pvValue,2)
					lnSize = .WritePos(lcBytes,8)
					*&
					llSuccess = (lnSize = 2)
					*&
				ENDIF && llSuccess
				*&
			CASE UPPER(pcField) = "RECORDSIZE"
				*&
				llSuccess = (VARTYPE(pvValue) = "N")
				*&
				IF llSuccess
					*&
					lcBytes = .DTHelper.Int2Bytes(pvValue,2)
					lnSize = .WritePos(lcBytes,10)
					*&
					llSuccess = (lnSize = 2)
					*&
				ENDIF && llSuccess
				*&
			CASE UPPER(pcField) = "TABLEFLAGS"
				*&
				llSuccess = (VARTYPE(pvValue) = "N") AND BETWEEN(pvValue,0,7)
				*&
				IF llSuccess
					*&
					lcBytes = .DTHelper.Int2Bytes(pvValue,1)
					lnSize = .WritePos(lcBytes,28)
					*&
					llSuccess = (lnSize = 1)
					*&
				ENDIF && llSuccess
				*&
			CASE UPPER(pcField) = "HASCDX"
				*&
				llSuccess = VARTYPE(pvValue) = "L"
				*&
				IF llSuccess
					*&
					lcBytes = .ReadPos(28,1)
					lnSize = .DTHelper.Bytes2Int(lcBytes)
					*&
					IF pvValue
						*&
						lnSize = BITSET(lnSize,0)
						*&
					ELSE
						*&
						lnSize = BITCLEAR(lnSize,0)
						*&
					ENDIF && pvValue
					*&
					lcBytes = .DTHelper.Int2Bytes(lnSize,1)
					lnSize = .WritePos(lcBytes,28)
					*&
					llSuccess = (lnSize = 1)
					*&
				ENDIF && llSuccess
				*&
			CASE UPPER(pcField) = "HASMEMO"
				*&
				llSuccess = VARTYPE(pvValue) = "L"
				*&
				IF llSuccess
					*&
					lcBytes = .ReadPos(28,1)
					lnSize = .DTHelper.Bytes2Int(lcBytes)
					*&
					IF pvValue
						*&
						lnSize = BITSET(lnSize,1)
						*&
					ELSE
						*&
						lnSize = BITCLEAR(lnSize,1)
						*&
					ENDIF && pvValue
					*&
					lcBytes = .DTHelper.Int2Bytes(lnSize,1)
					lnSize = .WritePos(lcBytes,28)
					*&
					llSuccess = (lnSize = 1)
					*&
				ENDIF && llSuccess
				*&
			CASE UPPER(pcField) = "ISDBC"
				*&
				llSuccess = VARTYPE(pvValue) = "L"
				*&
				IF llSuccess
					*&
					lcBytes = .ReadPos(28,1)
					lnSize = .DTHelper.Bytes2Int(lcBytes)
					*&
					IF pvValue
						*&
						lnSize = BITSET(lnSize,2)
						*&
					ELSE
						*&
						lnSize = BITCLEAR(lnSize,2)
						*&
					ENDIF && pvValue
					*&
					lcBytes = .DTHelper.Int2Bytes(lnSize,1)
					lnSize = .WritePos(lcBytes,28)
					*&
					llSuccess = (lnSize = 1)
					*&
				ENDIF && llSuccess
				*&
			CASE UPPER(pcField) = "BACKLINK"
				*&
				llSuccess = VARTYPE(pvValue) = "C" and BETWEEN(LEN(pvValue),0,263)
				*&
				IF llSuccess
					*&
					*& ------------------------------
					*& First need the Headersize...
					*& ------------------------------
					*&
					lcBytes = .ReadPos(8,2)
					lvValue = .DTHelper.Bytes2Int(lcBytes)
					*&
					*& --------------------------
					*& Now Set the BackLink...
					*& --------------------------
					*&
					llSuccess = (.WritePos(PADR(LEFT(pvValue,263),263,CHR(0)),lvValue - 263) = 263)
					*&
				ENDIF && llSuccess
				*&
			ENDCASE
			*&
		ENDWITH && THIS
		*&
		RETURN llSuccess
		*&
	ENDPROC && PutHeader(pcField, pcValue)
	*&
	*& ==========================================
	*& dbfFile InitFields()
	*&
	*& Initialize the Field Information...
	*& ==========================================
	*&
	PROCEDURE InitFields()
		*&
		LOCAL lcFieldData, lnFields, lnField
		*&
		STORE 0 TO lnCount, lnField
		*&
		CREATE CURSOR FieldInfo (Name C(11),Type C(1), Offset I(4), length I(4), ;
			Decimal I(4), Flags I(4), AutoNext I(4), AutoStep I(4))
		*&
		*& -------------------------------------------------------
		*& Field Data runs from Byte 32 to (HeaderSize - 163)...
		*& Each Field Structure is 32 Bytes long...
		*& -------------------------------------------------------
		*&
		WITH This
			*&
			*& ----------------------------------
			*& Determine the Number of Fields...
			*& ----------------------------------
			*&
			lnFields = .FieldCount()
			*&
			*& ----------------------------
			*& Move to the first field...
			*& ----------------------------
			*&
			.SeekOffset(32,0)
			*&
			FOR lnField = 1 TO lnFields
				*&
				*& ------------------------------------------
				*& Extract the data for the given field...
				*& Field structure is 32Bytes Long...
				*& ------------------------------------------
				*&
				lcFieldData = .Read(32) 
				*&
				m.Name = STRTRAN(LEFT(lcFieldData,11),CHR(0),"")
				m.Type = SUBSTR(lcFieldData,12,1)
				m.OffSet = .DTHelper.Bytes2Int(SUBSTR(lcFieldData,13,4))
				m.Length = ASC(SUBSTR(lcFieldData,17,1)) && May need to use ASC()
				m.Decimal = ASC(SUBSTR(lcFieldData,18,1)) && May need to use ASC()
				m.Flags = ASC(SUBSTR(lcFieldData,19,1)) && May need to use ASC()
				m.AutoNext = .DTHelper.Bytes2Int(SUBSTR(lcFieldData,20,4))
				m.AutoStep = ASC(SUBSTR(lcFieldData,24,1)) && May need to use ASC()
				*&
				INSERT INTO FieldInfo FROM MEMVAR
				*&
			ENDFOR && lnI = 1 TO lnFields
			*&
			*& ---------------------------------------------------
			*& Create an Index for the FieldName but leave it in
			*& Native Order...
			*& ---------------------------------------------------
			*&
			INDEX on UPPER(Name) TAG FieldName
			SET ORDER TO
			*&
		ENDWITH && This
		*&
	ENDPROC && InitFields()
	*&
	*& ==========================================
	*& dbfFile FieldCount()
	*&
	*& Returns the number of Fields...
	*& ==========================================
	*&
	PROCEDURE FieldCount()
		*&
		RETURN ((.HeaderSize - 296)/32)
		*&
	ENDPROC && FieldCount()
	*&
	*& ==================================================
	*& dbfFile.IsField(pcField)
	*&
	*& Returns True or False if a given field name
	*& exists...
	*&
	*& ==================================================
	*&
	PROCEDURE IsField(pcField)
		*&
		LOCAL llSuccess
		*&
		llSuccess = VARTYPE(pcField) = "C" AND NOT EMPTY(pcField)
		*&
		IF llSuccess
			*&
			IF UPPER(ALLTRIM(FieldInfo.Name)) <> UPPER(ALLTRIM(pcField))
				*&
				*& -----------------------------------------------------
				*& If not already on the desired field then locate the
				*& expected field...
				*& -----------------------------------------------------
				*&
				llSuccess = SEEK(UPPER(ALLTRIM(pcField)),"FieldInfo","FieldName")
				*&
			ENDIF && UPPER(ALLTRIM(FieldInfo.Name)) <> UPPER(ALLTRIM(pcField))
			*&
		ENDIF && llSuccess
		*&
		RETURN llSuccess
		*&
	ENDPROC && IsField(pcField)
	*&
	*& ==================================================
	*& dbfFile.FieldInfo(pvField,pcInfo)
	*&
	*& Returns Information about a given Field...
	*&
	*& ==================================================
	*&
	PROCEDURE FieldInfo(pvField,pcInfo)
		*&
		LOCAL llSuccess
		*&
		SELECT FieldInfo
		*&
		*& ---------------------------------------------
		*& Verify the field is identified by an Integer
		*& or Character string...
		*& ---------------------------------------------
		*&
		llSuccess = INLIST(VARTYPE(pvField),"N","C")
		*&
		IF llSuccess
			*&
			*& -----------------------------------------
			*& Verify the type of info is character and
			*& that it is one of the correct FieldInfo
			*& value fields...
			*& -----------------------------------------
			*&
			llSuccess = VARTYPE(pcInfo) = "C" and not EMPTY(pcInfo) ;
				AND TYPE(pcInfo) <> "U"
			*&
		ENDIF && llSuccess
		*&
		IF llSuccess
			*&
			DO CASE 
			CASE VARTYPE(pvField) = "N"
				*&
				*& -------------------------------------------------
				*& Insure that the requested field is in the valid
				*& Range of Field Identifiers...
				*& -------------------------------------------------
				*&
				llSuccess = BETWEEN(pvField,1,This.FieldCount())
				*&
				IF llSuccess AND (RECNO("FieldInfo") <> pvField)
					*&
					*& -----------------------------------------------
					*& If it's not already on the correct record then
					*& go to the desired record...
					*& -----------------------------------------------
					*&
					GO &pvField
					*&
				ENDIF && llSuccess AND RECNO() <> pvField
				*&
			CASE VARTYPE(pvField) = "C"
				*&
				*& ---------------------------------------
				*& Is field will put the FieldInfo cursor
				*& on the record for this field...
				*& ---------------------------------------
				*&
				llSuccess = This.IsField(pvField)
				*&
			ENDCASE 
			*&
			IF llSuccess
				*&
				RETURN &pcInfo
				*&
			ENDIF && llSuccess
			*&
		ENDIF && llSuccess
		*&
		RETURN .NULL.
		*&
	ENDPROC && FieldInfo(pvField,pcInfo)
	*&
	*& ==================================================
	*& dbfFile.GetField()
	*&
	*& Returns the value for a given field based on the
	*& current Recno()
	*& ==================================================
	*&
	PROCEDURE GetField(pvField, plRaw)
		*&
		LOCAL llSuccess, lnCurrentPos, lnRecordPos, lnFieldOffset
		LOCAL lcBytes, lvOutPut
		*&
		STORE 0 TO lnCurrentPos, lnRecordPos, lnFieldOffset
		STORE "" TO lcBytes
		*&
		llSuccess = INLIST(VARTYPE(pvField),"N","C")
		*&
		IF llSuccess
			*&
			WITH This
				*&
				SELECT FieldInfo
				*&
				DO CASE 
				CASE VARTYPE(pvField) = "N"
					*&
					llSuccess = BETWEEN(pvField,-1,.FieldCount())
					*&
					IF llSuccess
						*&
						DO CASE
						CASE pvField < 0
							*&
							*& -------------------------------------------
							*& Special Case: OverRide...
							*& -------------------------------------------
							*& Actually asking for the whole RAW_RECORD...
							*& -------------------------------------------
							*&
							RETURN .ReadPos(.RecordOffset(.Recno()),.RecordSize)
							*&
						CASE EMPTY(pvField)
							*&
							*& -------------------------------------------
							*& Special Case: OverRide...
							*& -------------------------------------------
							*& I'm actually asking for the value of the
							*& Delete Flag which would be Field 0...
							*& -------------------------------------------
							*&
							RETURN .ReadPos(.RecordOffset(.Recno()),1)
							*&
						OTHERWISE
							*&
							*& -----------------------------
							*& Normal Field Operations...
							*& -----------------------------
							*&
							IF RECNO("FieldInfo") <> pvField
								*&
								GO &pvField
								*&
							ENDIF && RECNO("FieldInfo") <> pvField
							*&
						ENDCASE
						*&
					ENDIF && llSuccess
					*&
				CASE VARTYPE(pvField) = "C"
					*&
					*& ---------------------------------
					*& Special Case for OverRides...
					*& ---------------------------------
					*&
					DO CASE
					CASE UPPER(ALLTRIM(pvField)) == "RAW_RECORD"
						*&
						*& --------------------------------------------
						*& Return the whole Raw Record... (-1)
						*& --------------------------------------------
						*&
						RETURN .ReadPos(.RecordOffset(.Recno()),.RecordSize)
						*&
					CASE UPPER(ALLTRIM(pvField)) == "DELETED_FLAG"
						*&
						*& --------------------------------------------
						*& Just Return the Current Deleted Flag... (0)
						*& --------------------------------------------
						*&
						RETURN .ReadPos(.RecordOffset(.Recno()),1)
						*&
					ENDCASE
					*&
					*& --------------------------------------
					*& Otherwise do normal field behavior...
					*& --------------------------------------
					*& The IsField call will position the
					*& FieldInfo record on the correct one...
					*& --------------------------------------
					*&
					llSuccess = .IsField(pvField)
					*&
				ENDCASE
				*&
				IF llSuccess
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
					lnCurrentPos = .CurrentOffset()
					lnRecordPos = .RecordOffset(.Recno())
					*&
					*& ----------------------------------------------------
					*& Position pointer on the beginning of the requested
					*& field...
					*& ----------------------------------------------------
					*& We can assume that the lnRecordPos is Less than the
					*& lnCurrentPos...  Now I need to know the Record Level
					*& Offset for the Field to see where it needs to be...
					*& ----------------------------------------------------
					*& The Relative Target Field Offset is FieldInfo.Offset...
					*& This is relative to the beginning of the Record which
					*& is lnRecordPos being calculated as the beginning of
					*& the record the CurrentPosition pointer is actually
					*& located...
					*& ----------------------------------------------------
					*&
					lnFieldOffset = lnRecordPos + FieldInfo.Offset
					*&
					*& ------------------------------------------
					*& Locate the relative offset to the current
					*& position...
					*& ------------------------------------------
					*&
					.SeekOffset(.RelativeOffset(lnFieldOffset),1)
					*&
					*& ----------------------------------------------
					*& The current position should be located at the
					*& Target Field that we wish to read...
					*& ----------------------------------------------
					*&
					lcBytes = .Read(FieldInfo.Length)
					*&
					*& ------------------------------------------------
					*& Now really depends on if we're working in Raw
					*& Mode which is not the most common scenario...
					*& Typically it needs to be Formatted for the user...
					*& ------------------------------------------------
					*& This is where we would translate the Raw Data
					*& to a format appropriate to the Data Type...
					*& ------------------------------------------------
					*& In order to make this easier if the raw data is
					*& what is desired there is a second parameter
					*& where you can pass a Logical True in if you 
					*& really want the data raw...
					*& ------------------------------------------------
					*&
					IF plRaw
						*&
						*& ------------------------------
						*& Return it just like it is...
						*& ------------------------------
						*&
						RETURN lcBytes
						*&
					ELSE
						*&
						*& -----------------------------------------
						*& Transform it or Format it into something
						*& that is useful, based on it's Type...
						*& -----------------------------------------
						*&
						lvOutPut = .Bytes2DT(lcBytes,FieldInfo.Type,FieldInfo.Decimal)
						*&
						RETURN lvOutPut
						*&
					ENDIF && plRaw
					*&
				ENDIF && llSuccess
				*&
			ENDWITH && This
			*&
		ENDIF && llSuccess
		*&
		*& -----------------------------------------------
		*& This is a place holder to return nothing...
		*& Should always return above, never down
		*& here...
		*& -----------------------------------------------
		*&
		RETURN .null.
		*&
	ENDPROC && GetField(pvField, plRaw)
	*&
	*& ==================================================
	*& dbfFile.Bytes2DT(pcBytes,pcType,pnDecimal)
	*& ==================================================
	*& Helper method used return the Raw Bytes into the
	*& apropriate datatype for consumption...
	*&
	*& There will also be a reverse DT2Bytes that will
	*& Transform the Value back into Bytes to be written
	*& to the file (PutField Version)...
	*& ==================================================
	*&
	PROCEDURE Bytes2DT(pcBytes,pcType,pnDecimal)
		*&
		LOCAL llSuccess, lvData
		*&
		STORE .NULL. TO lvData
		*&
		llSuccess = VARTYPE(pcBytes) == "C"
		*&
		IF llSuccess
			*&
			llSuccess = VARTYPE(pcType) == "C" ;
				AND NOT EMPTY(pcType)
			*&
		ENDIF && llSuccess
		*&
		WITH This
			*&
			IF llSuccess
				*&
				DO CASE
				CASE UPPER(pcType) == "C"
					*&
					*& ---------------------------------------
					*& Character value...
					*& ---------------------------------------
					*& Just strip out the null terminators...
					*& ---------------------------------------
					*&
					lvData = STRTRAN(pcBytes,CHR(0),"")
					*&
				CASE UPPER(pcType) == "Y"
					*&
					*& ---------------------------------------
					*& Currency value...
					*& ---------------------------------------
					*& Check the decimals...
					*& ---------------------------------------
					*&
					lvData = .DTHelper.Bytes2Int(pcBytes)
					lvData = TRANSFORM(lvData)
					*&
					lvData = SUBSTR(lvData,1,LEN(lvData) - pnDecimal) ;
						+ "." + RIGHT(lvData,pnDecimal)
					*&
					lvData = NTOM(VAL(lvData))
					*&
				CASE UPPER(pcType) == "N"
					*&
					*& ---------------------------------------
					*& Numeric value...
					*& ---------------------------------------
					*&
					lvData = VAL(pcBytes)
					*&
				CASE UPPER(pcType) == "F"
					*&
					*& ---------------------------------------
					*& Float, same as Numeric value...
					*& ---------------------------------------
					*&
					lvData = VAL(pcBytes)
					*&
				CASE UPPER(pcType) == "D"
					*&
					*& ---------------------------------------
					*& Date... YYYYMMDD
					*& ---------------------------------------
					*&
					lvData = SUBSTR(pcBytes,7) + "/" ;
						+ SUBSTR(pcBytes,5,2) + "/" ;
						+ SUBSTR(pcBytes,1,4)
					*&
					lvData = CTOD(lvData)
					*&
				CASE UPPER(pcType) == "T"
					*&
					*& ---------------------------------------
					*& TimeStamp...
					*& ---------------------------------------
					*& This is an 8-byte value or DWORD
					*& where the high word is an Int that holds
					*& the Julian Day Number for the date, and
					*& the low word is an Int that contains the
					*& number of milliseconds since midnight...
					*& ---------------------------------------
					*&
					lvData = CTOT(SYS(10,.DTHelper.Bytes2Int(LEFT(pcBytes,4))))
					lvData = lvData + (.DTHelper.Bytes2Int(RIGHT(pcBytes,4))/1000)
					*&
				CASE UPPER(pcType) == "B"
					*&
					*& -----------------------------------------
					*& Double precision floating point 64bit...
					*& -----------------------------------------
					*& The hairy-est one of all...
					*& -----------------------------------------
					*& This is an 8-byte value that actually
					*& expands out to 64 bits instead of 32 bits
					*& which is where they get double precision
					*& and actually prevents rounding errors
					*& supporting a match to the input value...
					*& -----------------------------------------
					*& This is a multi-step operation:
					*& 1. Convert from Bytes to Hexidecimal
					*& 2. Convert from Hexidecimal to Binary
					*& 3. Bit-math operations to reveal the
					*&    REAL number from 64 binary bits...
					*& -----------------------------------------
					*&
					lvData = pcBytes
					lvData = .DTHelper.Bytes2Hex(lvData)
					lvData = .DTHelper.Hex2Bin(lvData)
					lvData = .DTHelper.Bin2Float(lvData)
					*&
				CASE UPPER(pcType) == "I"
					*&
					*& ---------------------------------------
					*& Integer...
					*& ---------------------------------------
					*&
					lvData = .DTHelper.Bytes2Int(pcBytes)
					*&
				CASE UPPER(pcType) == "L"
					*&
					*& ---------------------------------------
					*& Logical...
					*& ---------------------------------------
					*&
					lvData = IIF(pcBytes=="T",.T.,.F.)
					*&
				CASE UPPER(pcType) == "M"
					*&
					*& ---------------------------------------
					*& Memo...
					*& ---------------------------------------
					*&
					lvData = .DTHelper.Bytes2Int(pcBytes)
					*&
				CASE UPPER(pcType) == "G"
					*&
					*& ---------------------------------------
					*& General...
					*& ---------------------------------------
					*&
					lvData = .DTHelper.Bytes2Int(pcBytes)
					*&
				CASE UPPER(pcType) == "C" && Binary
					*&
					*& ---------------------------------------
					*& Character (binary)...
					*& ---------------------------------------
					*&
					lvData = pcBytes
					*&
				CASE UPPER(pcType) == "M" && Binary
					*&
					*& ---------------------------------------
					*& Memo (binary)...
					*& ---------------------------------------
					*&
					lvData = .DTHelper.Bytes2Int(pcBytes)
					*&
				CASE UPPER(pcType) == "P"
					*&
					*& ---------------------------------------
					*& Picture...
					*& ---------------------------------------
					*&
					lvData = .DTHelper.Bytes2Int(pcBytes)
					*&
				ENDCASE
				*&
			ENDIF && llSuccess
			*&
		ENDWITH && This
		*&
		RETURN lvData
		*&
	ENDPROC && Bytes2DT(pcBytes,pcType,pnDecimal)
	*&
	*& ==================================================
	*& dbfFile.CountRecords()
	*&
	*& Returns an Integer based on a real count for all
	*& of the physical records contained in the file
	*& regardless of the header's record count...
	*& ==================================================
	*&
	PROCEDURE CountRecords()
		*&
		LOCAL lnCount, lnFileSize
		*&
		STORE 0 TO lnCount, lnFileSize
		*&
		WITH This
			*&
			lnFileSize = .FileSize()
			*&
			IF lnFileSize > 0
				*&
				lnCount = INT(FLOOR((lnFileSize-.HeaderSize)/.RecordSize))
				*&
			ENDIF && lnFileSize > 0
			*&
		ENDWITH && This
		*&
		RETURN lnCount
		*&
	ENDPROC && CountRecords()
	*&
	*& ==================================================
	*& dbfFile.Recno()
	*&
	*& This is a helper method to return the Record
	*& Number where the Current File Pointer is located...
	*& ==================================================
	*&
	PROCEDURE Recno()
		*&
		LOCAL llSuccess
		LOCAL lnCurPos, lnRecno
		*&
		STORE 0 TO lnCurPos, lnRecno
		*&
		WITH This
			*&
			lnCurPos = .CurrentOffSet()
			*&
			IF lnCurPos => .HeaderSize
				*&
				lnRecno = INT(FLOOR((lnCurPos-.HeaderSize)/.RecordSize))
				*&
			ENDIF && lnCurPos > .HeaderSize
			*&
		ENDWITH && This
		*&
		RETURN lnRecno
		*&
	ENDPROC && Recno()
	*&
	*& ==================================================
	*& dbfFile.RecordOffset(pnRecno)
	*&
	*& This is a helper method will determine what the
	*& offset is where a given record begins...
	*& ==================================================
	*&
	PROCEDURE RecordOffset(pnRecno)
		*&
		LOCAL llSuccess
		LOCAL lnCurrent, lnRecStart
		*&
		STORE 0 TO lnCurrent, lnRecStart
		*&
		llSuccess = VARTYPE(pnRecno) = "N" and pnRecno > 0
		*&
		WITH This
			*&
			IF llSuccess
				*&
				lnCurrent = .CurrentOffset()
				*&
				IF lnCurrent => .HeaderSize
					*&
					lnRecStart = .HeaderSize + (.RecordSize * (pnRecno - 1))
					*&
				ENDIF && lnCurrent => lnHeader
				*&
			ENDIF llSuccess
			*&
		ENDWITH && This
		*&
		RETURN lnRecStart
		*&
	ENDPROC && RecordOffset(pnRecno)
	*&
	*& ==================================================
	*& dbfFile.Deleted(pnRecno)
	*&
	*& This is a helper method to tell if the Current
	*& or a Given Record is Deleted or Not...
	*& ==================================================
	*&
	PROCEDURE Deleted(pnRecno)
		*&
		LOCAL llDeleted
		*&
		WITH This
			*&
			IF PCOUNT() = 1
				*&
				*& ---------------------------------------------
				*& Test the indicated record...
				*& ---------------------------------------------
				*&
				IF VARTYPE(pnRecno) = "N" AND pnRecno > 0
					*&
					llDeleted = .ReadPos(.RecordOffset(pnRecno),1) = "*"
					*&
				ENDIF && VARTYPE(pnRecno) = "N" AND pnRecno > 0
				*&
			ELSE
				*&
				*& ---------------------------------------------
				*& Otherwise test the current record...
				*& ---------------------------------------------
				*&
				llDeleted = .ReadPos(.RecordOffset(.Recno()),1) = "*"
				*&
			ENDIF && EMPTY(PCOUNT())
			*&
		ENDWITH && This
		*&
		RETURN llDeleted
		*&
	ENDPROC && Deleted(pnRecno)
	*&
	*& ==================================================
	*& dbfFile.Delete(pnRecno)
	*&
	*& This is a helper method to mark a Record for
	*& Deletion...
	*& ==================================================
	*&
	PROCEDURE Delete(pnRecno)
		*&
		LOCAL llSuccess, lnOffset
		*&
		STORE 0 TO lnOffset
		*&
		WITH This
			*&
			IF PCOUNT() = 0
				*&
				*& ---------------------------------------
				*& Mark the current record as deleted...
				*& ---------------------------------------
				*&
				llSuccess = BETWEEN(.Recno(),1,.RecordCount)
				*&
				IF llSuccess
					*&
					lnOffset = .RecordOffset(.Recno())
					*&
				ENDIF && llSuccess
				*&
			ELSE
				*&
				llSuccess = VARTYPE(pnRecno) = "N" AND BETWEEN(pnRecno,1,.RecordCount)
				*&
				IF llSuccess
					*&
					lnOffset = .RecordOffset(pnRecno)
					*&
				ENDIF && llSuccess
				*&
			ENDIF && PCOUNT() = 0
			*&
			IF llSuccess
				*&
				llSuccess = (.WritePos("*", lnOffset) = 1)
				*&
			ENDIF && llSuccess
			*&
		ENDWITH && This
		*&
	ENDPROC && Delete(pnRecno)
	*&
	*& ==================================================
	*& dbfFile.Recall(pnRecno)
	*&
	*& This is a helper method to Recall a Record or
	*& set it to not be marked for Deletion...
	*& ==================================================
	*&
	PROCEDURE Recall(pnRecno)
		*&
		LOCAL llSuccess, lnOffset
		*&
		STORE 0 TO lnOffset
		*&
		WITH This
			*&
			IF PCOUNT() = 0
				*&
				*& ---------------------------------------
				*& Mark the current record as deleted...
				*& ---------------------------------------
				*&
				llSuccess = BETWEEN(.Recno(),1,.RecordCount)
				*&
				IF llSuccess
					*&
					lnOffset = .RecordOffset(.Recno())
					*&
				ENDIF && llSuccess
				*&
			ELSE
				*&
				llSuccess = VARTYPE(pnRecno) = "N" AND BETWEEN(pnRecno,1,.RecordCount)
				*&
				IF llSuccess
					*&
					lnOffset = .RecordOffset(pnRecno)
					*&
				ENDIF && llSuccess
				*&
			ENDIF && PCOUNT() = 0
			*&
			IF llSuccess
				*&
				llSuccess = (.WritePos(" ", lnOffset) = 1)
				*&
			ENDIF && llSuccess
			*&
		ENDWITH && This
		*&
	ENDPROC && Recall(pnRecno)
	*&
	*& ==================================================
	*& dbfFile.Go(pnRecno)
	*&
	*& This is a helper method to position a record
	*& pointer on a given logical record location...
	*& ==================================================
	*&
	PROCEDURE Go(pnRecno)
		*&
		LOCAL llSuccess, lnOffset
		*&
		STORE 0 TO lnOffset
		*&
		WITH This
			*&
			llSuccess = VARTYPE(pnRecno) = "N"
			*&
			IF llSuccess
				*&
				llSuccess = BETWEEN(pnRecno,1,.RecordCount)
				*&
				IF llSuccess
					*&
					*& -----------------------------------------------------------
					*& Determine the Offset and move the file pointer there...
					*& -----------------------------------------------------------
					*&
					lnOffset = .HeaderSize + (.RecordSize * (pnRecno-1))
					*&
					*& ---------------------------------------------
					*& Position on the Offset from the beginning of
					*& the file...
					*& ---------------------------------------------
					*&
					llSuccess = (.SeekOffset(lnOffSet,0) = lnOffSet)
					*&
				ENDIF && llSuccess
				*&
			ENDIF && llSuccess
			*&
		ENDWITH && This
		*&
		RETURN llSuccess
		*&
	ENDPROC && Go(pnRecno)
	*&
	*& ==================================================
	*& dbfFile.BOF()
	*&
	*& This is a helper method to indicate if the Record
	*& Pointer is positioned at the Beginning of the 
	*& (DBF) File...
	*& ==================================================
	*&
	PROCEDURE BOF()
		*&
		*& --------------------------------------------
		*& This may be a useful simplistic approach...
		*& --------------------------------------------
		*&
		RETURN EMPTY(This.Recno())
		*&
	ENDPROC && BOF()
	*&
	*& ==================================================
	*& dbfFile.EOF()
	*&
	*& This is a helper method to indicate if the Record
	*& Pointer is positioned at the End of the (DBF) File...
	*& ==================================================
	*& This is not to be confused with the...
	*& dbfFile.EndOfFile() which is inherited from the
	*& xFile class as it will indicate if the File
	*& Pointer is beyond the last byte in the file...
	*& They may however be equivelent though...
	*& ==================================================
	*&
	PROCEDURE EOF()
		*&
		*& -----------------------------------
		*& They may be equivelent afterall...
		*& -----------------------------------
		*&
		RETURN This.EndOfFile()
		*&
	ENDPROC && EOF()
	*&
ENDDEFINE && CLASS dbfFile as xFile
*&
*& ******************************************************
*& fptFile
*& ******************************************************
*& The fptFile will extend the xFile to support the 
*& characteristics and properties of the FPT file 
*& structure...
*& ******************************************************
*&
DEFINE CLASS fptFile as xFile
	*&
	*& ==================================================
	*& fptFile.BlockSize()
	*&
	*& Helper method to return the actual stored
	*& blocksize for memo text blocks...
	*& ==================================================
	*&
	PROCEDURE BlockSize()
		*&
		LOCAL llSuccess, lnSize, lcBytes
		*&
		STORE "" TO lcBytes
		STORE 0 TO lnSize
		*&
		WITH This
			*&
			lcBytes = .ReadPos(6,2)
			lnSize = .DTHelper.Bytes2Int(lcBytes,.T.) && Most Sig byte first...
			*&
		ENDWITH && This
		*&
		RETURN lnSize
		*&
	ENDPROC && BlockSize()
	*&
	*&
	*& ==================================================
	*& fptFile.NextFreeBlock()
	*&
	*& Helper method to return the location of the
	*& next free block for memo text...
	*& ==================================================
	*&
	PROCEDURE NextFreeBlock()
		*&
		LOCAL llSuccess, lnNextBlock, lcBytes
		*&
		STORE "" TO lcBytes
		STORE 0 TO lnNextBlock
		*&
		WITH This
			*&
			lcBytes = .ReadPos(0,4)
			lnNextBlock = .DTHelper.Bytes2Int(lcBytes,.T.) && Most Sig byte first...
			*&
		ENDWITH && This
		*&
		RETURN lnNextBlock
		*&
	ENDPROC && NextFreeBlock()
	*&
	*&
	*& ==================================================
	*& fptFile.BlockCount()
	*&
	*& Helper method to return the number of physical
	*& blocks in the file...
	*& ==================================================
	*&
	PROCEDURE BlockCount()
		*&
		LOCAL llSuccess, lnBlocks, lnFileSize, lnBlockSize
		*&
		STORE 0 TO lnBlocks, lnFileSize, lnBlockSize
		*&
		WITH This
			*&
			lnFileSize = .FileSize()
			lnBlockSize = .BlockSize()
			*&
			lnBlocks = INT(lnFileSize/lnBlockSize)
			*&
		ENDWITH && This
		*&
		RETURN lnBlocks
		*&
	ENDPROC && BlockCount()
	*&
	*& ==================================================
	*& fptFile.BlockInfo(pnBlock, pcInfo)
	*&
	*& Helper method to return other information about
	*& a given block.
	*& ==================================================
	*&
	PROCEDURE BlockInfo(pnBlock, pcInfo)
		*&
		LOCAL llSuccess, lnInfo, lnBlockSize, lcBytes
		*&
		STORE 0 TO lnInfo, lnBlockSize
		STORE "" TO lcBytes
		*&
		llSuccess = VARTYPE(pnBlock) == "N" ;
			AND NOT EMPTY(pnBlock)
		*&
		IF llSuccess
			*&
			llSuccess = VARTYPE(pcInfo) == "C" ;
				AND INLIST(UPPER(pcInfo),"TYPE","LENGTH")
			*&
		ENDIF && llSuccess
		*&
		WITH This
			*&
			IF llSuccess
				*&
				lnBlockSize = .BlockSize()
				*&
				lcBytes = .ReadPos(pnBlock * lnBlockSize,8)
				*&
				DO CASE
				CASE UPPER(pcInfo) == "TYPE"
					*&
					lnInfo = .DTHelper.Bytes2Int(LEFT(lcBytes,4),.T.)
					*&
				CASE UPPER(pcInfo) == "LENGTH"
					*&
					lnInfo = .DTHelper.Bytes2Int(RIGHT(lcBytes,4),.T.)
					*&
				ENDCASE
				*&
			ENDIF && llSuccess
			*&
		ENDWITH && This
		*&
		RETURN lnInfo
		*&
	ENDPROC && BlockInfo(pnBlock, pcInfo)
	*&
	*&
	*& ==================================================
	*& fptFile.GetData(pnBlock)
	*&
	*& Helper method to return the Memo text from
	*& a given block indicator as would be provided
	*& from the Memo field data in the table (dbf)...
	*& ==================================================
	*&
	PROCEDURE GetData(pnBlock)
		*&
		LOCAL llSuccess, lnBlockSize, lcBlockHeader, lnSize, lcText
		LOCAL lnBytesRead, lnBuffer
		*&
		STORE 0 TO lnBlockSize, lnSize, lnBytesRead, lnBuffer
		STORE "" TO lcText, lcBlockHeader
		*&
		llSuccess = VARTYPE(pnBlock) == "N" ;
			AND NOT EMPTY(pnBlock)
		*&
		WITH This
			*&
			IF llSuccess
				*&
				*& ---------------------------------
				*& Locate the block first...
				*& ---------------------------------
				*&
				lnBlockSize = .BlockSize()
				*&
				.SeekOffset(pnBlock * lnBlockSize,0)
				lcBlockHeader = .Read(8)
				*&
				lnSize = .DTHelper.Bytes2Int(RIGHT(lcBlockHeader,4),.T.) && Most Sig Byte first...
				*&
				*& -------------------------------------------------------
				*& FREAD is limited to reading 65535 bytes at a time
				*& a test must be performed and if more than that is
				*& needed, then it will need to perform sequential reads...
				*& -------------------------------------------------------
				*&
				DO WHILE lnBytesRead < lnSize
					*&
					lnBuffer = lnSize - lnBytesRead
					*&
					IF lnBuffer > 65535
						*&
						lnBuffer = 65535
						*&
					ENDIF && lnBuffer > 65535
					*&
					lcText = lcText + .Read(lnBuffer)
					*&
					lnBytesRead = lnBytesRead + lnBuffer
					*&
				ENDDO && WHILE lnBytesRead < lnSize
				*&
			ENDIF && llSuccess
			*&
		ENDWITH && This
		*&
		RETURN lcText
		*&
	ENDPROC && GetData(pnBlock)
	*&
ENDDEFINE && CLASS fptFile as xFile
*&
*& ******************************************************
*& Logger - Generic File Logger
*&
*& This is a Log File class that will be used
*& to generate Log files for the Scanner...
*& ******************************************************
*&
DEFINE CLASS Logger AS Session
	*&
	*& --------------------------------------------------------
	*& This is the Basic Text Logger Class...
	*& --------------------------------------------------------
	*& It needs 3 basic fundamental methods...
	*&
	*& 1) Write - Essentially the standard Write method that
	*&    only writes bytes to the file...
	*& 2) WriteLn - Essentially a PutString method which is a
	*&    Write method that adds a CRLF at the end...
	*& 3) Header - Returns a Formatted Header String without...
	*& --------------------------------------------------------
	*&
	FilePath = ""
	AppName = "" && This value will get written into the Header...
	Terminator = CHR(13)+CHR(10)
	*&
	*& =======================================================
	*& Logger.Header()
	*&
	*& Returns a Formatted Header String for the logfile 
	*& entry...
	*& =======================================================
	*&
	PROCEDURE Header()
		*&
		RETURN TTOC(DATETIME(),3) + SPACE(1) + SYS(0) + " [" + This.AppName + SYS(2015) + "] "
		*&
	ENDPROC && Header()
	*&
	*& =======================================================
	*& Logger.Write(pcString)
	*&
	*& Writes a String to the end of the file...
	*& =======================================================
	*&
	PROCEDURE Write(pcString)
		*&
		LOCAL llSuccess
		*&
		llSuccess = VARTYPE(pcString) = "C"
		*&
		IF llSuccess
			*&
			IF .f. && _Screen.Visible
				*&
				?STRTRAN(pcString,This.Terminator,"")
				*&
			ENDIF && _Screen.Visible
			*&
			STRTOFILE(pcString,This.FilePath,1)
			*&
		ENDIF && llSuccess
		*&
	ENDPROC && Write(pcString)
	*&
	*& =======================================================
	*& Logger.WriteHeader()
	*&
	*& Writes the Header to the File...
	*& =======================================================
	*&
	PROCEDURE WriteHeader()
		*&
		WITH This
			*&
			.Write(.Header())
			*&
		ENDWITH && This
		*&
	ENDPROC && WriteHeader()
	*&
	*& =======================================================
	*& Logger.NewLine()
	*&
	*& Writes a New Line (CRLF) ending to the file...
	*& =======================================================
	*&
	PROCEDURE NewLine()
		*&
		WITH This
			*&
			.Write(.Terminator)
			*&
		ENDWITH && This
		*&
	ENDPROC && NewLine()
	*&
	*& =======================================================
	*& Logger.WriteLn(pcString)
	*&
	*& Writes a String to the end of  the file followed by a 
	*& CRLF pair...
	*& =======================================================
	*&
	PROCEDURE WriteLn(pcString)
		*&
		LOCAL llSuccess
		*&
		llSuccess = VARTYPE(pcString) = "C"
		*&
		IF llSuccess
			*&
			WITH This
				*&
				.Write(.Header() + pcString + .Terminator)
				*&
			ENDWITH && This
			*&
		ENDIF && llSuccess
		*&
	ENDPROC && WriteLn(pcString)
	*&
ENDDEFINE && CLASS Logger AS Session
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
*&
*& ******************************************************
*& dtHelper - Generic Data Type Helper class...
*&
*& This is a helper class that makes transformation and
*& conversions of bytes, bits, and data types much easier...
*& ******************************************************
*&
DEFINE CLASS dtHelper AS SESSION
	*&
	*&
	*& ===========================================================================
	*&  dtHelper.Bin2Dec(pcBinNum)
	*& ===========================================================================
	*&  Purpose: convert binary string to decimal number            
	*&  Parameters: pbinnum - string to convert i.e.,    
	*&   '0' - '11111111111111111111111111111111111111111111111111111'
	*&   '0' - (53 1's)     
	*&    returns: integer data type      
	*&      Usage: nresult=bin2dec(cBinString)
	*&             STORE bin2dec('11111111') TO nMyNum 
	*&   nMyNum == 255
	*& ===========================================================================
	*& 
	PROCEDURE Bin2Dec(pcBinNum)
		*&
		LOCAL lnDigits, lnRetval, lnIndex
		STORE 0 TO lnDigits, lnRetval, lnIndex
		*&
		STORE 0 TO lnRetval
		pcBinNum = ALLTRIM(pcBinNum)
		STORE LEN(pcBinNum) TO lnDigits
		FOR lnIndex = 0 TO lnDigits
		   IF SUBSTR(pcBinNum, lnDigits - lnIndex, 1) = '1'
		      lnRetval = lnRetval + 2^lnIndex
		   ENDIF
		NEXT
		*&
		RETURN INT(lnRetval)
		*&
	ENDPROC && Bin2Dec(pcBinNum)
	*&
	*& ===========================================================================
	*&   dtHelper.Bin2Dec2(pcBinNum)
	*& ===========================================================================
	*&    Purpose: convert binary string to floating point fraction - i.e. .123     
	*& Parameters: pbinnum - string to convert i.e.,    
	*&   '0' - '11111111111111111111111111111111111111111111111111' (50 1's)        
	*&    returns: float data type        
	*&      Usage: nresult=bin2dec2(cBinString)
	*&             STORE bin2dec2('111') TO nMyNum 
	*&  nMyNum == .875
	*& ===========================================================================
	*& 
	PROCEDURE Bin2Dec2(pcBinNum)
		LOCAL lnRetval, lnIndex, lnDigits
		*&
		STORE 0 TO lnRetval, lnIndex, lnDigits
		pcBinNum =  ALLTRIM(pcBinNum)
		*&
		STORE LEN(pcBinNum) TO lnDigits
		*&
		FOR lnIndex = 1 TO lnDigits
			*&
			IF SUBSTR(pcBinNum, lnIndex, 1) = '1'
				*&
				lnRetval = lnRetval + 2^(-lnIndex)
				*&
			ENDIF
			*&
		ENDFOR && lnIndex = 1 TO lnDigits
		*&
		RETURN lnRetval
		*&
	ENDPROC && Bin2Dec2(pcBinNum)
	*&
	*& ===========================================================================
	*&   dtHelper.Bin2Float(pcBinNum, pnWordSize)
	*& ===========================================================================
	*&    Purpose: convert bcd binary to floating point decimal number  
	*& Parameters: string data type of binary representation of bcd number            
	*&  '0100000001011110110111001100110011001100110011001100110011001101' = 123.45           
	*&             nWordSize:  either 8 or 16 bit.  16 is default for better precision
	*&      Calls: bin2dec() and bin2dec2()
	*&    returns: string data type
	*&      Usage: nresult=bin2float(cBinString)
	*&    STORE bin2float('0111001100110011001100110011001100110011001100110011') ;
	*&       TO nMyNum 
	*&   nMyNum == 123.45
	*& ===========================================================================
	*&
	PROCEDURE Bin2Float(pcBinNum, pnWordSize)
		*&
		LOCAL lcSign, lcExponent, lcMantissa, lnExponent, lcDec, lnDec, lcInt, lnInt, lnValue
		STORE "" TO lcSign, lcExponent, lcMantissa, lcDec, lcInt
		STORE 0 TO lnExponent, lnDec, lnInt, lnValue
		*&
		WITH This
			*&
			IF Vartype(pnWordSize) # 'N'
			   IF Len(pcBinNum) = 32
			      STORE 8 TO pnWordSize  
			   ELSE   &&... len better be 64
			      STORE 16 TO pnWordSize  
			   ENDIF 
			ENDIF 
			*&
			STORE IIF(LEFT(pcBinNum, 1) = '1', '-', '+') + '1' TO lcSign
			IF pnWordSize = 8
			   STORE SUBSTR(pcBinNum, 2, 8) TO lcExponent
			   STORE SUBSTR(pcBinNum, 10)    TO lcMantissa
			ELSE 
			   STORE SUBSTR(pcBinNum, 2, 11) TO lcExponent
			   STORE SUBSTR(pcBinNum, 13)    TO lcMantissa
			ENDIF 
			*&
			IF pnWordSize = 8
			   lnExponent = .bin2dec(lcExponent) - 127
			ELSE 
			   lnExponent = .bin2dec(lcExponent) - 1023
			ENDIF 
			*&
			IF lnExponent < 0
			   lcDec = REPLICATE('0', ABS(lnExponent)-1) + '1' + lcMantissa
			   lnDec = .bin2dec2(lcDec)
			   lnInt = 0
			ELSE
			   lcInt = '1' + SUBSTR(lcMantissa, 1, lnExponent)
			   lcDec = SUBSTR(lcMantissa, lnExponent + 1)
			   lnInt = .bin2dec(lcInt)
			   lnDec = .bin2dec2(lcDec)
			ENDIF
			*&
			lnValue = lnInt + lnDec
			lnValue = lnValue * VAL(lcSign)
			*&
		ENDWITH && This
		*&
		RETURN lnValue
		*&
	ENDPROC && Bin2Float(pcBinNum, pnWordSize)
	*&
	*& ===========================================================================
	*&   dtHelper.Bin2Hex(pcBinString)
	*& ===========================================================================
	*&    Purpose: convert binary representation of bcd number to hex 
	*& Parameters: string data type.    123.45 =        
	*&      '0100000001011110110111001100110011001100110011001100110011001101'      
	*&       = 0x '405EDD2F1A9FBE77'      
	*&     Takes each segment of four binary digits and converts to hex digit       
	*&     Example: 0100 0000 0101 1110.... = 4 0 5 E .....           
	*&    returns: string data type       
	*&      Usage: cresult=bin2hex(cBinNum)
	*&             STORE bin2hex('0100') TO nMyNum 
	*&   nMyNum == '4'
	*& ===========================================================================
	PROCEDURE Bin2Hex(pcBinString)
		*&
		WITH This
			*&
			LOCAL lcHexString, lnStrLen, lnI
			*&
			STORE "" TO lcHexString
			STORE 0 TO lnI
			STORE Len(pcBinString) TO lnStrLen
			*&
			FOR lnI = 1 TO lnStrLen STEP 4
				*&
				lcHexString = lcHexString + ;
					.Dec2Basx(.Bin2Dec(SUBSTR(pcBinString, lnI, 4)), 16)
				*&
			ENDFOR && lnI = 1 TO lnStrLen STEP 4
			*&
		ENDWITH && This
		*&
		RETURN lcHexString
		*&
	ENDPROC && Bin2Hex(cBinString)
	*&
	*& ==================================================
	*& dtHelper.Bytes2Hex(pcString,plLR)
	*&
	*& This is a helper method to convert a raw byte
	*& string to a Hexidecimal representation.
	*& ==================================================
	*&
	PROCEDURE Bytes2Hex(pcString,plLR)
		*&
		LOCAL llSuccess, lcHex
		*&
		STORE "" TO lcHex
		*&
		llSuccess = VARTYPE(pcString) = "C" ;
			AND NOT EMPTY(pcString)
		*&
		IF llSuccess	
			*&
			llSuccess = VARTYPE(plLR) == "L"
			*&
		ENDIF && llSuccess
		*&
		WITH This
			*&
			IF llSuccess
				*&
				IF plLR
					*&
					*& ---------------------------------------
					*& Read the bytes from left to right...
					*& ---------------------------------------
					*&
					FOR lnI = 1 TO LEN(pcString)
						*&
						lcHex = lcHex + .DEC2BASX(ASC(SUBSTR(pcString,lnI,1)),16)
						*&
					ENDFOR && lnI = 1 TO LEN(pcString)
					*&
				ELSE
					*&
					*& ----------------------------------------
					*& Read the bytes from right to left...
					*& ----------------------------------------
					*&
					FOR lnI = LEN(pcString) TO 1 STEP - 1
						*&
						*& ---------------------------------------------
						*& It appears that this is actually reversing 
						** the byte order... doesn't look right but it 
						*& does appear to work...
						*& ---------------------------------------------
						*&
						lcHex = lcHex + .DEC2BASX(ASC(SUBSTR(pcString,lnI,1)),16)
						*&
					ENDFOR && lnI = LEN(pcString) TO 1 SKIP - 1
					*&
				ENDIF && plLR
				*&
			ENDIF && llSuccess
			*&
		ENDWITH && This
		*&
		RETURN lcHex
		*&
	ENDPROC && Bytes2Hex(pcString)
	*&
	*& ==================================================
	*& dtHelper.Bytes2Int(pcString,plLR)
	*&
	*& This is a helper method to convert a binary string
	*& of bytes to an actual integer that is human 
	*& readable.
	*&
	*& The plLR flag is an indicator that says the bytes
	*& are in Reverse Order so they can be properly
	*& decoded...
	*& ==================================================
	*&
	PROCEDURE Bytes2Int(pcString,plLR)
		*&
		LOCAL llSuccess, lnReturnVal, lnI, lnSize
		*&
		STORE 0 TO lnReturnVal, lnI, lnSize
		*&
		llSuccess = VARTYPE(pcString) == "C" ;
			AND NOT EMPTY(pcString)
		*&
		IF llSuccess
			*&
			llSuccess = VARTYPE(plLR) == "L"
			*&
		ENDIF && llSuccess
		*&
		IF llSuccess
			*&
			*& --------------------------------
			*& Convert the String to Integer...
			*& --------------------------------
			*&
			lnSize = LEN(pcString)
			*&
			FOR lnI = 0 TO lnSize - 1
				*&
				lnReturnVal = lnReturnVal + ASC(SUBSTR(pcString,lnI+1)) * ;
					IIF(plLR,256^(lnSize-1-lnI),256^lnI)
				*&
			ENDFOR && lnI = 0 TO lnSize - 1
			*&
		ENDIF && llSuccess
		*&
		RETURN INT(lnReturnVal)
		*&
	ENDPROC && Bytes2Int(pcString,plLR)
	*& 
	*& ===========================================================================
	*&    dtHelper.Dec2Basx(pnTempNum, pnNewBase)
	*& ===========================================================================
	*&    Purpose:  Convert whole number 0-?, to base 2-16 
	*&
	*& Parameters: pnTempNum - number to convert (0-9007199254740992)
	*&             base    - base to convert to i.e., 2 4 8 16...
	*&    returns: string
	*&      Usage:  cresult=Dec2BasX(nParm1, nParm2)
	*&              STORE Dec2BasX(255, 16) TO cMyString  &&... cMyString contains 'ff'
	*& ===========================================================================
	PROCEDURE Dec2Basx(pnTempNum, pnNewBase)
		*&
		STORE 0 TO lnWorkVal,;
		   remainder,;
		   dividend,;
		   nextnum,;
		   digit
		*&
		lnWorkVal = pnTempNum  
		ret_str = ''
		*&
		DO WHILE .T.
		   digit = MOD(lnWorkVal, pnNewBase)
		   dividend = lnWorkVal / pnNewBase
		   lnWorkVal = INT(dividend)
			*&
		   DO CASE
		      CASE digit = 10
		         ret_str = 'a' + ret_str
		      CASE digit = 11
		         ret_str = 'b' + ret_str
		      CASE digit = 12
		         ret_str = 'c' + ret_str
		      CASE digit = 13
		         ret_str = 'd' + ret_str
		      CASE digit = 14
		         ret_str = 'e' + ret_str
		      CASE digit = 15
		         ret_str = 'f' + ret_str
		      OTHERWISE
		         ret_str = LTRIM(STR(digit)) + ret_str
		   ENDCASE
			*&
		   IF lnWorkVal = 0
		      EXIT
		   ENDIF ( lnWorkVal = 0 )
		ENDDO && ( .T. )
		*&
		RETURN ret_str
		*&
	ENDPROC && Dec2Basx(pnTempNum, pnNewBase)
	*&
	*& ===========================================================================
	*&   dtHelper.Dec2Bin(pnDecimal, pnWordSize)    
	*& ===========================================================================
	*&    Purpose: convert floating point fraction to binary string -   
	*&        i.e. .75 = '11', .25 = '01' and .075 =      
	*&        '0001001100110011001100110011001100110011001100110011'    
	*& Parameters: nDecimal - Float number i.e. .45       
	*&             nWordSize:  either 8 or 16 bit.  16 is default for better precision
	*&    returns: string data type         
	*&      Usage: nresult=dec2bin(nDecNum)
	*&             STORE dec2bin(.45) TO nMyNum 
	*&  nMyNum == '0111001100110011001100110011001100110011001100110011'
	*& ===========================================================================
	*&
	PROCEDURE Dec2Bin(pnDecimal, pnWordSize)
		*&
		LOCAL lcBinString, lnWork, lnCounter, lnMax
		STORE '' TO lcBinString
		STORE pnDecimal TO lnWork
		STORE 0 TO lnCounter, lnMax
		*&
		WITH This
			*&
			*& ---------------------------------------------------
			*& We'll default the wordsize to 16 if not specified.  
			*& ---------------------------------------------------
			*&
			IF Vartype(pnWordSize) # 'N'
				*&
				STORE 16 TO pnWordSize
				*&
			ENDIF 
			*&
			IF pnWordSize = 8
			   STORE 22 TO lnMax
			ELSE 
			   STORE 51 TO lnMax
			ENDIF 
			*&
			DO WHILE lnWork # 0 AND lnCounter <= lnMax   &&... nMax precision bits
				*&
				lnWork = lnWork * 2
				IF lnWork >= 1
					lcBinString = lcBinString + '1'
					lnWork = MOD(lnWork, INT(lnWork))
				ELSE
					lcBinString = lcBinString + '0'
				ENDIF
				*&
				lnCounter = lnCounter + 1
				*&
			ENDDO
			*&
		ENDWITH && This
		*&
		RETURN lcBinString
		*&
	ENDPROC && Dec2Bin(pnDecimal, pnWordSize)
	*&
	*& ===========================================================================
	*&   dtHelper.Float2Bin(pnValue, pnWordSize)
	*& ===========================================================================
	*&    Purpose: This function will take a float, 0.?, and convert it to binary 
	*&      representation which can then be converted to hex bcd using bin2hex.
	*&
	*& Parameters: nValue - float numer i.e., 123.45
	*&             nWordSize:  either 8 or 16 bit.  16 is default for better precision
	*&      Calls: Dec2BasX() and Dec2Bin()
	*&    returns: string 
	*&      Usage:  cresult=float2bin(nValue)
	*&              STORE float2bin(123.45) TO cMyBin 
	*&   cMyBin == '0100000001011110110111001100110011001100110011001100110011001101'
	*& ===========================================================================
	PROCEDURE Float2Bin(pnValue, pnWordSize)
		*&
		LOCAL lcSignBit, lcBinString, lcExpBits, lcBits
		LOCAL lnExponent, lnCalcValue, lnInt, lnMantissa, lnBiased
		*&
		STORE "" TO lcSignBit, lcBinString, lcExpBits, lcBits
		STORE 0 TO lnExponent, lnCalcValue, lnInt, lnMantissa, lnBiased
		*&
		WITH This
			*&
			*& ------------------------------------------------
			*& Default the wordsize to 16 if not specified...
			*& ------------------------------------------------
			*&
			IF VARTYPE(pnWordSize) # 'N'
				*&
				STORE 16 TO pnWordSize
				*&
			ENDIF && VARTYPE(pnWordSize) # 'N'
			*&
			STORE IIF(pnValue > 0, '0', '1') TO lcSignBit
			STORE 0 TO lnExponent
			STORE ABS(pnValue) TO lnCalcValue, pnValue
			STORE INT(pnValue) TO lnInt
			IF lnInt > 0
			   STORE MOD(pnValue, INT(pnValue)) TO lnMantissa
			ELSE
			   STORE pnValue TO lnMantissa
			ENDIF
			*&
			IF lnInt > 1
			   lcBinString = SUBSTR(.Dec2Basx(lnInt, 2) + .Dec2Bin(lnMantissa, pnWordSize), 2)
			ELSE
			   lcBinString = .Dec2Bin(lnMantissa, pnWordSize)
			ENDIF
			*&
			*... calc exponent
			DO WHILE !(lnCalcValue >= 1 AND lnCalcValue < 2)
			   lnCalcValue = pnValue / (2 ^ lnExponent)     &&... start with +E
			   IF !(lnCalcValue >= 1 AND lnCalcValue < 2)
			      lnExponent = lnExponent * -1             &&... flip sign then try -E
			      lnCalcValue = pnValue / (2 ^ lnExponent)
			      IF (lnCalcValue >= 1 AND lnCalcValue < 2)
			         EXIT
			      ENDIF
			   ELSE
			      EXIT
			   ENDIF
			   lnExponent = ABS(lnExponent) + 1   &&... keep going?
			ENDDO
			*&
			lnMantissa = 1 + (1 / (2 ^ lnExponent))
			*&
			IF lnInt < 1
			   lcBinString = SUBSTR(lcBinString, ABS(lnExponent) + 1)
			ENDIF
			IF pnWordSize = 8
			   lnBiased = 127
			   lcExpBits = PADL(.Dec2Basx(lnExponent + lnBiased, 2), 8, '0')
			ELSE 
			   lnBiased = 1023
			   lcExpBits = PADL(.Dec2Basx(lnExponent + lnBiased, 2), 11, '0')
			ENDIF 
			lcBits = lcSignBit + lcExpBits + lcBinString
			*&
		ENDWITH && This
		*&
		IF pnWordSize = 8
			*&
		   RETURN PADR(lcBits, 32, '0')
			*&
		ELSE 
			*&
		   RETURN PADR(lcBits, 64, '0')
			*&
		ENDIF 
		*&
	ENDPROC && Float2Bin(pnValue, pnWordSize)
	*&
	*& ===========================================================================
	*&   dtHelper.Hex2Bin(pcHexString)
	*& ===========================================================================
	*&    Purpose: convert hex bcd number to binary representation of bcd number    
	*& Parameters: string data type       
	*&     Takes each hex digit and converts to four binary digits    
	*&     Example: 4 = 0100, 0 = 0000, 5 = 0101 etc.   
	*&    returns: string data type       
	*&      Usage: cresult=hex2bin(cHexString)
	*&             STORE hex2bin('405EDD2F1A9FBE77') TO nMyNum 
	*&  nMyNum == '0100000001011110110111010010111100011010100111111011111001110111'
	*& ===========================================================================
	*&
	PROCEDURE Hex2Bin(pcHexString)
		*&
		LOCAL lcBinString, lcBinString1, lnStrLen, lnI
		*&
		STORE '' TO lcBinString, lcBinString1
		STORE 0 TO lnStrLen, lnI
		*&
		STORE Len(pcHexString) TO lnStrLen
		*&
		FOR lnI = 1 TO lnStrLen
			*&
			lcBinString = lcBinString + ; 
				PADL(This.Dec2Basx(INT(VAL('0x' + SUBSTR(pcHexString, lnI, 1))), 2), 4, '0')
			*&
		ENDFOR && lnI = 1 TO lnStrLen
		*&
		RETURN lcBinString
		*&
	ENDPROC && Hex2Bin(pcHexString)
	*&
	*& ===========================================================================
	*& dtHelper.Hex2Bytes(cHex,lLR)
	*& ===========================================================================
	*&
	PROCEDURE Hex2Bytes(cHex,lLR)
		*&
		LOCAL llSuccess, lcString
		*&
		STORE "" TO lcString
		*&
		llSuccess = VARTYPE(cHex) == "C" AND NOT EMPTY(cHex)
		*&
		IF llSuccess
			*&
			llSuccess = VARTYPE(lLR) == "L"
			*&
		ENDIF && llSuccess
		*&
		WITH This
			*&
			IF llSuccess
				*&
				*& ---------------------------------------
				*& Either operation will consume 2 digits
				*& a piece... 00-FF = 0-255...
				*& ---------------------------------------
				*&
				IF lLR
					*&
					FOR lnI = 1 TO LEN(cHex) STEP + 2
						*&
						lcString = lcString + CHR(.Hex2Dec(SUBSTR(cHex,lnI,2)))
						*&
					ENDFOR && lnI = 1 TO LEN(cHex) STEP + 2
					*&
				ELSE
					*&
					FOR lnI = (LEN(cHex) - 1) TO 1 STEP - 2
						*&
						lcString = lcString + CHR(.Hex2Dec(SUBSTR(cHex,lnI,2)))
						*&
					ENDFOR && lnI = (LEN(cHex) - 1) TO 1 STEP - 2
					*&
				ENDIF && lLR
				*&
			ENDIF && llSuccess
			*&
		ENDWITH && This
		*&
		RETURN lcString
		*&
	ENDPROC && Hex2Bytes(cHex,lLR)
	*&
	*& ===========================================================================
	*&   dtHelper.Hex2Dec(hexnum)
	*& ===========================================================================
	*&              i.e., '0001' returns 1 and          
	*&                    'ffff' returns 65535          
	*& Parameters: hexnum - a string valued '0000' to 'ffff'          
	*&             decnum - initialized to 0 returns the value of the conversion    
	*&      Usage: nresult=hex2dec(cHexNum)
	*&             STORE hex2dec('FFFF') TO nMyNum &&... nMyNum contains 65535
	*& ===========================================================================
	*&
	PROCEDURE Hex2Dec(hexnum)
		*&
		STORE 0 TO decnum 
		STORE '' TO tempnum
		IF LEN(ALLTRIM(hexnum)) < 4
		   hexnum = PADL(hexnum, 4, '0')
		ENDIF ( LEN(ALLTRIM(hexnum)) < 4 )
		STORE LEN(hexnum)-1 TO indx
		*&
		*&
		FOR i = 1 TO LEN(hexnum)
			*&
		   DO CASE
		      CASE SUBSTR(UPPER(hexnum), i, 1) == "F"
		         tempnum = '15'
		      CASE SUBSTR(UPPER(hexnum), i, 1) == "E"
		         tempnum = '14'
		      CASE SUBSTR(UPPER(hexnum), i, 1) == "D"
		         tempnum = '13'
		      CASE SUBSTR(UPPER(hexnum), i, 1) == "C"
		         tempnum = '12'
		      CASE SUBSTR(UPPER(hexnum), i, 1) == "B"
		         tempnum = '11'
		      CASE SUBSTR(UPPER(hexnum), i, 1) == "A"
		         tempnum = '10'
		      OTHERWISE
		         tempnum = SUBSTR(hexnum, i, 1)
		   ENDCASE
		   decnum = decnum + (VAL(tempnum) * (16^indx))
		   indx = indx - 1
			*&
		ENDFOR && ( i )
		*&
		RETURN decnum
		*&
	ENDPROC && Hex2Dec(hexnum)
	*&
	*& ==================================================
	*& dtHelper.Int2Bytes(pnInt,pnSize,plLR)
	*&
	*& This is the opposite to Bytes2Int, where an
	*& integer is converted to a Binary String.  The size
	*& is requrired.  It was not necessary because the
	*& string told the size, however the Int could be
	*& a variety of sizes.
	*&
	*& plLR is an indicator that says the bytes should
	*& be in reverse order from the conversion...
	*& ==================================================
	*&
	PROCEDURE Int2Bytes(pnInt,pnSize,plLR)
		*&
		LOCAL llSuccess, lcString, lnI
		*&
		STORE "" TO lcString
		STORE 0 TO lnI
		*&
		llSuccess = VARTYPE(pnInt) == "N"
		*&
		IF llSuccess
			*&
			llSuccess = VARTYPE(pnSize) == "N" ;
				AND NOT EMPTY(pnSize)
			*&
		ENDIF && llSuccess
		*&
		IF llSuccess
			*&
			llSuccess = VARTYPE(plLR) == "L"
			*&
		ENDIF && llSuccess
		*&
		IF llSuccess
			*&
			IF llSuccess
				*&
				IF plLR
					*&
					FOR lnI = pnSize - 1 TO 0 STEP - 1
						*&
						lcString = lcString + CHR(pnInt/256^lnI%256)
						*&
					ENDFOR && lnI = pnSize - 1 TO 0 STEP - 1
					*&
				ELSE
					*&
					FOR lnI = 0 TO pnSize - 1
						*&
						lcString = lcString + CHR(pnInt/256^lnI%256)
						*&
					ENDFOR && lnI = 0 TO pnSize - 1
					*&
				ENDIF && plLR
				*&
			ENDIF && llSuccess
			*&
		ENDIF && llSuccess
		*&
		RETURN lcString
		*&
	ENDPROC && Int2Bytes(pnInt,pnSize,plLR)
	*&
	*& ==================================================
	*& dtHelper.Reverse(pcString)
	*&
	*& This is a helper function to reverse the order of
	*& the bytes in a string...
	*& ==================================================
	*&
	PROCEDURE Reverse(pcString)
		*&
		LOCAL llSuccess, lnByte, lnLength, lcString
		*&
		STORE 0 TO lnByte, lnLength
		STORE "" TO lcString
		*&
		llSuccess = VARTYPE(pcString) = "C"
		*&
		IF llSuccess
			*&
			FOR lnByte = lnLength TO 1 STEP - 1
				*&
				lcString = (lcString + SUBSTR(pcString,lnByte,1))
				*&
			ENDFOR && lnByte = lnLength TO 1 STEP - 1
			*&
			*&
		ENDIF && llSuccess
		*&
		RETURN lcString
		*&
	ENDPROC && Reverse(pcString)
	*&
ENDDEFINE && CLASS dtHelper AS SESSION
*&
*&
