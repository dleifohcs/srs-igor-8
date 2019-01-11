//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-File-load.ipf
//
// Functions for loading data files.  
//
//------------------------------------------------------------------------------------------------------------------------------------
//
// Copyright 2013 Steven Schofield
//
//    This library is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This library is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
//------------------------------------------------------------------------------------------------------------------------------------
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


//------------------------------------------------------------------------------------------------------------------------------------
// Below is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------
//
// Function SRSFileOpenHook(refNum,filenameStr,pathStr,typeStr,creator,kind)
// Function SRSLoadData(pathStr,filenameStr)
//
// ------------------------------------
// SRS SPECS file load functions
// ------------------------------------
// Function loadKaneXY2012(path,filename)
// Function loadNEXAFSASC2013(path, filename )
// Function/S NEXAFSDialogRegion(shortfilename)
// Function NEXAFSDialogTheta(shortfilename)
//
// ------------------------------------
// SRS STM file load functions
// ------------------------------------
// Function SRSFlatFileLoad(pathStr,filenameStr)
// Function/S ReadFlatStr(refNum)
// Function FlatRaw2Phys()
// Function/S FlatRedimensionAxes()
// Function FlatFile1DProcess()
// Function FlatFile2DProcess()
// Function FlatFile3DProcess()
// Function FlatAddInfo2Wave()
// Function/S FlatRenameWaveAndDF()
//
//--------------------------------
// Misc. data load functions
//--------------------------------
// Function loadWaveFunction( pathStr, filenameStr )
//
//------------------------------------------------------------------------------------------------------------------------------------
// Above is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------
// Define what to do when a file is dropped into Igor
//------------------------------------------------------------------------------------------------------------------------------------
Function SRSFileOpenHook(refNum,filenameStr,pathStr,typeStr,creator,kind)
	Variable refNum,kind
	String filenameStr,pathStr,typeStr,creator
	
	Variable fileOpenedStatus
	if(kind==0 || kind==6 || kind==7 || kind==8 || kind==9)
		PathInfo $pathStr
		String FullPathStr = S_path
		fileOpenedStatus = SRSLoadData(FullPathStr,filenameStr)
		return fileOpenedStatus // this will be 1 or 0; if 1 Igor won't attempt to open the file, otherwise it will.
	else
		return 0
	endif
End


//------------------------------------------------------------------------------------------------------------------------------------
// Examine the file extension and decide what to do 
//------------------------------------------------------------------------------------------------------------------------------------
Function SRSLoadData(pathStr,filenameStr)
	String pathStr,filenameStr
	
	// CREATE a data folder containing variables for controlling the behaviour of the programme,
	// e.g., determining whether or not to load all data in a single data folder, or separate DFs.
	createSRSControlVariables()
	
	String ext = ParseFilePath(4, filenameStr, ":", 0, 0)
//	String filenamestart = ParseFilePath(0, filenameStr, ".", 0, 0)
//Print "DEBUG: ", filenamestart
	Variable returnVar = 1 // set to 1 means that Igor will not attempt to open the file
	strswitch (ext)
		case "Z_flat":
			SRSFlatFileLoad(pathStr,filenameStr)
			break
		case "I_flat":
			SRSFlatFileLoad(pathStr,filenameStr)
			break
		case "flat":
			SRSFlatFileLoad(pathStr,filenameStr)
			break
		case "I(V)_flat":
			SRSFlatFileLoad(pathStr,filenameStr)
			break
		case "Aux1(V)_flat":
			SRSFlatFileLoad(pathStr,filenameStr)
			break
		case "I(Z)_flat":
			SRSFlatFileLoad(pathStr,filenameStr)
			break
		case "I(t)_flat":
			SRSFlatFileLoad(pathStr,filenameStr)
			break
		case "xy":
			loadXY2013(pathStr,filenameStr)
			break
		case "wfn":
			loadWaveFunction( pathStr, filenameStr )
			break
		case "asc":
			loadNEXAFSASC2013( pathStr, filenameStr )
			break
		case "easc":
			loadNEXAFSASC2014( pathStr, filenameStr )
			break
		case "acc":
			loadAccelerometer( pathStr, filenameStr )
			break
		case "11":
			loadSEMITIPfort( pathStr, filenameStr, 11)
			break
		case "95":
			loadSEMITIPfort( pathStr, filenameStr, 95)
			break
		case "96":
			loadSEMITIPfort( pathStr, filenameStr, 96)
			break
		case "97":
			loadSEMITIPfort( pathStr, filenameStr, 97)
			break
		case "14":
			loadSEMITIPfort( pathStr, filenameStr, 14)
			break
		case "91":
			loadSEMITIPfort( pathStr, filenameStr, 14)
			break
		case "92":
			loadSEMITIPfort( pathStr, filenameStr, 14)
			break
		case "15":
			loadSEMITIPfort( pathStr, filenameStr, 15 )
			break
		case "17":
			loadSEMITIPfort( pathStr, filenameStr, 17 )
			break
		case "19":
			loadSEMITIPfort( pathStr, filenameStr, 19 )
			break
		case "30":
			loadSEMITIPfort( pathStr, filenameStr, 30 )
			break
		case "40":
			loadSEMITIPfort( pathStr, filenameStr, 40 )
			break
		case "50":
			loadSEMITIPfort( pathStr, filenameStr, 50 )
			break
		case "tf0":
			loadScalaImage(pathStr, filenameStr)
			break
		case "tf1":
			loadScalaImage(pathStr, filenameStr)
			break
		case "tb0":
			loadScalaImage(pathStr, filenameStr)
			break
		case "tb1":
			loadScalaImage(pathStr, filenameStr)
			break
		case "testo":
			loadTestoLogData(pathStr, filenameStr)
			break
		case "PARCHG":
			loadPARCHG(pathStr, filenameStr)
			break
		case "dx":
			loaddx(pathStr, filenameStr)
			break
		case "wos":
			loadWOS(pathStr, filenameStr)
			break
		case "txt":
			loadxps(pathStr, filenameStr)
			break
		case "mww":
			loadmww(pathStr, filenameStr)
			break
		default:
			returnVar = 0
			Print "SRS macro package does not know this file extension type; handing file back to Igor file loader"
			break
	endswitch
	return returnVar
End




//--------------------------------------
// STS STM file loading functions
//--------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------
// Load data from Kane's XY file format (Dec. 2012 Australian Synchrotron trip)
//------------------------------------------------------------------------------------------------------------------------------------
Function loadKaneXY2012(path,filename)
	String path, filename
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Make a new datafolder based on the filename
	String DFnameFromFileName= removeBadChars(filename)
	DFnameFromFileName= removeSpace(DFnameFromFileName)
	NewDataFolder/O/S root:$DFnameFromFileName
	
	// Load the column data 
	LoadWave/Q/J/D/W/N/O/K=1/V={"\t, "," $",0,0} path+filename
	Variable numWaves= V_flag
	String waveNameList= S_waveNames
	
	// Assume the first wave is the x-axis data.  Get the wave name and make wave assignment 
	String xWStr= StringFromList(0,waveNameList,";")
	Wave xW= $xWStr
		
	Variable xMin = WaveMin(xW)
	Variable xMax = WaveMax(xW)
	
	// Scale the x-axis of the loaded waves (as per data in the first wave) and add units.
	// Future work: A switch function could be used to alter y units if "counts" is not appropriate for all.
	Variable i
	For (i=0; i<numWaves; i+=1)
		String wNameStr= StringFromList(i,waveNameList,";")
		Wave w= $wNameStr	
		SetScale/I x, xMin, xMax, "eV", w
		SetScale/I y, 0, 1, "counts", w
	EndFor
		
	// House keeping
//	KillWaves S_waveNames, S_path, S_fileName
	
	// Move to original data folder
//	SetDataFolder saveDF
End



//------------------------------------------------------------------------------------------------------------------------------------
// Load data from Kane's XY file format (Dec. 2012 Australian Synchrotron trip)
//------------------------------------------------------------------------------------------------------------------------------------
Function loadmww(path,filename)
	String path, filename
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Make a new datafolder based on the filename
	String DFnameFromFileName= removeBadChars(filename)
	DFnameFromFileName= removeSpace(DFnameFromFileName)
	//NewDataFolder/O/S root:$DFnameFromFileName
	NewDataFolder/O/S root:wavefunctions
	
	// Load the column data 
	LoadWave/Q/J/D/W/N/O/K=1/V={"\t, "," $",0,0} path+filename
	Variable numWaves= V_flag
	String waveNameList= S_waveNames
	Wave wave0
	
	Variable datalength = DimSize(wave0,0)
	Variable imagewidth = Sqrt(datalength)
	Redimension/N=(imagewidth,imagewidth) wave0
	
	Variable intensitySum = 1
	intensitySum = Sum(wave0)
	wave0 = wave0 / intensitySum
	Print "Normalising the sum of the intensity values to unity.  Before normalisation: ", intensitySum
	
	Duplicate/O wave0, $DFnameFromFileName
	KillWaves wave0
End




//------------------------------------------------------------------------------------------------------------------------------------
// Load data from 2013 XY format - i.e., the output of SinSpect
//------------------------------------------------------------------------------------------------------------------------------------
Function loadXY2013(pathStr,filenameStr)
	String pathStr, filenameStr
	
	// -------------------------------------------------------------------------------------------------------------------------------------------//
	// USER DEFINED VARIABLES FOR CONTROLLING THE BEHAVIOUR OF THIS FILE LOADER	
	Variable VERBOSE = 0  // set to 1 to increase the amount of output to the command window: useful for debugging 
	Variable keepEXT = 0 // set to 1 to keep the individual channel data and extended channels 
	// -------------------------------------------------------------------------------------------------------------------------------------------//
	
	// Save current DF
	String saveDF = GetDataFolder(1)
	
	// Make  DF to load data into 
	//KillDataFolder/Z root:XY
	NewDataFolder/O/S root:XY
	
	Variable i			// used in for loops
	Variable refNum		// used for the file identification
	String headerStr		// string to read file header line into
	
	// Combine path and filename into a single string 
	String FullFileNameStr = pathStr+filenameStr
	
	// Open data file
	Open/R/Z=1 refNum as FullFileNameStr
	Variable err = V_flag
	if ( err )
		Print "ERROR: unable to open the XY file for reading. Aborting."
		return 1
	endif
	
	// Output that we're beginning the file load 
	Print " "
	
	// VERBOSE
	if ( VERBOSE )
		Print "Loading XY file" 
	endif 
	
	// -----------------------------------------
	// SECTION 1: HEADER
	// -----------------------------------------

	// read the header line and write to screen	
	FReadLine refnum, headerStr
	// remove hash and quotes from headerStr
	headerStr = headerStr[2,strlen(headerStr)-2]
	if ( VERBOSE )
		Print headerStr
	endif
	
	// Close file - will load the data using Igor general wave load function (since Kane so nicely formatted the data file!)
	Close refnum
	
	// -----------------------------------------
	// SECTION 2: DATA
	// -----------------------------------------
	
	// load data using built in Igor function
	LoadWave/A/Q/G/D/W/O FullFileNameStr
	
	// get list of wave names
	String waveNameList = S_waveNames
	
	// get names of first two waves and assume these are the energy wave and the counts wave
	String energyWStr = StringFromList(0,waveNameList)
	String countsWStr = StringFromList(1,waveNameList)
	
	// make wave assignments
	Wave energyW = $energyWStr
	Wave countsW = $countsWStr
	
	// -------------------------------------------
	// SECTION 3: Data scaling, info, etc.
	// -------------------------------------------
	
	// add header to wave as a note
	Note/NOCR countsW, "HEADER:"+headerStr+";"
	
	// add x scale to counts wave
	// KOD: actually because it's a binding energy axis it's in reverse,
	// so to play it safe, set the scale directly from the first and last
	// energies not the min and max.
	Variable eVi = energyW(0)
	Variable eVf = energyW(numpnts(energyW)-1)
	if ( eVi > eVf )
		Reverse countsW
		SetScale/I x, eVf, eVi, "eV", countsW
	else
		SetScale/I x, eVi, eVf, "eV", countsW
	endif 
	
	// y scale
	SetScale/I y, 0, 1, "counts", countsW
		
	// -----------------------------------------
	// SECTION 4: rename data wave 
	// -----------------------------------------
	
	// kill redundant energy wave
	KillWaves/Z energyW	
			
	// get a sample description from user
	String shortfilename = ParseFilePath(3, filenameStr, ":", 0, 0)
	String sampleDescription = XPSDialogSamplePreparation(shortfilename)
	
	// add header to waves as a note
	Note/NOCR countsW, "DESCRIPTION:"+sampleDescription+";"
	
	// make a name from file name that is safe for naming an igor wave
	String filenameForWaveNames 
	filenameForWaveNames = replaceHyphen(filenameStr)  // replaces "-" with "_" in file name since Igor doesn't like those in wave names
	
	filenameForWaveNames = sampleDescription+"_"+filenameForWaveNames
	
	// make name for the data wave based on path and file name
	String newWaveNameStr = ParseFilePath(3,filenameForWaveNames, ":", 0, 0)  // remove the file extension
	// EDIT 13Dec2013: I think we want to removeBadChars and place the result in newWaveNameStr not filenameForWaveNames.
	newWaveNameStr = removeBadChars(filenameForWaveNames)  // just in case...
	
	// COMMENT 13Dec2013: What if the wave name is too long? Ask user for alternative.
	if (strlen(newWaveNameStr) >= 32)
		newWaveNameStr = SPECSDialogNameTooLong(newWaveNameStr)
	endif
	
	// copy data wave to one with same name as input file name
	Duplicate/O countsW, $newWaveNameStr
	KillWaves/Z countsW
	
	// make new wave assignment because use this below in section 6 for moving to new DF
	Wave countsW = $newWaveNameStr
	
	// ---------------------------------------------------------------------------------------
	// SECTION 5: Tidy Data Folder by moving EXT data to its own directory
	// ---------------------------------------------------------------------------------------
	
	if ( keepEXT == 1 ) // keep the individual channel data and extended channel data
	
		// Move all the other waves into a new datafolder (neater)
		String wStr=""
		String extDFStr = "ext_"+newWaveNameStr
		NewDataFolder/O $extDFStr
		for (i=2; i<ItemsInList(waveNameList); i+=1)
			wStr = StringFromList(i,waveNameList)
			Wave w = $wStr
			Duplicate/O w, root:XY:$(extDFStr):$(wStr)
			KillWaves/Z w
		endfor
	
	else 	// delete individual channel data and extended channel data
		
		for (i=2; i<ItemsInList(waveNameList); i+=1)
			wStr = StringFromList(i,waveNameList)
			Wave w = $wStr
			KillWaves/Z w
		endfor
		
	endif
	
	// ----------------------------------------------------------------------------------
	// SECTION 6: Rename data DF based on supplied user description 
	// ----------------------------------------------------------------------------------
	
	SetDataFolder root:
	if ( DataFolderExists(sampleDescription) )
		// do nothing
	else
		NewDataFolder root:$(sampleDescription)
	endif
	
	// Make copy of data in DESCRIPTION DF
	Duplicate/O countsW, root:$(sampleDescription):$newWaveNameStr
	
	// make copy of ext data as well if keepEXT flag is set
	if ( keepEXT == 1 ) // keep the individual channel data and extended channel data
		// kill DF in that directory if it exists
		KillDataFolder/Z root:$(sampleDescription):$extDFStr
		// duplicate the loaded DF
		DuplicateDataFolder root:XY:$extDFStr, root:$(sampleDescription):$extDFStr
	endif
	
	// Kill the XY data folder
	KillDataFolder/Z root:XY
	
	// ---------------------------------------------------
	// End
	// ---------------------------------------------------

	// return to original DF
	//SetDataFolder saveDF
	
	// Leave user in the DF of the data
	SetDataFolder root:$(sampleDescription)
End
	

//------------------------------------------------------------------------------------------------------------------------------------
// this loads the NEXAFS data files from the August 2013 trip to Australian Synchrotron
//------------------------------------------------------------------------------------------------------------------------------------
Function loadNEXAFSASC2013(path, filename )
	String filename, path
	Variable refNum
	Wave cln = root:reference:'mcp_n'
	
	String FullFileNameStr = path+filename

	DFREF saveDFR = GetDataFolderDFR()
	
	Open /R/Z=2 refNum as FullFileNameStr
	
	if (V_flag != 0)
		Print "error loading nexafs data"
		return 0 // Something broke
	endif
	
	// Information to command line
	Print "Detected .asc file input. Assuming from NEXAFS output, opening into new data folder."
	
	// Remove extension from filename
	String shortfilename = ParseFilePath(3, filename, ":", 0, 0)
	
	// Get input from used and create DF for data
	String datafoldername
	String region = NEXAFSDialogRegion(shortfilename)
	if ( cmpstr(region,"ref")==0 ) // reference spectrum
		datafoldername = "reference"
	else // not a reference spectrum
		Variable theta = NEXAFSDialogTheta(shortfilename)
		datafoldername = shortfilename+"_"+region+"_"+num2str(theta)
	endif
	NewDataFolder /O/S root:$datafoldername
	
	// Load data
	LoadWave /W/A/O/G FullFileNameStr
	Close refNum
	
	Wave wave0
	Wave wave1
	Wave wave2
	Wave wave3
	Wave wave4
	Wave wave5
	Wave wave6
	Wave wave7
	Wave wave8
	Wave wave9
	Wave wave10
	Wave wave11
	Wave wave12
	Wave wave13
	Wave wave14
	Wave wave15
	
	// data folder to store waves not commonly used in the analysis
	NewDataFolder/O/S data 
	
	// Rename waves
	Duplicate/O wave1, scanEnergy
	Duplicate/O wave2, dwellTime
	Duplicate/O wave3, encoderEnergy
	Duplicate/O wave4, drainCurrent
	Duplicate/O wave5, I0
	Duplicate/O wave6, refFoil
	Duplicate/O wave7, MCP
	Duplicate/O wave8, CHN
	Duplicate/O wave9, PHD
	Duplicate/O wave10, TFYPHD
	
	// Make new wave which is MCP/CHN - this is Bruce's "rough normalised data"
	Duplicate/O wave7, MCPoverCHN
	MCPoverCHN = MCP / CHN
	
	// Move back to main data folder for the NEXAFS data
	SetDataFolder root:$datafoldername
	
	
	
	Variable scanMin = WaveMin(scanEnergy)
	Variable scanMax = WaveMax(scanEnergy)
	
	// Set the scale on all the scan outputs
	SetScale/I x, scanMin, scanMax, "eV", drainCurrent
	SetScale/I x, scanMin, scanMax, "eV", I0
	SetScale/I x, scanMin, scanMax, "eV", refFoil
	SetScale/I x, scanMin, scanMax, "eV", MCP
	SetScale/I x, scanMin, scanMax, "eV", CHN
	SetScale/I x, scanMin, scanMax, "eV", PHD
	SetScale/I x, scanMin, scanMax, "eV", TFYPHD
	
	String mcpnName = "mcp_n"
	if ( cmpstr(region,"ref")==0 ) // reference spectrum
		Duplicate/O wave7 $mcpnName
	else // not reference
		mcpnName = shortfilename+"_"+region+"_"+num2str(theta)+"_n"
		Duplicate/O wave7 $mcpnName
		if ( WaveExists(cln) ) // check that a reference spectrum exists before attempting double normalisation
			String mcpdnName = shortfilename+"_"+region+"_"+num2str(theta)+"_dn"
			Duplicate/O MCP $mcpdnName
			Wave mcpdn = $mcpdnName
		else
			// do nothing
		endif
	endif
	
	Wave mcpn = $mcpnName
	
	// Check if the global variable "cleanSpectrum) exists. If it does, double normalize
	// into a variable mcpdn
	
	if ( WaveExists(cln) ) // reference spectrum exists so do double normalisation
		Duplicate/O MCP $mcpdnName
		Wave mcpdn = $mcpdnName
		mcpn = mcpn / I0
		mcpdn = mcpn
		mcpdn = mcpdn/cln
		// add the angle to the wave note so that it can be extracted later if desired
		Note/NOCR mcpdn, "THETA:"+num2str(theta)+";REGION:"+region
		
	else  // only single normalisation
		mcpn = mcpn / I0
	endif
	// add the angle to the wave note so that it can be extracted later if desired
	Note/NOCR mcpn, "THETA:"+num2str(theta)+";REGION:"+region
	
	// clean up
	KillWaves wave0, wave1, wave2, wave3, wave4, wave5, wave6
	KillWaves wave7, wave8, wave9, wave10,wave11, wave12
	KillWaves wave13, wave14, wave15
	
	SetDataFolder saveDFR
	return 1
End

//------------------------------------------------------------------------------------------------------------------------------------
// this loads the NEXAFS data files exported by Eliot Gann's NEXAFS program in 2014
//------------------------------------------------------------------------------------------------------------------------------------
Function loadNEXAFSASC2014(path, filename )
	String filename, path
	Variable refNum
	
	String FullFileNameStr = path+filename

	DFREF saveDFR = GetDataFolderDFR()
	
	Open /R/Z=2 refNum as FullFileNameStr
	
	if (V_flag != 0)
		Print "error loading nexafs data"
		return 0 // Something broke
	endif
	
	// Information to command line
	Print "Detected .easc file input. Assuming from NEXAFS output, opening into new data folder."
	
	// Remove extension from filename
	String shortfilename = ParseFilePath(3, filename, ":", 0, 0)
	
	// Get input from used and create DF for data
	String datafoldername
	String region = NEXAFSDialogRegion(shortfilename)
	
	// Go through file and find important data
	// Two things we need to find, the line: "Data---------------------------------------------------"
	// which tells us where the data starts (and also gives us column headings, allowing us not to worry about which columns
	// are which), and the line "anglestr = X" which tells us the photon incidence angle. We could be really sneaky about
	// how we do this search, but the easiest way is just to search for theta first and the data second.
	String buffer
	Variable len, linenumber, theta
	linenumber = 0
	theta = 0
	do
		FReadLine refNum, buffer
		len = strlen(buffer)
		if (len == 0)
			break // if we run out of file, break out of the loop
		endif		
		// Check the current line for the angle.
		sscanf buffer, "anglestr = %g", theta
		if (V_flag == 1) // E.g. we found theta
			break
		endif
		linenumber = linenumber + 1
	while (1)
	
	FSetPos refNum, 0
	
	// Check we actually found a value for theta. If not, ask the user.
	if (theta == 0)
		theta = NEXAFSDialogTheta(shortfilename)
	endif
	
	// Now search again for data
	linenumber = 0
	Variable result
	do
		FReadLine/T=(num2char(13)) refNum, buffer
		len = strlen(buffer)
		if (len == 0)
			// We've run out of file - tell Igor to figure out the columns on it's own 
			linenumber = 0
			break
		endif	
		result = StringMatch(buffer, "Data-*")
		if (result == 1)
			FReadLine/T=(num2char(13)) refNum, buffer
			FReadLine/T=(num2char(13)) refNum, buffer	
			FReadLine/T=(num2char(13)) refNum, buffer
			// buffer now contains the headers		
			break
		endif	
		linenumber = linenumber + 1
	while (1)
	
	FSetPos refNum, 0
	
	buffer = replaceNonSpaceWhiteSpace(definitelyRemoveQuotes(removeBadChars(buffer)))
	print "Found ", ItemsInList(buffer, " "), " channels."
	print "Channels are: ", buffer
	
	
	datafoldername = shortfilename+"_"+region+"_"+num2str(theta)
	NewDataFolder /O/S root:$datafoldername
	
	// Load data
	LoadWave /W/A/O/G FullFileNameStr
	Close refNum
	
	// data folder to store waves not commonly used in the analysis
	NewDataFolder/O/S data 
	
	If (ItemsInList(buffer, " ") != ItemsInList(S_waveNames))
		Print "Warning: number of waves read not the same as number of channels found."
	EndIf
	
	// Rename waves
	String wloadname, wname
	Variable i
	For (i=0; i<ItemsInList(S_waveNames);i+=1)
		wloadname="root:"+datafoldername+":"+StringFromList(i, S_waveNames)
		wname=StringFromList(i, buffer, " ")
		Wave w = $wloadname
		Duplicate/O w, $wname
	EndFor

	// Assumption is that the MCP channel has already been double-normalized as necessary
	// in Eliot's program, so just set the scales appropriately. We look for all the following
	// waves but might not have them all.
	String header_types = "EncoderPhotonEnergy;IzeroVF;PhotonEnergy;ExpTime;DrainCurrentVF;Ref_Foil_VF;MCP;Channeltron;Direct_PHD_VF;TFY_PHD_VF;DrainCurrent_Keithley1;Izero_Keithley3;RefFoil_Keithley4;Keithley6;RingCurrent;BL_PHD_VF;BL_PHD_Keithley2;Undulator_Gap_Request;Undulator_Gap_Readback"
	
	// Try first to find PhotonEnergy, then EncoderPhotonEnergy as a backup.
	Variable scanMin
	Variable scanMax
	Wave w = $"PhotonEnergy"
	If (WaveExists(w))
		scanMin = WaveMin(w)
		scanMax = WaveMax(w)
	Else
		Wave w = $"EncoderPhotonEnergy"
		If (WaveExists(w))
			scanMin = WaveMin(w)
			scanMax = WaveMax(w)
		Else
			Print "Warning: neither PhotonEnergy or EncoderPhotonEnergy found in headers. Are you sure you're loading NEXAFS here?"
			scanMin = 0
			scanMax = 1
		EndIf
	EndIf
		
	For (i=0;i<ItemsInList(header_types);i+=1)
		wname=StringFromList(i,header_types)
		Wave w = $wname
		If (WaveExists(w))
			SetScale/I x, scanMin, scanMax, "eV", w
		EndIf
	EndFor
	
	String baseName = shortfilename+"_"+region+"_"+num2str(theta)
	If (FindListItem("MCP", header_types) > -1)
		wname = "root:"+datafoldername+":"+baseName+"_mcp"
		Duplicate/O $"MCP" $wname
		Note/NOCR $wname, "THETA:"+num2str(theta)+";REGION:"+region
	EndIf
	If (FindListItem("Channeltron", header_types) > -1)
		wname = "root:"+datafoldername+":"+baseName+"_chn"
		Duplicate/O $"Channeltron" $wname
		Note/NOCR $wname, "THETA:"+num2str(theta)+";REGION:"+region
	EndIf

	// Move back to main data folder for the NEXAFS data
	SetDataFolder root:$datafoldername	

	// clean up
	For (i=0; i<ItemsInList(S_waveNames); i+=1)
		wname = StringFromList(i, S_waveNames)
		KillWaves $wname
	EndFor
	
	SetDataFolder saveDFR
	return 1
End

//------------------------------------------------------------------------------------------------------------------------------------
// Get Region from User for NEXAFS data load
//------------------------------------------------------------------------------------------------------------------------------------
Function/S NEXAFSDialogRegion(shortfilename)
	String shortfilename
	String region="X"
	String reference="No"
	Prompt region, "Enter Region Name for file "+shortfilename 
	Prompt reference, "Is this a reference spectrum?", popup, "No;Yes"
	DoPrompt shortfilename, region, reference
	if (V_Flag)
      	return "error"                   // User canceled
	else 
		if ( cmpstr(reference,"Yes")==0)
			return "ref"
		else
			return region
		endif
	endif
End

//------------------------------------------------------------------------------------------------------------------------------------
// Get input from user on sample preparation
//------------------------------------------------------------------------------------------------------------------------------------
Function/S XPSDialogSamplePreparation(shortfilename)
	String shortfilename
	String description="X"
	Prompt description, "Enter very brief sample description ( < 10 characters) "+shortfilename 
	DoPrompt shortfilename, description
	if (V_Flag)
      	return "error"                   // User canceled
	else 
		// clean up description if necessary
		description = replaceSpace(description)
		description = replaceHyphen(description)
		description = removeBadChars(description)
		
		return description
	endif
End

//------------------------------------------------------------------------------------------------------------------------------------
// Ask for an alternative file name because the automatically generated one is too long.
//------------------------------------------------------------------------------------------------------------------------------------
Function/S SPECSDialogNameTooLong(longfilename)
	String longfilename
	String shortname="X"
	
	do
		Prompt shortname, "Enter a shorter file name! ( < 32 characters) "+ longfilename 
		DoPrompt longfilename, shortname
	while (strlen(shortname) >= 32)
	
	if (V_Flag)
      		return "error"                   // User canceled
	else 
		// clean up description if necessary
		shortname = replaceSpace(shortname)
		shortname = replaceHyphen(shortname)
		shortname = removeBadChars(shortname)
		
		return shortname
	endif
End

//------------------------------------------------------------------------------------------------------------------------------------
// Get Theta from User for NEXAFS data load
//------------------------------------------------------------------------------------------------------------------------------------
Function NEXAFSDialogTheta(shortfilename)
	String shortfilename
	Variable theta=0
	Prompt theta, "Enter Theta for file "+shortfilename 
	DoPrompt shortfilename, theta
	if (V_Flag)
      	return 999                     // User canceled
	else 
		return theta
	endif
End


//--------------------------------------
// STS STM file loading functions
//--------------------------------------

// -------------------------------------------------------------------------------------------------------------------------------------------
//
// -------------------------------------------------------------------------------------------------------------------------------------------
Function SRSFlatFileLoad(pathStr,filenameStr)
	String pathStr, filenameStr

	// -------------------------------------------------------------------------------------------------------------------------------------------//
	// USER DEFINED VARIABLES FOR CONTROLLING THE BEHAVIOUR OF THIS FILE LOADER	
	Variable VERBOSE = 0  // set to 1 to increase the amount of output to the command window: useful for debugging 
	Variable RETAIN_MATRIX_INFO = 1  // set to 1 to keep all information loaded from the matrix file
	// -------------------------------------------------------------------------------------------------------------------------------------------//
	
	// Save current DF
	String saveDF = GetDataFolder(1)
	
	// Make temporary DF to load data into (will rename later)
	KillDataFolder/Z root:FlatFile
	NewDataFolder/O/S root:FlatFile
	
	Variable i, j, k		// used in for loops
	Variable refNum		// used for the file identification
	
	// Combine path and filename into a single string 
	String FullFileNameStr = pathStr+filenameStr
	
	String jpegpathStr = pathStr+":JPEG"
	String jpegIVpathStr = pathStr+":JPEG_IV"
	NewPath /Q/O dataDirectory, pathStr
	NewPath /Q/O/C dataJPEGDirectory, jpegpathStr
	NewPath /Q/O/C dataJPEGIVDirectory, jpegIVpathStr
	
	// Open data file
	Open/R/Z=1 refNum as FullFileNameStr
	Variable err = V_flag
	if ( err )
		Print "ERROR: unable to open the flat file for reading. Aborting."
		return 1
	endif
	
	// -----------------------------------------
	// SECTION 1: FILE IDENTIFICATION
	// -----------------------------------------
	
	// Print " "
	
	// VERBOSE
	if ( VERBOSE )
		Print "Loading File Identification" 
	endif 
	
	// Read magic string that tells us whether file is a flat file or not
	String magic_word = ""
	String file_structure_level = ""
	magic_word = PadString(magic_word,4,0)
	file_structure_level  = PadString(magic_word,4,0)
	FBinRead refNum, magic_word
	FBinRead refNum, file_structure_level 
	// if not a flat file then stop
	if ( cmpstr(magic_word,"FLAT")!=0 )
		Print "ERROR: File does not have a Flat File Format header.  Stopping"
		return 1
	else
		If ( VERBOSE ) 
			Print "Opened Flat File: file structure level =", file_structure_level 
		endif
	endif
	if ( cmpstr(file_structure_level ,"0100")!=0 )
		Print "WARNING: File structure level not '0100' - the flat file format may have changed since this loader was written"
	endif
	
	// -----------------------------------------------
	// SECTION 2: Axis Hierarchy Description
	// -----------------------------------------------
	
	// VERBOSE
	if ( VERBOSE )
		Print "Loading Axis Hierarchy Description"
	endif 
	
	// New DF for channel description
    	NewDataFolder/O/S root:FlatFile:axes
    	
	// Read axis count
	Variable/G axis_count;		FBinRead/F=3/U refNum, axis_count  // read how many axes exist in file

	// VERBOSE
	if ( VERBOSE )
		Print "Numer of axes found =", axis_count
	endif
	
	Make/O/T/N=(axis_count) axes_names
	
	// Loop over number of axes
	for ( i=0; i < axis_count; i+=1 ) 

		// make a new Data Folder for each axis to hold its properties
		NewDataFolder/O/S $("axis_"+num2str(i)) //$name
				
		// Axis description
		String/G axis_name = ReadFlatStr(refNum)
		axes_names[i] = axis_name
		
        	String/G parent_name = ReadFlatStr(refNum)
     	   	String/G unit = ReadFlatStr(refNum)
    	    	Variable/G clock_count; 		FBinRead/F=3 refNum, clock_count
        	Variable/G raw_start;			FBinRead/F=3 refNum, raw_start
        	Variable/G raw_inc;				FBinRead/F=3 refNum, raw_inc
        	Variable/G phys_start; 			FBinRead/F=5 refNum, phys_start
        	Variable/G phys_inc; 			FBinRead/F=5 refNum, phys_inc
        	Variable/G mirrored; 			FBinRead/F=3 refNum, mirrored
        	Variable tableset_count;		FBinRead/F=3 refNum, tableset_count
		
		// tableset data - loop over the number of table sets (given by tablesetcount)
		for ( j=0; j < tableset_count ; j+=1 ) 
			
			// create new sub-DF
			String saveDFjLoop = GetDataFolder(1)
            	NewDataFolder/O/S $("tableset_"+num2str(j))
            
            	// read variables
            	String/G associated_axis = ReadFlatStr(refNum)
           	 	Variable interval_count;		FBinRead/F=3 refNum, interval_count
           	 	
           	 	// loop over the numer of intervals (given by interval count)
           	 	for ( k=0; k < interval_count ; k+=1 )
				
           	 		// create new sub-DF
				String saveDFkLoop = GetDataFolder(1)
            		NewDataFolder/O/S $("interval_"+num2str(k))
                	
                		// read variables
                		Variable/G start;	FBinRead/F=3 refNum, start
                		Variable/G stop;	FBinRead/F=3 refNum, stop
                		Variable/G step;		FBinRead/F=3 refNum, step
                	
                		// return to DF 
           	 		SetDataFolder saveDFkLoop
                	endfor // k
                	
                	// return to DF 
           	 	SetDataFolder saveDFjLoop
            endfor // j
            
            // Back to axes DF
            SetDataFolder root:FlatFile:axes
    
      endfor	// i
      
      // Return to top level DF 
	SetDataFolder root:FlatFile
      
	// -----------------------------------------------
	// SECTION 3: Channel Description
	// -----------------------------------------------
	
	// VERBOSE
	if ( VERBOSE )
		Print "Loading Channel Description"
	endif 

	// New DF for channel description
    	NewDataFolder/O/S root:FlatFile:channel

	// Read channel name
    	String/G channel_name = ReadFlatStr(refNum)
    	String/G TF_name = ReadFlatStr(refNum)
    	String/G channel_unit = ReadFlatStr(refNum)
    	
    	Variable TF_parameter_count;		FBinRead/F=3 refNum, TF_parameter_count
    	
	String TF_parameter_Str 
	for ( i=0; i < TF_parameter_count; i+=1 )
		TF_parameter_Str = ReadFlatStr(refNum)
		Variable/G $TF_parameter_Str; 	FBinRead/F=5 refNum, $TF_parameter_Str
	endfor
		
	// Read view information
	Variable view_count; 			FBinRead/F=3 refNum, view_count
	if ( view_count > 0)
		if ( view_count == 1)
	
			Variable/G view_id;			FBinRead/F=3 refNum, view_id
	
		else	 	// if more than one view_id then store the values in a wave called view_id_w
	
			Make/O/N=(view_count) view_id_w
			Variable view_tmp
			for ( i=0; i<view_count; i+=1 )
				FBinRead/F=3 refNum, view_tmp
				view_id_w[i] = view_tmp
			endfor
	
		endif
	endif

	// Return to top level DF 
	SetDataFolder root:FlatFile
	
	// -----------------------------------------------
	// SECTION 4: Creation Information
	// -----------------------------------------------
	
	// VERBOSE
	if ( VERBOSE )
		Print "Loading Creation Information"
	endif 
	
	// Create DF
    	NewDataFolder/O/S root:FlatFile:creation_info
    	
	// Read  date and time stamp 
    	Variable timestamp;			FBinRead/F=3 refNum, timestamp 
    	Variable dummy;			FBinRead/F=3 refNum, dummy 

    	String/G datetimeStr = secs2date(timestamp+date2secs(1970,1,1),-2)+" "+secs2time(timestamp+date2secs(1970,1,1),1)

    	// Read comments
    	String/G comment = ReadFlatStr(refNum)

	// Return to top level DF 
	SetDataFolder root:FlatFile
	
	// -----------------------------------------------
	// SECTION 5: Raw Data 
	// -----------------------------------------------
	
	// VERBOSE
	if ( VERBOSE )
		Print "Loading Raw Data"
	endif 
	
	// Create DF
    	NewDataFolder/O/S root:FlatFile:raw_data
    	
    	Variable/G bricklet_size; 		FBinRead/F=3 refNum, bricklet_size
    	Variable data_count; 			FBinRead/F=3 refNum, data_count

	// VERBOSE
	if ( VERBOSE )
		Print "Size of bricklet =", bricklet_size
		Print "   ...of which,", data_count,"bytes are data"
	endif 
	
    	// create variables for holding data
    	Make/O/N=(data_count) raw_dataW

	// Read raw data
	FBinRead/F=3 refNum, raw_dataW
  
	// Return to top level DF 
	SetDataFolder root:FlatFile
	
	// -------------------------------------------------
	// SECTION 6: Sample position information
	// -------------------------------------------------	
		
	// VERBOSE
	if ( VERBOSE )
		Print "Loading Sample Position"
	endif 
	
	// Create DF
    	NewDataFolder/O/S root:FlatFile:sample_position
    
    	// Read offset informations
    	Variable/G offset_count; 		FBinRead/F=3 refNum, offset_count
    	
    	if ( offset_count > 1 )
    	
    		Make/N=(offset_count) offsetW_x
    		Make/N=(offset_count) offsetW_y
    		Variable offsettmp
    		
		for ( i=0; i < offset_count; i+=1 )
			FBinRead/F=5 refNum, offsettmp
        		offsetW_x[i]=offsettmp
        		FBinRead/F=5 refNum, offsettmp
        		offsetW_y[i]=offsettmp
    		endfor
    		
    	elseif ( offset_count == 1 )
    	
    		Variable/G offset_x;	FBinRead/F=5 refNum, offset_x
    		Variable/G offset_y;	FBinRead/F=5 refNum, offset_y
    		
    	endif
    	
    	// Return to top level DF 
	SetDataFolder root:FlatFile
	
	// -------------------------------------------------
	// SECTION 7: Experiment Information
	// -------------------------------------------------	
	
	// VERBOSE
	if ( VERBOSE )
		Print "Loading Experiment Information"
	endif 
	
	// Create DF
	NewDataFolder/O/S root:FlatFile:expt_info
	
    	String/G Experiment_Name = ReadFlatStr(refNum)
    	String/G Experiment_Version = ReadFlatStr(refNum)
    	String/G Experiment_Description = ReadFlatStr(refNum)
    	String/G File_Specification = ReadFlatStr(refNum)
 	String/G Flat_File_Creator = ReadFlatStr(refNum)
    	String/G Matrix_File_Creator = ReadFlatStr(refNum)
    	String/G Matrix_User_ID = ReadFlatStr(refNum)
	String/G Windows_Account_Name = ReadFlatStr(refNum)
	String/G Result_File_Specification = ReadFlatStr(refNum)
	Variable/G run_cycle;		FBinRead/F=3 refNum, run_cycle
	Variable/G scan_cycle;		FBinRead/F=3 refNum, scan_cycle
	
	// Return to top level DF 
	SetDataFolder root:FlatFile
	
	// ----------------------------------------------------------
	// SECTION 8: Experiment Element Parameter List
	// ----------------------------------------------------------
	
	// VERBOSE
	if ( VERBOSE )
		Print "Loading Experiment Element Parameter List "
	endif 
	
	// Create DF
	NewDataFolder/O/S root:FlatFile:expt_elements

	// Read Experiment Element Parameters 
    	Variable Experiment_Element_count;		FBinRead/F=3 refNum, Experiment_Element_count
	
	// Make a wave to hold all the experiment element names
	Make/O/T/N=(Experiment_Element_count) Parameter_List
	
	for (i=0; i < Experiment_Element_count; i+=1 )
		
		// New DF for each experiment element
		String Element_name = ReadFlatStr(refNum)
		NewDataFolder/O/S $Element_name
        	Parameter_List[i] = Element_name  // add the element name to the list (text wave)
        	
        	// Read each Parameter for current element...
        	Variable Element_instance_count; 		FBinRead/F=3 refNum, Element_instance_count
        	
        	// Create waves to hold the values
		Make/O/T/N=(Element_instance_count) Par_nameW
		Make/O/N=(Element_instance_count) Par_intW
		Make/O/T/N=(Element_instance_count) Par_unitW
		Make/O/T/N=(Element_instance_count) Par_valW

		// fill the variables
		Variable Par_int_tmp
		for ( j=0; j < Element_instance_count; j+=1 )

       		Par_nameW[j] = ReadFlatStr(refNum)
       		FBinRead/F=3 refNum, Par_int_tmp;			Par_intW[j] = Par_int_tmp
            	Par_unitW[j] = ReadFlatStr(refNum)
            	Par_valW[j] = ReadFlatStr(refNum)

		endfor // j loop
  		
  		// Return to element paramers DF
		SetDataFolder root:FlatFile:expt_elements
		
	endfor  // i loop
	
 	// Return to top level DF 
	SetDataFolder root:FlatFile
	
	
	// -------------------------------------------------------------------------
	// SECTION 9: Experiment Element Deployment Parameter List
	// -------------------------------------------------------------------------
	
	// VERBOSE
	if ( VERBOSE )
		Print "Loading Experiment Element Deployment Parameter List "
	endif 
	
    	Variable Experiment_Element_deploy_count;		FBinRead/F=3 refNum, Experiment_Element_count

	if ( Experiment_Element_deploy_count > 0 )
	
		// Create DF
		NewDataFolder/O/S root:FlatFile:expt_element_deploy_params
	
		Make/O/T/N=(Experiment_Element_deploy_count) Deploy_Parameter_List

		// Create waves to hold the values
		Make/O/T/N=(Experiment_Element_deploy_count) Par_deploy_nameW
		Make/O/T/N=(Experiment_Element_deploy_count) Par_deploy_valW
		
		for (i=0; i < Experiment_Element_deploy_count; i+=1 )
		
			// New DF for each experiment element
			NewDataFolder/O/S $("Experiment_Deploy_Element"+num2str(i))
	
			Par_deploy_nameW[j] = ReadFlatStr(refNum)
           	 	Par_deploy_valW[j] = ReadFlatStr(refNum)

			// Move back in DF
			SetDataFolder root:FlatFile:expt_element_deploy_params
		
		endfor
	
 		// Return to top level DF 
		SetDataFolder root:FlatFile
	
	endif
	
	// Close data file
	Close refNum 
	
	// -------------------------------------------------------------------------//
	// POST-LOAD OPERATIONS
	// -------------------------------------------------------------------------//
	
	// VERBOSE
	if ( VERBOSE )
		Print "Converting data to physical values"
	endif 
	
	// Convert RAW data to PHYSICAL data and increase precision to double precision floating point
	FlatRaw2Phys()
	
	// VERBOSE
	if ( VERBOSE )
		Print "Dimensioning the axes"
	endif 
	
	// Redimension the axes 
	FlatRedimensionAxes()
	
	// VERBOSE
	if ( VERBOSE )
		Print "Add experiment information to wave as an Igor Note"
	endif 
	
	// Add experiment information to wave data
	FlatAddInfo2Wave()
		
	// VERBOSE
	if ( VERBOSE )
		Print "Renaming waves and DF"
	endif 
	
	// Rename the data waves and the data folder according to the channel name, run and scan number, and image mode
	String dataDF = FlatRenameWaveAndDF()
	
	if ( VERBOSE )	
		Print "Finished loading"
	endif 
	
	// Move to DF containing the data
	SetDataFolder dataDF

// SHOULD MAKE THIS VARIABLE GLOBAL IN SRSSTMCONTROL VARIABLES	
	// Delete unused matrix information if RETAIN_MATRIX_INFO not set
	if ( RETAIN_MATRIX_INFO != 1 )
		KillDataFolder matrix_info
	endif
	
	// get global variable on automatic background subtraction preference
	SVAR autoBGplane = root:WinGlobals:SRSSTMControl:autoBGplane
	SVAR autoBGlinewise = root:WinGlobals:SRSSTMControl:autoBGlinewise
	String autoBG
	
	// automatic background subtraction
	if ( cmpstr(autoBGlinewise,"yes")==0 )
		autoBG = "linewise"
	elseif (cmpstr(autoBGplane,"yes")==0 )
		autoBG = "plane"
	else
		autoBG = "none"
	endif
	
	// Automatically display images and CITS if loading from flat file format
	SVAR autoDisplay = root:WinGlobals:SRSSTMControl:autoDisplay
	if ( cmpstr(autoDisplay,"yes")==0)
		if ( VERBOSE )
			Print "display", dataDF
		endif 
		displayAllData(autoBG=autoBG)
	endif
	
	// set minimum to zero
	//doSomethingWithData("subtractMin")
	
	
	// Move to original DF
	//SetDataFolder saveDF
End

 
//-----------------------------------------------------------------------
// Read a string from flat file
//-----------------------------------------------------------------------
Function/S ReadFlatStr(refNum)
	Variable refNum
	
	Variable i
	String returnStr = ""
      Variable char_count, charUTF16
      
      FBinRead/F=3 refNum, char_count	// read the 32 bit "field length" that determines how many characters 
      									// are in the string to be read

	// Read in each character of the string
	for ( i=0; i < char_count; i+=1 )
		 FBinRead/F=2 refNum, charUTF16
		 returnStr[i] = num2char(charUTF16)
	endfor
	
	return returnStr
End

	
//-------------------------------------	--------------------------------------------------------------------
// Scale RAW data to PHYSICAL data using the transfer function described in the flat file
//-------------------------------------	--------------------------------------------------------------------
Function FlatRaw2Phys()

	// Save the current DF
	String saveDF = GetDataFolder(1)
	
	// Move to FlatFile DF
	SetDataFolder root:FlatFile
	
	// Move to channel DF that has the transfer function information
	SetDataFolder channel
	
	// Load Variables
	String/G TF_name
	String/G channel_unit
	
	strswitch ( TF_name )
		case "TFF_Linear1D":
			Variable/G Factor
			Variable/G Offset
			break
		case "TFF_MultiLinear1D":
			Variable/G NeutralFactor
			Variable/G Offset
			Variable/G PreFactor
			Variable/G PreOffset
			Variable/G Raw_1
			break
		default:
			//
			break
	endswitch
	
	// Move to FlatFile DF
	SetDataFolder root:FlatFile
	
	// Move to channel DF that has the transfer function information
	SetDataFolder raw_data
	
	// Load raw data (1D wave prior to reshaping to image or cits etc)
	Wave raw_dataW
	
	// Duplicate wave to hold the physically scaled wave
	Duplicate/O raw_dataW phys_dataW
	
	// Increase precision of phys_dataW to double precision floating point
	Redimension/D phys_dataW
	
	// scale wave
	strswitch ( TF_name )
		case "TFF_Linear1D":
			phys_dataW = (phys_dataW - Offset) / Factor
			break
		case "TFF_MultiLinear1D":
			phys_dataW = (raw_1 - PreOffset) * (phys_dataW - Offset) / (NeutralFactor * PreFactor)
			break
		default:
			Print "WARNING: (FlatRaw2Phys) cannot determine transfer function type.  Data unscaled.  Check."
			break
	endswitch

	// add units to data
	SetScale/I d, 0, 1, channel_unit, phys_dataW
	
	// Move back to original DF
	SetDataFolder saveDF
	
End
		

//------------------------------------------------------------------------------------
// Redimension the axes (calls separate functions for images, sts, etc)
//------------------------------------------------------------------------------------
Function FlatRedimensionAxes()
	
	Variable VERBOSE = 0  // set to 1 to increase the amount of output to the command window: useful for debugging 
	
	// Save the current DF
	String saveDF = GetDataFolder(1)
	
	// Move to axes DF
	SetDataFolder root:FlatFile:axes
	
	Variable/G axis_count
	
	// get the names of each axis (i.e., load the text wave that already exists and holds this data)
	Wave/T axes_names
	Variable axes_names_len = DimSize(axes_names,0)
	Make/T/O/N=(axes_names_len) axes_names_short
	Variable i
	for ( i=0; i<axes_names_len; i+=1)
		axes_names_short[i] = EverythingAfterLastColon(axes_names[i])
	endfor

	// decide what do to for different number of axes
	switch ( axis_count )
		case 1:  	// 1D data
			if (VERBOSE )
				Print "Data is one dimensional: axis is", axes_names_short[0]
			endif 
			FlatFile1DProcess()
			break
		case 2: 	// 2D data
			if (VERBOSE )
				Print "Data is two dimensional: axes are",axes_names_short[0]+" and",axes_names_short[1]
			endif 
			FlatFile2DProcess()	
			break
		case 3:		// 3D data
			if (VERBOSE )
				Print "Data is three dimensional: axes are",axes_names_short[0]+",",axes_names_short[1]+",",axes_names_short[2]
			endif
			FlatFile3DProcess()
			break
		default:
			Print "ERROR: don't know how many axes exist for this data"
			break
	endswitch

	// Move back to original DF
	SetDataFolder saveDF
End
	
	
//-------------------------------------	--------------------------------------------------------------------
// 
//-------------------------------------	--------------------------------------------------------------------
Function FlatFile1DProcess()

	// Save the current DF
	String saveDF = GetDataFolder(1)
	
	// Move to FlatFile DF
	SetDataFolder root:FlatFile
	
	SetDataFolder axes
	String saveDFaxes = GetDataFolder(1)
	
	// V or Z (could possibly make this general by not renaming the data folder in the loading stage)
//	if ( DataFolderExists("V") )
//		SetDataFolder V
//	elseif ( DataFolderExists("Z") )
//		SetDataFolder Z
//	endif
	
	SetDataFolder axis_0
	
	Variable/G clock_count
	Variable/G mirrored
	Variable/G phys_start
	Variable/G phys_inc
	String/G unit
	
	// move to raw data DF 
	SetDataFolder root:FlatFile:raw_data
	
	Variable/G bricklet_size
	Wave phys_dataW
	
	// root data dir
	SetDataFolder root:FlatFile
	
	// Make data wave
	Duplicate/O phys_dataW, dataW 
	
	Variable data_length = DimSize(dataW,0) 
	
	// add NaNs to data if the bricklet is not complete
	if ( data_length < bricklet_size )
		Redimension/N=(bricklet_size) dataW
		dataW[data_length,bricklet_size-1] = NaN
	endif
	
	// Scale the x axes appropriately
	SetScale/P x, phys_start, phys_inc, unit, dataW
	
	// Check if a retrace wave is present 
	if (mirrored==1)
		Make/N=(bricklet_size/2) dataT
		Make/N=(bricklet_size/2) dataR
		dataT[] = dataW[p]
		dataR[] = dataW[p+bricklet_size/2]
		Reverse/P dataR
		SetScale/P x, phys_start, phys_inc, unit, dataT
		SetScale/P x, phys_start, phys_inc, unit, dataR
		
		KillWaves dataW
		Duplicate/O dataT, dataW
		KillWaves dataT
	endif
		// Scale the x and y axes appropriately
//	SetScale/P x, x_phys_start, x_phys_inc, x_unit, dataFU
//	SetScale/P y, y_phys_start, y_phys_inc, y_unit, dataFU
//	SetScale/I d, 0, 1, data_unit, dataFU
	
	// Move back to original DF
	SetDataFolder saveDF
	
End
	

//-------------------------------------	--------------------------------------------------------------------
// 
//-------------------------------------	--------------------------------------------------------------------
Function FlatFile2DProcess()
	
	// Save the current DF
	String saveDF = GetDataFolder(1)
	
	// Move to FlatFile DF
	SetDataFolder root:FlatFile
	
	SetDataFolder axes
	String saveDFaxes = GetDataFolder(1)
	
	// X (likely)
	SetDataFolder axis_0
	Variable/G clock_count
	Variable/G mirrored
	Variable/G phys_start
	Variable/G phys_inc
	String/G unit
	
	Variable xclock = clock_count
	Variable xmirrored = mirrored
	Variable x_phys_start = phys_start
	Variable x_phys_inc = phys_inc
	String x_unit = unit
	SetDataFolder saveDFaxes
	
	// Y (likely)
	SetDataFolder axis_1
	Variable/G clock_count
	Variable/G mirrored
	Variable/G phys_start
	Variable/G phys_inc
	String/G unit
	
	Variable yclock = clock_count
	Variable ymirrored = mirrored
	Variable y_phys_start = phys_start
	Variable y_phys_inc = phys_inc
	String y_unit = unit
	
	// Move to raw data DF
	SetDataFolder root:FlatFile:raw_data 
	
	Variable/G bricklet_size
	Wave phys_dataW
	
	// Get data units
	String data_information = WaveInfo(phys_dataW,0)
	String data_unit = StringByKey("DUNITS", data_information)		
	
	Variable data_length = DimSize(phys_dataW,0) 
	
	// add NaNs to data if the bricklet is not complete
	if ( data_length < bricklet_size )
		Redimension/N=(bricklet_size) phys_dataW
		phys_dataW[data_length,bricklet_size-1] = NaN
	endif
	
	Redimension /N=(xclock,yclock) phys_dataW
	
	Variable xWidth = 0
	Variable yWidth = 0

	// determine image width
	if ( xmirrored )
		xWidth = xclock / 2
	else 
		xWidth = xclock
	endif
	
	// determine image height
	if ( ymirrored )
		yWidth = yclock / 2		
	else
		yWidth = yclock	
	endif
	
	// Move to FlatFile DF
	SetDataFolder root:FlatFile
	
	// Make waves for each of the four images
	Make/D/O/N=(xWidth,yWidth) dataFU
	Make/D/O/N=(xWidth,yWidth) dataBU
	Make/D/O/N=(xWidth,yWidth) dataFD
	Make/D/O/N=(xWidth,yWidth) dataBD

	// copy data to image waves
	dataFU[][]=phys_dataW[p][q]
	if ( xmirrored )
		dataBU[][]=phys_dataW[p+xWidth][q]
	endif 
	if ( ymirrored )
		dataFD[][]=phys_dataW[p][q+yWidth]
	endif
	if ( xmirrored && ymirrored )
		dataBD[][]=phys_dataW[p+xWidth][q+yWidth]
	endif

	// Flip the x coords of "backward" images
	Reverse/DIM=0 dataBU
	Reverse/DIM=0 dataBD
	
	// Flip the y coords of "down" images
	Reverse/DIM=1 dataFD
	Reverse/DIM=1 dataBD

	// Reconstitute dataW with each of the individual images flipped appropriately (for debugging)
//	dataW[xWidth,2*xWidth-1][0,yWidth-1] = dataBU[p-xWidth][q]	
//	dataW[xWidth,2*xWidth-1][yWidth,2*yWidth-1] = dataBD[p-xWidth][q-yWidth]
//	dataW[0,xWidth-1][yWidth,2*yWidth-1] = dataFD[p][q-yWidth]

	// Scale the x and y axes appropriately
	SetScale/P x, x_phys_start, x_phys_inc, x_unit, dataFU
	SetScale/P y, y_phys_start, y_phys_inc, y_unit, dataFU
	SetScale/I d, 0, 1, data_unit, dataFU
	
	SetScale/P x, x_phys_start, x_phys_inc, x_unit, dataBU
	SetScale/P y, y_phys_start, y_phys_inc, y_unit, dataBU
	SetScale/I d, 0, 1, data_unit, dataBU
	
	SetScale/P x, x_phys_start, x_phys_inc, x_unit, dataFD
	SetScale/P y, y_phys_start, y_phys_inc, y_unit, dataFD
	SetScale/I d, 0, 1, data_unit, dataFD
	
	SetScale/P x, x_phys_start, x_phys_inc, x_unit, dataBD
	SetScale/P y, y_phys_start, y_phys_inc, y_unit, dataBD
	SetScale/I d, 0, 1, data_unit, dataBD
	
	// Clean up
	
	// Move to raw data DF
	SetDataFolder root:FlatFile:raw_data 
	
	KillWaves phys_dataW
	// Move back to original DF
	SetDataFolder saveDF
End			



//-------------------------------------	--------------------------------------------------------------------
// 
//-------------------------------------	--------------------------------------------------------------------
Function FlatFile3DProcess()

	// this loads in a "dumb" way right now - assumes the first axis is the spectroscopy axis, e.g., V and the
	// next two axes are X and Y.  If encounter problems it may become necessary to have the function
	// determine what kind of axis it is before loading.

	// Save the current DF
	String saveDF = GetDataFolder(1)
	
	// Move to axes DF
	SetDataFolder root:FlatFile:axes

	// V (for CITS)
	SetDataFolder root:FlatFile:axes:axis_0
	
	Variable/G clock_count
	Variable/G mirrored
	Variable/G phys_start
	Variable/G phys_inc
	String/G unit
	
	Variable V_clock = clock_count
	Variable V_mirrored = mirrored
	Variable V_phys_start = phys_start
	Variable V_phys_inc = phys_inc
	String V_unit = unit
	
	// Move to table set 0 DF (x-axis) 
	SetDataFolder root:FlatFile:axes:axis_0:tableset_0
	
	// Interval 0
	SetDataFolder interval_0
	
	Variable/G start
	Variable/G stop
	Variable/G step
	
	Variable x_0_start = start
	Variable x_0_stop = stop
	Variable x_0_step = step
	
	// Return to table set 0 DF (x-axis)
	SetDataFolder root:FlatFile:axes:axis_0:tableset_0
	
	//Determine if a second interval exists (e.g., for dual mode CITS)
	
	// create variables for the dual mode and set to 0 until determined whether or not these exist
	Variable x_1_start = 0
	Variable x_1_stop = 0
	Variable x_1_step = 0
	
	// Interval 1 (dual mode)
	if ( DataFolderExists ("interval_1") )
		SetDataFolder interval_1
	
		Variable/G start
		Variable/G stop
		Variable/G step
		
		x_1_start = start
		x_1_stop = stop
		x_1_step = step
	endif
		
	// Move to table set 1 DF (y-axis) 
	SetDataFolder root:FlatFile:axes:axis_0:tableset_1
	
	// Interval 0
	SetDataFolder interval_0
	
	Variable/G start
	Variable/G stop
	Variable/G step
	
	Variable y_0_start = start
	Variable y_0_stop = stop
	Variable y_0_step = step	
	
	// Get next tableset information if exists - e.g., if the "image down" CITS was acquired
	SetDataFolder root:FlatFile:axes:axis_0:tableset_1
	
	// create variables for the down scan and set to 1 until determined whether or not these exist
	Variable y_1_start = 0
	Variable y_1_stop = 0
	Variable y_1_step = 0	
		
	if ( DataFolderExists("interval_1") )
		SetDataFolder interval_1
		Variable/G start
		Variable/G stop
		Variable/G step
		
		y_1_start = start
		y_1_stop = stop
		y_1_step = step
	endif
	
	// X (likely)
	SetDataFolder root:FlatFile:axes:axis_1
	Variable/G clock_count
	Variable/G mirrored
	Variable/G phys_start
	Variable/G phys_inc
	String/G unit
	
	Variable x_clock = clock_count
	Variable x_mirrored = mirrored
	Variable x_phys_start = phys_start
	Variable x_phys_inc = phys_inc
	String x_unit = unit
	
	// Y (likely)
	SetDataFolder root:FlatFile:axes:axis_2
	Variable/G clock_count
	Variable/G mirrored
	Variable/G phys_start
	Variable/G phys_inc
	String/G unit
	
	Variable y_clock = clock_count
	Variable y_mirrored = mirrored
	Variable y_phys_start = phys_start
	Variable y_phys_inc = phys_inc
	String y_unit = unit
	
	// Need to adjust x_phys_inc and y_phys_inc to account for the reduced grid
	x_phys_inc = x_phys_inc * x_0_step
	y_phys_inc = y_phys_inc * y_0_step
	
	// chage to raw data DF
	SetDataFolder root:FlatFile:raw_data	
	
	// Copy the physically scaled data to a new wave called dataW
	Wave phys_dataW
	
	// add NaNs to data if the bricklet is not complete
	Variable/G bricklet_size
	Variable data_length = DimSize(phys_dataW,0) 
	if ( data_length < bricklet_size )
		Redimension/N=(bricklet_size) phys_dataW
		phys_dataW[data_length,bricklet_size-1] = NaN
	endif

	// Determine width and height of CITS images 
	Variable x_0_width = 1+ ( x_0_stop - x_0_start ) / x_0_step 
	Variable y_0_width = 1 + ( y_0_stop - y_0_start ) / y_0_step 
	Variable x_1_width = 1+ ( x_1_stop - x_1_start ) / x_1_step 
	Variable y_1_width = 1 + ( y_1_stop - y_1_start ) / y_1_step 
	Variable V_width = V_clock

	// Get data units
	String data_information = WaveInfo(phys_dataW,0)
	String data_unit = StringByKey("DUNITS", data_information)	
	
	// Move to FlatFile DF
	SetDataFolder root:FlatFile
	
	// Make waves for each of the four images
	Make/O/N=(x_0_width,y_0_width,V_width) dataFU
	Duplicate/O dataFU, dataBU
	Duplicate/O dataFU, dataFD
	Duplicate/O dataFU, dataBD
//	Make/O/N=(x_1_width,y_0_width,V_width) dataBU		// in principle it would be better to make the waves this way, but 
//	Make/O/N=(x_0_width,y_1_width,V_width) dataFD		// then need to check whether any of the widths are zero
//	Make/O/N=(x_1_width,y_1_width,V_width) dataBD		// need to change this if FORWARD/BACKWARD/UP/DOWN are not all the same size 

	Variable i, j, c, data_start
	c=0
	// UP
	for ( j = 0; j < y_0_width; j+=1 )
		// FORWARD
		for ( i=0; i < x_0_width; i+=1 )
			data_start = V_width * c
			dataFU[i][j][] = phys_dataW[data_start + r]
			c+=1
		endfor
		// BACKWARD
		for ( i=0; i < x_1_width; i+=1 )
			data_start = V_width * c
			dataBU[i][j][] = phys_dataW[data_start + r]
			c+=1
		endfor
	endfor 
	
	// DOWN
	for ( j = 0; j < y_1_width; j+=1 )
		// FORWARD
		for ( i=0; i < x_0_width; i+=1 )
			data_start = V_width * c
			dataFD[x_0_width-i-1][j][] = phys_dataW[data_start + r]
			c+=1
		endfor
		// BACKWARD
		for ( i=0; i < x_1_width; i+=1 )
			data_start = V_width * c
			dataBD[x_0_width-i-1][j][] = phys_dataW[data_start + r]
			c+=1
		endfor
	endfor 
	
		
	// Scale the x and y axes appropriately
	SetScale/P x, x_phys_start, x_phys_inc, x_unit, dataFU
	SetScale/P y, y_phys_start, y_phys_inc, y_unit, dataFU
	SetScale/P z, V_phys_start, V_phys_inc, V_unit, dataFU
	SetScale/I d, 0, 1, data_unit, dataFU
	
	SetScale/P x, x_phys_start, x_phys_inc, x_unit, dataBU
	SetScale/P y, y_phys_start, y_phys_inc, y_unit, dataBU
	SetScale/P z, V_phys_start, V_phys_inc, V_unit, dataBU
	SetScale/I d, 0, 1, data_unit, dataBU
	
	SetScale/P x, x_phys_start, x_phys_inc, x_unit, dataFD
	SetScale/P y, y_phys_start, y_phys_inc, y_unit, dataFD
	SetScale/P z, V_phys_start, V_phys_inc, V_unit, dataFD
	SetScale/I d, 0, 1, data_unit, dataFD
	
	SetScale/P x, x_phys_start, x_phys_inc, x_unit, dataBD
	SetScale/P y, y_phys_start, y_phys_inc, y_unit, dataBD
	SetScale/P z, V_phys_start, V_phys_inc, V_unit, dataBD
	SetScale/I d, 0, 1, data_unit, dataBD
	
	// Clean up
	// chage to raw data DF
	SetDataFolder root:FlatFile:raw_data	
	KillWaves phys_dataW
	
	// Move back to original DF
	SetDataFolder saveDF
End			

	
//-------------------------------------	--------------------------------------------------------------------
//
//-------------------------------------	--------------------------------------------------------------------
Function FlatAddInfo2Wave()

	// Save the current DF
	String saveDF = GetDataFolder(1)
	
	//-----------------------------------------------
	// GET THE TIME STAMP AND COMMENT
	
	// Move to FlatFile DF
	SetDataFolder root:FlatFile
	
	// Move to time stamp DF
	SetDataFolder creation_info

	String/G datetimeStr
	String/G comment
	
	//-----------------------------------------------
	// GET THE CHANNEL NAME
	
	// Move to FlatFile DF
	SetDataFolder root:FlatFile
	
	// Move to time stamp DF
	SetDataFolder channel

	String/G channel_name
	
	//----------------------------------------------------
	// GET THE EXPERIMENT INFO (SCAN # etc.)
	
	// Move to FlatFile DF
	SetDataFolder root:FlatFile
	
	// Move to time stamp DF
	SetDataFolder expt_info

	Variable/G run_cycle
	Variable/G scan_cycle
	String/G Experiment_Name
	String/G Experiment_Version
	String/G Matrix_File_Creator
	String/G Flat_File_Creator
	
	//---------------------------
	// GET THE BIAS VALUE

	// Move to FlatFile DF
	SetDataFolder root:FlatFile
	
	// Move DF to gap voltage
	SetDataFolder expt_elements
	SetDataFolder GapVoltageControl	
	
	// Get the waves that hold the names of the parameter entries, the values and the units
	WAVE/T V_nameW= Par_nameW
	Wave/T V_valW = Par_valW
	Wave/T V_unitW = Par_unitW
	
	// find out how many entries there are to search over
	Variable V_nameW_len = DimSize(V_nameW,0)
	
	// Find the number corresponding to the Voltage and Alt Voltage entries
	Variable i, V_num, Valt_num
	Variable V_alt_found = 0
	for ( i = 0; i < V_nameW_len ; i+=1 )
		strswitch ( V_nameW[i] )
			case "Voltage":
				V_num = i
				break
			case "Alternate_Voltage":
				Valt_num = i
				V_alt_found = 1 // set this flag to 1 if the alternate value is found ** NOTE, this actually doesn't mean anything since the value can exist but not have been aplied.  look at Enable_Alternatre_Preamp_range instead
				break
			default:
				break
		endswitch
	endfor

	// This is in case no "alternate" value exists
	if ( cmpstr(V_valW[3],"false") == 0 ) // alternate voltage is not used.
		Valt_num = V_num
		if (cmpstr(V_nameW[3],"Enable_Alternate_Preamp_Range")!=0 )
			Print "WARNING: looks like flat file format has been changed and the alternatve bias may not be correct"
		endif
	endif
	
	// get the bias values
	String V = V_valW[V_num]
	String Valt = V_valW[Valt_num]
	
	// get the bias value units (should be V)
	String V_unit= V_unitW[V_num]
	String Valt_unit = V_unitW[Valt_num]

	// Change to the top level DF
	SetDataFolder root:FlatFile
	
	//------------------------------------
	// GET THE REGULATOR VALUE
	
	// Move to FlatFile DF
	SetDataFolder root:FlatFile
	
	// Move DF to tunnelling current
	SetDataFolder expt_elements
	SetDataFolder Regulator
	
	// Get the waves that hold the names of the parameter entries, the values and the units
	WAVE/T Reg_nameW= Par_nameW
	Wave/T Reg_valW = Par_valW
	Wave/T Reg_unitW = Par_unitW
	
	Variable Reg_nameW_len = DimSize(Reg_nameW,0)
	
	// Find the number corresponding to the Voltage and Alt Voltage entries
	Variable Reg_num, Regalt_num
	Variable Reg_alt_found = 0
 	for ( i = 0; i < Reg_nameW_len ; i+=1 )
		strswitch ( Reg_nameW[i] )
			case "Setpoint_1":
				Reg_num = i
				break
			case "Alternate_Setpoint_1":
				Regalt_num = i
				Reg_alt_found = 1
				break
			default:
				break
		endswitch
	endfor
	
	// This is in case no "alternate" value exists
	// find the entry called "Enable_Alternate_Setpoint_1"
	for ( i =0; i< DimSize(Reg_valW,0); i+=1 )
		if ( cmpstr(Reg_NameW[i],"Enable_Alternate_Setpoint_1") == 1 )
			if ( cmpstr(Reg_valW[i],"false") == 0 )
				Regalt_num = Reg_num
			endif 
			break  // stop after the first instance
		endif
	endfor

	// get the regulator values
	String Reg = Reg_valW[Reg_num]
	String Regalt = Reg_valW[Regalt_num]
	
	// get the regulator value units (should be A)
	String Reg_unit= Reg_unitW[Reg_num]
	String Regalt_unit = Reg_unitW[Regalt_num]

	// Change to the top level DF
	SetDataFolder root:FlatFile
	
	//-------------------------------------------------
	// Add the information to the wave notes
		
	// determine whether this is a 1D data (e.g., STS) or rastered data (e.g., images or CITS)	
	Wave dataW
	Wave dataR
	if ( WaveExists(dataW) )// 1D wave
		
		// Create name	
		Note/NOCR dataW, "Name:"+channel_name+" "+num2str(run_cycle)+"-"+num2str(scan_cycle)+";"
	
		// Create DF name	
		Note/NOCR dataW, "DFName:"+channel_name+" "+num2str(run_cycle)+"-"+num2str(scan_cycle)+";"
		
		// Add timestamp
		Note/NOCR dataW, "Time stamp:"+datetimeStr+";"
		
		// Write bias values to wave notes
		Note/NOCR dataW, "Voltage:"+V+" "+V_unit+";"
		
		// Write regulator values to wave notes
		Note/NOCR dataW, "Setpoint:"+Reg+" "+Reg_unit+";"
		
		// Other information
		Note/NOCR dataW, "Experimet_Name:"+Experiment_Name+";"
		Note/NOCR dataW, "Experiment_Version:"+Experiment_Version+";"
		Note/NOCR dataW, "Matrix_File_Creator:"+Matrix_File_Creator+";"
		Note/NOCR dataW, "Flat_File_Creator:"+Flat_File_Creator+";"
		Note/NOCR dataW, "Comment:"+comment+";"
	
		if ( WaveExists(dataR) )// 1D wave (retrace)
		
			// Create name	
			Note/NOCR dataR, "Name:"+channel_name+" "+num2str(run_cycle)+"-"+num2str(scan_cycle)+"r;"
	
			// Create DF name	
			Note/NOCR dataR, "DFName:"+channel_name+" "+num2str(run_cycle)+"-"+num2str(scan_cycle)+";"
		
			// Add timestamp
			Note/NOCR dataR, "Time stamp:"+datetimeStr+";"
		
			// Write bias values to wave notes
			Note/NOCR dataR, "Voltage:"+V+" "+V_unit+";"
		
			// Write regulator values to wave notes
			Note/NOCR dataR, "Setpoint:"+Reg+" "+Reg_unit+";"
		
			// Other information
			Note/NOCR dataR, "Experimet_Name:"+Experiment_Name+";"
			Note/NOCR dataR, "Experiment_Version:"+Experiment_Version+";"
			Note/NOCR dataR, "Matrix_File_Creator:"+Matrix_File_Creator+";"
			Note/NOCR dataR, "Flat_File_Creator:"+Flat_File_Creator+";"
			Note/NOCR dataR, "Comment:"+comment+";"
		endif 
	else // 2D or 3D waves

		// Get the data waves
		Wave dataFU
		Wave dataBU
		Wave dataFD
		Wave dataBD

		//-------------------------------------------------
		// Add the information to the wave notes
		
		// Create name	
		Note/NOCR dataFU, "Name:"+channel_name+" "+num2str(run_cycle)+"-"+num2str(scan_cycle)+" FU;"
		Note/NOCR dataBU, "Name:"+channel_name+" "+num2str(run_cycle)+"-"+num2str(scan_cycle)+" BU;"
		Note/NOCR dataFD, "Name:"+channel_name+" "+num2str(run_cycle)+"-"+num2str(scan_cycle)+" FD;"
		Note/NOCR dataBD, "Name:"+channel_name+" "+num2str(run_cycle)+"-"+num2str(scan_cycle)+" BD;"
	
		// Create DF name	
		Note/NOCR dataFU, "DFName:"+channel_name+" "+num2str(run_cycle)+"-"+num2str(scan_cycle)+";"
		Note/NOCR dataBU, "DFName:"+channel_name+" "+num2str(run_cycle)+"-"+num2str(scan_cycle)+";"
		Note/NOCR dataFD, "DFName:"+channel_name+" "+num2str(run_cycle)+"-"+num2str(scan_cycle)+";"
		Note/NOCR dataBD, "DFName:"+channel_name+" "+num2str(run_cycle)+"-"+num2str(scan_cycle)+";"
		
		// Add timestamp
		Note/NOCR dataFU, "Time stamp:"+datetimeStr+";"
		Note/NOCR dataBU, "Time stamp:"+datetimeStr+";"
		Note/NOCR dataFD, "Time stamp:"+datetimeStr+";"
		Note/NOCR dataBD, "Time stamp:"+datetimeStr+";"
		
		// Write bias values to wave notes
		Note/NOCR dataFU, "Voltage:"+V+" "+V_unit+";"
		Note/NOCR dataFD, "Voltage:"+V+" "+V_unit+";"
		Note/NOCR dataBU, "Voltage:"+Valt+" "+Valt_unit+";"
		Note/NOCR dataBD, "Voltage:"+Valt+" "+Valt_unit+";"
		
		// Write regulator values to wave notes
		Note/NOCR dataFU, "Setpoint:"+Reg+" "+Reg_unit+";"
		Note/NOCR dataFD, "Setpoint:"+Reg+" "+Reg_unit+";"
		Note/NOCR dataBU, "Setpoint:"+Regalt+" "+Regalt_unit+";"
		Note/NOCR dataBD, "Setpoint:"+Regalt+" "+Regalt_unit+";"
		
		// Other information
		Note/NOCR dataFU, "Experimet_Name:"+Experiment_Name+";"
		Note/NOCR dataFU, "Experiment_Version:"+Experiment_Version+";"
		Note/NOCR dataFU, "Matrix_File_Creator:"+Matrix_File_Creator+";"
		Note/NOCR dataFU, "Flat_File_Creator:"+Flat_File_Creator+";"
		Note/NOCR dataFU, "Comment:"+comment+";"
		
		Note/NOCR dataBU, "Experimet_Name:"+Experiment_Name
		Note/NOCR dataBU, "Experiment_Version:"+Experiment_Version
		Note/NOCR dataBU, "Matrix_File_Creator:"+Matrix_File_Creator
		Note/NOCR dataBU, "Flat_File_Creator:"+Flat_File_Creator
		Note/NOCR dataBU, "Comment:"+comment
		
		Note/NOCR dataFD, "Experimet_Name:"+Experiment_Name
		Note/NOCR dataFD, "Experiment_Version:"+Experiment_Version
		Note/NOCR dataFD, "Matrix_File_Creator:"+Matrix_File_Creator
		Note/NOCR dataFD, "Flat_File_Creator: "+Flat_File_Creator
		Note/NOCR dataFD, "Comment: "+comment
		
		Note/NOCR dataBD, "Experimet_Name:"+Experiment_Name
		Note/NOCR dataBD, "Experiment_Version:"+Experiment_Version
		Note/NOCR dataBD, "Matrix_File_Creator:"+Matrix_File_Creator
		Note/NOCR dataBD, "Flat_File_Creator:"+Flat_File_Creator
		Note/NOCR dataBD, "Comment:"+comment
	
	endif
			
	// Return to orginal DF
	SetDataFolder saveDF
End	

	
//-------------------------------------	--------------------------------------------------------------------
// Rename the data waves and the data folder that contains the waves.  Returns the 
// string containing the data folder of the waves.
//-------------------------------------	--------------------------------------------------------------------
Function/S FlatRenameWaveAndDF()

	// Move to FlatFile DF
	SetDataFolder root:FlatFile
	
	String DFname = ""
	
	SVAR autoSaveImage = root:WinGlobals:SRSSTMControl:autoSaveImage
	
	// determine whether this is a 1D data (e.g., STS) or rastered data (e.g., images or CITS)	
	Wave dataW
	
	if ( WaveExists(dataW) ) // 1D wave
		
		String Wwavenote = note(dataW)
		String Wname = StringByKey("Name",Wwavenote)
		Wname = replaceBadChars(Wname)
		Wname = replaceSpace(Wname)
		Wname = replaceHyphen(Wname)
		
		DFname = StringByKey("DFName",Wwavenote)
		DFname = replaceBadChars(DFname)
		DFname = replaceSpace(DFname)
		DFname = replaceHyphen(DFname)
		
		if (cmpstr(autoSaveImage,"yes")==0)
			String Wdate = StringByKey("Time stamp",Wwavenote)
			Wdate = Wdate[2,3]+Wdate[5,6]+Wdate[8,9]+"_"+Wdate[11,12]+Wdate[13,14]
			Wdate = replaceBadChars(Wdate)
			Wdate = replaceSpace(Wdate)
			Wdate = replaceHyphen(Wdate)
			Wname = "IV"+Wdate+"_"+Wname[4,30]
		endif 
		
		Make/O/D  $Wname
		Duplicate/O dataW, $Wname
		KillWaves dataW
		
		Wave dataR
		
		if ( WaveExists(dataR) ) // 1D wave
		
			Wwavenote = note(dataR)
			Wname = StringByKey("Name",Wwavenote)
			Wname = replaceBadChars(Wname)
			Wname = replaceSpace(Wname)
			Wname = replaceHyphen(Wname)
		
		//	DFname = StringByKey("DFName",Wwavenote)
		//	DFname = replaceBadChars(DFname)
		//	DFname = replaceSpace(DFname)
		//	DFname = replaceHyphen(DFname)
		
			Make/O/D  $Wname
			Duplicate/O dataR, $Wname
			KillWaves dataR
		
		endif
		
	else // 2D or 3D waves
		// Assign waves
		Wave dataFU
		Wave dataBU
		Wave dataFD
		Wave dataBD
	
		String wavenoteFU = note(dataFU)
		String wavenoteBU = note(dataBU)
		String wavenoteFD = note(dataFD)
		String wavenoteBD = note(dataBD)
			
		String nameFU = StringByKey("Name",wavenoteFU)
		String nameBU = StringByKey("Name",wavenoteBU)
		String nameFD = StringByKey("Name",wavenoteFD)
		String nameBD = StringByKey("Name",wavenoteBD)
		
		nameFU = replaceBadChars(nameFU)
		nameFU = replaceSpace(nameFU)
		nameFU = replaceHyphen(nameFU)
		
		nameBU = replaceBadChars(nameBU)
		nameBU = replaceSpace(nameBU)
		nameBU = replaceHyphen(nameBU)
		
		nameFD = replaceBadChars(nameFD)
		nameFD = replaceSpace(nameFD)
		nameFD = replaceHyphen(nameFD)
		
		nameBD = replaceBadChars(nameBD)
		nameBD = replaceSpace(nameBD)
		nameBD = replaceHyphen(nameBD)
		
		
		
		if (cmpstr(autoSaveImage,"yes")==0)
		
			String dateFU = StringByKey("Time stamp",wavenoteFU)
			String dateBU = StringByKey("Time stamp",wavenoteBU)
			String dateFD = StringByKey("Time stamp",wavenoteFD)
			String dateBD = StringByKey("Time stamp",wavenoteBD)
		
			dateFU = dateFU[2,3]+dateFU[5,6]+dateFU[8,9]+"_"+dateFU[11,12]+dateFU[13,14]
			dateFD = dateFD[2,3]+dateFD[5,6]+dateFD[8,9]+"_"+dateFD[11,12]+dateFD[13,14]
			dateBU = dateBU[2,3]+dateBU[5,6]+dateBU[8,9]+"_"+dateBU[11,12]+dateBU[13,14]
			dateBD = dateBD[2,3]+dateBD[5,6]+dateBD[8,9]+"_"+dateBD[11,12]+dateBD[13,14]
			
			dateFU = replaceBadChars(dateFU)
			dateFU = replaceSpace(dateFU)
			dateFU = replaceHyphen(dateFU)
		
			dateBU = replaceBadChars(dateBU)
			dateBU = replaceSpace(dateBU)
			dateBU = replaceHyphen(dateBU)
		
			dateFD = replaceBadChars(dateFD)
			dateFD = replaceSpace(dateFD)
			dateFD = replaceHyphen(dateFD)
		
			dateBD = replaceBadChars(dateBD)
			dateBD = replaceSpace(dateBD)
			dateBD = replaceHyphen(dateBD)
				
			nameFU = "Z"+dateFU+"_"+nameFU[1,30]
			nameFD = "Z"+dateFU+"_"+nameFD[1,30]
			nameBU = "Z"+dateFU+"_"+nameBU[1,30]
			nameBD = "Z"+dateFU+"_"+nameBD[1,30]
		endif
		
		// Get name of the DF from the forward up wave
		DFname = StringByKey("DFName",wavenoteFU)
		
		DFname = replaceBadChars(DFname)
		DFname = replaceSpace(DFname)
		DFname = replaceHyphen(DFname)
		
		Make/O/D  $nameFU
		Make/O/D  $nameBU
		Make/O/D  $nameFD
		Make/O/D  $nameBD		

		Duplicate/O dataFU, $nameFU
		Duplicate/O dataBU, $nameBU
		Duplicate/O dataFD, $nameFD
		Duplicate/O dataBD, $nameBD
		
		KillWaves dataFU, dataBU, dataFD, dataBD
	
	endif
	
	// Create a new DF called matrix_info to store the extra flat file information in (neater)
	NewDataFolder matrix_info
	MoveDataFolder axes, matrix_info
	MoveDataFolder channel, matrix_info
	MoveDataFolder creation_info, matrix_info
	MoveDataFolder raw_data, matrix_info
	MoveDataFolder sample_position, matrix_info
	MoveDataFolder expt_info, matrix_info
	MoveDataFolder expt_elements, matrix_info
	if ( DataFolderExists( "Experiment_Element_deploy_count" ) )
		MoveDataFolder Experiment_Element_deploy_count, matrix_info
	endif
	
	// move to root DF
	SetDataFolder root:
	
	// check if DF already exists; if so add "_a", "_b", etc.  
	if ( DataFolderExists(DFname) )
		SetDataFolder root:
		Print "Warning: data with the same data folder name already exists."
		Variable i
		for ( i = 0; i < 99 ; i+=1)
			DFname = DFname+"_"+num2char(97+i)
			if ( DataFolderExists(DFname) !=1 )
				break
			else 
				DFname = DFname[0,strlen(DFname)-3]
			endif	
		endfor
	endif	

	// get this gloable variable to determine whether to load the data into separate or common
	SVAR commonDFcontrol = root:WinGlobals:SRSSTMControl:commonDataFolder
	
	// the code below will load all data into the same DF if commonDataFolder string set to "yes"
	if ( cmpstr(commonDFcontrol,"yes")==0 )
	 
		DFname = "MyData"
	
		if ( DataFolderExists(DFname) )
			// do nothing
		else 
			NewDataFolder $DFname
		endif
	
		SetDataFolder root:FlatFile
		
		String waveNameList = WaveList("*",";","")
		Variable numWaves = itemsInList(waveNameList,";")
		String waveNameStr
		for ( i=0 ; i<numWaves ; i+=1 )
			waveNameStr = StringFromList(i,waveNameList,";")
			MoveWave $waveNameStr, root:MyData:
		endfor
		KillDataFolder root:FlatFile	

		SetDataFolder root:

	else
		// rename the DF specific to this data
		SetDataFolder root:
		RenameDataFolder FlatFile, $DFname
	endif
	
	// return DF name
	return DFname
End



//--------------------------------
// Misc. data load functions
//--------------------------------


//------------------------------------------------------------------------------------------------------------------------------------
// Load output from "schroedsolve"
//------------------------------------------------------------------------------------------------------------------------------------
Function loadWaveFunction( pathStr, filenameStr )
	String pathStr, filenameStr
	
	Print "Wavefunction data"
		
	// -------------------------------------------------------------------------------------------------------------------------------------------//
	// USER DEFINED VARIABLES FOR CONTROLLING THE BEHAVIOUR OF THIS FILE LOADER	
	Variable VERBOSE = 1  // set to 1 to increase the amount of output to the command window: useful for debugging 
	// -------------------------------------------------------------------------------------------------------------------------------------------//
	
	// Save current DF
	String saveDF = GetDataFolder(1)
	
	// Make temporary DF to load data into (will rename later)
	KillDataFolder/Z root:WaveFuction
	NewDataFolder/O/S root:WaveFunction
	
	Variable ie,ix,iy			// used in for loops
	Variable refNum			// used for the file identification
	
	// Combine path and filename into a single string 
	String FullFileNameStr = pathStr+filenameStr
	
	Print " "
	Print "Opening wavefunction file for reading "
	Print "File: ",FullFileNameStr
	Print " "
	// Open data file
	Open/R/Z=1 refNum as FullFileNameStr
	Variable err = V_flag
	if ( err )
		Print "ERROR: unable to open the file for reading. Aborting."
		return 1
	endif
	
	Variable/G nx, ny, nz, norb
	Variable lenrec_start, lenrec_end, dataPoint, xdata_len, ydata_len
	
	// READ HEADER
	if ( VERBOSE )
		PRINT " "
		PRINT "READING HEADER INFORMATION"
	endif
	FBinRead/F=3 refNum, lenrec_start
	FBinRead/F=3 refNum, NX
	FBinRead/F=3 refNum, NY
	FBinRead/F=3 refNum, NZ
	FBinRead/F=3 refNum, NORB
	FBinRead/F=3 refNum, lenrec_end
//	if ( VERBOSE )
//		PRINT "len rec start =", lenrec_start
		PRINT "NX = ", NX
		PRINT "NY = ", NY
		PRINT "NZ = ", NZ
		PRINT "NORB = ", NORB
///		PRINT "len rec stop =", lenrec_end
		PRINT " "
		PRINT "READING EIGENVALUES"
//	endif
	
	// get file name without extension
	String filenameStrNoExt = ParseFilePath(3, filenameStr, ":", 0, 0)
	filenameStrNoExt = removeBadChars(filenameStrNoExt)
	filenameStrNoExt = replaceHyphen(filenameStrNoExt)

	// make wave to store eigenvalues
	Make/O/N=(norb) $(filenameStrNoExt+"_ev")
	Wave eigenval = $(filenameStrNoExt+"_ev")
	
	// make wave to store wavefunction
	xdata_len = 2*nx
	ydata_len = 2*nx
	Make/O/N=(xdata_len,ydata_len,norb) $(filenameStrNoExt+"_wf")
	Make/O/N=(xdata_len,ydata_len,norb) $(filenameStrNoExt+"_pd")
	Wave wavefunction = $(filenameStrNoExt+"_wf")
	Wave probdensity = $(filenameStrNoExt+"_pd")
	
	for ( ie=0; ie < norb; ie +=1 )
		// READ EIGENVALUE
		FBinRead/F=3 refNum, lenrec_start
		FBinRead/F=5 refNum, dataPoint
		FBinRead/F=3 refNum, lenrec_end
		eigenval[ie] = dataPoint
		if ( VERBOSE )
			PRINT "len rec start =", lenrec_start
			PRINT "Eigenvalue",ie,"is", eigenval[ie] 
			PRINT "len rec stop =", lenrec_end
			PRINT " "
			PRINT " LOADING DATA"
		else
			PRINT "Eigenvalue",ie,"is", eigenval[ie] 
		endif	

		for ( iy=0; iy < ydata_len; iy+=1 )
			// Read EVEC(x,y,e) for particular e, and y, for all x
			FBinRead/F=3 refNum, lenrec_start
			for ( ix=0; ix < xdata_len; ix+= 1)
				FBinRead/F=5 refNum, dataPoint
				wavefunction[xdata_len-ix-1][ydata_len-iy-1][ie] = -dataPoint
				probdensity[xdata_len-ix-1][ydata_len-iy-1][ie] = dataPoint*dataPoint
			endfor // ix
			FBinRead/F=3 refNum, lenrec_end
		endfor	// iy	
	endfor // ie

	// Close data file
	Close refNum 
	
	
	
	// Attempt to load dimensions etc.
	
	// If naming convention not changed then the dimensions are contained in this file 
	FullFileNameStr = pathStr+"hosc2d.mesh"
	
	// Open data file
	Open/R/Z=1 refNum as FullFileNameStr
	err = V_flag
	if ( err )
		Print "ERROR: Can't load dimension data"
		return 1
	else
		Print "Loading dimension data"
	endif
	String dummy
	
	// Close data file
	Close refNum 
	
End






// Quick and Dirty Load for Scala Data
function loadScalaImage(path, filename)
	String path, filename
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Make a new datafolder based on the filename
	String DFnameFromFileName= removeBadChars(filename)
	DFnameFromFileName= removeSpace(DFnameFromFileName)
	NewDataFolder/O/S root:$DFnameFromFileName
	
	GBLoadWave/T={16,4}/N=myScalaImage/W=1 path+filename 
	Wave myScalaImage0
	WaveStats myScalaImage0
	Variable datalength = V_npnts
	Print "Loaded SCALA format data"
	Print "Total numer of data points is ", datalength
	datalength = sqrt(datalength)
	Print "Attempting to redimension into ", datalength, " x ", datalength
	Duplicate/O myScalaImage0, img
	redimension/N=(datalength,datalength) img
	//KillWaves myScalaImage0
	
	SetDataFolder saveDF
end


//------------------------------------------------------------------------------------------------------------------------------------
// Load output from accelerometer labview programme
//------------------------------------------------------------------------------------------------------------------------------------
Function loadAccelerometer( pathStr, filenameStr )
	String pathStr, filenameStr
	
	Print "Loading accelerometer data"
	LoadWave/A/J/D/W/O/K=0 pathStr+filenameStr
	
	Variable numWaves = itemsInList(S_waveNames) - 1

	// The first wave is the frequency wave
	String freqStr = stringfromlist(0,S_waveNames)
	Wave freqW = $freqStr
	
	// First point a header (possibly time stamp, but not using this at the moment)
	DeletePoints/M=0 0, 1, freqW
	
	// Find out what the min and max frequency values are
	Variable freqmin = WaveMin(freqW)
	Variable freqmax = WaveMax(freqW)
	
	String ampStr
	if (numWaves == 1)  // i.e., this is an averaged wave
		ampStr = stringfromlist(1,S_waveNames)
		Wave ampW = $ampStr

		// First point a header (possibly time stamp, but not using this at the moment)
		DeletePoints/M=0 0, 1, ampW
	
		// Set the scales and add units
		//SetScale/I x, freqmin, freqmax, "Hz", ampW
		//SetScale/I d, 0,1, "m/s", ampW
	
		// convert to m/s/sqrt(Hz)
		//ampW = ampW * 25.4 * 1e-3
	
		// Display the wave
		display/k=1 ampW
		ModifyGraph log=1
		
	elseif (numWaves > 1) // i.e., the file contains spectra as a function of time
		Variable specLen = DimSize(freqW,0)

		Make/O/N=(numWaves,specLen) img
		Variable i
		for (i = 1; i<numWaves; i+=1)
			ampStr = stringfromlist(i,S_waveNames)
			Wave ampW = $ampStr
			// First point a header (possibly time stamp, but not using this at the moment)
			DeletePoints/M=0 0, 1, ampW
			img[i][] = ampW[q]
			KillWaves ampW
		endfor
		
		// Set the scales and add units
		SetScale/I y, freqmin, freqmax, "Hz", img
		SetScale/I d, 0,1, "m/s", img
	
		// convert to m/s/sqrt(Hz)
		img = img * 25.4 * 1e-3
		
		// display
		imgDisplay("img")
		updateColourRangeByHist("",type="exp")
		
	endif 
	
	// Clean up
	KillWaves freqW
	

End


//------------------------------------------------------------------------------------------------------------------------------------
// Load output from 
//------------------------------------------------------------------------------------------------------------------------------------
Function loadSEMITIPfort( path, filename, fortNum)
	String path, filename
	Variable fortNum
	
	// Save current DF
	String saveDF = GetDataFolder(1)
	
	// write to screen 
	Print "SEMITIP v6 fort."+num2str(fortNum)+" data (STS)"
	
	// get input from user
	String description="X"
	If  ( fortNum!= 99 )
		Prompt description, "Enter very brief description for the wave name ( < 10 characters) "+filename 
		DoPrompt filename, description
	endif
	
	if (V_Flag)
      	return -1                   // User canceled
      	
	else 
	
		// clean up description if necessary to avoid having wave names that igor doesn't like for some functions
		description = replaceSpace(description)
		description = replaceHyphen(description)
		description = removeBadChars(description)
	
		// make new DF
		NewDataFolder/O/S root:SEMITIP_STS
	
		// load data
		LoadWave/G/D/W/A path+filename
	
		Wave wave0, wave1, wave2, wave3
		Variable dataLen
		
		String addendum
		switch ( fortNum )
			case 11:
				addendum = "_p"
				fortNum = 11
				break
			case 95:
				addendum = "_b"
				fortNum = 11
				break
			case 96:
				addendum = "_v"
				fortNum = 11
				break
			case 97:
				addendum = "_c"
				fortNum = 11
				break
		endswitch
		
		switch ( fortNum )
			case 11:
				NewDataFolder/O/S root:SEMITIP_STS:$description
				
				String zWName = "z_"+description+addendum
				Duplicate/O wave0 $zWName
				Wave zW = $zWName
				zW = zW * 1e-9
				SetScale/I d,0,1,"m", zW
				
				String potWName = "V_"+description+addendum
				Duplicate/O wave1 $potWName
				Wave potW = $potWName
				SetScale/I d,0,1,"eV", potW
				
				if ( WaveExists(wave2) )
					Duplicate/O wave2 'potential2'
					SetScale/I d,0,1,"eV",'potential2'
				endif 
		
				// Display the potential versus z-axis
				Display/k=1 potW vs zW
				ModifyGraph log(bottom)=1,tick=2,mirror=1,standoff=0;DelayUpdate
				Label left "Potential (\\U)";DelayUpdate
				Label bottom "Depth (\\U)"
				TextBox/C/N=text0/F=0 description
				DoUpdate
								
				break
			case 14:  // tunnelling current from SEMITIP
			
				NewDataFolder/O/S root:SEMITIP_STS:$description
				String stsWStr = "C"+description
				String stsExtWStr = "C_E_"+description
				String stsLocWStr = "C_L_"+description
				
				String stsAbsWStr = "CA"+description
				String stsExtAbsWStr = "CA_E_"+description
				String stsLocAbsWStr = "CA_L_"+description
				
				dataLen = DimSize(wave1,0)
				
				// interpolate data (this is to fix the data point reversal that occurs in the raw data
				Interpolate2/T=1/N=(dataLen) /Y=$(stsWStr) wave0, wave1
				Wave stsW = $stsWStr
				
				SetScale/I x, WaveMin(wave0), WaveMax(wave0),"V",stsW
				SetScale/I d,0,1,"A", stsW
				
				// extended state contribution to the current
				if ( WaveExists(wave2) )
					// interpolate data (this is to fix the data point reversal that occurs in the raw data
					Interpolate2/T=1/N=(dataLen) /Y=$(stsExtWStr) wave0, wave2
					Wave stsExtW = $stsExtWStr
					SetScale/I x, WaveMin(wave0), WaveMax(wave0),"V", stsExtW
					SetScale/I d,0,1,"A", stsExtW
				endif
				
				// localalised state contribution to the current
				if ( WaveExists(wave3) )
					// interpolate data (this is to fix the data point reversal that occurs in the raw data
					Interpolate2/T=1/N=(dataLen) /Y=$(stsLocWStr) wave0, wave3
					Wave stsLocW = $stsLocWStr
					SetScale/I x, WaveMin(wave0), WaveMax(wave0),"V",stsW
					SetScale/I d,0,1,"A", stsW
				endif
							
				//Display Current
				Display/k=1 stsW
				ModifyGraph tick=2,mirror=1,standoff=0;DelayUpdate
				Label left "Current (\\U)";DelayUpdate
				Label bottom "Bias (\\U)"
				ModifyGraph zero=2
				DoUpdate
				
				// Display extended state contribution to the current
				if ( WaveExists(wave2) )
					AppendToGraph stsExtW
					ModifyGraph lstyle($stsExtWStr)=3,rgb($stsExtWStr)=(0,0,0)
					Legend/C/N=text0/F=0/A=LT
					DoUpdate
				endif
				
				// Display localalised state contribution to the current
				if ( WaveExists(wave3) )
					AppendToGraph stsLocW
					ModifyGraph lstyle($stsLocWStr)=3,rgb($stsLocWStr)=(3,52428,1)
					Legend/C/N=text0/F=0/A=LT
					DoUpdate
				endif
				
				// Make and display absolute value waves
				Duplicate/O stsW, $stsAbsWStr
				Wave stsAbsW = $stsAbsWStr
				stsAbsW = Abs(stsW)
				SetScale/I x, WaveMin(wave0), WaveMax(wave0),"V",stsAbsW
				//Display AbsCurrent
				Display/k=1 stsAbsW
				ModifyGraph tick=2,mirror=1,standoff=0;DelayUpdate
				Label left "Current Magnitude (\\U)";DelayUpdate
				Label bottom "Bias (\\U)"
				ModifyGraph zero=2
				ModifyGraph log(left)=1;DelayUpdate
				SetAxis left 1e-13,1e-07
				DoUpdate
				
				// Display extended state contribution to the current
				if ( WaveExists(wave2) )
					Duplicate/O stsExtW, $stsExtAbsWStr
					Wave stsExtAbsW = $stsExtAbsWStr
					stsExtAbsW = Abs(stsExtW)
					AppendToGraph stsExtAbsW
					ModifyGraph lstyle($stsExtAbsWStr)=3,rgb($stsExtAbsWStr)=(0,0,0)
					Legend/C/N=text0/F=0/A=LT
					DoUpdate
				endif
				
				// Display localalised state contribution to the current
				if ( WaveExists(wave3) )
					Duplicate/O stsLocW, $stsLocAbsWStr
					Wave stsLocAbsW = $stsLocAbsWStr
					stsLocAbsW = Abs(stsLocW)
					AppendToGraph stsLocAbsW
					ModifyGraph lstyle($stsLocAbsWStr)=3,rgb($stsLocAbsWStr)=(3,52428,1)
					Legend/C/N=text0/F=0/A=LT
					DoUpdate
				endif
			
				break
				
			case 15:
				NewDataFolder/O/S root:SEMITIP_STS:$description
				String newWStr = "stsd_"+description
				// interpolate data (this is to fix the data point reversal that occurs in the raw data
				Interpolate2/T=1/N=(dataLen) /Y=$(newWStr) wave0, wave1
				SetScale/I x,0,1,"V",$(newWStr) 
				SetScale/I y,0,1,"A/Vm2",$(newWStr) 
				break
			case 30:
				NewDataFolder/O/S root:SEMITIP_STS:$description
				Duplicate/O wave0 $(description+"_30_V")
				Duplicate/O wave1 $(description+"_30_n")
				Duplicate/O wave2 $(description+"_30_En")
				Duplicate/O wave3 $(description+"_30_delta_e")
				break
			case 40:
				NewDataFolder/O/S root:SEMITIP_STS:$description
				Duplicate/O wave0 $(description+"_40_V")
				Duplicate/O wave1 $(description+"_40_n")
				Duplicate/O wave2 $(description+"_40_En")
				Duplicate/O wave3 $(description+"_40_delta_e")
				break
			case 50:
				NewDataFolder/O/S root:SEMITIP_STS:$description
				Duplicate/O wave0 $(description+"_50_V")
				Duplicate/O wave1 $(description+"_50_n")
				Duplicate/O wave2 $(description+"_50_En")
				Duplicate/O wave3 $(description+"_50_delta_e")
				break
			default:
				newWStr = "data_"+description
				break
		endswitch
			
		// clean up
		SetDataFolder root:SEMITIP_STS
		KillWaves/Z wave0, wave1, wave2, wave3, dummy
		
	endif 
		
	// return to DF
	//SetDataFolder saveDF
End



/------------------------------------------------------------------------------------------------------------------------------------
// Load output from Testo temperature/humidity datalogger
//------------------------------------------------------------------------------------------------------------------------------------
Function loadTestoLogData( path, filename )
	String path, filename
	Variable refNum
	
	String FullFileNameStr = path+filename

	DFREF saveDFR = GetDataFolderDFR()
	
	Open /R/Z=2 refNum as FullFileNameStr
	
	if (V_flag != 0)
		Print "error loading Testo data"
		return 0 // Something broke
	endif
	
	// Information to command line
	Print "Detected .testo file input. Assuming from Testo 174H datalogger. Opening into new data folder."
	
	// Remove extension from filename
	String shortfilename = ParseFilePath(3, filename, ":", 0, 0)
	
	NewDataFolder /O/S root:testo
	
	// Load data
	Variable err = V_flag
	if ( err )
		Print "ERROR: unable to open the flat file for reading. Aborting."
		return 1
	endif
	
	// -----------------------------------------
	// SECTION 1: FILE IDENTIFICATION
	// -----------------------------------------
	
	Print " "
	Print "Warning: time accurate to day only - start day time and end day time have not been set"
	
	// Read header
	String buffer = ""
	FReadLine refNum, buffer
	Variable len
	Variable linecount=0
	do
		FReadLine refNum, buffer
		len = strlen(buffer)
		if (len == 0)
			break						// No more lines to be read
		endif
		linecount+=1
	while (1)
	Close refNum	
	
	Variable id, t_tmp, h_tmp
	String date_tmp, time_tmp

	Make/T/O/N=(linecount) dateW
	Make/T/O/N=(linecount)  timeW
	Make/O/N=(linecount)  temperature
	Make/O/N=(linecount)  humidity
	
	Open /R/Z=2 refNum as FullFileNameStr
	Variable i=0
	FReadLine refNum, buffer
	do
		FReadLine refNum, buffer
		len = strlen(buffer)
		if (len == 0)
			break						// No more lines to be read
		endif
		
		sscanf buffer, "%i %s %s %e %e", id, date_tmp, time_tmp, t_tmp, h_tmp
		
		dateW[i]=date_tmp
		timeW[i]=time_tmp
		temperature[i] = t_tmp
		humidity[i] = h_tmp
		i+=1
		
	while (1)
	Close refNum
	
	Variable startday = str2num(StringFromList(0,dateW[0],"/"))
	Variable startmonth = str2num(StringFromList(1,dateW[0],"/"))
	Variable startyear = str2num(StringFromList(2,dateW[0],"/"))
	
	Variable endday = str2num(StringFromList(0,dateW[linecount-1],"/"))
	Variable endmonth = str2num(StringFromList(1,dateW[linecount-1],"/"))
	Variable endyear = str2num(StringFromList(2,dateW[linecount-1],"/"))
	
	Variable startdate = date2secs(startyear,startmonth,startday)
	Variable enddate = date2secs(endyear,endmonth,endday)
	
	Variable starthour = str2num(StringFromList(0,timeW[0],":"))
	Variable startminute = str2num(StringFromList(1,timeW[0],":"))
	Variable endhour = str2num(StringFromList(0,timeW[linecount-1],":"))
	Variable endminute = str2num(StringFromList(1,timeW[linecount-1],":"))

	SetScale/I x, startdate+60*60*starthour+60*startminute, enddate+60*60*endhour+60*endminute, "dat", temperature
	SetScale/I x, startdate+60*60*starthour+60*startminute, enddate+60*60*endhour+60*endminute, "dat", humidity

	Display/k=1 temperature; AppendToGraph/R humidity
	ModifyGraph rgb(humidity)=(1,16019,65535)
	ModifyGraph tick(left)=2,tick(bottom)=2,mirror(bottom)=1,standoff(left)=0;DelayUpdate
	ModifyGraph standoff(bottom)=0;DelayUpdate
	SetAxis/A bottom 
	SetAxis left 20,26
	ModifyGraph lsize=1.5
	SetAxis right 10,90
	Legend/C/N=text0/F=0/A=LT
	ModifyGraph dateInfo(bottom)={0,1,2}
	Label left "Temperature";DelayUpdate
	Label bottom "Date/time";DelayUpdate
	Label right "Humidity"

	DoUpdate
End



//------------------------------------------------------------------------------------------------------------------------------------
// Load VASP PARCHG
//------------------------------------------------------------------------------------------------------------------------------------
Function loadPARCHG(pathStr,filenameStr)
	String pathStr, filenameStr
	Variable/G lineCount=0
	
	String fileNameForWaves = ParseFilePath(3, filenameStr, ":", 0, 0)
	fileNameForWaves = removeBadChars(fileNameForWaves)
	fileNameForWaves = removeSpace(fileNameForWaves)
	
	// Save current DF
	String saveDF = GetDataFolder(1)
	
	// Make  DF to load data into 
	NewDataFolder/O/S root:PARCHG
	
	Variable i			// used in for loops
	Variable refNum		// used for the file identification
	String buffer
	
	// Combine path and filename into a single string 
	String/G FullFileNameStr = pathStr+filenameStr
	
	// Open data file
	Open/R/Z=1 refNum as FullFileNameStr
	Variable err = V_flag
	if ( err )
		Print "ERROR: unable to open the PARCHG file for reading. Aborting."
		return 1
	endif
	
	// Output that we're beginning the file load 
	Print " "
	Print "Loading PARCHG file" 
	
	// -----------------------------------------
	// SECTION 1: HEADER
	// -----------------------------------------
	
	String/G headerStr

	// read the header line and write to screen	
	FReadLine refnum, headerStr
	FReadLine refnum, buffer
	Variable/G header_unknown = str2num(buffer)
	lineCount = lineCount + 2
	
	// -----------------------------------------
	// SECTION 2: unit cell
	// -----------------------------------------
	Variable d1, d2, d3, d4, d5, d6, d7, d8, d9, d10
	Make/O/N=(3,3) unitcell
	for ( i=0; i<3; i+=1)
		FReadLine refnum, buffer
		sscanf buffer, "%f %f %f", d1, d2, d3
		unitcell[i][0]=d1
		unitcell[i][1]=d2
		unitcell[i][2]=d3
	endfor
	lineCount = lineCount+i
	
	// -----------------------------------------
	// SECTION 3: element types
	// -----------------------------------------
	FReadLine refnum, buffer
	lineCount = lineCount+1
	String ds1, ds2, ds3, ds4, ds5, ds6, ds7, ds8, ds9
	sscanf buffer, "%s %s %s %s %s %s %s %s %s", ds1, ds2, ds3, ds4, ds5, ds6, ds7, ds8, ds9
	Make/T/O/N=9 dummyStrWave
	dummyStrWave[0]=ds1
	dummyStrWave[1]=ds2
	dummyStrWave[2]=ds3
	dummyStrWave[3]=ds4
	dummyStrWave[4]=ds5
	dummyStrWave[5]=ds6
	dummyStrWave[6]=ds7
	dummyStrWave[7]=ds8
	dummyStrWave[8]=ds9
	for ( i=0; i<9; i+=1 )
		if (strlen(dummyStrWave[i])==0)
			break
		endif
	endfor
	if (strlen(dummyStrWave[8])!=0 )
		Print "WARNING: this loader can handle a maximum of 9 element types; if you have more you need to edit this loader"
	endif 
	Variable/G numElem = i
	Make/T/O/N=(numElem) elements
	elements[]=dummyStrWave[p]
	KillWaves/Z dummyStrWave
	
	// -----------------------------------------
	// SECTION 4: number of atoms
	// -----------------------------------------
	FReadLine refnum, buffer
	lineCount = lineCount+1
	sscanf buffer, "%s %s %s %s %s %s %s %s %s", ds1, ds2, ds3, ds4, ds5, ds6, ds7, ds8, ds9
	d1 = str2num (ds1)
	Make/O/N=(9) dummyWave
	Wave dummyWave
	dummyWave[0]=str2num(ds1)
	dummyWave[1]=str2num(ds2)
	dummyWave[2]=str2num(ds3)
	dummyWave[3]=str2num(ds4)
	dummyWave[4]=str2num(ds5)
	dummyWave[5]=str2num(ds6)
	dummyWave[6]=str2num(ds7)
	dummyWave[7]=str2num(ds8)
	dummyWave[8]=str2num(ds9)
	Make/O/N=(numElem) atomNumbers
	atomNumbers=dummyWave[p]
	KillWaves/Z dummyWave
	Variable/G totalAtoms = Sum(atomNumbers)
	
	FReadLine refnum, buffer
	String/G unitcell_type = buffer
	lineCount = lineCount+1
	String/G unitCellType = buffer
	
	// -----------------------------------------
	// SECTION 5: read atoms.
	// -----------------------------------------
	
	Make/O/N=(totalAtoms,3) xyz
	for ( i=0; i<totalAtoms; i+=1 )
		FReadLine refnum, buffer
		sscanf buffer, "%f %f %f", d1, d2, d3
		xyz[i][0]=d1
		xyz[i][1]=d2
		xyz[i][2]=d3
	endfor
	lineCount = lineCount+i
	
	// -----------------------------------------
	// SECTION 5: read PARCHG
	// -----------------------------------------
	
	//Blank line
	FReadLine refnum, buffer
	
	// PARCHG dimensions
	FReadLine refnum, buffer
	sscanf buffer, "%f %f %f", d1, d2, d3
	Make/O/N=3 dimPARCHG
	dimPARCHG[0] = d1
	dimPARCHG[1] = d2
	dimPARCHG[2] = d3
	Variable numData = dimPARCHG[0] * dimPARCHG[1] * dimPARCHG[2]
	lineCount = lineCount+2
	
	//
	FReadLine refnum, buffer
	FReadLine refnum, buffer
	FReadLine refnum, buffer	 
	
	Variable column_skip=0
	for (i=0; i<strlen(buffer); i+=1)
		if ( cmpstr(buffer[i]," ")!=0 )
			break
		endif
		column_skip += 1
	endfor
	Print column_skip
	Close refnum
	
	// USE IGOR Procedure to load PARCHG data
	//LoadWave/J/Q/D/N=wave/O/K=1/V={"\t, "," $",0,0}/L={0,lineCount,0,1,0} FullFileNameStr
	LoadWave/J/D/K=0/A=wave/V={"\t, "," $",0,0}/L={0,lineCount,0,column_skip,0} FullFileNameStr
	Wave wave0, wave1, wave2, wave3, wave4, wave5, wave6, wave7, wave8, wave9
	Variable/G dataLen = DimSize(wave0,0)
	Make/O/N=(dataLen,10) PARCHG_3D
	PARCHG_3D[][0] = wave0[p]
	PARCHG_3D[][1] = wave1[p]
	PARCHG_3D[][2] = wave2[p]
	PARCHG_3D[][3] = wave3[p]
	PARCHG_3D[][4] = wave4[p]
	PARCHG_3D[][5] = wave5[p]
	PARCHG_3D[][6] = wave6[p]
	PARCHG_3D[][7] = wave7[p]
	PARCHG_3D[][8] = wave8[p]
	PARCHG_3D[][9] = wave9[p]
	KillWaves/Z wave0, wave1, wave2, wave3, wave4, wave5, wave6, wave7, wave8, wave9
	Duplicate/O PARCHG_3D, PARCHG
	MatrixTranspose PARCHG_3D
	Redimension/N=(numData) PARCHG_3D
	Redimension/N=(dimPARCHG[0], dimPARCHG[1], dimPARCHG[2]) PARCHG_3D
	// end
	
	KillDataFolder/Z root:$fileNameForWaves
	DuplicateDataFolder root:PARCHG, root:$fileNameForWaves
	KillDataFolder/Z root:PARCHG
	
	Print "done"
End


//------------------------------------------------------------------------------------------------------------------------------------
// Save VASP PARCHG
// fullFileNameStr is used to get the path.  This string is created with PARCHG is loaded.
// filename will be the new file name (plus ext .PARCHG)
// it is the file PARCHG that is written (2D not 3D)
//------------------------------------------------------------------------------------------------------------------------------------
Function savePARCHG(fullFileNameStr,[filename])
	String fullFileNameStr, filename
	fullFileNameStr = fullFileNameStr
	
	String path = ParseFilePath(1, fullfilenameStr, ":", 1, 0)
	String outputFileName 
	
	if ( ParamIsDefault(filename) )
		outputFileName = path+"Igor.PARCHG"
	else
		outputFileName = path+filename+".PARCHG"
	endif
	
	// Save current DF
	String saveDF = GetDataFolder(1)
	
	Variable i			// used in for loops
	Variable refNum		// used for the file identification
	
	// Open data file
	Open/Z=1 refNum as outputFileName
	Variable err = V_flag
	if ( err )
		Print "ERROR: unable to open the PARCHG file for writing. Aborting."
		return 1
	endif
	
	// Output that we're beginning the file load 
	Print " "
	Print "Saving PARCHG file" 
	
	String tab_space = "    "
	// -----------------------------------------
	// SECTION 1: HEADER
	// -----------------------------------------
	
	
	String/G headerStr
	Variable/G header_unknown
	
	fprintf refnum, "%s\n", headerStr
	fprintf refnum, "%s%f\n", tab_space, header_unknown
	
	Wave unitcell
	
	fprintf refnum, "%s%f %f %f\n", tab_space, unitcell[0][0], unitcell[0][1], unitcell[0][2]
	fprintf refnum, "%s%f %f %f\n", tab_space, unitcell[1][0], unitcell[1][1], unitcell[1][2]
	fprintf refnum, "%s%f %f %f\n", tab_space, unitcell[2][0], unitcell[2][1], unitcell[2][2]
	
	Wave/T elements
	Variable/G numElem
	
	fprintf refnum, "%s", tab_space
	for ( i=0; i< numElem; i+=1 )
		fprintf refnum, "%s ", elements[i]
	endfor
	fprintf refnum, "\n"
	
	fprintf refnum, "%s", tab_space
	Wave atomNumbers
	for ( i=0; i< numElem; i+=1 )
		fprintf refnum, "%d ", atomNumbers[i]
	endfor
	fprintf refnum, "\n"
	
	String/G unitcell_type
	fprintf refnum, "%s\n", unitcell_type
	
	Wave xyz
	Variable/G totalAtoms
	for ( i=0; i<totalAtoms; i+=1 )
		fprintf refnum, "  %f  %f %f\n", xyz[i][0], xyz[i][1], xyz[i][2]
	endfor
	
	fprintf refnum, "\n"
	
	Wave dimPARCHG
	fprintf refnum, "   %d %d %d\n", dimPARCHG[0], dimPARCHG[1], dimPARCHG[2]
	Close refnum
	
	Wave PARCHG
	Save/A=2/G/F/M="\n" PARCHG as outputFileName

End


//------------------------------------------------------------------------------------------------------------------------------------
// Load DX
//------------------------------------------------------------------------------------------------------------------------------------
Function loaddx(pathStr,filenameStr)
	String pathStr, filenameStr
	Variable/G lineCount=0
	
	String fileNameForWaves = ParseFilePath(3, filenameStr, ":", 0, 0)
	fileNameForWaves = removeBadChars(fileNameForWaves)
	fileNameForWaves = removeSpace(fileNameForWaves)
	
	// Save current DF
	String saveDF = GetDataFolder(1)
	
	// Make  DF to load data into 
	NewDataFolder/O/S root:DX
	
	Variable i			// used in for loops
	Variable refNum		// used for the file identification
	String buffer
	
	// Combine path and filename into a single string 
	String/G FullFileNameStr = pathStr+filenameStr
	
	// Open data file
	Open/R/Z=1 refNum as FullFileNameStr
	Variable err = V_flag
	if ( err )
		Print "ERROR: unable to open the DX file for reading. Aborting."
		return 1
	endif
	
	// Output that we're beginning the file load 
	Print " "
	Print "Loading OpenDX format charge density file" 
	
	// -----------------------------------------
	// SECTION 1: HEADER
	// -----------------------------------------
	
	String/G headerStr

	// read the header line 
	FReadLine refnum, headerStr
	lineCount += 1

	Variable d1, d2, d3, d4, d5, d6, d7, d8, d9, d10
	String  dum1, dum2, dum3, dum4, dum5, dum6, dum7, dum8, dum9
	Make/N=3 grid
	Make/O /N=3 origin
	Make/O /N=3 a1
	Make/O /N=3 a2
	Make/O /N=3 a3
	
	// 
	FReadLine refnum, buffer
	lineCount += 1
	sscanf buffer, "%s %i %s %s %s %i %i %i", dum1, d1, dum2, dum3, dum4, d2, d3, d4
	grid[0] = d2
	grid[1] = d3
	grid[2] = d4
	
	// 
	FReadLine refnum, buffer
	lineCount += 1
	sscanf buffer, "%s %s %s %s", dum1, dum2, dum3, dum4
	origin[0] = str2num(dum2)
	origin[1] = str2num(dum3)
	origin[2] = str2num(dum4)
	
	// 
	FReadLine refnum, buffer
	lineCount += 1
	sscanf buffer, "%s %s %s %s", dum1, dum2, dum3, dum4
	a1[0] = str2num(dum2)
	a1[1] = str2num(dum3)
	a1[2] = str2num(dum4)
	
	// 
	FReadLine refnum, buffer
	lineCount += 1
	sscanf buffer, "%s %s %s %s", dum1, dum2, dum3, dum4
	a2[0] = str2num(dum2)
	a2[1] = str2num(dum3)
	a2[2] = str2num(dum4)
	
	// 
	FReadLine refnum, buffer
	sscanf buffer, "%s %s %s %s", dum1, dum2, dum3, dum4
	a3[0] = str2num(dum2)
	a3[1] = str2num(dum3)
	a3[2] = str2num(dum4)
	
	// 
	FReadLine refnum, buffer
	lineCount += 1
	
	// 
	FReadLine refnum, buffer
	lineCount += 1
	
	// 
	FReadLine refnum, buffer
	lineCount += 1
	
	//
	Variable/G dataLen 
	FReadLine refnum, buffer
	lineCount += 1
	sscanf buffer, "%s %s %s %s %s %s %s %s %s %f", dum1, dum2, dum3, dum4, dum5, dum6, dum7, dum8, dum9, datalen
	Variable DXLen = dataLen/5

//	FReadLine refnum, buffer
///	lineCount += 1

//      Variable column_skip=0
//	for (i=0; i<strlen(buffer); i+=1)
//		if ( cmpstr(buffer[i]," ")!=0 )
//			break
//		endif
//		column_skip += 1
//	endfor

	Make/O/N=(dataLen) DX
	for ( i=0; i<DXLen; i+=1 )
		FReadLine refnum, buffer
		lineCount += 1
		sscanf buffer, "%f %f %f %f %f", d1, d2, d3, d4, d5
		DX[5*i] = d1
		DX[5*i+1] = d2
		DX[5*i+2] = d3
		DX[5*i+3] = d4
		DX[5*i+4] = d5
//		DX[i][0] = d1
//		DX[i][1] = d2
//		DX[i][2] = d3
//		DX[i][3] = d4
//		DX[i][4] = d5
	endfor
	
//	Duplicate/O DX, PARCHG 
//	MatrixTranspose PARCHG 
//	Redimension/N=(dataLen) PARCHG
	
//	Variable PARCHGLen = dataLen/10
//	Redimension/N=(10, PARCHGLen) PARCHG
//	MatrixTranspose PARCHG 
	// Close file
	close refnum
	
	Print "Creating PARCHG wave"
	
	Variable PARCHGLen = dataLen/10
	Make/O/N=(PARCHGLen,10) PARCHG
	for ( i=0; i<PARCHGLen; i+=1 )
		PARCHG[i][0] = DX[i*10]
		PARCHG[i][1] = DX[i*10+1]
		PARCHG[i][2] = DX[i*10+2]
		PARCHG[i][3] = DX[i*10+3]
		PARCHG[i][4] = DX[i*10+4]
		PARCHG[i][5] = DX[i*10+5]
		PARCHG[i][6] = DX[i*10+6]
		PARCHG[i][7] = DX[i*10+7]
		PARCHG[i][8] = DX[i*10+8]
		PARCHG[i][9] = DX[i*10+9]	
	endfor


// USE IGOR Procedure to load PARCHG data
//	LoadWave/J/D/K=0/A=wave/V={"\t, "," $",0,0}/L={0,lineCount,0,column_skip,0} FullFileNameStr
	//Wave wave0, wave1, wave2, wave3, wave4
	//dataLen = DimSize(wave0,0)
//Print dataLen
//	Make/O/N=(dataLen,5) PARCHG
//	PARCHG[][0] = wave0[p]
//	PARCHG[][1] = wave1[p]
//	PARCHG[][2] = wave2[p]
//	PARCHG[][3] = wave3[p]
//	PARCHG[][4] = wave4[p]
	//KillWaves/Z wave0, wave1, wave2, wave3, wave4, wave5, wave6, wave7, wave8, wave9
	//Duplicate/O PARCHG_3D, PARCHG
	//MatrixTranspose PARCHG_3D
	//Redimension/N=(3) PARCHG_3D
	//Redimension/N=(dimPARCHG[0], dimPARCHG[1], dimPARCHG[2]) PARCHG_3D
	// end

	KillVariables lineCount
	
// HACK
	Make/O/T/N=3 elements
	elements[0] = "B"
	elements[1] = "Si"
	elements[2] = "H"
	Variable/G numElem = 3
	Make/O/N=3 atomNumbers
	atomNumbers[0] = 24   
	atomNumbers[1] = 601    
	atomNumbers[2] = 75
	String/G unitcell_type = "Direct"
	Variable/G totalAtoms = Sum(atomNumbers)
	Make/O/N=(totalAtoms,3) xyz
	xyz = 0.0 
	Make/N=3 dimPARCHG
	dimPARCHG[0] = grid[1]
	dimPARCHG[1] = grid[2]
	dimPARCHG[2] = grid[0]
		
	// Create variables for PARCHG write
	String/G headerStr = "PARCHG file generated from DX file"
	Variable/G header_unknown = 1
	Make/O/N=(3,3) unitcell
	unitcell[][0] = a3[p] * 300
	unitcell[][1] = a2[p] * 300
	unitcell[][2] = a1[p] * 240
	MatrixTranspose unitcell	
	
	PARCHG = 1000000 * PARCHG
	
	// Writing PARCHG file
	Print "Writing PARCHG file ", fileNameForWaves
	savePARCHG(fullFileNameStr,filename=fileNameForWaves)
	
	KillDataFolder/Z root:$fileNameForWaves
	DuplicateDataFolder root:DX, root:$fileNameForWaves
	KillDataFolder/Z root:DX
	SetDataFolder root:$fileNameForWaves
End


//------------------------------------------------------------------------------------------------------------------------------------
// Load XPS txt output from CASAXPS
//------------------------------------------------------------------------------------------------------------------------------------
Function loadxps(pathStr,filenameStr)
	String pathStr, filenameStr
	
	String fileNameForWaves = ParseFilePath(3, filenameStr, ":", 0, 0)
	fileNameForWaves = removeBadChars(fileNameForWaves)
	fileNameForWaves = removeSpace(fileNameForWaves)
	
	// Save current DF
	String saveDF = GetDataFolder(1)
	
	// Make  DF to load data into 
	NewDataFolder/O/S root:XPS
	
	Variable i,j			// used in for loops
	Variable refNum		// used for the file identification
	
	// Combine path and filename into a single string 
	String/G FullFileNameStr = pathStr+filenameStr
	String buffer
	String firstWord
	
	// Output that we're beginning the file load 
	Print " "
	Print "Loading XPS txt format output from CASAXPS" 

	// ----
	// Find out how many spectra there are
	// ----
	
	// Open data file
	Open/R/Z=1 refNum as FullFileNameStr
	Variable err = V_flag
	if ( err )
		Print "ERROR: unable to open the CASA file for reading. Aborting."
		return 1
	endif

	Variable/G numSpectra = 0
	for (j=0; j<10000; j+=1)
		// read the header line 
		FReadLine refnum, buffer
		sscanf buffer, "%s", firstWord
		if ( cmpstr(firstWord,"Cycle")==0 )
			numSpectra +=1
		endif
	endfor
	Close refNum
	Print "Number of spectra = ", numSpectra
	
	// ----
	// Find out how many peaks
	// ----
	
	// Open data file
	Open/R/Z=1 refNum as FullFileNameStr
	err = V_flag
	if ( err )
		Print "ERROR: unable to open the CASA file for reading. Aborting."
		return 1
	endif
	
	for (j=0; j<100000; j+=1)
		// read the header line 
		FReadLine refnum, buffer
		sscanf buffer, "%s", firstWord
		if ( cmpstr(firstWord,"Position")==0 )
			break
		endif
	endfor
	
	Variable bufferLen = strlen(buffer)
	String nextStr
	
	// Remove the first word
	sscanf buffer, "%s", nextStr
	buffer = buffer[strlen(nextStr)+1,bufferLen]
	
	Variable numPeaks = 0 
	for (i=0;i<100;i+=1)
		sscanf buffer, "%s", nextStr
		if ( strlen(nextStr)==0 )
			break
		endif
		buffer = buffer[strlen(nextStr)+1,bufferLen]
	endfor
	numPeaks=i
	Print "Number of peaks = ", numPeaks
	
	Close refNum

	// ----
	// Now load the data
	// ----
	
	Make/O/N=(numPeaks,numSpectra) peakEnergies
	Make/O/N=(numPeaks,numSpectra) peakFWHM
	Make/O/N=(numPeaks,numSpectra) peakAreas
	
	// Open data file
	Open/R/Z=1 refNum as FullFileNameStr
	err = V_flag
	if ( err )
		Print "ERROR: unable to open the CASA file for reading. Aborting."
		return 1
	endif
	
	Variable specNum = -1
	for (j=0; j<100000; j+=1)
		// read the header line 
		FReadLine refnum, buffer
		sscanf buffer, "%s", firstWord
		if ( cmpstr(firstWord,"Cycle")==0 )  
			specNum += 1
		endif
		if ( cmpstr(firstWord,"Position")==0 )  // load position data (i.e. energies)
			buffer = buffer[strlen(firstWord)+1,bufferLen]
			for (i=0; i<numPeaks; i+=1)
				sscanf buffer, "%s", firstWord
				buffer = buffer[strlen(firstWord)+1,bufferLen]
				peakEnergies[i][specNum] = str2num(firstWord)
			endfor
		endif
		if ( cmpstr(firstWord,"FWHM")==0 )  // load position data (i.e. energies)
			buffer = buffer[strlen(firstWord)+1,bufferLen]
			for (i=0; i<numPeaks; i+=1)
				sscanf buffer, "%s", firstWord
				buffer = buffer[strlen(firstWord)+1,bufferLen]
				peakFWHM[i][specNum] = str2num(firstWord)
			endfor
		endif
		if ( cmpstr(firstWord,"Area")==0 )  // load position data (i.e. energies)
			buffer = buffer[strlen(firstWord)+1,bufferLen]
			for (i=0; i<numPeaks; i+=1)
				sscanf buffer, "%s", firstWord
				buffer = buffer[strlen(firstWord)+1,bufferLen]
				peakAreas[i][specNum] = str2num(firstWord)
			endfor
		endif
	endfor
	
	// make separate waves for Areas
	make/N=(numSpectra) SumWave
	SumWave = 0
	String wavenameStr
	for (i=0; i<numPeaks; i+=1)
		//wavenameStr = "areaWave_"+num2str(i)
		wavenameStr = "areaWave_"+num2str(peakEnergies[i][0])
		make/N=(numSpectra) $wavenameStr
		Wave currentwave = $wavenameStr
		currentwave[] = peakAreas[i][p]
		SumWave = SumWave + currentwave
	endfor
	
	
	
	Close refNum

		
	KillDataFolder/Z root:$fileNameForWaves
	DuplicateDataFolder root:XPS, root:$fileNameForWaves
	KillDataFolder/Z root:XPS
	SetDataFolder root:$fileNameForWaves
End



//------------------------------------------------------------------------------------------------------------------------------------
// Load Web Of Science output process as LATEX input
//------------------------------------------------------------------------------------------------------------------------------------
Function loadWOS(pathStr,filenameStr)
	String pathStr, filenameStr
	
	String fileNameForWaves = ParseFilePath(3, filenameStr, ":", 0, 0)
	fileNameForWaves = removeBadChars(fileNameForWaves)
	fileNameForWaves = removeSpace(fileNameForWaves)
	
	// Save current DF
	String saveDF = GetDataFolder(1)
	
	// Make  DF to load data into 
	NewDataFolder/O/S root:WOS
	
	Variable i,j			// used in for loops
	Variable refNum		// used for the file identification
	
	// Combine path and filename into a single string 
	String/G FullFileNameStr = pathStr+filenameStr
	String buffer
	String dummyStr
	
	// Output that we're beginning the file load 
	Print " "
	Print "Loading Web of Science Data"

	// ----
	// Find out how many spectra there are
	// ----
	
	// Open data file
	Open/R/Z=1 refNum as FullFileNameStr
	Variable err = V_flag
	if ( err )
		Print "ERROR: unable to open the WOS file for reading. Aborting."
		return 1
	endif
	
	String identifier
	// Count how many Journal Articles
	Variable articleNum = 0
	for (i=0; i<100000; i+=1)
		FReadLine refnum, buffer
		sscanf buffer, "%s %s", identifier, dummyStr
		if ( cmpstr(identifier,"PT")==0 )
			if ( cmpstr(dummyStr,"J")==0 )
				articleNum += 1
			endif
		endif	
	endfor
	Variable NumberOfArticles = articleNum
	Print "Found",NumberOfArticles,"journal article references"

	//Back to start of file
	FSetPos refNum, 0
	
	// Wave for titles
	Make/T/O/N=(articleNum) J_Title
	Make/T/O/N=(articleNum) J_Authors
	Make/T/O/N=(articleNum) J_Name
	
	// Get titles
	articleNum=-1
	Variable getJournalTitle=1
	Variable getJournalAuthors=1
	Variable getJournalName=1
	Variable bufferlen
	Variable numOfAuthors
	String nextName, nextTitle
	String tempAuthorName,tempAuthorList
	for (i=0; i<100000; i+=1)
		FReadLine refnum, buffer
		sscanf buffer, "%s %s", identifier, dummyStr
		// Article Type
		if ( cmpstr(identifier,"PT")==0 )
			if ( cmpstr(dummyStr,"J")==0 )
				articleNum += 1
				getJournalTitle = 0
				getJournalAuthors = 0
				getJournalName = 0
			else
Print dummyStr
			endif
		endif
		// Article Authors
		if ( cmpstr(identifier,"AU")==0 )
			if ( getJournalAuthors==0 )
				getJournalAuthors = 1
				bufferlen = strlen(buffer)
				J_Authors[articleNum] = formatAuthor(buffer[3,bufferlen])
				for ( j=0; j<100; j+=1 )
					FReadLine refnum, buffer
					if ( cmpstr(buffer[0,2], "   ")==0 )
						bufferlen = strlen(buffer)
						nextName = formatAuthor(buffer[3,bufferlen])
					else 
						Break;
					endif 
					J_Authors[articleNum] = J_Authors[articleNum]+", "+nextName
				endfor
				J_Authors[articleNum] = removeEscapeChars(J_Authors[articleNum])
				// reformat author names
//				numOfAuthors = itemsInList(J_Authors[articleNum],";")
//				for ( j=0; j<numOfAuthors; j+=1 )
//					tempAuthorName = StringFromList(j,J_Authors[articleNum])
//					tempAuthorName = formatAuthor(tempAuthorName)
//					tempAuthorList = tempAuthorList+";"+tempAuthorName			
//				endfor
//				J_Authors[articleNum] = tempAuthorList
				// Need to scane for these two strings to continue on with next entry below
				sscanf buffer, "%s %s", identifier, dummyStr
			endif
		endif
		// Article Title
		if ( cmpstr(identifier,"TI")==0 )
			if ( getJournalTitle==0 )
				getJournalTitle = 1
				bufferlen = strlen(buffer)
				J_Title[articleNum] = buffer[3,bufferlen]
				for ( j=0; j<100; j+=1 )
					FReadLine refnum, buffer
					if ( cmpstr(buffer[0,2], "   ")==0 )
						bufferlen = strlen(buffer)
						nextTitle = buffer[3,bufferlen]
					else 
						Break;
					endif 
					J_Title[articleNum] = J_Title[articleNum]+" "+nextTitle
				endfor
				J_Title[articleNum] = removeEscapeChars(J_Title[articleNum])
				J_Title[articleNum] = CheckCaps(J_Title[articleNum],2)
				J_Title[articleNum] = SpecialTitleChars(J_Title[articleNum])
				J_Title[articleNum] = SpecialTitleCharsSRS(J_Title[articleNum])
				sscanf buffer, "%s %s", identifier, dummyStr
			endif
		endif
		// Article Journal Name
		if ( cmpstr(identifier,"SO")==0 )
			if ( getJournalName==0 )
				getJournalName = 1
				bufferlen = strlen(buffer)
				J_Name[articleNum] = buffer[3,bufferlen]
				J_Name[articleNum] = removeEscapeChars(J_Name[articleNum])
				J_Name[articleNum] = CheckCaps(J_Name[articleNum],3)
			endif
		endif
		
	endfor
	
	// Close
	Close refNum
	
	// Write LATEX file
	String OutFile_tex = pathStr+filenameStr+".tex"
	String OutFile_txt = pathStr+filenameStr+".txt"
	Variable refTEXNum, refTXTNum
	Open/Z=1 refTEXNum as OutFile_tex
	Open/Z=1 refTXTNum as OutFile_txt
	
	String refStr
	String latexTitle, latexAuthors, latexName
	for (i=0; i<NumberOfArticles; i+=1)
		// Write TXT
		refStr = "["+num2str(i+1)+"] "+J_Authors[i]+", "+J_Title[i]+", "+J_Name[i] 
		fprintf refTXTNum, "%s", refStr+"\n"
		// Write LaTeX
		latexTitle = EscapeLaTeXChars(J_Title[i])
		latexAuthors = EscapeLaTeXChars(J_Authors[i])
		latexName = EscapeLaTeXChars(J_Name[i])
		fprintf refTEXNum, "%s", "\\title{"+latexTitle+"}\n"
		fprintf refTEXNum, "%s", "\authors{"+latexAuthors+"}\n"
		fprintf refTEXNum, "%s", "\\reference{"+latexName+"}\n"
		fprintf refTEXNum, "%s", "\allowpagebreak\n"
		fprintf refTEXNum, "%s", "\pubentry\n"
		fprintf refTEXNum, "%s", "\n"
	endfor
	
	Close refTEXNum
	Close refTXTNum
	Print "Finished"
	
	
	KillDataFolder/Z root:$fileNameForWaves
	DuplicateDataFolder root:WOS, root:$fileNameForWaves
	KillDataFolder/Z root:WOS
	SetDataFolder root:$fileNameForWaves
End