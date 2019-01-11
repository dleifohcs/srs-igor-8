//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-STM-data-manip.ipf
//
// A collection of functions for manipulating scanning tunnelling microscopy data
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
//------------------------------
// Top level
//------------------------------
// Function doSomethingWithData(actionType)
//
//------------------------------
// Line profile from data
//------------------------------
// Function lineProfile(graphname)
// Function removeLineProfile(graphName)
// Function makeLineProfile(graphname)
// Function updateLineProfile(graphname)
//
//------------------------------
// Cursor functions
//------------------------------
// Function CursorDependencyForGraph(graphName)
// Function CursorMovedForGraph(info, cursNum)
//
//-------------------------------
// Global Programme control
//-------------------------------
// Function createSRSControlVariables()
//
//-------------------------------
// Background subtraction
//-------------------------------
// Function subtractPlane(graphname,[ROI])
// Function subtractMin(graphname)
// Function subtractLinewise(graphname)
//
//-------------------------------
// CITS functions
//-------------------------------
// Function dispSTSfromCITS(graphname,)
// Function backupData(graphname,suffixStr)
// Function manipulateCITS(graphname,action)
// Function refresh3dData(graphName)
// Function matrixConvolveData(graphName)
// Function makeKernel(graphName,dim)
// Function quickSaveImage([symbolicPath,imageType])
// Function quickScript(scriptType)
// Function createROI(graphname)
// Function killROI(graphname)
// Function imageArithmetic(graphname)
//
//------------------------------------------------------------------------------------------------------------------------------------
// Above is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------
// This function gets data from the top window, creates appropriate variables in root:WinGlobals
// and then calls some function to operate on the data according to value it is called with.
// This is for 2D and 3D data sets
Function doSomethingWithData(actionType)
	String actionType
	// actionType={ 
	//--- ANALYSIS
	//						"lineprofile"
	//--- MANIPULATION
	//						"subtractplane"
	//						"subtractplaneROI"
	// 						"subtractlinewise"
	// 						"subtractMin"
	//						"imageArithmetic"
	//--
	// 						"STSfromCITS"
	//						"STSfromCITSROI"
	//						"duplicateLinePlot"
	// 						"differentiateCITS"
	// 						"smoothZ"
	//						"mConvolution"
	// 						"extractImageFromCITS"
	//
	//						"createROI"
	//						"killROI"
	//--- APPEARANCE
	//						"makeImgPretty"
	//						"changeColour"
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// create the global control variables if they don't exist (required for example in setting the default image colours)
	createSRSControlVariables()
	
	// Get name of top graph
	String graphName= WinName(0,1)
	
	// Check if there is a graph before doing anything
	if( strlen(graphName) )

		// Create WinGlobals etc.
		GlobalsForGraph(graphName)
		
		// Move to the created data folder for the graph window
		SetDataFolder root:WinGlobals:$graphName

		// Get name of the image Wave
		String wnameList = ImageNameList("", ";")
		String/G imgWStr = StringFromList(0, wnameList)
		// Remove the quotes from literal wave names
		imgWStr = possiblyRemoveQuotes(imgWStr)
		
		// Get datafolder of the image wave
		String/G imgDF
		imgDF = ImageInfo("",imgWStr,0)		
		imgDF = StringByKey("ZWAVEDF",imgDF)

		// Create global variable of path and name of image wave
		String/G imgWFullStr= imgDF+PossiblyQuoteName(imgWStr)
		
		// Create Wave assignment for image
		Wave imgW= $imgWFullStr 

		// Check dimension of the wave is > 1.  If not, do nothing.
		if (WaveDims(imgW)>1)
			// Call the appropriate function for the requested manipulation type
			// Note that it is important to still be in the datafolder root:WinGlobals:$graphName 
			// when these functions are called since they load  
			strswitch (actionType)
			
				case "upSampleImage":  // x and y axes the same; pad with zeros
					
					upSampleImage(graphName)			
					break
					
				case "upSampleCITS":  // x and y axes the same; pad with zeros
					
					backupData(graphName,"I")
					
					upSampleCITS(graphName)			
					break
					
				case "copyImageData":  // x and y axes the same; pad with zeros
					
					copyImageData(graphName,"I")
						
					break
					
				case "equalAxes":  // x and y axes the same; pad with zeros
					
					equalAxes(graphName)			
					break
					
				case "padImage":  // x and y axes the same; pad with zeros
					
					Variable px = 0
					String side="right"
					Prompt px, "Number of pixels to pad"
					Prompt side, "Which side to pad", popup, "left;right;top;bottom"
					DoPrompt "Smoothing", px, side
		
					padImage(graphName,side,px)	
					break
				
				case "cropImg":
					
					// can't do conventional "backup" for crop since this resets the view area.
								
					// crop
					cropImg(graphName)			
					break
					
				case "cropCITS":
					
					// can't do conventional "backup" for crop since this resets the view area.
								
					// crop
					cropCITS(graphName)			
					break
					
				case "rotateImg":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"R")  // the string in the second variable is appended to wave name after backup up the original data
					
					// rotate
					rotateImg(graphName)			
					break
				
				case "skewImgHor":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"S")  // the string in the second variable is appended to wave name after backup up the original data
					
					// first subtract the mean 
					doSomethingWithData("subtractMean")
					Print "Note: have removed the mean background"
					
					// rotate
					skewImg(graphName,"horizontal")			
					break
					
				case "skewImgVer":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"S")  // the string in the second variable is appended to wave name after backup up the original data
					
					// first subtract the mean 
					doSomethingWithData("subtractMean")
					Print "Note: have removed the mean background"
					
					// rotate
					skewImg(graphName,"vertical")			
					break
				
				case "FFT":
									
					// Function for removing a plane background
					subtractMin(graphName,mintype="mean")
					
					// Update the colour scale (important after background substraction)
					updateColourRange(graphName)
	
					// FFT
					FFTimage(graphName,"complex")			
					break

				case "FFTCITS":
					
					// Function for removing a plane background
					manipulateCITS(graphName,"FFTCITS")
					
					break
				
				case "FFTmag":
				
					// Function for removing a plane background
					subtractMin(graphName,mintype="mean")
					
					// Update the colour scale (important after background substraction)
					updateColourRange(graphName)
					
					// FFT
					FFTimage(graphName,"mag")			
					break
					
				case "IFFT":
				
					// IFFT
					IFFTimage(graphName)			
					break
				
				case "FFTlowpass":
				
					FFTlowpass(graphName)
					break 
					
				case "lineprofile":
						
					Cursor/K D
					Cursor/K E
					
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForGraph(graphName) 
					
					// generate line profile
					lineProfile(graphName)
					break
				
				case "lineprofileMulti":
	
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForGraph(graphName) 
					
					// generate line profile
					lineProfileMulti(graphName)
					break
					
				case "subtractplane":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"P")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					subtractPlane(graphName)
					
					// Update the colour scale (important after background substraction)
					updateColourRange(graphName)

					// Update line profiles after manupulating data
					updateLineProfile(graphname)
					
					break

				case "subtractplaneROI":
					
					// Make a back up copy of the original data in a data folder of the same name
//					backupData(graphName,"R")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					subtractPlane(graphName,ROI="yes")
					
					// Update the colour scale (important after background substraction)
					updateColourRange(graphName)

					// Update line profiles after manupulating data
					updateLineProfile(graphname)
					
					break
				
				case "subtractROIFFT":
					
					// Make a back up copy of the original data in a data folder of the same name
//					backupData(graphName,"R")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					subtractROI(graphName,"no")
										
					break
				
				case "subtractROIFFTInverse":
					
					// Make a back up copy of the original data in a data folder of the same name
//					backupData(graphName,"R")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					subtractROI(graphName,"yes")
										
					break
					
				case "subtractlinewise":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"L")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					subtractLinewise(graphName)
					
					// Update the colour scale (important after background substraction)
					updateColourRange(graphName)

					// Update line profiles after manupulating data
					updateLineProfile(graphname)
					
					break
				
				case "subtractMin":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"Z")  // the string in the second variable is appended to wave name after backup up the original data
				
					// Function for removing a plane background
					subtractMin(graphName)
					
					// Update the colour scale (important after background substraction)
					updateColourRange(graphName)
					
					// Update line profiles after manupulating data
					updateLineProfile(graphname)
					
					break
				
				case "subtractMean":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"Z")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					subtractMin(graphName,mintype="mean")
					
					// Update the colour scale (important after background substraction)
					updateColourRange(graphName)
					
					// Update line profiles after manupulating data
					updateLineProfile(graphname)
					
					break
					
				case "imageArithmetic":
					
					imageArithmetic("subtract")
					
					break
					
				case "differentiateCITS":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"D")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					manipulateCITS(graphName,"differentiate")
					
					break
					
				case "topCorCITS":
					Print ""
					Print "NOTICE: Please ensure that you have applied the mean background subtraction to your topography image."
					Print ""
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"T")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					manipulateCITS(graphName,"topCor")
					
					break
				
				case "topCorCITSdeltaz":
					Print ""
					Print "NOTICE: Please ensure that you have applied the mean background subtraction to your topography image."
					Print ""
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"T")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					manipulateCITS(graphName,"topCordeltaz")
					
					break
					
				case "differentiateNormalisedCITS":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"DN")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					manipulateCITS(graphName,"differentiateNormalised")
					
					break


				case "smoothZ":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"S")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					manipulateCITS(graphName,"smoothZ")
					
					break
					
				case "STSfromCITS":
				
					// Make wave assignment to 3d data wave
					Wave citsImgW
					
					// Check that the image displayed has an associated 3d dataset.  The image must have been displayed with the SRS macros that generate the appropriate global variables
					if (WaveExists(citsImgW)==1)
				
						// Establish link between cursor positions and CursorMoved fn. 
						CursorDependencyForGraph(graphName)
					
						// Display STS curve
						dispSTSfromCITS(graphName)
					else
						Print "Error: this is not a 3d data set, or it was not displayed using the img3dDisplay(imgWStr) function of the SRS-STM macros"
					endif
					break
				
				case "STSfromCITSROI":
				
					// Make wave assignment to 3d data wave
					Wave citsImgW
					
					// Check that the image displayed has an associated 3d dataset.  The image must have been displayed with the SRS macros that generate the appropriate global variables
					if (WaveExists(citsImgW)==1)
				
						// Establish link between cursor positions and CursorMoved fn. 
						CursorDependencyForGraph(graphName)
					
						// Display STS curve
						dispSTSfromCITSROI(graphName)
					else
						Print "Error: this is not a 3d data set, or it was not displayed using the img3dDisplay(imgWStr) function of the SRS-STM macros"
					endif
					break
				
				case "STSfromCITSAll":
				
					// Make wave assignment to 3d data wave
					Wave citsImgW
					
					// Check that the image displayed has an associated 3d dataset.  The image must have been displayed with the SRS macros that generate the appropriate global variables
					if (WaveExists(citsImgW)==1)
				
						// Establish link between cursor positions and CursorMoved fn. 
						CursorDependencyForGraph(graphName)
					
						// Display STS curve
						dispSTSfromCITSROI(graphName,all="yes")
					else
						Print "Error: this is not a 3d data set, or it was not displayed using the img3dDisplay(imgWStr) function of the SRS-STM macros"
					endif
					break
					
				case "duplicateLinePlot":
					
					duplicateLinePlotNewWaves()
					break
					
				case "createROI":
				
					// create ROI on graphName
					createROI(graphName)

					break
				
				case "killROI":
				
					// killl ROIs if any exist
					killROI(graphName)

					break
					
				case "mConvolution":
					
					backupData(graphName,"M")
					
					// Function convolving a matrix with the data
					matrixConvolveData(graphName)

					break
				
				case "extractImageFromCITS":
				
					// Function convolving a matrix with the data
					manipulateCITS(graphname,"extractImage")

					break
					
				case "extractImageSFromCITS":
				
					// Function convolving a matrix with the data
					manipulateCITS(graphname,"extractImages")

					break
				

				case "makeImgPretty":
					
					// get global variables
					SVAR defaultImageColours = root:WinGlobals:SRSSTMControl:defaultImageColours
					SVAR autoUpdateImageColour = root:WinGlobals:SRSSTMControl:autoUpdateImageColour
	
					// Add a z-scale
					imgScaleBar(graphName)

					// Change graph size, etc., so that it looks nice
					imgGraphPretty(graphName)

					// Apply a colour scale to the image
					changeColour(graphName,colour=defaultImageColours,changeScale=autoUpdateImageColour)
					
					// Add information panel
					imgAddInfo(graphName)

					break
					
				case "make3DImgPretty":

					// Change graph size, etc., so that it looks nice
					imgGraphPretty(graphName)
					
					// Add a z-scale
					imgScaleBar(graphName)
					
						
					// Apply a colour scale to the image
					changeColour(graphName,colour="Blue2")
					
					// Add information panel area
					img3DInfoPanel(graphName)
					
					ModifyGraph width=194
					DoUpdate
					ModifyGraph width=0
					DoUpdate
					
					// Add image information (bias, current, etc.)
					//imgAddInfo(graphName)

					break
					
				case "changeColour":
					
					changeColour(graphName,changeScale="no")
					break
					
				case "changeBiasCurrent":
					
					changeBiasCurrent(graphName)
					
					KillWindow $graphname
					
					SetDataFolder imgDF
					imgDisplay(imgWStr)
					break
					
				default:
					Print "Error, unknown manipulationType"
					break
					
			endswitch
		else 
				Print "Data must be 2 or 3 dimensional.  Stopping."
		endif
		//bring the graph containing the data to the front
		DoWindow/F $graphName 
	else
		Print "Error: no data window"
	endif

	// Move back to the original data folder
	SetDataFolder saveDF
End


//--------------------------------------------------------------------------------------------------------------
// This is called from the manipulateData function when user asks for a line profile of the current graph
Function lineProfile(graphname)
	String graphname

	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure

	SVAR CITSLineProfileLog = root:WinGlobals:SRSSTMControl:CITSLineProfileLog
		
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data.  This can be either a 2d, or 3d data wave
	Wave imgW= $imgWFullStr

	// Determine image size for positioning the cursors
	Variable xMin= DimOffset(imgW,0)
	Variable xMax= (DimDelta(imgW,0) * DimSize(imgW,0) + DimOffset(imgW,0))
	Variable yMin= DimOffset(imgW,1)
	Variable yMax= (DimDelta(imgW,1) * DimSize(imgW,1) + DimOffset(imgW,1))
	Variable xRange = xMax - xMin
	Variable yRange = yMax - yMin
	
	// Calculate cursor positions
	Variable leftCursX= xMin + (0.25 * xRange)
	Variable rightCursX= xMax - (0.25 * xRange)
	Variable leftCursY= yMin + (0.25 * yRange)
	Variable rightCursY= yMax - (0.25 * yRange)
	
	// Load the cursor positions from global variables if they exist
	Variable/G xA
	Variable/G xB
	Variable/G yA
	Variable/G yB
	
	if ( (Abs(xA)+Abs(xB)+Abs(yA)+Abs(yB))!=0 && (Abs(xA)+Abs(xB)+Abs(yA)+Abs(yB)) < 10000 )  // assume if these are all zero then they have not been defined before, otherwise they have so use those numbers/
		leftCursX= xA
		rightCursX= xB
		leftCursY= yA
		rightCursY= yB
	endif
	
	// Generate folder and global variables for 2d plot (if working with 3d data set)
	// This must be done before calling "Cursor" below, since the 2dline profile DF in WinGlobals needs to be created before the cursors are placed
	if (WaveExists(citsImgW)==1)

		// Create name that will be used for the 2d slice graph window and associated WinGlobals folder
		String/G lineProfile2dGraphName= graphName+"_2dProfile"
		
		// Create WinGlobals etc. for the 2d line profile graph window (this is used later for colour scaling etc.)
		GlobalsForGraph(lineProfile2dGraphName)
		
	endif
	
	// Place Cursors on Image (unless they are already there)
	if (strlen(CsrInfo(A))==0)
		Cursor/N=1/W=$graphName/I/s=1/c=(65535,65535,65535) A, $imgWStr, leftCursX, leftCursY
	endif 
	if (strlen(CsrInfo(B))==0)
		Cursor/N=1/W=$graphName/I/s=1/c=(65535,65535,65535) B, $imgWStr, rightCursX, rightCursY
	endif
			
	// Create Global Variables with Cursor Positions
	Variable/G xB= hcsr(B)
	Variable/G yB= vcsr(B)
	Variable/G xA= hcsr(A)
	Variable/G yA= vcsr(A)

	// Make a wave to display a line between the cursors on the image
	Make/O/N=2 lineprofx={xA,xB}, lineprofy={yA,yB}
	RemoveFromGraph/Z lineprofy // in case a line profile already drawn then remove it
	AppendToGraph lineprofy vs lineprofx // display the path on the image
	ModifyGraph rgb=(65535,65535,65535); DoUpdate  // change colour to white	

	// We don't actually need to run "makelineprofile()" because this is called when the cursors are generated above	
//	makelineprofile(graphName)
	
	// Make wave assignment to the 1d line profile generated in makeLineProfile()
	Wave lineProfile1D
	
	// Create a new graph to display the line profile
	String/G lineProfileGraphName= graphName+"_lineprofile"
	DoWindow/K $lineProfileGraphName
	Display/k=1/N=$lineProfileGraphName 
	AppendToGraph/W=$lineProfileGraphName lineProfile1D
	
	//--- now do 2d image slice
	
	// Generate folder and global variables for 2d plot (if working with 3d data set)
	if (WaveExists(citsImgW)==1)

		// Create name that will be used for the 2d slice graph window and associated WinGlobals folder
		String/G lineProfile2dGraphName= graphName+"_2dProfile"
		
		// Create WinGlobals etc. for the 2d line profile graph window (this is used later for colour scaling etc.)
		GlobalsForGraph(lineProfile2dGraphName)
		
		// Move into the WinGlobals folder for the 2d slice
		SetDataFolder root:WinGlobals:$(lineProfile2dGraphName)
		
		// Create global variables in this data folder.  These are used by other procedures such as the colour change function
		String/G imgDF= "root:WinGlobals:"+lineProfile2dGraphName+":"
		String/G imgWStr= "lineProfile2D"
		String/G imgWFullStr= imgDF+imgWStr
		
		// We don't actually need to run "makelineprofile()" because this is called when the cursors are generated above	
//		makelineprofile(graphName)
				
		// Make the graph window
		DoWindow/K $lineProfile2dGraphName
		Display/k=1/N=$lineProfile2dGraphName
		
		// Append the 2d line profile to the graph window and make it look nice
		AppendImage/W=$lineProfile2dGraphName lineProfile2D
		imgGraphPretty(lineProfile2dGraphName)
		imgScaleBar(lineProfile2dGraphName)
		if ( cmpstr(CITSLineProfileLog,"yes")==0 )
			changeColour(lineProfile2dGraphName,colour="SRSBlue2")
		else
			changeColour(lineProfile2dGraphName,colour="BlueExp")
		endif
		ModifyGraph width=0
		ModifyGraph height=0
		DoUpdate
		
		// Move back to the WinGlobals data folder for the 3d data set
		SetDataFolder root:WinGlobals:$(GraphName)
	endif
	
		
	// Arrange graph windows on screen
	if (WaveExists(citsImgW)==1)
		AutoPositionWindow/E/m=0/R=$graphName $lineProfile2dGraphName
		AutoPositionWindow/E/m=1/R=$lineProfile2dGraphName $lineProfileGraphName
	else
		AutoPositionWindow/E/m=0/R=$GraphName $lineProfileGraphName
	endif
	 
	// Move back to the original data folder
	SetDataFolder saveDF

End

//--------------------------------------------------------------------------------------------------------------
// Remove line profile.
Function removeLineProfile(graphName)
	String graphName
	
	if ( cmpstr(graphName,"")==0 )
		// Get name of top graph
		graphName= WinName(0,1)
	endif

	Cursor/K A
	Cursor/K B
	Cursor/K D
	Cursor/K E
	
	RemoveFromGraph/Z lineprofy
	
End

//--------------------------------------------------------------------------------------------------------------
// 
Function LineProfileColourBlack(graphName,colour)
	String graphName, colour
	
	if ( cmpstr(graphName,"")==0 )
		// Get name of top graph
		graphName= WinName(0,1)
	endif
	
	Variable Cx, Cy, Cz
	StrSwitch(colour)
		Case "black":
			Cx = 65535
			Cy = 0
			Cz = 0
			break
		Case "green":
			Cx = 0
			Cy = 65535
			Cz = 0
			break
		Case "blue":
			Cx = 0
			Cy = 0
			Cz = 65535
			break
		Case "red":
			Cx = 65535
			Cy = 0
			Cz = 0
			break
		Default:
			Cx = 65535
			Cy = 65535
			Cz = 65535
			break
	endswitch
	
	Cursor/M /C=(Cx,Cy,Cz) A
	Cursor/M /C=(Cx,Cy,Cz) B
	Cursor/M /C=(Cx,Cy,Cz) C
	ModifyGraph rgb=(Cx,Cy,Cz)
	
End

//--------------------------------------------------------------------------------------------------------------
// Called from "CursorMoved" and "lineProfile"
Function makeLineProfile(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
		
	// These global variables have been created and set already
	String/G imgWFullStr
	Wave imgW= $imgWFullStr 
	Wave lineprofx, lineprofy
	
	NVAR lineProfileWidth = root:WinGlobals:SRSSTMControl:lineProfileWidth
	SVAR CITSLineProfileLog = root:WinGlobals:SRSSTMControl:CITSLineProfileLog
	
	// this variable will be 0 if there are no NaNs or INFs in lineprofx and lineprofy
	Variable anyNaNs = numtype(lineprofx[0]) + numtype(lineprofy[0]) + numtype(lineprofx[1]) + numtype(lineprofy[1]) + numtype(lineprofx[2]) + numtype(lineprofy[2]) + numtype(lineprofx[3]) + numtype(lineprofy[3]) 

	// check if any of lineprof values are NaN or inf before calculating the lineprofile
	// this is necessary in case the user has killed and recreated the image window (in which case NaNs appear...)
	if ( anyNaNs != 0)  
		// do nothing
	else
		// Use inbuilt Igor routine to generate the line profile
		ImageLineProfile/SC width=lineProfileWidth, xwave=lineprofx, ywave=lineprofy, srcwave=imgW

		// Copy the created wave to a new wave that will be used for plotting
		Duplicate/O W_ImageLineProfile lineProfile1D
		KillWaves/Z W_ImageLineProfile
	
		// Create a "distance" wave from the two x- and y- waves
		Duplicate/O W_LineProfileX lineProfileDistance
		Wave xline= W_LineProfileX
		Wave yline= W_LineProfileY
		Wave dline= lineProfileDistance
	
		// ensure xline and yline are always increasing positive
		if (xline(numpnts(xline)-1) - xline(0)<0)
			Reverse xline 
		endif
		if (yline(numpnts(yline)-1) - yline(0)<0)
			Reverse yline 
		endif
	
		// Set origin of x and y waves to zero then calculate the distance wave
		Variable xlinemin= WaveMin(xline)
		Variable ylinemin= WaveMin(yline)
		xline= xline - xlinemin
		yline= yline - ylinemin
		dline = Sqrt(xline^2 + yline^2)
		
		// Calculate the length of the line profile
		Variable lineLength
		if ( numtype(hcsr(D))!=0 )
			// if D cursor is not on the graph then assume only single line profile A->B
			lineLength = sqrt ( (lineprofy[1] - lineprofy[0])^2 + (lineprofx[1] - lineprofx[0])^2 )
		elseif ( numtype(hcsr(E))!=0 )
			// if E cursor is not on the graph then assume only single line profile A->B
			lineLength = sqrt ( (lineprofy[1] - lineprofy[0])^2 + (lineprofx[1] - lineprofx[0])^2 )	
		else
			// Otherwise assume this is multi line profile
			lineLength = sqrt ( (lineprofy[3] - lineprofy[2])^2 + (lineprofx[3] - lineprofx[2])^2 ) + sqrt ( (lineprofy[2] - lineprofy[1])^2 + (lineprofx[2] - lineprofx[1])^2 )	 + sqrt ( (lineprofy[1] - lineprofy[0])^2 + (lineprofx[1] - lineprofx[0])^2 )	
		endif
	
		// Having calculated the distance wave we can delete the X and Y waves to make the data folder neater
		KillWaves/Z W_LineProfileX, W_LineProfileY
	
		// Give the line profile appropriate units (taken from image wave)
		String/G imgWXUnit= WaveUnits(imgW,0)
		String/G imgWYUnit= WaveUnits(imgW,1)
		String/G imgWDUnit= WaveUnits(imgW,-1)
		SetScale/I y, 0, 1, imgWDUnit,  lineProfile1D
		//SetScale/I x, WaveMin(dline), WaveMax(dline), imgWXUnit,  lineProfile1D
		SetScale/I x, 0, lineLength, imgWXUnit,  lineProfile1D
		
		// Now that the 1d line profile has been generated, check whether this is a 3d data set (e.g., cits) and if so then
		// generate the 2d slice profile from it	
		if (WaveExists(citsImgW)==1)
	
			// Get the global string that tells us where the cits wave data is
			String/G citsWFullStr
		
			// Make the wave assignment to this data
			Wave citsW= $citsWFullStr
			
			// Use inbuilt Igor routine to generate the line profile
			ImageLineProfile/SC/P=-2 width=lineProfileWidth, xwave=lineprofx, ywave=lineprofy, srcwave=citsW

			// Copy the created wave to a new wave that will be used for plotting - this wave is put in a separate data folder
			Duplicate/O M_ImageLineProfile root:WinGlobals:$(graphName+"_2dProfile"):lineProfile2D
//			KillWaves/Z M_ImageLineProfile, W_LineProfileX, W_LineProfileY
			
			// Move into 2d data slice DF
			SetDataFolder root:WinGlobals:$(graphName+"_2dProfile")
			
			// Take the logarithm of the data
			Wave lineProfile2D
			if ( cmpstr(CITSLineProfileLog,"yes")==0 )	
				Duplicate/O lineProfile2D, lineProfile2D_orig
				RemovePointsBelow(lineProfile2D,1e-12,0)
				lineProfile2D = Log(lineProfile2D)
			endif
			
			// Give the 2d line profile appropriate units (taken from image wave)
			String/G citsWXUnit= WaveUnits(citsW,0)
			String/G citsWYUnit= WaveUnits(citsW,1)
			String/G citsWZUnit= WaveUnits(citsW,2)
			String/G citsWDUnit= WaveUnits(citsW,-1)

			// Determine image size for positioning the cursors
			Variable zMin= DimOffset(citsW,2)
			Variable zMax= (DimDelta(citsW,2) * DimSize(citsW,2) + DimOffset(citsW,2))
			SetScale/I x, 0, linelength, citsWXUnit,  root:WinGlobals:$(graphName+"_2dProfile"):lineProfile2D
			SetScale/I y, zMin, zMax, citsWZUnit,  lineProfile2D
			SetScale/I d, 0, 1, citsWDUnit, lineProfile2D
			
			// Move back to 3d data DF
			SetDataFolder root:WinGlobals:$(graphName)
			
		endif		// end of 2d slice generation
			
	endif 	// end of "isNaN" checking

	//calculate angle
	Variable lineAngle, lineAngleADE, lineAngleDEB, lineAngletoNinty
	if ( numtype(hcsr(D))!=0 )
			// if D cursor is not on the graph then assume only single line profile A->B
			lineAngle = (180/pi) * atan ( (lineprofy[1] - lineprofy[0]) / (lineprofx[1] - lineprofx[0]) )
			lineAngletoNinty = 90 - lineAngle
			if ( (lineprofx[1] - lineprofx[0]) < 0 && (lineprofy[1] - lineprofy[0]) > 0 )
				lineAngle = 180 + lineAngle
				lineAngletoNinty = lineAngletoNinty-90
			endif
			if ( (lineprofx[1] - lineprofx[0]) < 0 && (lineprofy[1] - lineprofy[0]) < 0 )
				lineAngle = 180 + lineAngle
			endif
			if ( (lineprofx[1] - lineprofx[0]) > 0 && (lineprofy[1] - lineprofy[0]) < 0 )
				lineAngle = 360 + lineAngle
				lineAngletoNinty =lineAngletoNinty- 90
			endif
		else
			// HAVE NOT YET ADDED THE CALCULATION FOR ANGLES IN MULTI POINT LINE PROFILE
			// WILL DO THIS AT SOME POINT IN TEH FUTURE// Otherwise assume this is multi line profile
			lineAngleADE = (180/pi) * ( atan ( (lineprofy[2] - lineprofy[1]) / (lineprofx[2] - lineprofx[1]) ) - atan ( (lineprofy[1] - lineprofy[0]) / (lineprofx[1] - lineprofx[0]) ))
			lineAngleDEB = 0
	endif
	
	
	// Display line profile information
	if ( numtype(hcsr(D))!=0 )
		if (numtype(lineLength)==0 && numtype(lineAngle)==0)
			Print "Length=", lineLength, imgWXUnit+".  Angle=", lineAngle, "degrees."+".  90-Angle=", lineAngletoNinty, "degrees."
		endif
	else
		if (numtype(lineLength)==0 && numtype(lineAngle)==0)
			Print "TOTAL Length=", lineLength, imgWXUnit+".  Angle (ADE)= *NOT YET IMPLEMENTED*"
		endif
	endif
	
	// move back to original DF
	SetDataFolder saveDF
End




//--------------------------------------------------------------------------------------------------------------
// Update line profiles after manupulating data
Function updateLineProfile(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Check if there is an image line profile being displayed.  
	String/G lineProfileGraphName  // Load the name of the STS graph window from global variables
	String lineProfileGraphExists= WinList(lineProfileGraphName,"","WIN:1")  // check that the window (still) exists

	// Refresh graphs (if they exist)
	if ( strlen(lineProfileGraphExists)!=0 )
		doSomethingWithData("lineprofile")
	else
		KillStrings/Z lineProfileGraphName
	endif
	
	// Return to saved data folder
	SetDataFolder saveDF
	
End


//--------------------------------------------------------------------------------------------------------------
Function CursorDependencyForGraph(graphName)
	String graphName
	
	NewDataFolder/O root:WinGlobals
	NewDataFolder/O/S root:WinGlobals:$graphName
	String/G S_CursorAInfo, S_CursorBInfo, S_CursorCInfo, S_CursorDInfo, S_CursorEInfo
	Variable/G dependentA
	SetFormula dependentA, "CursorMovedForGraph(S_CursorAInfo, 0)"
	Variable/G dependentB
	SetFormula dependentB,"CursorMovedForGraph(S_CursorBInfo, 1)"
	Variable/G dependentC
	SetFormula dependentC,"CursorMovedForGraph(S_CursorCInfo, 2)"
	Variable/G dependentD
	SetFormula dependentD,"CursorMovedForGraph(S_CursorDInfo, 3)"
	Variable/G dependentE
	SetFormula dependentE,"CursorMovedForGraph(S_CursorEInfo, 4)"
End


//--------------------------------------------------------------------------------------------------------------
Function CursorMovedForGraph(info, cursNum)
	String info
	Variable cursNum // 0 if A cursor, 1 if B cursor, 2 if C cursor
	
	Variable result= NaN // error result
	
	// Check that the top graph is the one in the info string.
	String topGraph= WinName(0,1)
	String graphName= StringByKey("GRAPH", info)
	
	String df= GetDataFolder(1);
	SetDataFolder root:WinGlobals:$graphName

	if( CmpStr(graphName, topGraph) == 0 )
		String tName= StringByKey("TNAME", info)
		String xPtStr= StringByKey("POINT", info)
		String yPtStr= StringByKey("YPOINT", info)
		Variable/G xPt= str2num(xPtStr)
		Variable/G yPt= str2num(yPtStr)	
	
		Wave lineprofx, lineprofy
		// If the cursor is off the trace name will be zero length so do nothing
		if( strlen(tName) ) // cursor still on
			
			Variable xVal, yVal
			switch ( cursNum )
				
				// Cursor A has moved
				case 0:
					xVal= hcsr(A)
					yVal= vcsr(A)
					Variable/G xA= xVal
					Variable/G yA= yVal
					lineprofx[0]=xA
					lineprofy[0]=yA
					// update line profile
					makeLineProfile(graphName) 
					break
					
				//Cursor B has moved
				case 1:
					xVal= hcsr(B)
					yVal= vcsr(B)
					Variable/G xB= xVal
					Variable/G yB= yVal
					lineprofx[3]=xB
					lineprofy[3]=yB
					// update line profile
					makeLineProfile(graphName) 
					break 
				
				// Cursor D has moved
				case 3:
					xVal= hcsr(D)
					yVal= vcsr(D)
					Variable/G xD= xVal
					Variable/G yD= yVal
					lineprofx[1]=xD
					lineprofy[1]=yD
					// update line profile
					makeLineProfile(graphName) 
					break
					
				//Cursor E has moved
				case 4:
	
					xVal= hcsr(E)
					yVal= vcsr(E)
					Variable/G xE= xVal
					Variable/G yE= yVal
					lineprofx[2]=xE
					lineprofy[2]=yE
					// update line profile
					makeLineProfile(graphName) 
					break 
				
				case 2:
					
					String/G citsWFullStr
						
					// Get STS and CITS waves
					Wave stsW
					Wave citsW= $citsWFullStr
						
					// Get STS wave from the 3d data set at the appropriate point
					//stsW[]=citsW[xPt][yPt][p]
					
					// FROM HERE IS DUPLICATED FROM STS DISPLAY FUNCTION
					
					
					SVAR stsAveragingNone =  root:WinGlobals:SRSSTMControl:stsAveragingNone
					SVAR stsAveraging3x3 =  root:WinGlobals:SRSSTMControl:stsAveraging3x3
					SVAR stsAveraging5x5 =  root:WinGlobals:SRSSTMControl:stsAveraging5x5
					SVAR stsAveraging9x9 =  root:WinGlobals:SRSSTMControl:stsAveraging9x9
		
					Variable i,j
					if ( cmpstr(stsAveragingNone,"yes")==0 )
						// Get STS wave from the 3d data set at the appropriate point
						stsW[]=citsW[xPt][yPt][p]
					elseif ( cmpstr(stsAveraging3x3,"yes")==0 )
						stsW=0
						for (i=0;i<3;i+=1)
							for (j=0;j<3;j+=1)
								stsW[]=citsW[xPt-2+i][yPt-2+j][p] + stsW[p]
							endfor
						endfor
						stsW = stsW/9
					elseif ( cmpstr(stsAveraging5x5,"yes")==0 )
						stsW=0
						for (i=0;i<5;i+=1)
							for (j=0;j<5;j+=1)
								stsW[]=citsW[xPt-2+i][yPt-2+j][p] + stsW[p]
							endfor
						endfor
						stsW=stsW/25
					elseif ( cmpstr(stsAveraging9x9,"yes")==0 )
						stsW=0
						for (i=0;i<9;i+=1)
							for (j=0;j<9;j+=1)
								stsW[]=citsW[xPt-2+i][yPt-2+j][p] + stsW[p]
							endfor
						endfor
						stsW=stsW/81
					else 
						// Get STS wave from the 3d data set at the appropriate point
						stsW[]=citsW[xPt][yPt][p]
					endif
	// TO HERE				
					break
			endswitch
		endif
	endif
	SetDataFolder df
	return result
End






//--------------------------------------------------------------------------------------------------------------
Function createSRSControlVariables([forced])
	String forced
	
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	if ( ParamIsDefault (forced) )
		forced = "yes"  // this was originally "no" but I'm testing the idea of always forcing this.
	endif
	
	if ( cmpstr(forced,"yes")==0 )
		//do nothing here
		//Print "Forcing reset and recreation of global variables"
	else
	  if ( DataFolderExists("root:WinGlobals:SRSSTMControl") )
		return 1
		// do nothing and exit the function
	  endif
	endif 
	
	NewDataFolder/O root:WinGlobals
	NewDataFolder/O/S root:WinGlobals:SRSSTMControl
	
	// Create a global string that can be set to "yes" if the user wants to load all their data into a single data folder
	// e.g., if they are loading multiple STS measurements taken at the same point.
	// "yes" "no"
	String/G commonDataFolder
	if (strlen(commonDataFolder)==0)
		commonDataFolder = "no"
	endif
	
	// Whether or not to automatically display images upon loading
	// "yes" "no"
	String/G autoDisplay
	if (strlen(autoDisplay)==0)
		autoDisplay = "yes"
	endif
	
	// control autobackground options
	String/G autoBGnone
	if (strlen(autoBGnone)==0)
		autoBGnone = "no"
	endif
	// plane
	String/G autoBGplane
	if (strlen(autoBGPlane)==0)
		autoBGPlane = "yes"
	endif
	
	// linewise
	String/G autoBGlinewise
	if (strlen(autoBGlinewise)==0)
		autoBGlinewise = "no"
	endif
	
	// autoimagesave
	String/G autoSaveImage
	if (strlen(autoSaveImage)==0)
		autoSaveImage = "no"
	endif
	
	// make a toggle for automatically updating image colour range or not *CURRENTLY NOT USED*
	String/G autoUpdateImageColour
	if (strlen(autoUpdateImageColour)==0)
		autoUpdateImageColour = "yes"
	endif
	
	// make a toggle for automatically updating CITS colour range or not
	String/G autoUpdateCITSColour
	if (strlen(autoUpdateCITSColour)==0)
		autoUpdateCITSColour = "yes"
	endif
	
	// make a toggle for automatically updating CITS colour range or not
	String/G autoUpdateCITSColourExp
	if (strlen(autoUpdateCITSColourExp)==0)
		autoUpdateCITSColourExp = "no"
	endif
	
	// make a toggle for automatically updating CITS colour range or not
	String/G CITSLineProfileLog
	if (strlen(CITSLineProfileLog)==0)
		CITSLineProfileLog = "no"
	endif
	
	// make a toggle for automatically updating CITS colour range or not
	String/G autoUpdateCITSColourExp
	if (strlen(autoUpdateCITSColourExp)==0)
		autoUpdateCITSColourExp = "no"
	endif
	
	String/G syncCITS
	if (strlen(syncCITS)==0)
		syncCITS = "yes"
	endif
	
	String/G defaultImageColours
	if (strlen(defaultImageColours)==0)
		defaultImageColours = "Autumn"
	endif

	String/G coloursList
	Variable i
	String newColoursList = ""
	String colourStr, newColourStr
	Variable colourStrLen
	
	if (strlen(coloursList)==0)
		coloursList = indexedfile(SRSctab,-1,".ibw")
		i=0
		coloursList = indexedfile(SRSctab,-1,".ibw")
		Do 
			colourStr = StringFromList(i,coloursList)
			colourStrLen = strlen(colourStr)
			if (colourStrLen < 1)
				Break
			endif
			newColourStr = colourStr[0,colourStrLen-5]
			//Print i, colourStr, colourStrLen, newColourStr
			newColoursList = AddListItem(newColourStr,newColoursList,";",0)
			i += 1
		While ( colourStrLen > 0 )
		coloursList=""
		i=0
		// reverse the order of the list.  
		Do 
			colourStr = StringFromList(i,NewColoursList)
			colourStrLen = strlen(colourStr)
			if (colourStrLen < 1)
				Break
			endif
			coloursList = AddListItem(colourStr,ColoursList)
			i += 1
		While ( colourStrLen > 0 )
		
		
		
		
		//coloursList = "Autumn"
		//coloursList = coloursList+";BlueExp;Blue2;SRSBlue;SRSBlue2"
		//coloursList = coloursList+";SRSBBR;SRSBBY"
		//coloursList = coloursList+";BlueBlackYellow"
		//coloursList = coloursList+";Defect1;Defect2"
		//coloursList = coloursList+";GoldOrange;PinkScale;Bicolor;Grasshopper;Red2;Expfast1;GrayBinary1;Rust"
		//coloursList = coloursList+"Expfast2;GrayBinary2;Sailing;Expmult1;GrayBinary3;Strawberry;BlueLog;Expmult2"
		//coloursList = coloursList+";GrayExp;Sunset;BlueRedGreen2"
		//coloursList = coloursList+";Expmult3;Green2;Thunderbolt;BlueRedGreen3;Expmult4;Green3;Titanium"
	endif
	
	// this variable can be set to control whether or not STS extracted from CITS are averaged with neighbours
	String/G stsAveragingNone = "yes"
	String/G stsAveraging3x3 = "no"
	String/G stsAveraging5x5 = "no"
	String/G stsAveraging9x9= "no"
	
	// set a width for line profiles
	Variable/G lineProfileWidth
	if (lineProfileWidth<=1)
		lineProfileWidth = 1
	endif

	
	// set a low current limit for producing normalised differential conductance
	Variable/G normConductLim
	if (normConductLim==0)
		normConductLim=1e-12
	endif
	
	
	// set a low current limit for producing normalised differential conductance
	Variable/G CITSKappa
	if (CITSKappa==0)
		CITSKappa=1e10
	endif

	SetDataFolder saveDF
End



//--------------------------------------------------------------------------------------------------------------
// PLANE SUBTRACT
Function subtractPlane(graphname,[ROI])
	String graphname, ROI 
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	
	// Create name of ROI wave
	String imgWROIStr= graphName+"_ROI_W"
	
	if ( ParamIsDefault(ROI) )  // plane subtract the entire image
	
		// Create a Region of Interest (ROI) wave that covers the entire image
		Duplicate/O imgW, $imgWROIStr
		Wave imgWROI= $imgWROIStr
		imgWROI=1
	else
		if ( cmpstr(ROI,"yes")==0 )  // plane subtract using ROI wave
		
			// Drawing tools
			SetDrawLayer/W=$graphName ProgFront
				
			ImageGenerateROIMask/W=$graphName $imgWStr
			
			if ( WaveExists(imgWROI)==0 )
			
				Duplicate/O M_ROIMask $imgWROIStr
				KillWaves/Z M_ROIMask
			
				Wave imgWROI= $imgWROIStr
				
			endif 
			
			// Drawing tools
			SetDrawLayer/W=$graphName UserFront
			
			// Drawing tools
			HideTools/W=$graphName 
			
		endif 
	endif
	
	
	if ( WaveExists(imgWROI)!=0 )  // Don't do anything unless a ROI exists (either for the entire image or a user drawn ROI)
	
		Redimension/B/U imgWROI 			

		WaveStats/Q imgW
		Variable rawImgAvg = V_avg
		// Use in-built Igor function for plane removal
		ImageRemoveBackground /O/R=imgWROI/P=1 imgW
		imgW = imgW + rawImgAvg
		
		// Use in-built Igor function for plane removal
		//ImageRemoveBackground /O/R=imgWROI/P=1 imgW
		
	else
		Print "Warning: no background substraction performed.  Missing ROI wave?"
	
	endif 
	
	// Clean up
	KillWaves/Z imgWROI
	
	// Return to saved data folder
	SetDataFolder saveDF
End


//--------------------------------------------------------------------------------------------------------------
// ROI SUBTRACT
Function subtractROI(graphname,inverse)
	String graphname, inverse
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	
	// Create name of ROI wave
	String imgWROIStr= graphName+"_ROI_W"

	// IF THE WAVE IS COMPLEX DO THE FOLLOWING  (CAN FIND OUT IF WAVE IS COMPLEX USING WAVEINFO - odd values of NUMTYPE mean complex wave.  Add this in later)
		
	// Drawing tools
	SetDrawLayer/W=$graphName ProgFront
	If ( cmpstr(inverse,"yes")==0 ) // make inverse ROI		
		ImageGenerateROIMask/e=1/i=0/W=$graphName $imgWStr
	else // make normal ROI
		ImageGenerateROIMask/W=$graphName $imgWStr
	endif
	
	Redimension/C M_ROIMask	
	Duplicate/C/O M_ROIMask $imgWROIStr
	Wave imgWROI = $imgWROIStr
	KillWaves/Z M_ROIMask
		
	// Drawing tools
	SetDrawLayer/W=$graphName UserFront
			
	// Drawing tools
	HideTools/W=$graphName 
	
	SetDataFolder imgDF
	
	// Create name of ROI subtracted wave
	String imgWROISubStr= imgWStr+"R"

		
	// Duplicate data
	Duplicate/O/C imgW, $imgWROISubStr
	Wave/C imgWROISub = $imgWROISubStr
	imgWROISub = imgW * imgWROI

	
	
//	if ( WaveExists(imgWROI)!=0 )  // Don't do anything unless a ROI exists (either for the entire image or a user drawn ROI)
	
//		Redimension/B/U imgWROI 			

//	else
//		Print "Warning: Missing ROI wave?"
	
//	endif 
	
	// Clean up
//	KillWaves/Z imgWROI
	
	// Return to saved data folder
	//SetDataFolder saveDF
End


//--------------------------------------------------------------------------------------------------------------
// zero
Function subtractMin(graphname,[mintype])
	String graphname, mintype
	
	If (paramisdefault(mintype) )
		mintype = "min"
	elseif ( cmpstr(mintype,"mean")!=0 )
		mintype = "min"
	endif
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	
	Variable minVal
	
	if ( cmpstr(mintype,"mean")==0 )
		WaveStats imgW 
		minVal= V_Avg
	else 
		minVal= WaveMin(imgW)
	endif
	
	imgW= imgW - minVal

	// Return to saved data folder
	SetDataFolder saveDF
End

	
//--------------------------------------------------------------------------------------------------------------
// shiftImageZ
Function shiftImageZ(graphname,shift)
	String graphname
	Variable shift
		
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save

	if ( cmpstr(graphname,"")==0 )
		// Get name of top graph
		graphName= WinName(0,1)
	endif
		
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	
	imgW= imgW - shift

	// Return to saved data folder
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------------------------------
// User dialogue for manually setting the colour range
Function shiftImageZDialogue(graphName)
	String graphName
	Variable shift=0
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// If graphName not given (i.e., ""), then get name of the top graph window
	if ( strlen(graphName)==0 )
			graphName= WinName(0,1)
	endif
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	
	Prompt shift, "Shift value: " // 
	DoPrompt "Shift image Z", shift

	if (V_Flag)
      	Print "Warning: User cancelled dialogue"
      	return -1                     // User canceled
      else // 
      	     		
     		Print "shiftImageZ(\""+graphName+"\","+num2str(shift)+")"
      	shiftImageZ(graphName,shift)
      	
   	endif
	
	// Move back to original DF
	SetDataFolder saveDF
End


	
//--------------------------------------------------------------------------------------------------------------
// LINEWISE BACKGROUND SUBTRACT
Function subtractLinewise(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr

	Variable xPts = DimSize(imgW,0)
	Variable yPts = DimSize(imgW,1)
	
	KillWaves/Z lineWave
	Make/O/N=(xPts) lineWave
	Duplicate/O lineWave, linefitWave
	
	Variable i=0
	for (i=0; i<yPts; i+=1)
		lineWave  = imgW[p][i]
		// check that data exists and if so do the fit and subtract, if not do nothing
		if ( numtype(sum(lineWave))==0 )
			CurveFit/N/Q/NTHR=0 line  lineWave /D=linefitWave
			lineWave=lineWave - linefitWave
			imgW[][i] = lineWave[p]
		endif
	endfor

	// Clean up
	KillWaves/Z lineWave, linefitWave, W_coef, W_sigma
	
	// Return to saved data folder
	SetDataFolder saveDF
End


//--------------------------------------------------------------------------------------------------------------
Function dispSTSfromCITS(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDFSTSfromCITS = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
//	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	String/G citsDF
	String/G citsWStr
	String/G citsWFullStr
//	String/G citsImgW
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	Wave citsW= $citsWFullStr

	// Determine image size for positioning the cursors and for dimensionaing the STS wave
	Variable xMin= DimOffset(imgW,0)
	Variable xMax= (DimDelta(imgW,0) * DimSize(imgW,0) + DimOffset(imgW,0))
	Variable yMin= DimOffset(imgW,1)
	Variable yMax= (DimDelta(imgW,1) * DimSize(citsW,1) + DimOffset(imgW,1))
	Variable zMin= DimOffset(citsW,2)
	Variable zMax= (DimDelta(citsW,2) * DimSize(citsW,2) + DimOffset(citsW,2))
	Variable xRange = xMax - xMin
	Variable yRange = yMax - yMin
	
	// Calculate cursor position
	Variable cursX= xMin + (0.5 * xRange)
	Variable cursY= yMin + (0.5 * yRange)
	
	// Place the Cursor on Image (unless it is already there)
	if (strlen(CsrInfo(C))==0)
		Cursor/I/s=2/c=(65535,65535,65535) C, $imgWStr, cursX, cursY
	endif 
	
	// Create a new graph to display the STS
	String/G STSgraphname= graphName+"_STS"
	DoWindow/K $STSgraphname

	// Create a new blank graph window
	Display/k=1/N=$STSgraphname 
	AutoPositionWindow/E/m=1
	
	// Load the size of the lineProfile2dGraphName dimension (this was computed and saved as a global variable in the image display function)
	Variable/G zSize
	
	//Make a new wave to store a single STS curve in
	Make/O/N=(zSize) stsW
	
	// Load the cursor x and y position from already saved global variables
	Variable/G xPt
	Variable/G yPt
	
	SVAR stsAveragingNone =  root:WinGlobals:SRSSTMControl:stsAveragingNone
	SVAR stsAveraging3x3 =  root:WinGlobals:SRSSTMControl:stsAveraging3x3
	SVAR stsAveraging5x5 =  root:WinGlobals:SRSSTMControl:stsAveraging5x5
	SVAR stsAveraging9x9 =  root:WinGlobals:SRSSTMControl:stsAveraging9x9
	
	Variable i,j
	if ( cmpstr(stsAveragingNone,"yes")==0 )
		// Get STS wave from the 3d data set at the appropriate point
		stsW[]=citsW[xPt][yPt][p]
	elseif ( cmpstr(stsAveraging3x3,"yes")==0 )
		stsW=0
		for (i=0;i<3;i+=1)
			for (j=0;j<3;j+=1)
				stsW[]=citsW[xPt-2+i][yPt-2+j][p] + stsW[p]
			endfor
		endfor
		stsW = stsW/9
	elseif ( cmpstr(stsAveraging5x5,"yes")==0 )
		stsW=0
		for (i=0;i<5;i+=1)
			for (j=0;j<5;j+=1)
				stsW[]=citsW[xPt-2+i][yPt-2+j][p] + stsW[p]
			endfor
		endfor
		stsW=stsW/25
	elseif ( cmpstr(stsAveraging9x9,"yes")==0 )
		stsW=0
		for (i=0;i<9;i+=1)
			for (j=0;j<9;j+=1)
				stsW[]=citsW[xPt-2+i][yPt-2+j][p] + stsW[p]
			endfor
		endfor
		stsW=stsW/81
	else 
		// Get STS wave from the 3d data set at the appropriate point
		stsW[]=citsW[xPt][yPt][p]
	endif

	// Give the line profile appropriate units.  These units were saved in global variables in the image display function
	String/G citsWZUnit   //= WaveUnits(citsW,2)
	String/G citsWDUnit   //= WaveUnits(citsW,-1)

	SetScale/I x, zMin, zMax, citsWZUnit, stsW
	SetScale/I d, 0, 1, citsWDUnit, stsW

	AppendToGraph stsW
	
	// Return to saved data folder
	SetDataFolder saveDFSTSfromCITS
	
	DoWindow/F $graphname
End


//--------------------------------------------------------------------------------------------------------------
Function dispSTSfromCITSROI(graphname,[all])
	String graphname
	String all
	
	If ( paramisdefault(all) )
		all = "no"
	endif
	
	// Get current data folder
	DFREF saveDFSTSfromCITS = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
//	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	String/G citsDF
	String/G citsWStr
	String/G citsWFullStr
//	String/G citsImgW
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	Wave citsW= $citsWFullStr
	
	// Create name of ROI wave
	String imgWROIStr= graphName+"_ROI_W"
		
	// Drawing tools
	SetDrawLayer/W=$graphName ProgFront
				
	ImageGenerateROIMask/W=$graphName $imgWStr
			
	if ( WaveExists(imgWROI)==0 )
		Duplicate/O M_ROIMask $imgWROIStr
		KillWaves/Z M_ROIMask
		Wave imgWROI= $imgWROIStr
	endif 
			
	// Drawing tools
	SetDrawLayer/W=$graphName UserFront
			
	// Drawing tools
	HideTools/W=$graphName 
			
	Redimension/B/U imgWROI 			

	// Duplicate the CITS data into the WinGlobals directory
	Duplicate/O citsW, citsROIonlyW
	
	Variable xNum = DimSize(citsROIonlyW,0)
	Variable yNum = DimSize(citsROIonlyW,1)
	Variable zNum = DimSize(citsROIonlyW,2)
	
	Variable i
	// if all != yes then set STS outside ROI to zero.
	if ( cmpstr (all, "yes") == 0 )
		// do nothing
	else
		for (i=0;i<zNum;i+=1)
			citsROIonlyW[][][i] = citsROIonlyW[p][q][i] * imgWROI[p][q]
		endfor
	endif
	
	// Determine image size 
	Variable xMin= DimOffset(imgW,0)
	Variable xMax= (DimDelta(imgW,0) * DimSize(imgW,0) + DimOffset(imgW,0))
	Variable yMin= DimOffset(imgW,1)
	Variable yMax= (DimDelta(imgW,1) * DimSize(citsW,1) + DimOffset(imgW,1))
	Variable zMin= DimOffset(citsW,2)
	Variable zMax= (DimDelta(citsW,2) * DimSize(citsW,2) + DimOffset(citsW,2))

	// Create a new graph to display the STS
	String/G STSgraphname= graphName+"_STS"
	DoWindow/K $STSgraphname

	// Create a new blank graph window
	Display/k=1/N=$STSgraphname 
	AutoPositionWindow/E/m=1
	
	// Load the size of the lineProfile2dGraphName dimension (this was computed and saved as a global variable in the image display function)
	Variable/G zSize
	
	//Make a new wave to store a single STS curve in
	Make/O/N=(zSize) stsROIW
	Make/O/N=(zSize) stsROIWtmp
	stsROIW = 0
	
	// Sum all of the waves in the cits into one
	Variable j, c, s
	for (i=0;i<xNum;i+=1)
		for (j=0;j<yNum;j+=1)
			stsROIWtmp[] = citsROIonlyW[i][j][p]
			stsROIWtmp = abs(stsROIWtmp)
			s = sum(stsROIWtmp)
			if ( s > 0 ) 
				stsROIW =  citsROIonlyW[i][j][p] + stsROIW
				c += 1
			endif
		endfor
	endfor
	stsROIW = stsROIW/c
	Print "STS sum of",c,"CITS data points"

	KillWaves stsROIWtmp
	
	// Give the line profile appropriate units.  These units were saved in global variables in the image display function
	String/G citsWZUnit   //= WaveUnits(citsW,2)
	String/G citsWDUnit   //= WaveUnits(citsW,-1)

	SetScale/I x, zMin, zMax, citsWZUnit, stsROIW
	SetScale/I d, 0, 1, citsWDUnit, stsROIW

	AppendToGraph stsROIW
	
	// Display the ROI that was applied
	Display/k=1/N=$imgWROIStr 
	imgDisplay(imgWROIStr)
	
	// Return to saved data folder
	SetDataFolder saveDFSTSfromCITS
End

//--------------------------------------------------------------------------------------------------------------
// Create a backup wave in new data folder
Function backupData(graphname,suffixStr)
	String graphname, suffixStr
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName 
	
	// Check that the image displayed has an associated 3d dataset.  The image must have been displayed with the SRS macros that generate the appropriate global variables
	//If it does then we will save the 3d wave, rather than the 2d wave. 
	if (WaveExists(citsImgW)==1)  // 3d data
	
		// Get the global variable for the 3d wave
		String/G citsDF		// data folder
		String/G citsWStr
		String/G citsWFullStr		// data folder plus wave name

//		String/G databackupDF = citsDF+PossiblyQuoteName(citsWStr)
//		NewDataFolder/O $databackupDF
//		String/G backupDataStr= databackupDF+":"+PossiblyQuoteName(citsWStr)
//		Duplicate/O $citsWFullStr $backupDataStr	
		
		String newcitsWStr = citsWStr+suffixStr
		SetDataFolder $citsDF
		Duplicate/O $citsWStr, $newcitsWStr
//		KillWaves/Z 	$newcitsWStr
		
		// Update global variables
		citsWStr= newcitsWStr
		citsWFullStr= citsDF+PossiblyQuoteName(citsWStr)
		
	else // 2d data
		
		// Get the global variable for this graph (these were set in the manipulateData procedure)
		String/G imgDF		// data folder plus wave name
		String/G imgWStr
		String/G imgWFullStr		// data folder plus wave name
		
		// Make a new DF to store a copy of the original data
//		String/G databackupDF = imgDF+PossiblyQuoteName(imgWStr)
//		NewDataFolder/O $databackupDF
//		String/G backupDataStr= databackupDF+":"+PossiblyQuoteName(imgWStr)
//		Duplicate/O $imgWFullStr $backupDataStr
		
		String newimgWStr = imgWStr+suffixStr
		SetDataFolder $imgDF
		Duplicate/O $imgWFullStr, $newimgWStr
		
		KillWindow $graphname
		//KillWaves/Z $imgWFullStr
		
		imgDisplay(newimgWStr)
		
		// Update global variables
		imgWStr= newimgWStr
		imgWFullStr= imgDF+PossiblyQuoteName(imgWStr)
		
	endif
	
	SetDataFolder saveDF

End
	

//--------------------------------------------------------------------------------------------------------------
// Create a copy of image data to root:ImageData
Function copyImageData(graphname,suffixStr)
	String graphname, suffixStr
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName 
	
	// Check that the image displayed has an associated 3d dataset.  The image must have been displayed with the SRS macros that generate the appropriate global variables
	//If it does then we will save the 3d wave, rather than the 2d wave. 
	
	
	// 2d data
		
		// Get the global variable for this graph (these were set in the manipulateData procedure)
		String/G imgDF		// data folder plus wave name
		String/G imgWStr
		String/G imgWFullStr		// data folder plus wave name
		
		// Make a new DF to store a copy of the original data
		String/G databackupDF = "root:imageData"
		NewDataFolder/O $databackupDF
		String/G backupDataStr= databackupDF+":"+PossiblyQuoteName(imgWStr)
		Duplicate/O $imgWFullStr $backupDataStr
			
	SetDataFolder saveDF

End
	




//--------------------------------------------------------------------------------------------------------------
// Differentiate a 3d data set with respect to its z coordinate
Function manipulateCITS(graphname,action)
	String graphname, action
	// action= "differentiate"
	// action= "smoothZ"
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save

	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName 
	
	// Check that the image displayed has an associated 3d dataset.  The image must have been displayed with the SRS macros that generate the appropriate global variables
	//If it does then we will save the 3d wave, rather than the 2d wave. 
	if (WaveExists(citsImgW)==1)  // 3d data
		
		// Load the global variables 
		String/G citsDF
		String/G citsWStr
		String/G citsWFullStr
		
		// get x and y pixel sizes
		Variable/G xSize
		Variable/G ySize
		// get number of slices
		Variable/G zSize
		
		// used in loops		
		Variable i
		
		String imgWFullStr
		String imgWStr
		String imgDF
		
		String wList
		Variable wNum
		
		Variable kappa = 0
		
		// make wave assignment to the 3d data set
		Wave citsW = $citsWFullStr
		
		Variable wLength, xLength, yLength, startV, deltaV, bias, current
		Variable xx,yy,jj
		
		strswitch ( action )
			case "differentiate":
			
				// Use in built Igor routine to differentiate the 3d data set with respect to its z axis
				Differentiate/DIM=2 citsW
		
				// Give the line profile appropriate units (taken from image wave)
				String/G waveDUnit= WaveUnits(citsW,-1)
				if (cmpstr(waveDUnit,"A")==0)
					// original data in A, so differentiated data in S
					SetScale/I d, 0, 1, "S",  citsW
				else
					Print "Warning: Do not know what units to assign to differentiated data"
					SetScale/I d, 0, 1, "",  citsW
				endif
				
				// Refresh 3D data windows
				refresh3dData(graphName)
				break
				
			case "differentiateNormalised":
		
				Duplicate citsW, citsWDiff
				Duplicate citsW, citsWNorm
				
				// Use in built Igor routine to differentiate the 3d data set with respect to its z axis
				Differentiate/DIM=2 citsWDiff
		
				NVAR normConductLim = root:WinGlobals:SRSSTMControl:normConductLim

				wLength =  DimSize(citsW,2)
				xLength =  DimSize(citsW,0)
				yLength =  DimSize(citsW,1)
				startV =  DimOffset(citsW,2)
				deltaV =  DimDelta(citsW,2)
								
				for (xx=0;xx<xLength;xx+=1)
					for (yy=0;yy<yLength;yy+=1)
						for (jj=0;jj<wLength;jj+=1)
							current = citsW[xx][yy][jj]
							bias = startV+jj*deltaV
							citsWNorm[xx][yy][jj] = current/bias
							if ( Abs(citsW[xx][yy][jj]) < normConductLim )
								citsW[xx][yy][jj] = 0
							else
								citsW[xx][yy][jj] = citsWDiff[xx][yy][jj]/citsWNorm[xx][yy][jj]
							endif
						endfor	
					endfor
				endfor
						
				// Give the line profile appropriate units (taken from image wave)
				String/G waveDUnit= WaveUnits(citsW,-1)
				if (cmpstr(waveDUnit,"A")==0)
					// original data in A, so differentiated data in S
					SetScale/I d, 0, 1, "S",  citsW
				else
					Print "Warning: Do not know what units to assign to differentiated data"
					SetScale/I d, 0, 1, "",  citsW
				endif
				
				// Refresh 3D data windows
				refresh3dData(graphName)
				break
				
			case "topCor":
				
				// First choose a 2D image file for the topography
				SetDataFolder citsDF
				imgDF = citsDF
				
				// List (2D) waves in current data folder
				wList =  WaveList("*",";","DIMS:2") 
				wNum = ItemsInList(wList)
	
				if (wNum!=0)  // check that at least one 2D or 3D data set exists 
	
					// Ask user which image they want to work with if there is more than one wave in the data folder
					// otherwise choose the single wave as the one to use	
					if (wNum>1)
						imgWStr= imgChooseDialog(wList,wNum)  // returns the image name, or "none" if user cancels
					else
						imgWStr= StringFromList(0,wList,";")  // if there is only one image file don't bother asking the user
					endif
		
					if (cmpstr(imgWStr,"none") != 0)  // check user did not cancel before proceeding
						imgWFullStr= imgDF+PossiblyQuoteName(imgWStr)
	
						// Create Wave assignment for image
						Wave imgW= $imgWFullStr

						// Display the data
						if (WaveDims(imgW)<3)
							// if a 2D wave then do the following
							imgDisplay(imgWStr)
						else
							// if a 3D wave then do the following
							img3dDisplay(imgWStr)
						endif
					else  // user cancelled
						Print "Image display cancelled by user" 
						break
					endif
				else
					Print "Error: no 2D or 3D image data found in the current data folder"
					break
				endif
				
				SetDataFolder root:WinGlobals:$graphName 

				Duplicate/O citsW, citsWOrig
		
				NVAR CITSKappa = root:WinGlobals:SRSSTMControl:CITSKappa
				kappa = CITSKappa
				
				wLength =  DimSize(citsW,2)
				xLength =  DimSize(citsW,0)
				yLength =  DimSize(citsW,1)

				for (xx=0;xx<xLength;xx+=1)
					for (yy=0;yy<yLength;yy+=1)
						for (jj=0;jj<wLength;jj+=1)
							citsW[xx][yy][jj] =  citsWOrig[xx][yy][jj] / Exp(-2 * kappa * imgW[xx][yy])
						endfor
					endfor
				endfor
				
				// Refresh 3D data windows
				refresh3dData(graphName)
				break
			
			case "topCordeltaz":
				
				// First choose a 2D image file for the topography
				SetDataFolder citsDF
				imgDF = citsDF
				
				// List (2D) waves in current data folder
				wList =  WaveList("*",";","DIMS:2") 
				wNum = ItemsInList(wList)
	
				if (wNum!=0)  // check that at least one 2D or 3D data set exists 
	
					// Ask user which image they want to work with if there is more than one wave in the data folder
					// otherwise choose the single wave as the one to use	
					if (wNum>1)
						imgWStr= imgChooseDialog(wList,wNum)  // returns the image name, or "none" if user cancels
					else
						imgWStr= StringFromList(0,wList,";")  // if there is only one image file don't bother asking the user
					endif
		
					if (cmpstr(imgWStr,"none") != 0)  // check user did not cancel before proceeding
						imgWFullStr= imgDF+PossiblyQuoteName(imgWStr)
	
						// Create Wave assignment for image
						Wave imgW= $imgWFullStr

						// Display the data
						if (WaveDims(imgW)<3)
							// if a 2D wave then do the following
							imgDisplay(imgWStr)
							Duplicate/O imgW, kappaW
						else
							// if a 3D wave then do the following
							img3dDisplay(imgWStr)
						endif
					else  // user cancelled
						Print "Image display cancelled by user" 
						break
					endif
				else
					Print "Error: no 2D or 3D image data found in the current data folder"
					break
				endif
				
				SetDataFolder root:WinGlobals:$graphName 
				
				Duplicate/O citsW, citsWOrig
		
				wLength =  DimSize(citsW,2)
				xLength =  DimSize(citsW,0)
				yLength =  DimSize(citsW,1)
				
				// get the default image set point from image note
				String imgInfoFromNote = note(imgW)
				String setpointStr = StringByKey("Setpoint",imgInfoFromNote)
				
				Variable currentsetpoint=str2num(setpointStr)
				Variable deltaz=50e-12
				Prompt currentsetpoint, "Image current set point (in Amps)"
				Prompt deltaz, "Delta z applied during CITS acquisition (in metres)"
				DoPrompt "Image set point current and delta z value", currentsetpoint, deltaz
		
// bug in this for loop
//				for (xx=0;xx<xLength;xx+=1)
//					for (yy=0;yy<yLength;yy+=1)
//						for (jj=0;jj<wLength;jj+=1)
//							kappa = (ln(Abs(citsW[xx][yy][0])) - ln(currentsetpoint))/deltaz
//							kappaW[xx][yy] = kappa
//							citsW[xx][yy][jj] =  citsWOrig[xx][yy][jj] / Exp(-2 * kappa * imgW[xx][yy])
//						endfor
//					endfor
//				endfor


// Manuel's replacement for loop:
				for (xx=0;xx<xLength;xx+=1)
					for (yy=0;yy<yLength;yy+=1)
						kappa = ( ln(currentsetpoint) - ln( Abs(citsWOrig[xx][yy][0]) )) /(2*deltaz) //ln(regulation) - ln(current at start of I(V)) -> becomes negative and hence deltaz can be enterred negatively, as it was, too
						//[xx][yy][0] -> zero doesn't make a difference in kappa-map
						kappaW[xx][yy] = kappa
							for (jj=0;jj<wLength;jj+=1)
								//kappa = (ln Ê Ê( Abs(citsW[xx][yy][0]) ) - ln(currentsetpoint)) Ê Ê /deltaz
								//kappa = ( ln(currentsetpoint) - ln( Abs(citsWOrig[xx][yy][0]) )) Ê Ê /deltaz //ln(regulation) - ln(current at start of I(V)) -> becomes negative and hence deltaz can be enterred negatively, as it was, too
								// If in line above 'Abs(citsW)' is taken, then the kappaW wave changes with changing deltaz +- imgW[xx][yy]
								//kappaW[xx][yy] = kappa
								//citsW[xx][yy][jj] = ÊcitsWOrig[xx][yy][jj] / Exp(2 * kappa * imgW[xx][yy])
								citsW[xx][yy][jj] = citsWOrig[xx][yy][jj] * Exp(2 * kappa * imgW[xx][yy])
								//citsW[xx][yy][jj] = ÊcitsWOrig[xx][yy][jj] * Exp(2 * kappa * (deltaz - imgW[xx][yy]))
							endfor
					endfor
				endfor

				
				// Refresh 3D data windows
				refresh3dData(graphName)
				break
				
			case "smoothZ":
			
				// Prompt user for smoothing factor
				Variable smthfactor=5
				Prompt smthfactor, "Enter smoothing factor: " 
				DoPrompt "Smoothing factor", smthfactor
				if (V_Flag)
 					Print "Warning: User cancelled 'smooth CITS'"                          // User canceled
  				else			 			
					Smooth/B/DIM=2/E=3 smthfactor, citsW
				endif
				
				// Refresh 3D data windows
				refresh3dData(graphName)
				
				break
				
			case "FFTCITS":

				String/G citsFFTrWStr = citsWStr+"Fr"
				//String/G citsFFTcWStr = citsWStr+"Fc"
				
				// Move to the data data folder to duplicate the 
				SetDataFolder citsDF

				// Calculate the FFT slice by slice. 		
				Duplicate/O citsW, $citsFFTrWStr
				Wave FFTcitsW = $citsFFTrWStr
				Redimension/C citsW
				Make/O/C/N=(xSize,ySize) citsSliceTmp
				Make/O/N=(xSize,ySize) FFTSliceTmp
				for (i=0; i<zSize;i+=1)
					citsSliceTmp[][] = citsW[p][q][i]
					FFT/MAG/DEST=FFTSliceTmp citsSliceTmp
					FFTcitsW[][][i]=FFTSliceTmp[p][q]
				endfor
				
				Note/NOCR FFTcitsW, "3Dtype:CITSFFT;"
				
				// Change the original CITS wave back to real
				Redimension/R citsW
				
				// Copy wave scaling
				Variable startcitsV = DimOffset(citsW,2)
				Variable deltacitsV = DimDelta(citsW,2)

				SetScale/P z, startcitsV, deltacitsV, FFTcitsW
				
				// Display the resulting FFT wave.		
				img3dDisplay(citsFFTrWStr)
				updateColourRangeByHist("",type="exp")
				
				// Move to the data folder containing the global variables for the graph
				SetDataFolder root:WinGlobals:$graphName 
				
				break
				
			case "extractImages":
				
				// get currently displayed slice number
				Variable/G citsZvar
				
				// make a new data folder if it doesn't already exist and move there
				NewDataFolder/O root:CITSImageSlices
				SetDataFolder root:CITSImageSlices
				
				for (i=0; i<zSize; i+=1)
					// make image name
					String CITSimageName = citsWStr+"_"+num2str(i)
					
					Make/O/N=(xSize,ySize) $CITSimageName
					Wave myImage = $CITSimageName
					myImage[][] = citsW[p][q][i]
				
				endfor
				
				// move back to image info DF
				SetDataFolder root:WinGlobals:$graphName 
				
// SHOULD ADD units and dimensions here *************

				
				
				break
			case "extractImage":
				
				// get x and y pixel sizes
				Variable/G xSize
				Variable/G ySize
				
				// get number of slices
				Variable/G zSize
				
				// get currently displayed slice number
				Variable/G citsZvar
				
				// make a new data folder if it doesn't already exist and move there
				NewDataFolder/O root:CITSImageSlices
				SetDataFolder root:CITSImageSlices
				
				// make image name
				String CITSimgName = citsWStr+"-"+num2str(citsZvar)
					
				Make/O/N=(xSize,ySize) $CITSimgName
				Wave myImage = $CITSimgName
				myImage[][] = citsW[p][q][citsZvar]
				
				
				// move back to image info DF
				SetDataFolder root:WinGlobals:$graphName 
				
// SHOULD ADD units and dimensions here *************

				
				
				break
				
			default:
				Print "Don't know what you want to do with this data"
				break
		endswitch
			
	else // 2d data
		Print "Error: this is not a 3d data set, or it was not displayed using the img3dDisplay(imgWStr) function of the SRS-STM macros"
	endif
	
	
	// Return to original data folder
	SetDataFolder saveDF

End


//-----------------------------------------
Function refresh3dData(graphName)
	String graphName
		
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName 
		
	// Load the global variables 
	String/G citsDF
	String/G citsWStr
	
	// Check if there is point spectra being displayed.  
	String/G STSgraphname  // Load the name of the STS graph window from global variables
	String STSpointGraphExists= WinList(STSgraphname,"","WIN:1")  // check that the window (still) exists

	// Check if there is point spectra being displayed.  
	String/G lineProfileGraphName
	String lineProfileGraphExists= WinList(lineProfileGraphName,"","WIN:1")  // check that the window (still) exists

	// Kill the window that has the original data and the display the differentiated data
	KillWindow $graphName
	SetDataFolder citsDF
	img3dDisplay(citsWStr)
	
	if ( strlen(lineProfileGraphExists)!=0)
		DoWindow/F $graphName //bring the graph containing the data to the front
		lineProfile(graphName)
	endif
	
	// Refresh point spectra graph (if it exists)
	if ( strlen(STSpointGraphExists)!=0 )
		DoWindow/F $graphName //bring the graph containing the data to the front
		dispSTSfromCITS(graphName)
	endif
	
	// Refresh line profile graph (if it exists)
	
	// Return to saved DF
	SetDataFolder saveDF
	
End


//-----------------------------------------------------------
// matrix convolution for 2d or 3d data
Function matrixConvolveData(graphName)
	String graphName

	// If graphName not given (i.e., ""), then get name of the top graph window
	if ( strlen(graphName)==0 )
		graphName= WinName(0,1)
	endif
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save DF
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName
		
	// Get information about the image wave
	String/G imgWStr
	String/G imgDF
	String/G imgWFullStr

	// create a variable for the dimensions of the data
	Variable dim=-1
	
	// Check that the image displayed has an associated 3d dataset.  The image must have been displayed with the SRS macros that generate the appropriate global variables
	//If it does then we will work with a 3d wave, otherwise 2d 
	if (WaveExists(citsImgW)==1)  // 3d data
		
		// Load the global variables 
		String/G citsDF
		String/G citsWStr
		String/G citsWFullStr
		
		// make wave assignment to the 3d data set
		Wave dataW = $citsWFullStr
		
		// set the dimension variable
		dim=3
	
	else // 2d wave

		// make wave assignment to the 2d image wave
		Wave dataW = $imgWFullStr	
			
		// set the dimension variable
		dim=2
	
	endif
	
	Variable V_Flag
	// Make the kernel for the manipulation
	V_Flag = makeKernel(graphName,dim)
	
	if (V_Flag == -1)
		return -1
	endif
	
	// Convert the data to single precision floating point
	Redimension/S dataW // to avoid integer truncation
	
	// Use built in Igor function for matric convolution
	MatrixConvolve sKernel dataW  // creates new wave M_Convolution
	Wave convolvedW= M_Convolution

	if (WaveExists(citsImgW)==1)  // 3d data
		// copy the data to the appropriate place
		dataW= convolvedW
		KillWaves/Z M_Convolution
		// refresh the data displays
		refresh3dData(graphName)
	else
		// rescale colour of image
		DoWindow/F $graphName
		updateColourRange("")
	endif
	
	// return to DF	
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------
Function makeKernel(graphName,dim)
	String graphName
	Variable dim
	Variable normalisation
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save DF
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName
	
	// set default parameters
	Variable kernelSize=5
	Variable kernelParam=1
	String kernelName = "Gaussian Smooth"
	
	// Get input from user
	Prompt kernelSize, "Please enter side length, n, of the (nxn) kernel: " 
	Prompt kernelName,"Kernel type: ",popup,"Gaussian Smooth;Laplacian (3x3);Laplacian (5x5);Laplacian (7x7);none"
	
	// Ask user what kernel to use
	DoPrompt "Make kernel", kernelName
	
	 // User canceled so quit
	if (V_Flag)
		Print "Warning: User cancelled"         
		return -1
	endif 
	
	 // User selected "none", so quit
	if ( cmpstr(kernelName,"none")==0 )
		Print "Warning: User cancelled"         
		return -1
	endif 
	
	// define min/max x and y axes for calculating kernel function
	Variable limitXYZ = (kernelSize-1)/2
	
	// make the kernel
	StrSwitch( kernelName )
		case "Gaussian Smooth":
			// ask for gaussian sharpness
			Prompt kernelParam, "Enter c for Exp[-x^2/(2c^2)]" 
			DoPrompt "Gaussian kernel parameters", kernelSize, kernelParam
			
			 // User canceled so quit
			if (V_Flag)
				Print "Warning: User cancelled"         
				return -1
			endif 
	
			// make a 2D kernel
			Make/O/N=(kernelSize,kernelSize) sKernel 
			SetScale/I x -limitXYZ,limitXYZ,"", sKernel
			SetScale/I y -limitXYZ,limitXYZ,"", sKernel 
			sKernel = Exp(- (x^2 + y^2)/(2*kernelParam^2) )
			normalisation= Sum(sKernel)
			sKernel= sKernel/normalisation
			break
		case "Laplacian (3x3)":  
			Make/O/N=(3,3) sKernel 
			sKernel[][]={{-1,-1,-1},{-1,8,-1},{-1,-1,-1}}
			break
		case "Laplacian (5x5)":  
			Make/O/N=(5,5) sKernel 
			sKernel[][]={{0,0,-1,0,0},{0,-1,-2,-1,0},{-1,-2,17,-2,-1},{0,-1,-2,-1,0},{0,0,-1,0,0}}
			break
		case "Laplacian (7x7)":  
			Make/O/N=(5,5) sKernel 
			sKernel[][]={{-10,-5,-2,-1,-2,-5,-10},{-5,0,3,4,3,0,-5},{-2,3,6,7,6,3,-2},{-1,4,7,8,7,4,-1},{-2,3,6,7,6,3,-2},{-5,0,3,4,3,0,-5},{-10,-5,-2,-1,-2,-5,-10}}
			break
		default:  //unitary		
			Make/O/N=(1,1) sKernel //  create a unitary kernel (2d)
			sKernel=1
			normalisation= Sum(sKernel)
			sKernel= sKernel/normalisation
			break
	endSwitch

	// convert the kernel to 3D if using 3D data
	if ( dim == 3 )
		Make/O/N=(kernelSize,kernelSize,kernelSize) sKernel3d
		sKernel3d[][][] = sKernel[p][q]
		normalisation= Sum(sKernel3d)
		sKernel3d= sKernel3d/normalisation
		Duplicate/O sKernel, sKernel2d
		Duplicate/O sKernel3d, sKernel
		// show the 2D kernel
		//imgDisplay("sKernel2d")
		//updateColourRange("")
	else 
		// show the 2D kernel
		imgDisplay("sKernel")
		updateColourRange("")
	endif
		
	// Return to original DF
	SetDataFolder saveDF
End



//------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------
Function makeKernelOld(graphName,dim)
	String graphName
	Variable dim
	Variable normalisation
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save DF
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName
	
	// set default parameters
	Variable kernelSize=5
	Variable kernelParam=1
	String kernelName = "Gaussian Smooth"
	
	// Get input from user
	Prompt kernelSize, "Please enter side length, n, of the (nxn) kernel: " 
	Prompt kernelParam, "Please enter kernel variable parameter" 
	Prompt kernelName,"Kernel type: ",popup,"Gaussian Smooth;Laplacian (3x3);Laplacian (5x5);none"
	
	// Ask user what kernel to use
	DoPrompt "Make kernel", kernelName
	
	 // User canceled so quit
	if (V_Flag)
		Print "Warning: User cancelled"         
		return -1
	endif 
	
	 // User selected "none", so quit
	if ( cmpstr(kernelName,"none")==0 )
		Print "Warning: User cancelled"         
		return -1
	endif 
	
	// define min/max x and y axes for calculating kernel function
	Variable limitXYZ = (kernelSize-1)/2
	
	if (dim==3) // 3d wave
		
		Make/O/N=(kernelSize,kernelSize,kernelSize) sKernel // first create the convolution kernel 
		SetScale/I x -limitXYZ,limitXYZ,"", sKernel
		SetScale/I y -limitXYZ,limitXYZ, "", sKernel 	// Equivalent to rect(2*fx)*rect(2*fy) in the spatial frequency domain. 
		SetScale/I z -limitXYZ,limitXYZ,"", sKernel

		strswitch( kernelName )
			case "Gaussian Smooth":
				sKernel = Exp(- (x^2 + y^2)/(2*kernelParam^2) )
				normalisation= Sum(sKernel)
				sKernel= sKernel/normalisation
				break
			default:  //unitary		
				Print "Warning: This option does not apply to 3D data sets; doing nothing and exiting"
				Make/O/N=(1,1,1) sKernel //  
				sKernel=1
				normalisation= Sum(sKernel)
				sKernel= sKernel/normalisation
				break
		endswitch
		
	else // 2d wave
	
		Make/O/N=(kernelSize,kernelSize) sKernel // first create the convolution kernel 
		
		SetScale/I x -limitXYZ,limitXYZ,"", sKernel
		SetScale/I y -limitXYZ,limitXYZ,"", sKernel 	// Equivalent to rect(2*fx)*rect(2*fy) in the spatial frequency domain. 

		strswitch( kernelName )
			case "Gaussian":
//				convTypeLetter = "G"
				sKernel = Exp(- (x^2 + y^2)/(2*kernelParam^2) )
				normalisation= Sum(sKernel)
				sKernel= sKernel/normalisation
				break
			case "Laplacian (3)":  
//				convTypeLetter = "L"
				Make/O/N=(3,3) sKernel 
				sKernel[][]={{-1,-1,-1},{-1,8,-1},{-1,-1,-1}}
				break
			case "Laplacian (5)":  
//				convTypeLetter = "L"
				Make/O/N=(5,5) sKernel 
				sKernel[][]={{-10,-5,-2,-1,-2,-5,-10},{-5,0,3,4,3,0,-5},{-2,3,6,7,6,3,-2},{-1,4,7,8,7,4,-1},{-2,3,6,7,6,3,-2},{-5,0,3,4,3,0,-5},{-10,-5,-2,-1,-2,-5,-10}}
				break
			default:  //unitary		
				Make/O/N=(1,1) sKernel //  create a unitary kernel (2d)
				sKernel=1
				normalisation= Sum(sKernel)
				sKernel= sKernel/normalisation
				break
		endswitch
		// show the kernel
		imgDisplay("sKernel")
	endif
	
	
	
	// Back up the data and add letter to new data.  Ideally we would do this elsewhere, but this is the easiest place to do it
	// given that this is where we create the different types of kernels for matrix convolution
//	backupData(graphName,convTypeLetter)  // the string in the second variable is appended to wave name after backup up the original data		
	
	// Return to original DF
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------
// currently only JPEG images are fully supported
//------------------------------------------------------------------------------------------------------------
Function quickSaveImage([symbolicPath,imageType])
	String symbolicPath,imageType
	
	// Get name of top graph
	String graphName= WinName(0,1)

	SVAR autoSaveImage = root:WinGlobals:SRSSTMControl:autoSaveImage
	
	// if imageType not given then set it to "JPEG"
	if ( ParamIsDefault(imageType) )
		imageType="JPEG"
	endif

	// if symbolicPath not given then set it to "SRSDesktop".  This symbolic path is created in SRSSTM2012.ipf
	if ( ParamIsDefault(symbolicPath) )
		symbolicPath="UserDesktop"
	endif
	
	// Create String variables for use later on
	String fileExt= ".default"
	String imageFileName= "defaultImageName"
	String imageDataOnly= "no"
	
	strswitch (imageType)
		case "JPEG":
			fileExt=".jpg"
			break
		
		case "TIFF":
			fileExt=".tif"
			imageDataOnly= "yes"
			break
			
	endswitch
	
//	Variable i
	String imageFileNameImageOnly
//	for (i=0;i<9;i+=1)
	
		// Attempt to open image to find out if it already exists
		//imageFileName= graphName+"_"+num2str(i)+fileExt
		
		imageFileName = StringFromList(0,ImageNameList(graphName,""))
		// check if line trace
		if ( strlen(imageFileName)==0 )
			imageFileName = StringFromList(0,TraceNameList(graphName,"",1))
		endif
		
		imageFileNameImageOnly = "IMG_"+imageFileName
		//ImageLoad /Q/O /Z /T=any /P=$symbolicPath imageFileName
		//if ( V_Flag )
			// Clean up
			//KillWaves/Z $imageFileName
		//	KillWaves/Z imageFileName
		//else
			strswitch ( imageDataOnly )
				case "no":
					SavePICT /O/Z /Q=1 /P=$symbolicPath /T=imageType /B=144 as imageFileName+".jpg"
					break
				
				case "yes":
					
					// Get current data folder
					DFREF saveDF = GetDataFolderDFR()	  // Save
					
					String tmpDFname = "root:WinGlobals:"+graphName
					if ( DataFolderExists(tmpDFname) )
						// do nothing (will carry on after this if statement
					else
						// not an SRSSTM image window so quit
						Print "Error: This does not appear to be an image window (SRSSTM)"
						break
					endif
					// Move to the created data folder for the graph window
					SetDataFolder root:WinGlobals:$graphName
					
					// get image wave name (includ. full DF path)
					String/G imgWFullStr		// data folder plus wave name
					
					// Duplicate image wave
					Duplicate/O $imgWFullStr imgWforTIFFOutput
					
					Resample/DIM=0/UP=2 imgWforTIFFOutput
					Resample/DIM=1/UP=2 imgWforTIFFOutput
					
					//ImageTransform /C=root:WinGlobals:$(graphName):ctab fliprows imgWforTIFFOutput					
					//ImageTransform /O /C=root:WinGlobals:$(graphName):ctab flipcols imgWforTIFFOutput
					ImageTransform /C=root:WinGlobals:$(graphName):ctab cmap2rgb imgWforTIFFOutput
					ImageRotate/O/V M_RGBOut
					ImageSave/IGOR/O/D=32/T="TIFF"/P=$symbolicPath /Q=1 M_RGBOut as imageFileNameImageOnly+".tiff"
					
//					KillWaves/Z imgWforTIFFOutput, M_RGBOut
					// return to DF
					SetDataFolder saveDF		
					
					break 
					
				default:
					Print "Sorry, something went wrong with image save"
					break
			endswitch

			if (cmpstr(autoSaveImage,"yes")==0)
				KillWindow $graphName
			endif
	//		break  // this breaks out of the for loop
		//endif
//	endfor 
End


//------------------------------------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------------------------------------
Function quickScript(scriptType)
	String scriptType
		
		strswitch( scriptType )
			case "CITSstandard":
				displayData()
				doSomethingWithData("differentiateCITS")
				doSomethingWithData("smoothZ")
				doSomethingWithData("mConvolution")
				//doSomethingWithData("STSfromCITS")
				doSomethingWithData("lineprofile")
				break				
			case "STSstandard":
				// Get current data folder
				DFREF saveDF = GetDataFolderDFR()	  // Save DF
				// display all STS
				display1DWaves("all")
				// average
				DoSomethingToAllTracesInGraph("",type="average")
				// differentiate
				DoSomethingToAllTracesInGraph("",type="differentiate")
				// smooth
				DoSomethingToAllTracesInGraph("",type="smooth-B")
				break
		endswitch
End



//--------------------------------------------------------------------------------------------------------------
// 
Function createROI(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data.  This can be either a 2d, or 3d data wave
	Wave imgW= $imgWFullStr
	
	SetAxis/A left;DelayUpdate
	SetAxis/A bottom

	// Drawing tools
	SetDrawLayer/W=$graphName ProgFront

	ShowTools/W=$graphName /A rect
End


//--------------------------------------------------------------------------------------------------------------
// 
Function killROI(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data.  This can be either a 2d, or 3d data wave
	Wave imgW= $imgWFullStr
	
	// Drawing tools
	SetDrawLayer/W=$graphName ProgFront
	
	// 100% solid pattern
	SetDrawEnv/W=$graphName fillpat=1
	SetDrawEnv/W=$graphName save
	
	// Kill everything in ProgFront layer
	DrawAction /W=$graphName delete
	
	// Hide tools palete
	HideTools/W=$graphName /A 
	
	// Drawing tools
	SetDrawLayer/W=$graphName UserFront
	
End


//----------------------------------------------------------
// Calculate FFT
//----------------------------------------------------------
Function FFTimage(graphName,type)
	String graphName, type
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// From this point work in the original data folder where the data is
	SetDataFolder imgDF 
	
	// Make wave assignment to the data  (/C designates complex wave)
	Wave imgW= $imgWFullStr
		
	// Determine size of the image
	Variable ImgRows = DimSize(imgW,0)
	Variable ImgCols = DimSize(imgW,1)

	Variable cropimageflag = 0 // use this as a flag to determined whether we need to create a new image
	Variable ImgRowsCrop = ImgRows
	Variable ImgColsCrop = ImgCols
	
	// if either cols or rows are odd then make them even by subtracting 1
	if ( mod(ImgRows,2)==1 )
		ImgRowsCrop -= 1
		cropimageflag = 1
	endif
	
	if ( mod(ImgCols,2)==1 )
		ImgColsCrop -= 1
		cropimageflag = 1
	endif
	
	if (cropimageflag==1)
		// Move to the image data folder to replace the image with the one of even sides for the FFT
		Redimension/N=(ImgRowsCrop,ImgColsCrop) imgW
	endif
	
	// Create name for FFT wave
	String imgFFTStr= imgWStr+"F"
	
	// Duplicate the image wave and then make this a complex wave
	//Duplicate/O imgW, $imgFFTStr
	//Wave imgFFT= $imgFFTStr
	Redimension/C imgW
					
	// Compute the FFT magnitude
	FFT/MAG/DEST=$imgFFTStr imgW
	
	// Check if FFT window already exists and kill it if it does
	DoWindow/F $(imgFFTStr+"0")
	if (V_flag!=0)
		KillWindow $(imgFFTStr+"0")
	endif
	
	// display the FFT and update the contrast
	imgDisplay(imgFFTStr)
	String FFTgraphName= WinName(0,1)
	changeColour(FFTgraphName,colour="BlueLog")
	//updateColourRangeByHist("",type="exp")
	 updateColourRange("",minVal=-5e-08,maxVal=5e-08)
	
	if ( cmpstr(type,"complex")==0 )
		// Compute the full complex output FFT
		FFT/DEST=$imgFFTStr imgW
	endif
	
	GetAxis/Q bottom
	SetAxis bottom V_min/2, V_max/2
	GetAxis/Q left
	SetAxis left V_min/2, V_max/2
	
	// convert the original image back to real
	Redimension/R imgW
	
	// further adjust colour scale
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$FFTgraphName 
	
	// The ctable wave has been created and put in the appropriate WinGlobals location with the global variables and so can be assigned
	Wave ctab
	
	Variable/G ctabwMin
	Variable/G ctabwMax
	Variable ctabRange= ctabwMax - ctabwMin
	
	ctabwMin = ctabwMin - ctabRange
	ctabwMax = ctabwMax + ctabRange
	
	// Update colour range
	updateColourRange(FFTgraphName,minVal=ctabwMin,maxVal=ctabwMax)
	
End



//----------------------------------------------------------
// Calculate IFFT
//----------------------------------------------------------
Function IFFTimage(graphName)
	String graphName
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// From this point work in the original data folder where the data is
	SetDataFolder imgDF 
	
	// Make wave assignment to the data  (/C designates complex wave)
	Wave imgW= $imgWFullStr
		
	// Determine size of the image
	Variable ImgRows = DimSize(imgW,0)
	Variable ImgCols = DimSize(imgW,1)

	Variable cropimageflag = 0 // use this as a flag to determined whether we need to create a new image
	Variable ImgRowsCrop = ImgRows
	Variable ImgColsCrop = ImgCols
	// if either cols or rows are odd then make them even by subtracting 1
	if ( mod(ImgRows,2)==1 )
		ImgRowsCrop -= 1
		cropimageflag = 1
	endif
	
	if ( mod(ImgCols,2)==1 )
		ImgColsCrop -= 1
		cropimageflag = 1
	endif
	
	if (cropimageflag==1)
		// Move to the image data folder to replace the image with the one of even sides for the FFT
		Redimension/N=(ImgRowsCrop,ImgColsCrop) imgW
	endif
	
	// Create name for FFT wave
	String imgIFFTStr= imgWStr+"I"
	
	// Duplicate the image wave and then make this a complex wave
	Duplicate/O imgW, $imgIFFTStr
	Wave imgIFFT= $imgIFFTStr
	
	// Compute the FFT magnitude
	IFFT/C/DEST=dummyWave imgIFFT
	IFFT/C/DEST=imgIFFT imgIFFT
	CopyScales dummyWave, imgIFFT
	
	// Convert the wave back to real so it can be displayed
	Redimension/R imgIFFT
	
	// Check if FFT window already exists and kill it if it does
	DoWindow/F $(imgIFFTStr+"0")
	if (V_flag!=0)
		KillWindow $(imgIFFTStr+"0")
	endif
	
	// display the FFT and update the contrast
	imgDisplay(imgIFFTStr)
	String IFFTgraphName= WinName(0,1)
	changeColour(IFFTgraphName,colour="Autumn")
	updateColourRangeByHist("",type="gaussian")

	KillWaves/Z filterWave
End




//----------------------------------------------------------
// Calculate FFT, filter the FFT, calculate the IFFT
//----------------------------------------------------------
Function FFTlowpass(graphName)
	String graphName
	
	Variable cutoff, width
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// From this point work in the original data folder where the data is
	SetDataFolder imgDF 
	
	// Make wave assignment to the data
	Wave/C imgW= $imgWFullStr
	
	// Determine size of the image
	Variable ImgRows = DimSize(imgW,0)
	Variable ImgCols = DimSize(imgW,1)
	
	// Make the filter wave to convolute with the FFT before taking the inverse FF
	Make/O/N=(ImgRows,ImgCols) filterWave
	CopyScales imgW, filterWave
	
	// get the max x and y values for the FFT to compute guess at filter params
	Variable filterXmax = DimDelta(filterWave,0) * DimSize(filterWave,0)
	Variable filterYmax = DimDelta(filterWave,1) * DimSize(filterWave,1)
	Variable filterRange = max (filterXmax,filterYmax)
	
	// Ask user for filter parameters
	cutoff=filterRange/5
	width = filterRange/100
	Prompt cutoff, "Filter cut off" 
	Prompt width, "Filter width " 
	DoPrompt "Please enter parameter for FFT filtering", cutoff, width

	if (V_Flag)
		Print "Warning: User cancelled FFT dialogue"
		return -1
 	endif		
								
	filterWave[][] = sqrt(x^2+y^2)
	filterWave[][] = 1 / ( Exp( (sqrt(x^2+y^2)-cutoff)/width ) + 1)
	
	// for the purposes of displaying the filtered FFT we are going to create a magnitude
	// FFT, display that, then make this the complex FFT spectrum.  This is because the functions
	// at present do not handle colour scaling when the data is complex.
	
	// Duplicate the FFT to a new one that will be filtered
	String filteredFFTStr = imgWStr+"f"
	Duplicate/O imgW, $filteredFFTStr
	Wave filteredFFT = $filteredFFTStr
	Redimension/R filteredFFT
	filteredFFT = sqrt(magsqr(imgW))
	
	// Check if window already exists and kill it if it does
	DoWindow/F $(filteredFFTStr+"0")
	if (V_flag!=0)
		KillWindow $(filteredFFTStr+"0")
	endif
	
	// display
	imgDisplay(filteredFFTStr)
	String filteredFFTgraphName= WinName(0,1)
	changeColour(filteredFFTgraphName,colour="BlueLog")
	updateColourRangeByHist("",type="exp")
	
	// now convert back to complex and calculate the filtered FFT
	redimension/C filteredFFT
	MatrixOp/O filteredFFT = imgW * filterWave
	
	doSomethingWithData("IFFT")

End




//----------------------------------------------------------
// rotate
//----------------------------------------------------------
Function rotateImg(graphName)
	String graphName
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// From this point work in the original data folder where the data is
	SetDataFolder imgDF 
	
	// Make wave assignment to the data  (/C designates complex wave)
	Wave imgW= $imgWFullStr
	
	WaveStats imgW
	Variable waveAvg = V_avg
	
	Variable angle=0
	Prompt angle, "Enter Rotation Angle"
	DoPrompt "Image rotation", angle
		
	ImageRotate/E=(waveAvg)/O/A=(-angle) imgW

End





//----------------------------------------------------------
// crop to current view area
//----------------------------------------------------------
Function cropImg(graphName)
	String graphName
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// From this point work in the original data folder where the data is
	SetDataFolder imgDF 
	
	// Make wave assignment to the data  
	Wave imgW= $imgWFullStr
	
	GetAxis/W=$graphName bottom
	Variable Xmin = V_min
	Variable Xmax = V_max
	
	GetAxis/W=$graphName left
	Variable Ymin = V_min
	Variable Ymax = V_max
	
	// Make wave duplicate for cropping
	String cropWStr = imgWstr+"C"
	Duplicate/O imgW, $cropWStr
	
	// reassign the wave reference to the new wave
	Wave cropW=$cropWStr
	
	// Determine point number corresponding to axes min and max
	Variable XminPoint =  (Xmin - DimOffset(imgW, 0))/DimDelta(imgW,0)
	Variable XmaxPoint =  (Xmax - DimOffset(imgW, 0))/DimDelta(imgW,0)
	Variable YminPoint =  (Ymin - DimOffset(imgW, 1))/DimDelta(imgW,1)
	Variable YmaxPoint =  (Ymax - DimOffset(imgW, 1))/DimDelta(imgW,1)
	Variable imgWmaxX = DimSize(imgW,0)
	Variable imgWmaxY = DimSize(imgW,1)

	DeletePoints/M=0 round(XmaxPoint), imgWmaxX, cropW
	DeletePoints/M=1 round(YmaxPoint), imgWmaxY, cropW
	DeletePoints/M=0 0, round(XminPoint), cropW
	DeletePoints/M=1 0, round(YminPoint), cropW

	// Check if FFT window already exists and kill it if it does
	DoWindow/F $(graphName+"0")
	if (V_flag!=0)
		KillWindow $(graphName+"0")
	endif
	
	// Display cropped wave
	imgDisplay(cropWStr)
	
//	SetAxis/A
//	DoUpdate

End




//----------------------------------------------------------
// crop to current view area
//----------------------------------------------------------
Function cropCITS(graphName)
	String graphName

	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G citsDF			// data folder containing the data shown on the graph
	String/G citsWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G citsWFullStr		// data folder plus wave name
	
	// From this point work in the original data folder where the data is
	SetDataFolder citsDF 
	
	// Make wave assignment to the data  
	Wave citsW= $citsWFullStr
	
	GetAxis/W=$graphName bottom
	Variable Xmin = V_min
	Variable Xmax = V_max
	
	GetAxis/W=$graphName left
	Variable Ymin = V_min
	Variable Ymax = V_max
	
	// Make wave duplicate for cropping
	String cropWStr = citsWstr+"C"
	Duplicate/O citsW, $cropWStr
Print cropWStr	
	// reassign the wave reference to the new wave
	Wave cropW=$cropWStr
	
	// Determine point number corresponding to axes min and max
	Variable XminPoint =  (Xmin - DimOffset(citsW, 0))/DimDelta(citsW,0)
	Variable XmaxPoint =  (Xmax - DimOffset(citsW, 0))/DimDelta(citsW,0)
	Variable YminPoint =  (Ymin - DimOffset(citsW, 1))/DimDelta(citsW,1)
	Variable YmaxPoint =  (Ymax - DimOffset(citsW, 1))/DimDelta(citsW,1)
	Variable citsWmaxX = DimSize(citsW,0)
	Variable citsWmaxY = DimSize(citsW,1)

	Print XminPoint 
	Print XmaxPoint 
	Print YminPoint 
	Print YmaxPoint 
	Print citsWmaxX
	Print citsWmaxY 
	
	DeletePoints/M=0 round(XmaxPoint), citsWmaxX, cropW
	DeletePoints/M=1 round(YmaxPoint), citsWmaxY, cropW
	DeletePoints/M=0 0, round(XminPoint), cropW
	DeletePoints/M=1 0, round(YminPoint), cropW

	// Check if FFT window already exists and kill it if it does
	DoWindow/F $(graphName+"0")
	if (V_flag!=0)
		KillWindow $(graphName+"0")
	endif
	
	// Display cropped wave
	//imgDisplay(cropWStr)
	
//	SetAxis/A
//	DoUpdate

End




//----------------------------------------------------------
// 
//----------------------------------------------------------
Function upSampleImage(graphName)
	String graphName
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// From this point work in the original data folder where the data is
	SetDataFolder imgDF 
	
	// Make wave assignment to the data  
	Wave imgW= $imgWFullStr
	
	Variable factor=2
	Prompt factor, "Enter the upscale factor (1 + number of new points between each old point)"
	DoPrompt "Resample image", factor
	
	Resample/Dim=0/Up=(factor) imgW
	Resample/Dim=1/Up=(factor) imgW
		
End



//----------------------------------------------------------
// 
//----------------------------------------------------------
Function upSampleCITS(graphName)
	String graphName
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G citsDF			// data folder containing the data shown on the graph
	String/G citsWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G citsWFullStr		// data folder plus wave name
	
	// From this point work in the original data folder where the data is
	SetDataFolder citsDF 
	
	// Make wave assignment to the data  
	Wave citsW= $citsWFullStr
	
	Variable factor=2
	Prompt factor, "Enter the upscale factor (1 + number of new points between each old point)"
	DoPrompt "Resample image", factor
	if( V_Flag )
	      	return 0          // user canceled
   	endif
   	
	Resample/Dim=0/Up=(factor) citsW
	Resample/Dim=1/Up=(factor) citsW
	//Resample/Dim=3/Up=(factor) citsW
		
	refresh3dData(graphName)
End



//--------------------------------------------------------------------------------------------------------------
Function imageArithmetic(type)
	String type
			
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
			// do arithmetic
			String window1 = StringFromList(0,windowList)
			String window2 = StringFromList(1,windowList)		
			
			GetWindow $window1, wavelist
			Wave/T W_wavelist
			String wave1Str = W_wavelist[0]
		
			GetWindow $window2, wavelist
			Wave/T W_wavelist
			String wave2Str = W_wavelist[0][1]
Print wave1Str, wave2Str
		endif
	else
		Print "Error: There is no top graph window"
	Endif
	
	// Move to original data folder
	SetDataFolder saveDF

End





//--------------------------------------------------------------------------------------------------------------
// This is called from the manipulateData function when user asks for a line profile of the current graph
Function lineProfileMulti(graphname)
	String graphname

	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data.  This can be either a 2d, or 3d data wave
	Wave imgW= $imgWFullStr

	// Determine image size for positioning the cursors
	Variable xMin= DimOffset(imgW,0)
	Variable xMax= (DimDelta(imgW,0) * DimSize(imgW,0) + DimOffset(imgW,0))
	Variable yMin= DimOffset(imgW,1)
	Variable yMax= (DimDelta(imgW,1) * DimSize(imgW,1) + DimOffset(imgW,1))
	Variable xRange = xMax - xMin
	Variable yRange = yMax - yMin
	
	// Calculate cursor positions
	Variable leftCursX= xMin + (0.25 * xRange)
	Variable rightCursX= xMax - (0.25 * xRange)
	Variable leftCursY= yMin + (0.25 * yRange)
	Variable rightCursY= yMax - (0.25 * yRange)
	
	Variable leftMidCursX= xMin + (0.375 * xRange)
	Variable rightMidCursX= xMax - (0.375* xRange)
	Variable leftMidCursY= yMin + (0.375 * yRange)
	Variable rightMidCursY= yMax - (0.375 * yRange)
	
	// Load the cursor positions from global variables if they exist
	Variable/G xA
	Variable/G xB
	Variable/G xD
	Variable/G xE
	Variable/G yA
	Variable/G yB
	Variable/G yD
	Variable/G yE
	
	
	if ( (Abs(xA)+Abs(xB)+Abs(yA)+Abs(yB)+Abs(xD)+Abs(xE)+Abs(yD)+Abs(yE))!=0 && (Abs(xA)+Abs(xB)+Abs(yA)+Abs(yB)+Abs(xD)+Abs(xE)+Abs(yD)+Abs(yE)) < 10000 )  // assume if these are all zero then they have not been defined before, otherwise they have so use those numbers/
		leftCursX= xA
		rightCursX= xB
		leftCursY= yA
		rightCursY= yB
		leftMidCursX= xD
		rightMidCursX= xE
		leftMidCursY= yD
		rightMidCursY= yE
	endif
	
	// Generate folder and global variables for 2d plot (if working with 3d data set)
	// This must be done before calling "Cursor" below, since the 2dline profile DF in WinGlobals needs to be created before the cursors are placed
	Wave citsImgW
	if (WaveExists(citsImgW)==1)

		// Create name that will be used for the 2d slice graph window and associated WinGlobals folder
		String/G lineProfile2dGraphName= graphName+"_2dProfile"
		
		// Create WinGlobals etc. for the 2d line profile graph window (this is used later for colour scaling etc.)
		GlobalsForGraph(lineProfile2dGraphName)
		
	endif
	
	// Place Cursors on Image (unless they are already there)
	if (strlen(CsrInfo(A))==0)
		Cursor/N=1/W=$graphName/I/s=1/c=(65535,65535,65535) A, $imgWStr, leftCursX, leftCursY
	endif 
	if (strlen(CsrInfo(B))==0)
		Cursor/N=1/W=$graphName/I/s=1/c=(65535,65535,65535) B, $imgWStr, rightCursX, rightCursY
	endif
	if (strlen(CsrInfo(D))==0)
		Cursor/N=1/W=$graphName/I/s=1/c=(65535,65535,65535) D, $imgWStr, leftMidCursX, leftMidCursY
	endif 
	if (strlen(CsrInfo(E))==0)
		Cursor/N=1/W=$graphName/I/s=1/c=(65535,65535,65535) E, $imgWStr, rightMidCursX, rightMidCursY
	endif
			
	// Create Global Variables with Cursor Positions
	Variable/G xB= hcsr(B)
	Variable/G yB= vcsr(B)
	Variable/G xA= hcsr(A)
	Variable/G yA= vcsr(A)
	
	Variable/G xD= hcsr(D)
	Variable/G yD= vcsr(D)
	Variable/G xE= hcsr(E)
	Variable/G yE= vcsr(E)

	// Make a wave to display a line between the cursors on the image
	Make/O/N=4 lineprofx={xA,xD,xE,xB}, lineprofy={yA,yD,yE,yB}
	RemoveFromGraph/Z lineprofy // in case a line profile already drawn then remove it
	AppendToGraph lineprofy vs lineprofx // display the path on the image
	ModifyGraph rgb=(65535,65535,65535); DoUpdate  // change colour to white	

	// We don't actually need to run "makelineprofile()" because this is called when the cursors are generated above	
//	makelineprofile(graphName)
	
	// Make wave assignment to the 1d line profile generated in makeLineProfile()
	Wave lineProfile1D
	
	// Create a new graph to display the line profile
	String/G lineProfileGraphName= graphName+"_lineprofile"
	DoWindow/K $lineProfileGraphName
	Display/k=1/N=$lineProfileGraphName 
	AppendToGraph/W=$lineProfileGraphName lineProfile1D
	
	//--- now do 2d image slice
	
	// Generate folder and global variables for 2d plot (if working with 3d data set)
	if (WaveExists(citsImgW)==1)

		// Create name that will be used for the 2d slice graph window and associated WinGlobals folder
		String/G lineProfile2dGraphName= graphName+"_2dProfile"
		
		// Create WinGlobals etc. for the 2d line profile graph window (this is used later for colour scaling etc.)
		GlobalsForGraph(lineProfile2dGraphName)
		
		// Move into the WinGlobals folder for the 2d slice
		SetDataFolder root:WinGlobals:$(lineProfile2dGraphName)
		
		// Create global variables in this data folder.  These are used by other procedures such as the colour change function
		String/G imgDF= "root:WinGlobals:"+lineProfile2dGraphName+":"
		String/G imgWStr= "lineProfile2D"
		String/G imgWFullStr= imgDF+imgWStr
		
		// We don't actually need to run "makelineprofile()" because this is called when the cursors are generated above	
//		makelineprofile(graphName)
				
		// Make the graph window
		DoWindow/K $lineProfile2dGraphName
		Display/k=1/N=$lineProfile2dGraphName
		
		// Append the 2d line profile to the graph window and make it look nice
		AppendImage/W=$lineProfile2dGraphName lineProfile2D
		imgGraphPretty(lineProfile2dGraphName)
		imgScaleBar(lineProfile2dGraphName)
		changeColour(lineProfile2dGraphName,colour="BlueExp")
		ModifyGraph width=0
		ModifyGraph height=0
		DoUpdate
		
		// Move back to the WinGlobals data folder for the 3d data set
		SetDataFolder root:WinGlobals:$(GraphName)
	endif
	
		
	// Arrange graph windows on screen
	if (WaveExists(citsImgW)==1)
		AutoPositionWindow/E/m=0/R=$graphName $lineProfile2dGraphName
		AutoPositionWindow/E/m=1/R=$lineProfile2dGraphName $lineProfileGraphName
	else
		AutoPositionWindow/E/m=0/R=$GraphName $lineProfileGraphName
	endif
	 
	// Move back to the original data folder
	SetDataFolder saveDF

End



Function skew(imgName)
	String imgName
	
	Wave img = $imgName
	Variable imgRows = DimSize(img, 0)
	Variable imgCols = DimSize(img,1)
	
	Make/D/O/N=(2,2) xi
	Make/D/O/N=(2,2) yi
	
	xi[0][0]=0
	xi[0][1]=0
	xi[1][0]=imgRows
	xi[1][1]=imgRows
	
	yi[0][0]=0
	yi[0][1]=imgCols
	yi[1][0]=0
	yi[1][1]=imgCols

	Duplicate/O xi, xf
	Duplicate/O yi, yf
	
	Variable skew=0.1* imgCols
	
	xf[0][0]=0
	xf[0][1]=0+skew
	xf[1][0]=imgRows-skew
	xf[1][1]=imgRows
	
	yf[0][0]=0
	yf[0][1]=imgCols
	yf[1][0]=0
	yf[1][1]=imgCols
	
	ImageInterpolate /WM=2/sgrx=xi/sgry=yi/dgrx=xf/dgry=yf Warp img

End




//----------------------------------------------------------
// pad image with NaNs so axes are equal
//----------------------------------------------------------
Function equalAxes(graphName)
	String graphName
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// From this point work in the original data folder where the data is
	SetDataFolder imgDF 
	
	// Make wave assignment to the data  
	Wave imgW= $imgWFullStr
	
	Variable imgWmaxX = DimSize(imgW,0)
	Variable imgWmaxY = DimSize(imgW,1)
	
	Variable sideLength = imgWmaxX
	
	if ( imgWmaxX < imgWmaxY )
		sideLength = imgWmaxY
	endif
	
	Make/O/N=(sideLength,sideLength) paddedImage
	paddedImage = NaN
	paddedImage[0,imgWmaxX-1][0,imgWmaxY-1] = imgW[p][q]
	CopyScales/I imgW, paddedImage
	
	if ( imgWmaxX >= imgWmaxY )
		SetScale/I y, DimOffset(imgW,0), DimDelta(imgW,0), paddedImage  // make y scale same as x scale
	else 
		SetScale/I x, DimOffset(imgW,1), DimDelta(imgW,1), paddedImage  // make x scale same as y scale
	endif
	
	Note/NOCR paddedImage, note(imgW)
	
	KillWindow $graphName
	KillWaves imgW
	Rename paddedImage, $imgWStr
	
	imgDisplay(imgWStr)
End


//----------------------------------------------------------
// pad image with NaNs so axes are equal
//----------------------------------------------------------
Function padImage(graphName,side,px)
	String graphName, side
	Variable px
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// From this point work in the original data folder where the data is
	SetDataFolder imgDF 
	
	// Make wave assignment to the data  
	Wave imgW= $imgWFullStr
	
	Variable imgWmaxX = DimSize(imgW,0)
	Variable imgWmaxY = DimSize(imgW,1)
	
	Variable xsideLength = imgWmaxX
	Variable ysideLength = imgWmaxY
	If ( cmpstr(side,"left")==0 || cmpstr(side,"right")==0 )
		xsideLength = imgWmaxX + px
	endif
	If ( cmpstr(side,"top")==0 || cmpstr(side,"bottom")==0 )
		ysideLength = imgWmaxY + px
	endif
	
	Make/D/O/N=(xsideLength,ysideLength) paddedImage
	
	WaveStats imgW
	Variable img_avg = V_avg
	paddedImage = img_avg
	
	if  ( cmpstr(side,"left")==0 )
		paddedImage[px,px+imgWmaxX-1][0,imgWmaxY] = imgW[p-px][q]
	endif
	if  ( cmpstr(side,"right")==0 )
		paddedImage[0,imgWmaxX-1][0,imgWmaxY-1] = imgW[p][q]
	endif
	if  ( cmpstr(side,"top")==0 )
		paddedImage[0,imgWmaxX-1][0,imgWmaxY-1] = imgW[p][q]
	endif
	if  ( cmpstr(side,"bottom")==0 )
		paddedImage[0,imgWmaxX-1][px,px+imgWmaxY-1] = imgW[p][q-px]
	endif
	
	Redimension/N=(xsideLength,ysideLength) imgW
	
	imgW = paddedImage
	//CopyScales/I imgW, paddedImage
	
	//Note/NOCR paddedImage, note(imgW)
	
	//KillWindow $graphName
	//KillWaves/Z imgW
	//Duplicate/O paddedImage, $imgWStr
	//KillWaves/Z paddedImage
	
	//imgDisplay(imgWStr)
End




//----------------------------------------------------------
// skew
//----------------------------------------------------------
Function skewImg(graphName,axis)
	String graphName, axis
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// From this point work in the original data folder where the data is
	SetDataFolder imgDF 
	
	// Make wave assignment to the data  (/C designates complex wave)
	Wave imgW= $imgWFullStr
	
	WaveStats imgW
	Variable waveAvg = V_avg
	
	Variable skewangle=0
	Prompt skewangle, "Enter Skew Angle"
	DoPrompt "Image skew", skewangle
	
	Variable imgRows = DimSize(imgW, 0)
	Variable imgCols = DimSize(imgW,1)
	
	Make/D/O/N=(2,2) xi
	Make/D/O/N=(2,2) yi
	
	xi[0][0]=0
	xi[0][1]=0
	xi[1][0]=imgRows
	xi[1][1]=imgRows
	
	yi[0][0]=0
	yi[0][1]=imgCols
	yi[1][0]=0
	yi[1][1]=imgCols

	Duplicate/O xi, xf
	Duplicate/O yi, yf
	
	Variable skew
	String side
	if ( cmpstr(axis,"horizontal") == 0)
		skew = imgCols * Tan(2 * pi * skewangle / 360)
		if ( skew < 0) 
			side = "left"
		else 
			side = "right"
		endif
		// make space to skew without losing data
		padImage(graphName,side,Abs(skew))
		// Calculate the skew points
		xf[0][0]=0
		xf[0][1]=0+skew
		xf[1][0]=imgRows
		xf[1][1]=imgRows+skew
	endif 
	
	if ( cmpstr(axis,"vertical") == 0)
		skew = imgRows * Tan(skewangle)
		yf[0][0]=0
		yf[0][1]=imgCols
		yf[1][0]=0 - skew
		yf[1][1]=imgCols - skew
	endif 
	Redimension/D imgW
	ImageInterpolate /WM=2/sgrx=xi/sgry=yi/dgrx=xf/dgry=yf Warp imgW
	
	Wave M_InterpolatedImage
	imgW = M_InterpolatedImage
	//KillWaves/Z M_InterpolatedImage

End










// The several functions below were taken from https://notendur.hi.is/~agust/kennsla/WaveMetrics%20Procedures/Data%20Manipulation/Remove%20Points.ipf
// RemoveOutliers(theWave, minVal, maxVal)
//	Removes all points in the wave below minVal or above maxVal.
//	Returns the number of points removed.
Function RemoveOutliers(theWave, minVal, maxVal)
	Wave theWave
	Variable minVal, maxVal

	Variable p, numPoints, numOutliers
	Variable val
	
	numOutliers = 0
	p = 0											// the loop index
	numPoints = numpnts(theWave)				// number of times to loop

	do
		val = theWave[p]
		if ((val < minVal) %| (val > maxVal))	// is this an outlier?
			numOutliers += 1
		else										// if not an outlier
			theWave[p - numOutliers] = val		// copy to input wave
		endif
		p += 1
	while (p < numPoints)
	
	// Truncate the wave
	DeletePoints numPoints-numOutliers, numOutliers, theWave
	
	return(numOutliers)
End

// RemoveOutliersXY(theXWave, theYWave, minVal, maxVal)
//	Removes each point in an XY pair whose Y value is below minVal or above maxVal.
//	Returns the number of points removed.
Function RemoveOutliersXY(theXWave, theYWave, minVal, maxVal)
	Wave theXWave
	Wave theYWave
	Variable minVal, maxVal

	Variable p, numPoints, numOutliers
	Variable val
	
	numOutliers = 0
	p = 0														// the loop index
	numPoints = numpnts(theYWave)						// number of times to loop

	do
		val = theYWave[p]
		if ((val < minVal) %| (val > maxVal))				// is this an outlier?
			numOutliers += 1
		else													// if not an outlier
			theYWave[p - numOutliers] = val				// copy to input Y wave
			theXWave[p - numOutliers] = theXWave[p]		// copy to input Y wave
		endif
		p += 1
	while (p < numPoints)
	
	// Truncate the wave
	DeletePoints numPoints-numOutliers, numOutliers, theXWave, theYWave
	
	return(numOutliers)
End

// RemoveNaNs(theWave)
//	Removes all points in the wave with the value NaN.
//	A NaN represents a blank or missing value.
//	Returns the number of points removed.
Function RemoveNaNs(theWave)
	Wave theWave

	Variable p, numPoints, numNaNs
	Variable val
	
	numNaNs = 0
	p = 0											// the loop index
	numPoints = numpnts(theWave)				// number of times to loop

	do
		val = theWave[p]
		if (numtype(val)==2)					// is this NaN?
			numNaNs += 1
		else										// if not NaN
			theWave[p - numNaNs] = val			// copy to input wave
		endif
		p += 1
	while (p < numPoints)
	
	// Truncate the wave
	DeletePoints numPoints-numNaNs, numNaNs, theWave
	
	return(numNaNs)
End

// RemoveNaNsXY(theXWave, theYWave)
//	Removes all points in an XY pair if either wave has the value NaN.
//	A NaN represents a blank or missing value.
//	Returns the number of points removed.
Function RemoveNaNsXY(theXWave, theYWave)
	Wave theXWave
	Wave theYWave

	Variable p, numPoints, numNaNs
	Variable xval, yval
	
	numNaNs = 0
	p = 0											// the loop index
	numPoints = numpnts(theXWave)			// number of times to loop

	do
		xval = theXWave[p]
		yval = theYWave[p]
		if ((numtype(xval)==2) %| (numtype(yval)==2))		// either is NaN?
			numNaNs += 1
		else										// if not an outlier
			theXWave[p - numNaNs] = xval		// copy to input wave
			theYWave[p - numNaNs] = yval		// copy to input wave
		endif
		p += 1
	while (p < numPoints)
	
	// Truncate the wave
	DeletePoints numPoints-numNaNs, numNaNs, theXWave, theYWave
	
	return(numNaNs)
End

// This function written by SRS
Function RemovePointsBelow(theWave, minVal,newVal)
	Wave theWave
	Variable minVal, newVal

	Variable p, q, numPointsX, numPointsY, numOutliers
	Variable val
	
	numOutliers = 0
	p = 0
	q=0											// the loop index
	numPointsX = DimSize(theWave,0)				// number of times to loop
	numPointsY = DimSize(theWave,1)	

	do
	  do
		val = theWave[p][q]
		if (val <= minVal) 	// is this an outlier?
			theWave[p][q] = newVal
			numOutliers += 1
		endif
		p += 1
	  while (p < numPointsX)
	  p=0
	  q +=1
	 while (q < numPointsY)
	
	
	return(numOutliers)
End



// THIS PROCEDURE IS NOT CURRENTLY PART OF THE PACKAGE.  THIS WILL ALLOW THE AVERAGE OF A COLLECTION OF CITS IMAGES EXTRACTED FROM A CITS MAP.
Function AverageOfImages()
	Variable starti, endi
	SetDataFolder root:CITSImageSlices
	
	String wavelistStr = WaveList("*",";","DIMS:2")
	String waveStr = StringFromList(0,wavelistStr,";")
	Variable base_len = strlen(wavestr)
	String base=waveStr[0,base_len-2]
	

	starti = 0
	endi = ItemsInList(wavelistStr)
		
	Prompt starti, "Start Image: "
	Prompt endi, "End image: "
	DoPrompt "What start and end image", starti, endi
	Variable i
	
	//starti = 60
	//endi = 153

	
	String startWStr = base+num2str(starti)
	Wave startW = $startWStr
	Duplicate/O startW, avgImgWave
	Wave avgImgWave
	
	String currentImg
	
	for (i=starti+1; i<=endi; i+=1)
		currentImg= base+num2str(i)
		Wave currentImgWave = $currentImg
		avgImgWave = avgImgWave + currentImgWave
	endfor
	
	//avgImgWave = avgImgWave / (endi-starti+1)
	
	NewDataFolder/O root:avgCITSImage
	String finalImgName = base+"_"+num2str(starti)+"_"+num2str(endi)
	Duplicate/O avgImgWave root:avgCITSImage:$(finalImgName)
	
	KillWaves avgImgWave
	
	//String newwavename = "avgImgWave_"+num2str(starti)+"_"+num2str(endi)
	//Rename avgImgWave, $newwavename
	SetDataFolder root:avgCITSImage
	imgDisplay(finalImgName)
	TextBox/K/N=text1
End


Function changeBiasCurrent(graphName)
String graphName

	if ( strlen(graphName)==0 )
		graphName= WinName(0,1)	
	endif
	
	// Get name of the image Wave
	String wnameList = ImageNameList("", ";")
	String imgWStr = StringFromList(0, wnameList)
	
	// Get full name and path to image wave
	String/G imgWFullStr

	// Create wave assignment for 3d cits wave
	Wave imgW = $imgWFullStr
	
	// Get the wave note
	String imgInfoFromNote = note(imgW)
	
	// Get the bias and setpoint values from the wave note
	String biasStr = StringByKey("Voltage",imgInfoFromNote)
	String setpointStr = StringByKey("Setpoint",imgInfoFromNote)
	
	// convert to nano, pico, etc.
	//biasStr = sciunit(biasStr)
	//setpointStr = sciunit(setpointStr)
	
	//Variable bias, setpoint
	Variable bias, setpoint
	String biasUnit, setpointUnit
	sscanf biasStr, "%f%s", bias, biasUnit
	sscanf setpointStr, "%f%s", setpoint, setpointUnit
	
	Variable promptBias = str2num(biasStr)
	Variable promptCurrent = str2num(setpointStr)
		
	Prompt promptBias, "Bias value: "
	Prompt promptCurrent, "Current value: "
	DoPrompt "Setting bias and current value for "+imgWStr, promptBias, promptCurrent
	
	imgInfoFromNote = ReplaceStringByKey("Voltage",imgInfoFromNote, num2str(promptBias)+" "+biasUnit)
	imgInfoFromNote = ReplaceStringByKey("Setpoint",imgInfoFromNote, num2str(promptCurrent)+" "+setpointUnit)
	
	Note/K imgW, imgInfoFromNote
		
End