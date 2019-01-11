//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-SPECS-manip.ipf
//
// Collection of functions for working with 1D waves; specifically for spectroscopy manipulation
// NEXAFS
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
#pragma rtGlobals=1


//------------------------------------------------------------------------------------------------------------------------------------
// Below is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------
//
// Function doSomethingWithSpecsData(actionType)
// Function GlobalsForSpecsGraph(graphName)
// Function CursorDependencyForSpecsGraph(graphName)
// Function CursorMovedForSpecsGraph(info, cursNum)
// Function subtractLeadingEdge(graphName)
// Function postEdgeNormalisation(graphName)
// Function XPSBackground(graphName,type)
// Function XPSMeasureEnergyOffset(graphName,[type])
// Function XPSApplyEnergyOffset(graphName)
// Function findMinimum(graphName)
// Function XPSXRangeToBackground()
// Function prettyNEXAFS()
// Function setNEXAFSyAxis()
// Function setNEXAFSyAxisVariable()
// Function setDefaultCursors()
//
//------------------------------------------------------------------------------------------------------------------------------------
// Above is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------



//------------------------------------------------------------------------------------------------------------------------------------
// Top level function for manipulating spectroscopy data
//------------------------------------------------------------------------------------------------------------------------------------
Function doSomethingWithSpecsData(actionType)
	String actionType
	// actionType = leadingSubtraction
		
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Get name of top graph
	String graphName= WinName(0,1)

	// Check again (in case user cancelled above) if there is a graph before doing anything
	if( strlen(graphName) )
		
		// Create WinGlobals etc.
		GlobalsForGraph(graphName)
		
		// Move to the created data folder for the graph window
		SetDataFolder root:WinGlobals:$graphName
		
		// Get name of the Wave
		Wave w= WaveRefIndexed("",0,1)
		
		// Get DF name
		String/G wDF = GetWavesDataFolder(w,1)
		
		// Create global variable of path and name of image wave
		String/G wFullStr= GetWavesDataFolder(w,2)
		
		// Get wave name
		String/G wStr= WaveName("",0,1)
		
		// Remove the quotes from literal wave names
		wStr = possiblyRemoveQuotes(wStr)
		
		// Check dimension of the wave is > 1.  If not, do nothing.
		if (WaveDims(w)<2)
			// Call the appropriate function for the requested manipulation type
			// Note that it is important to still be in the datafolder root:WinGlobals:$graphName 
			// when these functions are called since they load  
			strswitch (actionType)
				case "leadingSubtraction":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
				
					// leading edge subtraction
					subtractLeadingEdge(graphName,"linear")
					
					break
					
				case "leadingConstantSubtraction":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
					
					// leading edge subtraction
					subtractLeadingEdge(graphName,"constant")
					
					break
				
				case "leadingAvgSubtraction":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
					
					// leading edge subtraction
					subtractLeadingEdge(graphName,"constantAvg")
					
					break
					
				case "postEdgeNormalisation":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
					
					// post edge normalise
					postEdgeNormalisation(graphName)
					
					break
					
				case "XPSLinearBackground":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
					
					// XPS linear background subtraction
					XPSBackground(graphName,type="linear")
					
					break
					
        			case "XPSShirleyBackground":
					
					// Establish link between cursor positions and CursorMoved fn.
					CursorDependencyForSpecsGraph(graphName)
					
					// XPS Shirley background
					XPSBackground(graphName,type="shirley")
					
					break
					
        			case "XPSMeasureSi2p32Offset":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
					
					// 
					XPSMeasureEnergyOffset(graphName,type="Si2p32")
				
					break
					
				case "XPSMeasureAu4f72Offset":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
					
					// 
					XPSMeasureEnergyOffset(graphName,type="Au4f72")
					
					break
					
				case "XPSApplyEnergyOffset":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
					
					// 
					XPSApplyEnergyOffset(graphName)
					
					break
					
				case "findTracePeakWithGaussian":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
					
					// 
					findTracePeakWithGaussian(graphName)
					
					break
				
				default:
					Print "Error, unknown manipulationType"
					break
					
			endswitch
		else 
				Print "Data must 1 dimensional.  Stopping."
		endif
	else
		Print "Error: need at least one graph window open"
	endif
	
	//bring the graph containing the data to the front
	//DoWindow/F $graphName 

	// Move back to the original data folder
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------------------------------------------------------------
//Function GlobalsForSpecsGraph(graphName)
//	String graphName//
//
//	if ( DataFolderExists("root:WinGlobals")!=1 )
//		NewDataFolder/O root:WinGlobals
//	endif
//	if ( DataFolderExists("root:WinGlobals:"+graphName)!=1)
//		NewDataFolder/O root:WinGlobals:$graphName
//	endif
//End


//------------------------------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------------------------------
//Function CursorDependencyForSpecsGraph(graphName)
//	String graphName
//	
//	NewDataFolder/O root:WinGlobals
//	NewDataFolder/O/S root:WinGlobals:$graphName
//	String/G S_CursorAInfo, S_CursorBInfo
//	Variable/G dependentA
//	SetFormula dependentA, "CursorMovedForSpecsGraph(S_CursorAInfo, 0)"
//	Variable/G dependentB
//	SetFormula dependentB,"CursorMovedForSpecsGraph(S_CursorBInfo, 1)"
//End


//------------------------------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------------------------------
Function CursorMovedForSpecsGraph(info, cursNum)
	String info
	Variable cursNum // 0 if A cursor, 1 if B cursor 

	Variable result= NaN // error result
	
	// Check that the top graph is the one in the info string.
	String topGraph= WinName(0,1)
	String graphName= StringByKey("GRAPH", info)
	
	String DFSave= GetDataFolder(1);
	SetDataFolder root:WinGlobals:$graphName

	if( CmpStr(graphName, topGraph) == 0 )
		String tName= StringByKey("TNAME", info)
		String xPtStr= StringByKey("POINT", info)
		String yPtStr= StringByKey("YPOINT", info)
		Variable/G xPt= str2num(xPtStr)
		
		Variable leftXVal, rightXVal
		
		// If the cursor is off the trace name will be zero length so do nothing
		if( strlen(tName) ) // cursor still on
			leftXVal= hcsr(A)
			rightXVal= hcsr(A)
			Variable/G xA= leftXVal
			Variable/G xB= rightXVal

		endif
	endif
	
	//doSomethingWithSpecsData("leadingSubtraction")
	
	SetDataFolder DFSave
	return result
End


//------------------------------------------------------------------------------------------------------------------------------------
// Function to remove a background based on the slope of the leading edge
//------------------------------------------------------------------------------------------------------------------------------------
Function subtractLeadingEdge(graphName,type)
	String graphName,type
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
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
	
	// Calculate cursor positions
	Variable leftCurs= xMin + (0.05 * xRange)
	Variable rightCurs= xMin + (0.13 * xRange)
	
	// Load the cursor positions from global variables if they exist
	Variable/G xA
	Variable/G xB
	
	// Try to load cursors from reference spectrum data folder if they exist
	NVAR cursorA = root:reference:cursorA
	NVAR cursorB = root:reference:cursorB

	if ( (Abs(xA)+Abs(xB))>0 && (Abs(xA)+Abs(xB)) < 10000 )  // assume if these are all zero then they have not been defined before, otherwise they have so use those numbers/
		leftCurs= xA
		rightCurs= xB
	elseif ( numtype (cursorA+cursorB)==0 )  // checks these are not NaN or INF
		leftCurs= cursorA
		rightCurs= cursorB
	endif

	// Place Cursors on Image (unless they are already there)
	if (strlen(CsrInfo(A))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) A, $wStr, leftCurs
	endif 
	if (strlen(CsrInfo(B))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) B, $wStr, rightCurs
	endif
	
	// Create a wave that will be used for the leading edge subtraction
	Duplicate/O w, fitW
	
	// Determine the wave to be used for leading edge subtraction, depending on type of subtraction desired
	
	strswitch ( type )
		case "constant":
			fitW = vcsr(A)   // horizontal line with y value equal to cursor A
			break
		case "constantAvg":  // horizontal line with y value equal to the average of y values between cursors
			fitW = mean(w,hcsr(A),hcsr(B))  // horizontal line with y value equal to mean y value between cursors
			break
		case "linear":
			CurveFit/NTHR=0 line  w[pcsr(A),pcsr(B)] /D=fitW
			Wave fitCoef=W_coef
			fitW= fitCoef[1]*x + fitCoef[0]
			Variable minY, maxY
			GetAxis/Q left
			RemoveFromGraph/Z/W=$graphName fitW
			SetAxis left V_min, V_max
			break
	endswitch
	
	// Show the wave used for subtraction on the graph window
	RemoveFromGraph/Z fitW
	AppendToGraph/C=(0,0,0) fitW
	
	// change to data DF	
	SetDataFolder wDF
	
	// make wave name for subtracted wave
	String newWStr
	newWStr= wStr+"_CS"
	
	// Create new wave that has been modified
	Duplicate/O w, $newWStr
	
	// Make wave assignment
	Wave newW= $newWStr
	
	// Perform subtraction
	newW= w-fitW
	
	// Display result
	DoWindow/K $(newWStr+"0")
	Display/k=1/N=$newWStr newW
	String newGraphName= WinName(0,1)
	
	AutoPositionWindow/E/m=0/R=$graphName $newGraphName
End


//------------------------------------------------------------------------------------------------------------------------------------
// Function to perform post-edge normalisation
//------------------------------------------------------------------------------------------------------------------------------------
Function postEdgeNormalisation(graphName)
	String graphName
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
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
	
	// Calculate cursor positions
	Variable leftCurs= xMax - (0.05 * xRange)
	Variable rightCurs= xMax 
	
	// Load the cursor positions from global variables if they exist
	Variable/G xA
	Variable/G xB
	
	if ( (Abs(xA)+Abs(xB))!=0 && (Abs(xA)+Abs(xB)) < 10000 )  // assume if these are all zero then they have not been defined before, otherwise they have so use those numbers/

		leftCurs= xA
		rightCurs= xB

	endif
		
	// Place Cursors on Image (unless they are already there)
	if (strlen(CsrInfo(A))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) A, $wStr, leftCurs
	endif 
	if (strlen(CsrInfo(B))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) B, $wStr, rightCurs
	endif
	
	// Find average value between cursors
	WaveStats/R=[pcsr(A),pcsr(B)] w
	Variable normConstant = V_avg

	// change to data DF	
	SetDataFolder wDF
	
	// make wave name for subtracted wave
	String newWStr= wStr+"_N"
	
	// Create new wave that has been modified
	Duplicate/O w, $newWStr
	
	// Make wave assignment
	Wave newW= $newWStr
	
	// Perform normalisation
	newW= w/normConstant
	DoWindow/K $(newWStr+"0")
	Display/k=1/N=$newWStr newW
	String newGraphName= WinName(0,1)
	
	AutoPositionWindow/E/m=0/R=$graphName $newGraphName
	
End



//------------------------------------------------------------------------------------------------------------------------------------
// Function to remove a background in XPS type spectrum
//------------------------------------------------------------------------------------------------------------------------------------
Function XPSBackground(graphName,[type])
	String graphName,type
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
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
	
	// Calculate cursor positions
	Variable leftCurs= xMin + (0.1 * xRange)
	Variable rightCurs= xMax - (0.1 * xRange)
	
	// Load the cursor positions from global variables if they exist
	Variable/G xA
	Variable/G xB
	
	// Try to load cursors from reference spectrum data folder if they exist
	NVAR cursorA = root:reference:cursorA
	NVAR cursorB = root:reference:cursorB

	if ( numtype (cursorA+cursorB)==0 )  // checks these are not NaN or INF
		leftCurs= cursorA
		rightCurs= cursorB
	endif

	if ( (Abs(xA)+Abs(xB))>0 && (Abs(xA)+Abs(xB)) < 10000 )  // assume if these are all zero then they have not been defined before, otherwise they have so use those numbers/
		Print "xA=",xA
		leftCurs= xA
		rightCurs= xB
	endif

	// Place Cursors on Image (unless they are already there)
	if (strlen(CsrInfo(A))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) A, $wStr, leftCurs
	endif 
	if (strlen(CsrInfo(B))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) B, $wStr, rightCurs
	endif
	
	// Create a wave that will be used for the background subtraction
	Duplicate/O w, fitW
	
	// Determine the wave to be used for background subtraction, depending on type of subtraction desired
	
	Variable m,b
	Variable xLeft =  xcsr(A)
	Variable xRight =  xcsr(B)
	Variable yLeft =  vcsr(A)
	Variable yRight =  vcsr(B)
	
	strswitch ( type )  // Idea is to do linear first on pre-edge, then Shirley (you have to move the cursors!)
		case "linear":
			m = (yRight - yLeft) / (xRight - xLeft)
			b = yRight - m*xRight
			fitW = m*x + b
			break
		case "shirley":
			Wave shirleyW = XPSShirleyBackground(w, pcsr(A), pcsr(B))
			fitW = shirleyW
			KillWaves/Z shirleyW
			break
		default :
			break
	endswitch
	
	// Show the wave used for subtraction on the graph window
	RemoveFromGraph/Z fitW
	AppendToGraph/C=(0,0,0) fitW
	
	// change to data DF	
	SetDataFolder wDF
	
	// make wave name for subtracted wave
	String newWStr
	strswitch ( type )  // only know how to do Linear at the moment...
		case "linear":
			newWStr= wStr+"_L"
			break
		case "shirley":
			newWStr= wStr+"_Sh"
			break
	endswitch
	
	// Create new wave that has been modified
	Duplicate/O w, $newWStr
	
	// Make wave assignment
	Wave newW= $newWStr
	
	// Perform subtraction
	newW= w-fitW
	
	// Add wave note
	strswitch ( type )  
		case "linear":
				Note/NOCR newW, "BG:linear, m="+num2str(m)+", b="+num2str(b)+";"
			break
		case "shirley":
				Note/NOCR newW, "BG:shirley;"
			break
		default :
			// do nothing
			break
	endswitch
	
	// add wave note for background region
	Note/NOCR newW, "BG_MIN: "+num2str(xLeft)+";"
	Note/NOCR newW, "BG_MAX: "+num2str(xRight)+";"
	
	// Display result
	DoWindow/K $(newWStr+"0")
	Display/k=1/N=$newWStr newW
	
	// set x-axis range based on the BG_MIN and BG_MAX keywords added to teh wave note
	XPSXRangeToBackground("KE")
	//SetAxis bottom xLeft, xRight
	
	String newGraphName= WinName(0,1)
	
	AutoPositionWindow/E/m=0/R=$graphName $newGraphName
End

//------------------------------------------------------------------------------------------------------------------------------------
// Iteratively compute a Shirley background for XPS spectrum between two cursor points.
//------------------------------------------------------------------------------------------------------------------------------------
Function/WAVE XPSShirleyBackground(data, pl, pr)
	Wave data
	Variable pl, pr
	
	// USER SETTING - max number of iterations for the Shirley background
	Variable maxit = 10
	Variable it = 0
	Variable tol = 1e-5
	Variable dbg = 1
	
	// background, new background (next iteration) and background difference.
	Duplicate/O data b
	b = 0
	Duplicate/O data bnew
	bnew = 0
	Duplicate/O bnew bdiff
	
	// Loop variables
	Variable ksum = 0
	Variable ysum = 0
	Variable k,i,j
	Variable imax = numpnts(data)
	Variable xl = leftx(data) + pl * deltax(data)
	Variable xr = leftx(data) + pr * deltax(data)
	Variable yl = data[pl]
	Variable yr = data[pr]
	
	// Initial background is a step from xl
	for (i=pl;i<imax;i=i+1)
		b[i] = yr-yl
		bnew[i] = yr-yl
	endfor
	
	do
		if (dbg == 1)
			print "Shirley iteration", it, norm(bdiff)
		endif
		ksum = 0.0
		// k = (yr - yl) / (integral_xl^xr J(x') - yl - b(x') dx')
		for (i=pl;i<pr;i=i+1)
			ksum = ksum + deltax(data) * 0.5 * (data[i] + data[i+1] - 2 * yl - b[i] - b[i+1])
		endfor
		k = (yr - yl) / ksum
		// Generate a new b
		for (i=pl;i<pr;i = i+1)
			ysum = 0.0
			for (j=pl;j<i;j = j + 1)
				ysum = ysum + deltax(data) * 0.5 * (data[j] + data[j+1] - 2 * yl - b[j] - b[j+1])
			endfor
			bnew[i] = k * ysum
		endfor
		bdiff = bnew - b
		if (norm(bdiff) < tol)
			b = bnew
			break
		else
			b = bnew
		endif
		it = it + 1
	while (it < maxit)
	
	if (it >= maxit)
		print "Warning: max Shirley iterations exceeded before convergence, the Shirley spectrum may be rubbish!"
	endif
	
	b = b + yl
	return b
End 

//------------------------------------------------------------------------------------------------------------------------------------
// function to measure the energy different to a reference peak
//------------------------------------------------------------------------------------------------------------------------------------
Function XPSMeasureEnergyOffset(graphName,[type])
	String graphName,type
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G wDF			// data folder containing the data shown on the graph
	String/G wStr			// name of the wave shown on the graph
	String/G wFullStr		// data folder plus wave name
	
	// Make wave assignment to the data. 
	Wave w= $wFullStr
	
	// Load the cursor position from global variables if they exist
	Variable/G xA
	
	// Calculate cursor positions
	Variable referenceEnergy
	
	strswitch ( type )
		case "Au4f72":
			referenceEnergy = 83.98
			break
		case "Si2p32":
			referenceEnergy = 99.6
			break
		default:
			Print"Error: what region?"
			break
	endswitch
	
	// change to data DF	
	SetDataFolder wDF
	
	Variable peakPosition =  findTracePeakWithGaussian(graphName) 
	
	// variable for energy offset
	Variable/G energyOffset
	
	strswitch ( type )  
		case "Au4f72":	// Au reference from the 4f 7/2 line at 83.98
			energyOffset =  peakPosition - referenceEnergy
			Print "The Au(4f) 7/2 peak is offset by",energyOffset,"eV from its known position at 83.98 eV"
			Note/NOCR w, "REFERENCE: Au(4f) 7/2;"
			break
		case "Si2p32":	// Si reference from the 2p 3/2 line at 99.6
			energyOffset =  peakPosition - referenceEnergy
			Print "The Si(2p) 3/2 peak is offset by",energyOffset,"eV from its known position at 99.6 eV"
			Note/NOCR w, "REFERENCE: Si(2p) 3/2;"
			break
		default :
			Print "Error: don't know what the reference energy is"
			break
	endswitch
	
	// add delta E to wave note
	NOTE/NOCR w, "REFERENCE_SHIFT: "+num2str(energyOffset)
	
	SetDataFolder saveDF
End



//------------------------------------------------------------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------------------------------------------------------------
Function XPSApplyEnergyOffset(graphName)
	String graphName
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G wDF			// data folder containing the data shown on the graph
	String/G wStr			// name of the wave shown on the graph 
	String/G wFullStr		// data folder plus wave name
	
	// Make wave assignment to the data.  
	Wave w= $wFullStr
		
	// change to data DF	
	SetDataFolder wDF
	
	// variable for energy offset
	NVAR energyOffset
	
	if ( NVAR_exists(energyOffset) )
		Print "LOADED energy offset of,",energyOffset,"eV from data folder,",wDF
		Print "WARNING: subtracting this shift to all data in the current graph"
		ShiftTracesInGraph(graphName,shiftX=-energyOffset)
	else 
		Print "WARNING: could not load energy offset data"
		ShiftTracesInGraph(graphName)
	endif
	
End




//------------------------------------------------------------------------------------------------------------------------------------
// Searches the wave notes of all waves in the current data folder.  If one of them contains the key word
// "REFERENCE_SHIFT", then it extracts the corresponding energy shift from teh wave note and then applies
// this as a shift to the other waves in this data folder.
//------------------------------------------------------------------------------------------------------------------------------------
Function XPSApplyEnergyOffsetToDF()

	// List (1D) waves in current data folder
	String wList =  WaveList("*",";","DIMS:1") 
	Variable wNum = ItemsInList(wList)
	Variable i, energyShiftTmp, energyShift, refWcounter
	String notetmp, wName, waveDF, shiftedWaveName
	
	KillWaves/Z isReferenceW
	Make/N=(wNum) isReferenceW
	
	refWcounter = 0
	for ( i=0; i<wNum; i+=1)
	
		// get the name of the ith wave and read its wave note
		wName = StringFromList(i,wList)
		Wave w = $wName
		notetmp = note(w)
		
		// check for REFERENCE_SHIFT and read the number if it exists
		energyShiftTmp = NumberByKey("REFERENCE_SHIFT",notetmp)
		
		// record which wave is the reference wave
		if ( numtype(energyShiftTmp) == 0 ) 
			energyShift=energyShiftTmp
			isReferenceW[i] = 1  // this is a reference wave
			wList = RemoveFromList(wName,wList)  // remove this name from the list
			wNum -=1
		else
			isReferenceW[i] = 0 // this is not a reference wave
		endif
	endfor
		
	if ( sum(isReferenceW) > 1 )
		Print "ERROR: This data folder contains more than one reference wave. Aborting."
	elseif ( sum(isReferenceW) < 1 )
		Print "ERROR: This data folder does not contain a processed reference wave. Aborting. "
	else
		// apply energy shift to all waves excpt the reference wave
		for ( i=0; i<wNum; i+=1)
	
			// get the name of the ith wave and read its wave note
			wName = StringFromList(i,wList)
			Wave w = $wName
			
			waveDF = GetWavesDataFolder(w,1)		
			//FullWaveNameStr = GetWavesDataFolder(w,2)	
			
			// Move to waves DF
			SetDataFolder $waveDF
			
			shiftedWaveName = wName+"_SX"
			Duplicate/O w, $shiftedWaveName
						
			Wave sw = $shiftedWaveName
			
			SetScale/P x, dimOffset(w,0)-energyShift, dimDelta(w,0), sw
			
			// Add wave note
			Note/NOCR sw, "XSHIFTEDBY: "+num2str(energyShift)+";"
		endfor
	endif
	
	// Clean up
	KillWaves/Z isReferenceW
End


//------------------------------------------------------------------------------------------------------------------------------------
// Simple macro to make the x-axis of an XPS plot the same as the background region (that is stored in the wave note)
//------------------------------------------------------------------------------------------------------------------------------------
Function XPSXRangeToBackground(type)
	String type
	
	// TRY TO READ THE REGION FROM THE TOP WAVE using the WAVE NOTE
	
	// get top wave from top graph window
	Wave w= WaveRefIndexed("",0,1)
	
	// get the wave note string
	String wNote = note(w)
	
	// Determine min and max x-axis values (left,right) from the wave note
	Variable left, right
	Variable numberOfBackgroundSubtracts = StringByKeyNumberOfInstances("BG_MIN",wNote)
	left = NumberByKey("BG_MIN", wNote)
	right = NumberByKey("BG_MAX", wNote)
	if ( numberOfBackgroundSubtracts == 1 )  // only one background subtraction has been applied
		// do nothing, we're already done
	else  // more than one back ground subtraction so check if the range gets expanded
		Variable i, leftTmp, rightTmp
		for (i=1; i<numberOfBackgroundSubtracts; i+=1)
			leftTmp =  str2num(StringByKeyIndexed(i,"BG_MIN",wNote))
			if ( leftTmp < left )
				left = leftTmp
			endif
			rightTmp =  str2num(StringByKeyIndexed(i,"BG_MAX",wNote))
			if ( rightTmp > right )
				right = rightTmp
			endif
		endfor
	endif
	
	if ( numtype(left + right) == 0 ) // not a NaN
		strswitch(type)
			case "KE":
				SetAxis bottom left, right
				Print "Set x-axis to: left =",left,"right =",right
				break
			case "BE":
				SetAxis bottom right,left
				Print "Set x-axis to: left =",right,"right =",left
				break
		endswitch
	else 
		Print "Error: the wave not contains no information about the background region. (left =",left,"right =",right
		strswitch(type)
			case "KE":
				SetAxis/A bottom 
				Print "Set x-axis to full scale"
				break
			case "BE":
				SetAxis/A/R bottom
				Print "Set x-axis to full scale"
				break
		endswitch
	endif
End


//------------------------------------------------------------------------------------------------------------------------------------
// Simple macro to make the axes of the graph nice
//------------------------------------------------------------------------------------------------------------------------------------
Function prettyXPS()
	// check if there is a graph window first 
	String graphName= WinName(0,1)
	if ( strlen(graphName) ==0 )
		// do nothing
		Print "ERROR: no graph window present"
	else
		ModifyGraph width=566.929,height=283.465;DelayUpdate
		ModifyGraph mirror=1,standoff=0;DelayUpdate
		ModifyGraph tick=2;DelayUpdate
		SetAxis left 0,*;DelayUpdate
		ModifyGraph fSize=16;DelayUpdate
		ModifyGraph standoff(bottom)=1; DelayUpdate
		MakeTracesDifferentColours("SpectrumBlack")
		DoUpdate
		Legend/C/N=text0/F=0
		ModifyGraph width=0,height=0
		DoUpdate
	endif
End

//------------------------------------------------------------------------------------------------------------------------------------
// Simple macro to make the axes of the graph nice
//------------------------------------------------------------------------------------------------------------------------------------
Function prettyNEXAFS()
	// check if there is a graph window first 
	String graphName= WinName(0,1)
	if ( strlen(graphName) ==0 )
		// do nothing
		Print "ERROR: no graph window present"
	else
		ModifyGraph width=566.929,height=283.465;DelayUpdate
		ModifyGraph mirror=1,standoff=0;DelayUpdate
		ModifyGraph tick=2;DelayUpdate
		SetAxis left 0,*;DelayUpdate
		SetAxis/A bottom;DelayUpdate
		Label left "Normalised Auger Yield";DelayUpdate
		Label bottom "Photon Energy (\\U)";DelayUpdate
		ModifyGraph fSize=16;DelayUpdate
		Label left "\\Z16Normalised Auger Yield";DelayUpdate
		Label bottom "\\Z16Photon Energy (\\U)"
		MakeTracesDifferentColours("YellowHot256")
		DoUpdate
		Legend/C/N=text0/F=0
		ModifyGraph width=0,height=0
		DoUpdate
	endif
End

//------------------------------------------------------------------------------------------------------------------------------------
// Simple macro to make the axes of the graph nice
//------------------------------------------------------------------------------------------------------------------------------------
Function prettyNEXAFSpaperfig()
	// check if there is a graph window first 
	String graphName= WinName(0,1)
	if ( strlen(graphName) ==0 )
		// do nothing
		Print "ERROR: no graph window present"
	else
		ModifyGraph mirror=1,standoff=0;DelayUpdate
		ModifyGraph tick=2;DelayUpdate
		SetAxis left 0,*;DelayUpdate
		SetAxis/A bottom;DelayUpdate
		Label left "Normalised Auger Yield";DelayUpdate
		Label bottom "Photon Energy (\\U)";DelayUpdate
		ModifyGraph fSize=16;DelayUpdate
		Label left "\\Z16Normalised Auger Yield";DelayUpdate
		Label bottom "\\Z16Photon Energy (\\U)"
		DoUpdate
		Legend/C/N=text0/F=0
		DoUpdate
		
		ModifyGraph width=283.465,height=170.079; DelayUpdate
		SetAxis/A bottom 280, 320; DelayUpdate
		SetAxis left 0,4; DelayUpdate
		DoUpdate
	endif
End

//------------------------------------------------------------------------------------------------------------------------------------
// This looks for a variable in root:reference that determines the y-axis height and if it finds it it sets the y-axis
//------------------------------------------------------------------------------------------------------------------------------------
Function setNEXAFSyAxis()
	NVAR/Z yAxisHeight = root:reference:yAxisHeight
	if ( NVAR_Exists(yAxisHeight) )
		if ( yAxisHeight > 0)  // if variable is 0 or negative then autoscale, otherwise set the axis height
			SetAxis left 0, yAxisHeight
		else 
			SetAxis left 0, * 
		endif
	endif
End


//------------------------------------------------------------------------------------------------------------------------------------
// This will create global variables that store the desired y-axis height
//------------------------------------------------------------------------------------------------------------------------------------
Function setNEXAFSyAxisVariable()

	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	if ( DataFolderExists("root:reference") )
		SetDataFolder root:reference
	else
		NewDataFolder/S  root:reference
	endif 
	
	NVAR/Z yAxisHeight
	if ( NVAR_Exists(yAxisHeight)==0 )  // if cursorA variable does not exist then create it
		Variable/G yAxisHeight=0
	endif
	
	Variable promptyAxisHeight = yAxisHeight
		
	Prompt promptyAxisHeight, "Enter desired y-axis height (set to 0 for auto-scale)"
	DoPrompt "Y-axis height setting", promptyAxisHeight
		
	yAxisHeight=promptyAxisHeight
	
	// change back to original DF
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------------------------------
// This will create global variables that store the positions of the cursors used for NEXAFS
// preedge subtraction
//------------------------------------------------------------------------------------------------------------------------------------
Function setDefaultCursors()
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	if ( DataFolderExists("root:reference") )
		SetDataFolder root:reference
	else
		NewDataFolder/S  root:reference
	endif 
	
	NVAR/Z cursorA, cursorB
	if ( NVAR_Exists(cursorA)==0 )  // if cursorA variable does not exist then create it
		Variable/G cursorA=0
	endif
	if ( NVAR_Exists(cursorB)==0 )  // if cursorA variable does not exist then create it
		Variable/G cursorB=0
	endif
	
	Variable promptCursA = cursorA
	Variable promptCursB = cursorB
	
	Prompt promptCursA, "Energy for left cursor"
	Prompt promptCursB, "Energy for right cursor"
	DoPrompt "Default Cursor Energies for Pre-edge Subtraction", promptCursA, promptCursB
	
	cursorA=promptCursA
	cursorB = promptCursB
	
	// change back to original DF
	SetDataFolder saveDF
End


