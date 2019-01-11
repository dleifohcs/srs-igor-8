//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-Com-linetrace-funcs.ipf
//
// Collection of functions for working with 1D waves
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
#pragma rtGlobals=1		// Use modern global access method.


//------------------------------------------------------------------------------------------------------------------------------------
// Below is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------
//
//-------------------------------------------
// Functions for displaying line traces
//-------------------------------------------
// Function display1DWaves(mode)		
// Function display1D(wStr,[graphName,appendWave])
// Function removeAnnotations([graphName])
// Function getYvaluesFromGraph(graphName)
//
//-------------------------------------------
// Cursor functions
//-------------------------------------------
// Function GlobalsForGraph(graphName)
// Function CursorDependencyForSpecsGraph(graphName)
//
//-------------------------------------------
// Functions for interacting with user
//-------------------------------------------
// Function/S chooseWindow()
// Function/S chooseWindowDialogue(wList,wNum)
// Function/S chooseWindowPair()
// Function/S chooseWindowPairDialogue(windowList)
//
//----------------------------------------------------------------------------
// Functions for combining traces from different graph windows
//----------------------------------------------------------------------------
// Function collateTracesFromTwoGraphs()
// Function collateTracesFromMultipleGraphs()
// Function copyWavesToNewDF([newDFName])
// Function copyGraphDatatoDF(graphName,newDF)
// Function/S chooseMultipleWindows()
// Function/S chooseMultipleWindowDialogue(windowList)
// Function displayCollatedTraces(windowList)
// Function divideGraphs()
// Function duplicateLinePlotNewWaves()
// Function/S createDataDF(baseName)
//
//----------------------------------------------------------------------------
// Functions for performing general wave manipulations
//----------------------------------------------------------------------------
// Function MakeTracesDifferentColours(paletteName)
// Function SmoothTracesInGraph(graphName,[type])
//
//
// Function findTracePeakWithGaussian(graphName)
//
// Function DoSomethingToAllTracesInGraph(graphName,[type])
//------------------------------------------------------------------------------------------------------------------------------------





//------------------------------------------------------------------------------------------------------------------------------------
Function display1DWaves(mode)
	String mode
	
	// Get current data folder
	String wDF = GetDataFolder(1)
	String wDFName= GetDataFolder(0)  // this is used to name the graph window
	
	// remove bad characters from the DFname
	wDFName = removeBadChars(wDFName)
	wDFName = removeSpace(wDFName)

	// List (1D) waves in current data folder
	String wList =  WaveList("*",";","DIMS:1") 
	Variable wNum = ItemsInList(wList)

	if (wNum!=0)  // check that at least one wave exists before displaying anything
	
		// Define some variable and strings for use below
		String wName,wNameFullStr
		Variable i  // for looping within the case arguments below
		Variable foundWave = 0 
		
		// this switch statement controls what type of display is done - i.e., a single trace, or all traces etc.
		strswitch(mode)
			case "all":
				wName= StringFromList(0,wList,";") 

				// Display the first wave
				display1D(wName)
				
				// Append the rest of the waves
				for (i=1; i<wNum; i+=1)
					wName= StringFromList(i,wList,";") 
					display1D(wName,appendWave="yes")
				endfor
				break
				
			case "one":
				if ( wNum > 1)
					wName= chooseWindowDialogue(wList,wNum)  // returns the image name, or "none" if user cancels
				else 
					wName = StringFromList(0,wList)
				endif
				if ( cmpstr(wName,"None")==0 )
					// do nothing
				else
					display1D(wName,graphName=wDFName)
				endif			
				break
				
			case "oneDN":  // this is specifically for the NEXAFS spectra - it tries to load the wave that ends in "_dn"
				for ( i=0; i<itemsInList(wList); i+=1 )
					wName = StringFromList(i,wList)
					if ( cmpstr (wName[strLen(wName)-3, strLen(wName)],"_dn") == 0 ) 
						// this is the wave you're looking for so break
						foundWave = 1  // set this to 1 if we have found the wave
						break
					endif
				endfor
				if ( foundWave==0 )  // if didn't find the wave then ask the user which wave to use
					wName= chooseWindowDialogue(wList,wNum)  // returns the image name, or "none" if user cancels		
				endif
				
				if ( cmpstr(wName,"None")==0 )
						// do nothing
				else
					display1D(wName,graphName=wDFName)
				endif	
				
				break
			
			case "oneN":  // this is specifically for the NEXAFS spectra - it tries to load the wave that ends in "_n"
				for ( i=0; i<itemsInList(wList); i+=1 )
					wName = StringFromList(i,wList)
					if ( cmpstr (wName[strLen(wName)-2, strLen(wName)],"_n") == 0 ) 
						// this is the wave you're looking for so break
						foundWave = 1  // set this to 1 if we have found the wave
						break
					endif
				endfor
				if ( foundWave==0 )  // if didn't find the wave then ask the user which wave to use
					wName= chooseWindowDialogue(wList,wNum)  // returns the image name, or "none" if user cancels		
				endif
				
				if ( cmpstr(wName,"None")==0 )
						// do nothing
				else
					display1D(wName,graphName=wDFName)
				endif	
				
				break
				
			case "appendall":
				wName= StringFromList(0,wList,";") 

				// Append the rest of the waves
				for (i=0; i<wNum; i+=1)
					wName= StringFromList(i,wList,";") 
					display1D(wName,appendWave="yes")
				endfor
				break
			case "appendone":
				if ( wNum > 1 )
					wName= chooseWindowDialogue(wList,wNum)  // returns the image name, or "none" if user cancels
				else
					wName = StringFromList(0,wList)
				endif
				if ( cmpstr(wName,"None")==0 )
					// do nothing
				else
					display1D(wName,appendWave="yes")
				endif
				break
			default:
				Print "Error in display1DWaves()"
				break
		endswitch
	else
		Print "Error: no 1D wave data found in the current data folder"
	endif
End


//------------------------------------------------------------------------------------------------------------------------------------
Function display1D(wStr,[graphName,appendWave])
	String wStr, graphName, appendWave

	//wStr = PossiblyQuoteName(wStr)
	
	if ( ParamIsDefault(appendWave) )
		if ( ParamIsDefault(graphName) )
			Display/K=1 $wStr
		else
			Display/K=1/N=$(graphName) $wStr
		endif
	else
		if ( cmpstr(appendWave,"yes")==0 )
			AppendToGraph $wStr
		endif
	endif
End


//------------------------------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------------------------------
Function removeAnnotations([graphName])
	String graphName
	
	if ( ParamIsDefault(graphName) )
		// Get name of top graph
		graphName= WinName(0,1)
	endif
	DoWindow/F $graphName
	RemoveFromGraph/Z/W=$graphName fitW
	Cursor/K A
	Cursor/K B
		
	// Kill cursor variables if they exist
	KillVariables/Z root:WinGlobals:$(graphName):xA
	KillVariables/Z root:WinGlobals:$(graphName):xB
	
End


//------------------------------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------------------------------
Function getYvaluesFromGraph(graphName)
	String graphName
	Variable i, eV, theta
	String waveNameStr, waveDF, FullWaveNameStr
	
	// Get current data folder
	String saveDF = GetDataFolder(1)	  // Save
	
	if ( cmpstr(graphName,"")==0 )
		// Get name of top graph
		graphName= WinName(0,1)
	endif

	// Create WinGlobals etc.
	GlobalsForGraph(graphName)
		
	// Move to the created data folder for the graph window
	SetDataFolder root:WinGlobals:$graphName
		
	// Get name of the top Wave
	Wave w = WaveRefIndexed("",0,1)
		
	// Get wave name
	String/G wStr = WaveName("",0,1)
		
	// Remove the quotes from literal wave names
	wStr = possiblyRemoveQuotes(wStr)

	// Determine image size for positioning the cursors
	Variable xMin= DimOffset(w,0)
	Variable xMax= (DimDelta(w,0) * DimSize(w,0) + DimOffset(w,0))
	Variable xRange= xMax - xMin
	
	// Calculate cursor positions
	Variable cursPos= xMin + (0.2 * xRange)
	
	// Establish link between cursor positions and CursorMoved fn. 
	CursorDependencyForSpecsGraph(graphName) 
	
	// Place Cursor on Image (unless already there)
	if (strlen(CsrInfo(A))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) A, $wStr, cursPos
	endif 
		
	// Set energy to cursor position
	eV = hcsr(A,graphName)
	
	// make data folder to hold result
	NewDataFolder/O/S root:$(graphName+"_analysis")
	
	// Check if there is a graph before doing anything
	if( strlen(graphName) )
		// get trace names
		String waveNameList=TraceNameList(graphName, ";", 1 )
		Variable numWaves = itemsInList(waveNameList)
		String smoothedWaveName
		
		// Make waves to hold the x and y values (eV and intensity) 
		Make/O/N=(numWaves) $("NEXAFStheta_"+num2str(eV))
		Make/O/N=(numWaves) $("NEXAFSintensity_"+num2str(eV))
		
		Wave NEXAFStheta = $("NEXAFStheta_"+num2str(eV))
		Wave NEXAFSintensity = $("NEXAFSintensity_"+num2str(eV))
		
		// loop through the traces in graph window
		for (i=0; i<numWaves; i+=1)
			waveNameStr = StringFromList(i,waveNameList)
			Wave w = WaveRefIndexed(GraphName,i,1)	
			waveDF = GetWavesDataFolder(w,1)		
			FullWaveNameStr = GetWavesDataFolder(w,2)
			theta = NumberByKey("THETA",note(w)) 
			if ( numtype (theta)!=0 ) // check if theta is NaN or INF
				Print "Warning: could not determine theta for trace",i,"so assigning it an x value of",i
				theta = i
			endif
			NEXAFStheta[i] = theta
			NEXAFSintensity[i] = w(eV)
		endfor
		
		// Reorder the data in ascending order
		Sort NEXAFStheta, NEXAFStheta, NEXAFSintensity
		
		// Display result
		DoWindow/K $(graphName+"_analysis0")
		Display/k=1 /N=$(graphName+"_analysis") NEXAFSintensity vs NEXAFStheta
		ModifyGraph mode=4
		String newGraphName= WinName(0,1)
		AutoPositionWindow/E/m=0/R=$graphName $newGraphName
		
	else	
		Print "Error: no graph of that name"
	endif
	
	SetDataFolder $saveDF
End


//--------------------------------------------------------------------------------------------------------------
Function GlobalsForGraph(graphName)
	String graphName

	if ( DataFolderExists("root:WinGlobals")!=1 )
		NewDataFolder/O root:WinGlobals
	endif
	if ( DataFolderExists("root:WinGlobals:"+graphName)!=1)
		NewDataFolder/O root:WinGlobals:$graphName
	endif
End


//------------------------------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------------------------------
Function CursorDependencyForSpecsGraph(graphName)
	String graphName
	
	NewDataFolder/O root:WinGlobals
	NewDataFolder/O/S root:WinGlobals:$graphName
	String/G S_CursorAInfo, S_CursorBInfo
	Variable/G dependentA
	SetFormula dependentA, "CursorMovedForSpecsGraph(S_CursorAInfo, 0)"
	Variable/G dependentB
	SetFormula dependentB,"CursorMovedForSpecsGraph(S_CursorBInfo, 1)"
End

//--------------------------------------------------------------------------------------------------------------
//Function RemoveCursorGlobals(graphName)
//	String graphName
//	
//	KillDataFolder root:WinGlobals:$graphName
//	KillDataFolder root:WinGlobals:
//End


//------------------------------------------------------------------------------------------------------------------------------------
// Ask user to choose a window
Function/S chooseWindow()
	
	// List graph windows
	String windowList =  WinList("*", ";", "WIN:1") 
	Variable windowListNum = ItemsInList(windowList)
	
	String chosenWindowsStr= ""
	
	// check that there is more than one window
	if ( windowListNum>0 )
	  	
	  	chosenWindowsStr= windowList
	
		// open dialogue if there is more than one windows
		if ( windowListNum>1 )
			 chosenWindowsStr= chooseWindowDialogue(windowList,windowListNum)
		endif
		
	else
		Print "Error: there must be at least one graph window open"
	endif
	
	return chosenWindowsStr
End


//------------------------------------------------------------------------------------------------------------------------------------
Function/S chooseWindowDialogue(wList,wNum)
	String wList
	Variable wNum
 
	String wName
	Prompt wName,"Which wave would you like to display?", popup, wList 
	DoPrompt "Spectroscopy display",wName
   	if( V_Flag )
      	return "none"          // user canceled
   	endif
	return wName
End


//------------------------------------------------------------------------------------------------------------------------------------
// Ask user to choose two windows
Function/S chooseWindowPair()
	
	// List graph windows
	String windowList =  WinList("*", ";", "WIN:1") 
	Variable windowListNum = ItemsInList(windowList)
	
	String chosenWindowsStr= ""
	
	// check that there is more than one window
	if ( windowListNum>1 )
	  	
	  	chosenWindowsStr= chooseWindowPairDialogue(windowList)
				
	else
		Print "Error: there must be at least two graph windows open"
	endif
	
	return chosenWindowsStr
End


//------------------------------------------------------------------------------------------------------------------------------------
// The GUI dialogue to ask user to choose two windows
Function/S chooseWindowPairDialogue(windowList)
	String windowList

	String windowName1
	String windowName2
	String windowListAlt=windowList
	
	// Remove the first two list items so they can be added in reverse order
	windowListAlt= RemoveListItem(0,windowListAlt)
	windowListAlt= RemoveListItem(0,windowListAlt)
	
	// Add first two list items in reverse order
	String strTmp=StringFromList(0,windowList)
	windowListAlt=AddListItem(strTmp,windowListAlt)
	strTmp=StringFromList(1,windowList)
	windowListAlt=AddListItem(strTmp,windowListAlt)
	
	// User Prompt for window choice if there are more than two widows open
	Prompt windowName1,"Choose window 1", popup, windowList 
	Prompt windowName2,"Choose window 2", popup, windowListalt
	DoPrompt "Window choice dialogue",windowName1,windowName2
	if( V_Flag )
 		return "none"          // user canceled
	endif
	String windowName
   	if ( cmpstr(windowName1,windowName2)!=0 )
		windowName= AddListItem(windowName1,windowName2)
	else
		Print "Error: Please select two different windows"
		windowName=""
	endif
	
	return windowName
End


//------------------------------------------------------------------------------------------------------------------------------------
Function collateTracesFromTwoGraphs()
		
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Get name of top graph
	String graphName= WinName(0,1)
	
	// Check if there is a graph before doing anything
	if( strlen(graphName) )

		// Function to get user to choose two graph windows
		String windowList= chooseWindowPair()
	
		if ( cmpStr(windowList,"none")==0 )
			Print "Warning: cancelled by user"
		else
			displayCollatedTraces(windowList)
		endif
	else
		Print "Error: There is no top graph window"
	Endif
	
	// Move to original data folder
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------------------------------
Function collateTracesFromMultipleGraphs()
		
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Get name of top graph
	String graphName= WinName(0,1)
	
	// Check if there is a graph before doing anything
	if( strlen(graphName) )

		// Function to get user to choose two graph windows
		String windowList= chooseMultipleWindows()
		if ( cmpStr(windowList,"none")==0 )
			Print "Warning: cancelled by user"
		else
			displayCollatedTraces(windowList)
		endif

	else
		Print "Error: There is no top graph window"
	Endif
	
	// Move to original data folder
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------------------------------
Function copyWavesToNewDF([newDFName])
	String newDFName

	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Get name of top graph
	String graphName= WinName(0,1)
	
	// Check if there is a graph before doing anything
	if( strlen(graphName) )

		// Function to get user to choose graph window
		//graphName= chooseWindow()
		
		if ( ParamIsDefault(newDFName) )
			newDFName= "data"
		endif
		
		copyGraphDatatoDF(graphName,newDFName)
		
		//Print "Graph data copied to new DF"

	else
		Print "Error: There is no top graph window"
	Endif
	
	// Move to original data folder
	SetDataFolder saveDF
End



//------------------------------------------------------------------------------------------------------------------------------------
Function copyGraphDatatoDF(graphName,newDF)
	String graphName, newDF
	
	Variable i,j
	for (i=0; i<999; i+=1)
	
		// Get name of the ith Wave from the graph window
		Wave w= WaveRefIndexed(graphName,i,1)
		
		// Stop if no wave exists
		if ( WaveExists(w) )
			String wStr= NameOfWave(w)
		else
			break
		endif
		
		// Create DF if it doesn't exist
		if ( i==0 )
			String fullDFStr="root:"+newDF
			if ( DataFolderExists(fullDFStr) )
				// Do nothing
			else
				NewDataFolder $fullDFStr
			endif
		endif
		
		// Check if a wave of the same name already exists in the DF.  If it does append a number to the wave.
		String newWStr= wStr
		String fullWStr= fullDFStr+":"+newWStr
		
		Wave testWave= $fullWStr
		
		if ( WaveExists(testWave) )
			
			for (j=1; j<99; j+=1)
				newWStr= wStr+"_"+num2str(j)
				fullWStr= fullDFStr+":"+newWStr
				Wave testWave= $fullWStr
				if ( WaveExists(testWave) )
					// do nothing
				else
					wStr= newWStr
					break
				endif
			endfor
		endif
		
		// Make a copy of the wave
		Duplicate/O w, $(fullDFStr+":"+wStr)

		
	endfor // the loop continues until there aren't any more waves in the graph window
	
End





//------------------------------------------------------------------------------------------------------------------------------------
// Ask user to choose multiple windows
Function/S chooseMultipleWindows()
	
	// List graph windows
	String windowList =  WinList("*", ";", "WIN:1") 
	Variable windowListNum = ItemsInList(windowList)
	
	String chosenWindowsStr= ""
	
	// check that there is more than one window
	if ( windowListNum>1 )
	  	chosenWindowsStr= chooseMultipleWindowDialogue(windowList)	
	  	// check that windows were chosen
	  	if ( cmpstr(chosenWindowsStr,"")==0 )
	  		chosenWindowsStr="none"
	  	endif
	else
		Print "Error: there must be at least two graph windows open"
	endif
	
	return chosenWindowsStr
End


//------------------------------------------------------------------------------------------------------------------------------------
// The GUI dialogue to ask user to choose multiple windows
Function/S chooseMultipleWindowDialogue(windowList)
	String windowList
	windowList = AddListItem("Finished",windowList)
	String windowName = ""
	String newWindowList =""
	
	Variable i
	for (i = 0; i<99; i+=1)
		// User Prompt for window choice if there are more than two widows open
		Prompt windowName,"Choose window", popup, windowList 
		DoPrompt "Window choice dialogue",windowName
		if( V_Flag )
 			return "none"          // user canceled
		endif
		if ( cmpstr(windowName,"Finished")==0 )
			break
		endif
		newWindowList = AddListItem(windowName,newWindowList)
	endfor
	
	return newWindowList
End


//------------------------------------------------------------------------------------------------------------------------------------
Function displayCollatedTraces(windowList)
	String windowList

	// Determine how many windows are in the list
	Variable graphListNum = ItemsInList(windowList)
	
	// get the first graph name
	String graphName= StringFromList(0,windowList)
	
	// get the first wave from the first graph
	Wave w= WaveRefIndexed(graphName,0,1)
	
	// get the datafolder for the wave
	String wDF = GetWavesDataFolder(w,1)
	
	// get the name of the first wave
	String wStr= NameOfWave(w)	

	// full wave name including DF
	String wNameFullStr= GetWavesDataFolder(w,2)

	// display the first trace from the first graph
	display1D(wNameFullStr)
	
	Variable i=0
	for (i=1; i<99; i+=1)
	
		// Get name of the ith Wave from the graph window
		Wave w= WaveRefIndexed(graphName,i,1)
		
		// Stop if no wave exists
		if ( WaveExists(w) )
			wNameFullStr= GetWavesDataFolder(w,2)
			display1D(wNameFullStr,appendWave="yes")
		else 
			break
		endif
	endfor
	
	Variable m=0  // now loop over the remaining windows
	for ( m=1; m<graphListNum; m+=1 )
		// get the next graph name
		graphName= StringFromList(m,windowList)
		
		for ( i=0; i<99; i+=1 ) 
			// Get name of the ith Wave from the graph window
			Wave w= WaveRefIndexed(graphName,i,1)
			
			// Stop if no wave exists
			if ( WaveExists(w) )
				wNameFullStr= GetWavesDataFolder(w,2)
				display1D(wNameFullStr,appendWave="yes")
			else
				break
			endif
		endfor // i loop
	endfor // m loop
		
End


//------------------------------------------------------------------------------------------------------------------------------------
Function divideGraphs()
	
	// get current DF
	String saveDF = GetDataFolder(1)
	
	// List graph windows
	String windowList =  WinList("*", ";", "WIN:1") 
	Variable windowListNum = ItemsInList(windowList)
	
	String windowPairList= windowList
	
	if ( windowListNum > 1 )
		windowPairList= chooseWindowPair()
	else
		Print "Error: there must be at least two graph windows open"
	endif
	
	// get name of top window
	String graphName= StringFromList(0,windowPairList)
	
	// get the first wave from the first graph
	Wave w= WaveRefIndexed(graphName,0,1)
	
	// get the name of the wave
	String wName= NameOfWave(w)
	
	// create name for new wave
	String newWName= wName+"_n"
	
	// get the waves DF
	String wDF= GetWavesDataFolder(w,1)
	String wDFName= GetWavesDataFolder(w,0)
	
	// Change to the waves DF
	SetDataFolder wDF
	
	// Duplicate the original wave
	Duplicate/O w, $newWName
	
	Wave newW= $newWName
	
	// get name of second graph window
	String graphNameTwo= StringFromList(1,windowPairList)
	
	// get the first wave from the second graph
	Wave w2= WaveRefIndexed(graphNameTwo,0,1)
	
	// Divide first wave by the second
	newW= w/w2
	
	display1D(newWName,graphName=wDFName)
	
	// change back to original DF
	SetDataFolder saveDF
End





//--------------------------------------------------------------------------------------------------------------
//  
//--------------------------------------------------------------------------------------------------------------
Function duplicateLinePlotNewWaves()
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Get name of top graph
	String graphName= WinName(0,1)

	// Check if there is a graph before doing anything
	if( strlen(graphName) )
	
		// Get list of wave names
		String wnameList = TraceNameList(graphName,";",1)
		Variable numTraces = ItemsInList(wnameList,";")
		
		// Get name of the top trace on the graph
		String wNametmp = StringFromList(0, wnameList)
		wNametmp = possiblyRemoveQuotes(wNametmp)

		// make a wave assignment to this trace
		Wave wtmp= TraceNameToWaveRef(graphName, wNametmp )

		if ( WaveDims(wtmp) !=1)
			// do nothing because not a line plot
			Print "Error: Not a line plot.  Please click on a graph window with line traces and rerun."
		
		else // continue			
		
			// create name for new DF
			String newDF= createDataDF("data")
			newDF = EverythingAfterLastColon(newDF)
			
			// Copy each of the waves from the graph window in the "newDF" -- this will be root:data#	
			copyWavesToNewDF(newDFName=newDF)
			
			SetDataFolder root:$(newDF)
				
			// Create a new blank graph window
			String graphCopyName= graphName+"_CLONE"
			DoWindow/F $graphCopyName
			if ( V_Flag )
				// do nothing because graph window exists
			else
				// create the window
				Display/k=1/N=$graphCopyName 	// create display window because it doesn't yet exist
				
				// Position the window
				AutoPositionWindow/R=$graphName/E/m=0 $graphCopyName
			endif
			KillVariables/Z V_Flag
			
			// Display all waves in the new DF
			display1DWaves("appendall")
			
			//Variable i=0
			//for ( i=0; i < numTraces; i+=1)

				// Get name of the trace(s) on the graph
				//String wName = StringFromList(i, wnameList)
				//wName = possiblyRemoveQuotes(wName)
		
				// make a wave assignment to this trace
				//Wave w= TraceNameToWaveRef(graphName, wName )
		
				// Get waves DF
				//String wDF= GetWavesDataFolder(w,0)
				//String wFullName= GetWavesDataFolder(w,2)

				// create name for new DF
				//String newDF= createDataDF("data")
			
				// Copy wave to the new data folder
				//String newWFullName= newDF+":"+wName
				//Duplicate/O $wFullName $possiblyRemoveHash(newWFullName)
			
				// Make wave assignment to new wave
				//Wave newW= $newWFullName
			
				// Append trace to graph
				//AppendToGraph/W=$graphCopyName newW
		
			//endfor
		endif
	endif
	
	// Original DF
	SetDataFolder saveDF
End
	



//--------------------------------------------------------------------------------------------------------------
//  
//--------------------------------------------------------------------------------------------------------------
Function duplicateLinePlotOrigWaves()
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Get name of top graph
	String graphName= WinName(0,1)

	// Check if there is a graph before doing anything
	if( strlen(graphName) )
	
		// Get list of wave names
		String wnameList = TraceNameList(graphName,";",1)
		Variable numTraces = ItemsInList(wnameList,";")
		
		// Get name of the top trace on the graph
		String wNametmp = StringFromList(0, wnameList)
		wNametmp = possiblyRemoveQuotes(wNametmp)

		// make a wave assignment to this trace
		Wave wtmp= TraceNameToWaveRef(graphName, wNametmp )

		if ( WaveDims(wtmp) !=1)
			// do nothing because not a line plot
			Print "Error: Not a line plot.  Please click on a graph window with line traces and rerun."
		
		else // continue			
						
			// Create a new blank graph window
			String graphCopyName= graphName+"_COPY"
			DoWindow/F $graphCopyName
			if ( V_Flag )
				// do nothing because graph window exists
			else
				// create the window
				Display/k=1/N=$graphCopyName 	// create display window because it doesn't yet exist
				
				// Position the window
				AutoPositionWindow/R=$graphName/E/m=0 $graphCopyName
			endif
			KillVariables/Z V_Flag
			
			Variable i=0
			for ( i=0; i < numTraces; i+=1)

				// Get name of the trace(s) on the graph
				String wName = StringFromList(i, wnameList)
				wName = possiblyRemoveQuotes(wName)
		
				// make a wave assignment to this trace
				Wave w= TraceNameToWaveRef(graphName, wName )
		
				// Get waves DF
				String wDF= GetWavesDataFolder(w,0)
				String wFullName= GetWavesDataFolder(w,2)
			
				// Append trace to graph
				AppendToGraph/W=$graphCopyName w
		
			endfor
		endif
	endif
	
	// Original DF
	SetDataFolder saveDF
End
	
	



//------------
//	
Function/S createDataDF(baseName)
	String basename
	
	Variable i
	
	for (i=0;i<999;i+=1)
		String newDF= "root:"+baseName+num2str(i)
		If ( DataFolderExists(newDF) )
			// continue with loop if the DF exists
		else
			NewDataFolder/O $newDF
			return newDF
			break  // finish after creating a new DF
		endif
	endfor
End
	
	
	

//------------------------------------------------------------------------------------------------------------------------------------
Function MakeTracesDifferentColours(paletteName)
	String paletteName
	string trl=tracenamelist("",";",1), item
	variable items=itemsinlist(trl), i
	colortab2wave $paletteName
	wave/i/u M_colors
	Variable colors = DimSize(M_colors,0)
	variable ink=colors/items
	for(i=0;i<items;i+=1)
		item=stringfromlist(i,trl)
		ModifyGraph rgb($item)=(M_colors[i*ink][0],M_colors[i*ink][1],M_colors[i*ink][2])
	endfor
	killwaves/z M_colors
end




//------------------------------------------------------------------------------------------------------------------------------------
// This function operates on a graph window.  It duplicates all traces in that window into their own DFs and
// appends "_S" to their names.  It then smooths the waves.
//------------------------------------------------------------------------------------------------------------------------------------
Function SmoothTracesInGraph(graphName,[type])
	String graphName, type
	Variable i
	String waveNameStr, waveDF, FullWaveNameStr
	
Print "****************WARNING*******************"
Print "THIS FUNCTION NOW REDUNDANT.  "
PRINT " PLEASE USE: Function DoSomethingToAllTracesInGraph(graphName,[type])"
Print "****************WARNING*******************"
	
	// Get current data folder
	String saveDF = GetDataFolder(1)	  // Save
	
	if ( cmpstr(graphName,"")==0 )
		// Get name of top graph
		graphName= WinName(0,1)
	endif
	
	Variable smth=3
	if ( cmpstr(type,"SG")==0 )
		smth=5
	else
		Prompt smth, "Enter Smoothing Factor"
		DoPrompt "Smoothing", smth
	endif
	
	// Check if there is a graph before doing anything
	if( strlen(graphName) )
		String waveNameList=TraceNameList(graphName, ";", 1 )
		Variable numWaves = itemsInList(waveNameList)
		String smoothedWaveName
		for (i=0; i<numWaves; i+=1)
			waveNameStr = StringFromList(i,waveNameList)
			Wave w = WaveRefIndexed(GraphName,i,1)	
			waveDF = GetWavesDataFolder(w,1)		
			FullWaveNameStr = GetWavesDataFolder(w,2)	
			
			// Move to waves DF
			SetDataFolder $waveDF
			
			smoothedWaveName = waveNameStr+"_S"
			Duplicate/O w, $smoothedWaveName
			
			strswitch (type)
				case "SG":
					Smooth/S=2 smth, $smoothedWaveName
					break
				case "B":
					Smooth smth, $smoothedWaveName
					break
				default:
					Smooth smth, $smoothedWaveName
					break
			endswitch
			
			Wave sw = $smoothedWaveName
			
			
			if ( i==0 )
				display1D(smoothedWaveName)
			else
				display1D(smoothedWaveName,appendWave="yes")
			endif
			
		endfor
	else	
		Print "Error: no graph of that name"
	endif
	
	SetDataFolder $saveDF
End







//------------------------------------------------------------------------------------------------------------------------------------
// This function operates on a graph window.  It duplicates all traces in that window into their own DFs and
// appends "_X" to their names.  It then applies a shift equal to shiftX to their x-axes.
//------------------------------------------------------------------------------------------------------------------------------------
Function ShiftTracesInGraph(graphName,[shiftX])
	String graphName
	Variable shiftX
	Variable i
	String waveNameStr, waveDF, FullWaveNameStr
	
	// Get current data folder
	String saveDF = GetDataFolder(1)	  // Save
	
	if ( cmpstr(graphName,"")==0 )
		// Get name of top graph
		graphName= WinName(0,1)
	endif
	
	// Check if there is a graph before doing anything
	if( strlen(graphName) )
		
		// if no shift amount was given the request the user enter it
		if ( ParamIsDefault(shiftX) )
			Prompt shiftX, "Enter amount to shift the X-axis"
			DoPrompt "Shift X", shiftX
			if ( V_flag )
				shiftX = 0
			endif
		endif
		
		String waveNameList=TraceNameList(graphName, ";", 1 )
		Variable numWaves = itemsInList(waveNameList)
		String shiftedWaveName
		
		for (i=0; i<numWaves; i+=1)
			waveNameStr = StringFromList(i,waveNameList)
			Wave w = WaveRefIndexed(GraphName,i,1)	
			waveDF = GetWavesDataFolder(w,1)		
			FullWaveNameStr = GetWavesDataFolder(w,2)	
			
			// Move to waves DF
			SetDataFolder $waveDF
			
			shiftedWaveName = waveNameStr+"_SX"
			Duplicate/O w, $shiftedWaveName
						
			Wave sw = $shiftedWaveName
			
			SetScale/P x, dimOffset(w,0)+shiftX, dimDelta(w,0), sw
			
			// Add wave note
			Note/NOCR sw, "XSHIFTEDBY: "+num2str(shiftX)+";"
		
			if ( i==0 )
				display1D(shiftedWaveName)
			else
				display1D(shiftedWaveName,appendWave="yes")
			endif
			
		endfor
	else	
		Print "Error: no graph of that name"
	endif
	
	SetDataFolder $saveDF
End








//------------------------------------------------------------------------------------------------------------------------------------
//  Finds location of peak, then fits a gaussian and returns the x location of the gaussian apex
//------------------------------------------------------------------------------------------------------------------------------------
Function findTracePeakWithGaussian(graphName)
	String graphName
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Get top graph name if name not supplied
	if ( cmpstr(graphName,"")==0 )
		// Get name of top graph
		graphName= WinName(0,1)
	endif
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G wDF			// data folder containing the data shown on the graph
	String/G wStr			// name of the wave shown on the graph 
	String/G wFullStr		// data folder plus wave name
	
	// Make wave assignment to the data. 
	Wave w= $wFullStr
	
	// Determine image size for positioning the cursors
	Variable xMin= DimOffset(w,0)
	Variable xMax= (DimDelta(w,0) * DimSize(w,0) + DimOffset(w,0))
	Variable xRange= xMax - xMin
	
	// Automatically find where the peak is
	Variable minPeakHeight = 0.95*WaveMax(w)
	FindPeak/M=(minPeakHeight) w
	Print "peak at", V_PeakLoc
	
	// Set cursor positions 
	Variable leftCurs= V_PeakLoc - (0.01 * xRange)
	Variable rightCurs= V_PeakLoc + (0.01 * xRange)
	
	// Place Cursors on Image (unless they are already there)
	if (strlen(CsrInfo(A))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) A, $wStr, leftCurs
	endif 
	if (strlen(CsrInfo(B))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) B, $wStr, rightCurs
	endif
	
	// Fit gaussian to wave peak (between cursors)
	CurveFit/NTHR=0 gauss w[pcsr(A),pcsr(B)] /D
	Wave fittedWave = $"fit_"+wStr
	Duplicate/O fittedWave, fitW
	RemoveFromGraph/Z fitW
	AppendToGraph/C=(0,0,0) fitW
	KillWaves/Z fittedWave
	
	// Find maximum of the fitted gaussian
	FindPeak fitW
	Variable peakLoc= V_PeakLoc
	
	// Output to command area
	Print " "
	Print "Location of maximum of the fitted Gaussian is", peakLoc, "eV"
	
	// Change back to original DF
	SetDataFolder saveDF
	
	// Return the result
	return peakLoc
End






//------------------------------------------------------------------------------------------------------------------------------------
// This function operates on a graph window.  It duplicates all traces in that window into their own DFs and
// appends "_X" to their names.  It then performs some action of the waves (smoothing, differentiating...)
//------------------------------------------------------------------------------------------------------------------------------------
Function DoSomethingToAllTracesInGraph(graphName,[type])
	String graphName, type
	Variable i
	String waveNameStr, waveDF, FullWaveNameStr
	
	// Get current data folder
	String saveDF = GetDataFolder(1)	  // Save
	
	if ( cmpstr(graphName,"")==0 )
		// Get name of top graph
		graphName= WinName(0,1)
	endif
	
	// Check if there is a graph before doing anything
	if( strlen(graphName) )
		String waveNameList=TraceNameList(graphName, ";", 1 )
		Variable numWaves = itemsInList(waveNameList)
		String manipulatedWaveName
		
		
		// get any input required from user before entering the loop
		strswitch (type)
			case "smooth-B":
				Variable smth=3
				Prompt smth, "Enter Smoothing Factor"
				DoPrompt "Smoothing", smth
				break
		endswitch
		
		// Duplicate the wave if want to average the data
		if ( cmpstr(type,"average") == 0 )
			waveNameStr = StringFromList(0,waveNameList)
			Wave w = WaveRefIndexed(GraphName,0,1)	
			waveDF = GetWavesDataFolder(w,1)		
			FullWaveNameStr = GetWavesDataFolder(w,2)	
			manipulatedWaveName = waveNameStr+"_A"
			NewDataFolder/O/S root:averaged
			Duplicate/O w, $manipulatedWaveName
			Variable wavesAveraged = 0
		endif
		
		Variable rasterstart
		Variable Traster
		String xunit
		if ( cmpstr(type,"xunits") == 0 )
			Wave w = WaveRefIndexed(GraphName,0,1)	
			String w_info = WaveInfo(w,0)
			xunit = StringByKey("xunits",w_info)
			rasterstart = DimOffset(w,0)
			Traster = DimDelta(w,0)
			Prompt rasterstart, "Enter start value"
			Prompt Traster, "Enter t-raster value"
			Prompt xunit, "Enter new wave x-axis units"
			DoPrompt "X Units Change", rasterstart, Traster, xunit
			if( V_Flag )
 			     	// user canceled
 			endif
 		endif
						
		// loop over all waves in this graph window
		for (i=0; i<numWaves; i+=1) 
			waveNameStr = StringFromList(i,waveNameList)
			Wave w = WaveRefIndexed(GraphName,i,1)	
			waveDF = GetWavesDataFolder(w,1)		
			FullWaveNameStr = GetWavesDataFolder(w,2)	
			
			// Move to waves DF
			SetDataFolder $waveDF
			
			strswitch (type)
				case "smooth-SG":
					manipulatedWaveName = waveNameStr+"_SG"
					Duplicate/O w, $manipulatedWaveName
					Wave mw = $manipulatedWaveName
					Smooth/S=2 5, mw
					break
				case "xunits": 				      	
					SetScale/P x, rasterstart, Traster, xunit, w				
					break
				case "FFT":
					manipulatedWaveName = waveNameStr+"_FFT"
					//Duplicate/O w, $manipulatedWaveName
					//Wave mw = $manipulatedWaveName
					//FFT/OUT=3/DEST=fftwave, w
					FFT/OUT=3/DEST=$manipulatedWaveName w
					break
				case "smooth-B":
					manipulatedWaveName = waveNameStr+"_SB"
					Duplicate/O w, $manipulatedWaveName
					smoothAWaveB(manipulatedWaveName,smth)
					break
				case "differentiate":
					manipulatedWaveName = waveNameStr+"_D"
					Duplicate/O w, $manipulatedWaveName
					Wave mw = $manipulatedWaveName
					Differentiate mw
					
					break
				case "differentiateNormalised": // Normalised derivative **TESTING**
					NVAR normConductLim = root:WinGlobals:SRSSTMControl:normConductLim
					manipulatedWaveName = waveNameStr+"_DN"
					Duplicate/O w, $manipulatedWaveName
					Wave mw = $manipulatedWaveName
					Duplicate/O mw, mwDiffCond
					Duplicate/O mw, mvTotCond
					Variable wLength =  DimSize(mw,0)
					Variable startx =  DimOffset(mw,0)
					Variable delta =  DimDelta(mw,0)
					Variable bias, current
					Differentiate mwDiffCond
					Variable jj
					for (jj=0;jj<wLength;jj+=1)
						current = mw[jj]
						bias = startx+jj*delta
						mvTotCond[jj] = current/bias
						if ( Abs(mw[jj]) < normConductLim )
							mw[jj] = 0
						else
							mw[jj] = mwDiffCond[jj]/mvTotCond[jj]
						endif
					endfor
					
					break
			
				case "average":
					SetDataFolder root:averaged
					Wave mw = $manipulatedWaveName
					mw = mw + w
					wavesAveraged += 1
					break
				default:
					Print "ERROR: Don't know what to do with this data"
					break
			endswitch
			
			if (cmpstr(type,"average")==0)
				// do nothing
			else
				// Display the result 
				if ( i==0 )
					display1D(manipulatedWaveName)
				else
					display1D(manipulatedWaveName,appendWave="yes")
				endif
			endif
			
		endfor
		
		// Divide average wave by number of traces (if doing an average)		
		if ( cmpstr(type,"average") == 0 )
			mw = mw / wavesAveraged
			display1D(manipulatedWaveName)
		endif
	else	
		Print "Error: no graph of that name, or no graph window open"
	endif
	
	SetDataFolder $saveDF
End

Function smoothAWaveB(waveStr,smth)
	String waveStr
	Variable smth
	
	Wave w = $waveStr
	
	Smooth smth, w
End



// BELOW IS A HACK FOR EMILY's DATA 29 OCT 2018

Function makeImageFromTraceList()
	// Get current data folder
	String wDF = GetDataFolder(1)
	String wDFName= GetDataFolder(0)  // this is used to name the graph window
	
	// remove bad characters from the DFname
	wDFName = removeBadChars(wDFName)
	wDFName = removeSpace(wDFName)

	// List (1D) waves in current data folder
	String wList =  WaveList("*",";","DIMS:1") 
	Variable wNum = ItemsInList(wList)

	String wName,wNameFullStr
	Variable i  // for looping within the case arguments below
	Variable foundWave = 0 
		
	wName= StringFromList(0,wList,";") 
	Wave wTrace = $wName
	
	WaveStats/Q wTrace;
	Make/O/N=(V_npnts,wNum) image
	image = 0
	// 
	image[][0]= wTrace[p]
				
	// Append the rest of the waves
	for (i=1; i<wNum; i+=1)
		wName= StringFromList(i,wList,";") 
		Wave wTrace = $wName
		image[][i]= wTrace[p]
	endfor

End