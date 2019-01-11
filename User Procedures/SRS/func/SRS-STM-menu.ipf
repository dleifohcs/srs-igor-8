//------------------------------------------------------------------------------------------------------------------------------------
// 
// SRS-STM-menu.ipf
//
// Creates the menu for SRS-SPECS.
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
// Use modern global access method.

// Menu

Menu "STM", dynamic
		Submenu "Display"
			"Display 2D or 3D data/F10", displayData()
			"Display all in data folder", displayAllData()
			"-"
			"Clone an existing window", CloneWindow()
			"-"
			"Copy current image data to root:imageData", dosomethingwithdata("copyimagedata")
		End
		Submenu "Colours"
			"Change image colour", doSomethingWithData("changeColour")
			setControlMenuItemDefaultColour(), changeDefaultImageColour()
			"-"
			"Set z-range: default", updateColourRange("")
			"Set z-range: Gaussian fit to histogram", updateColourRangeByHist("",type="gauss")
			"Set z-range: Exponential fit to histogram", updateColourRangeByHist("",type="exp")
			"Set z-range manually", updateColourRangeDialogue("")
			"-"
			"-"
			"Decrease Brightness"+"/F3", incrementColourScale("","increase","both")
			"Increase Brightness"+"/F4", incrementColourScale("","decrease","both")
			"Decrease Contrast"+"/SF3", incrementColourScale("","increase","range")
			"Increase Contrast"+"/SF4", incrementColourScale("","decrease","range")
			"-"
			"Decrease scale maximum"+"/OF3", incrementColourScale("","decrease","max")
			"Increase scale maximum"+"/OF4", incrementColourScale("","increase","max")
			"Decrease scale minimum"+"/SOF3", incrementColourScale("","decrease","min")
			"Increase scale minimum"+"/SOF4", incrementColourScale("","increase","min")
			"-"
			"FFT scale",   updateColourRange("",minVal=-5e-08,maxVal=1e-07)
		End
		"-"
		Submenu "Image tools"
			Submenu "Background subtraction"
				"Plane", doSomethingWithData("subtractplane")
				"Linewise", doSomethingWithData("subtractlinewise")
				"-"
				"Plane from ROI", doSomethingWithData("subtractplaneROI")
				"-"
				"Subtract image offset", doSomethingWithData("subtractMin")
				"Subtract image mean", doSomethingWithData("subtractMean")
				"Shift image Z-axis manually",shiftImageZDialogue("")
			End
			"-"
			"Crop [to current view area]", doSomethingWithData("cropImg")
			"-"
			"Rotate clockwise", doSomethingWithData("rotateImg")
			"-"
			"Skew image - horizontal", doSomethingWithData("skewImgHor")
			"Skew image - vertical", doSomethingWithData("skewImgVer")
			"-"
			"Pad image", doSomethingWithData("padImage")
			"Pad image with NaNs to give equal axes", doSomethingWithData("equalAxes")
			"Interpolate image [up-sample]", doSomethingWithData("upSampleImage")
			"-"
			"Change the value of bias and current", doSomethingWithData("changeBiasCurrent")
		End
		Submenu "CITS tools"
			"Differentiate CITS", doSomethingWithData("differentiateCITS")
			"-"
			"Topography correct CITS - fixed kappa", doSomethingWithData("topCorCITS")
			"Topography correct CITS - using delta z", doSomethingWithData("topCorCITSdeltaz")
			setControlMenuItem("kappaForCITSCorrect"), setControlMenuItemCITSKappa()
			
			"-"
			"FFTCITS", doSomethingWithData("FFTCITS")
			"-"
			"\\M0::Normalised differential conductance, i.e., (dI/dV)/(I/V)", doSomethingWithData("differentiateNormalisedCITS")
			setControlMenuItem("normConductanceCurrentLimit"), setControlMenuItemNormCondLim()
			"-"
			"Smooth CITS along z-axis", doSomethingWithData("smoothZ")
			"-"
			"STS from CITS - Point", doSomethingWithData("STSfromCITS")
			"STS from CITS - ROI", doSomethingWithData("STSfromCITSROI")
			"STS from CITS - All", doSomethingWithData("STSfromCITSAll")
			"-"
			"Interpolate CITS [up-sample]", doSomethingWithData("upSampleCITS")
			"-"
			"Crop [to current view area]", doSomethingWithData("cropCITS")
			"-"
			"Extract a CITS slice to an image", doSomethingWithData("extractImageFromCITS")
			"Extract all CITS slices to images", doSomethingWithData("extractImageSFromCITS")
			"Average CITS slices over a range", AverageOfImages()
		End
		Submenu "Region of Interest"
			"Create or Edit ROI", doSomethingWithData("createROI")
			"Kill ROI", doSomethingWithData("killROI")
		End
		Submenu "FFT"
			//"Calculate FFT magnitude", doSomethingWithData("FFTmag")
			"FFT [real -> complex]", doSomethingWithData("FFT")
			"FFT magnitude [real -> real]", doSomethingWithData("FFTmag")
			"Inverse FFT [complex -> real]", doSomethingWithData("IFFT")
			"-"
			"Low Pass Filter a FFT window", doSomethingWithData("FFTlowpass")
			"-"
			"FFTCITS", doSomethingWithData("FFTCITS")
			"-"
			"Subtract ROI from Complex FFT", doSomethingWithData("subtractROIFFTInverse")
			"Keep only ROI from Complex FFT", doSomethingWithData("subtractROIFFT")
		End
		Submenu "Line Profile"
			"Line Profile", doSomethingWithData("lineprofile")
			"Line Profile - Multiple point - EXPERIMENTAL", doSomethingWithData("lineprofileMulti")
			"-"
			"Remove line profile", removeLineProfile("")	
			"-"
			setControlMenuItem("lineProfileWidth"), setControlMenuItemLineProfWdth()
			"-"
			Submenu "Cursor Colour"
				"Black", LineProfileColourBlack("","black")
				"White", LineProfileColourBlack("","")
				"Red", LineProfileColourBlack("","red")
				"Green", LineProfileColourBlack("","green")
				"Blue", LineProfileColourBlack("","blue")
			End	
		End
		"Matrix convolution",  doSomethingWithData("mConvolution")
		"-"
		Submenu "Save image"
			"Save image Window as JPEG to Desktop/F2",quickSaveImage(symbolicPath="UserDesktop",imageType="JPEG")
			"Save image Window as JPEG to Documents",quickSaveImage(symbolicPath="UserDocuments",imageType="JPEG")
			"-"
			"Save image DATA as TIFF to Desktop/SF2",quickSaveImage(symbolicPath="UserDesktop",imageType="TIFF")
			"Save image DATA as TIFF to Documents",quickSaveImage(symbolicPath="UserDocuments",imageType="TIFF")
			
			//"Quick save JPEG to Documents/SF2",quickSaveImage(symbolicPath="SRSDocuments")
		End
		"-"
		Submenu "Automated scripting"
			"Batch process CITS from data folder", quickScript("CITSstandard")
			"Batch process point STS folder", quickScript("STSstandard")
		End
		"-"
		Submenu "Global Programme Control"
			"Force regeneration of control variables", createSRScontrolvariables(forced="yes")
			"-"
			setControlMenuItem("autoDisplay"), toggleAutoDisplay()
			setControlMenuItem("commonDataFolder"), toggleCommonDataFolderState()
			"-"
			setControlMenuItem("autoBGnone"), setdefaultBackground("none")
			setControlMenuItem("autoBGplane"), setdefaultBackground("plane")
			setControlMenuItem("autoBGlinewise"), setdefaultBackground("linewise")	
			"-"
			setControlMenuItem("stsAveragingNone"),  setdefaultSTSaveraging("none")
			setControlMenuItem("stsAveraging3x3"),  setdefaultSTSaveraging("3x3")
			setControlMenuItem("stsAveraging5x5"),  setdefaultSTSaveraging("5x5")
			setControlMenuItem("stsAveraging9x9"),  setdefaultSTSaveraging("9x9")
			"-"
			// setControlMenuItem("autoUpdateImageColour"), toggleAutoImageColour()
			setControlMenuItem("autoUpdateCITSColour"), toggleAutoCITSColour()
			setControlMenuItem("autoUpdateCITSColourExp"), toggleAutoCITSColourExp()
			setControlMenuItem("CITSLineProfileLog"), toggleCITSLineProfileLog()
			"-"
			setControlMenuItem("syncCITS"), togglesyncCITS()
			"-"
			setControlMenuItem("autoSaveImage"), toggleAutoSaveImage()
			
		End
		"-"
		"About", SRSSTMAbout()

End


// set global variable for programme control
Function toggleCommonDataFolderState()
	createSRSControlVariables()
	SVAR commonDataFolder = root:WinGlobals:SRSSTMControl:commonDataFolder
	if (cmpstr(commonDataFolder,"yes")==0)
		commonDataFolder = "no"
	else
		commonDataFolder = "yes"
		// Turn off autodisplay if loading into MyData , since otherwise will display multiples of same images. 
		SVAR autoDisplay = root:WinGlobals:SRSSTMControl:autoDisplay
		autoDisplay = "no"
	endif
End

// set global variable for programme control
Function toggleAutoDisplay()
	createSRSControlVariables()
	SVAR autoDisplay = root:WinGlobals:SRSSTMControl:autoDisplay
	if (cmpstr(autoDisplay,"yes")==0)
		autoDisplay = "no"
	else
		autoDisplay = "yes"
		// turn off the MyData folder option if doing autodisplay
		SVAR commonDataFolder = root:WinGlobals:SRSSTMControl:commonDataFolder
		commonDataFolder = "no"
	endif
End

// set global variable for programme control
Function toggleAutoSaveImage()
	createSRSControlVariables()
	SVAR autoSaveImage = root:WinGlobals:SRSSTMControl:autoSaveImage
	if (cmpstr(autoSaveImage,"yes")==0)
		autoSaveImage = "no"
	else
		autoSaveImage = "yes"
	endif
End


// set global variable for programme control
Function toggleAutoImageColour()
	createSRSControlVariables()
	SVAR autoUpdateImageColour = root:WinGlobals:SRSSTMControl:autoUpdateImageColour
	if (cmpstr(autoUpdateImageColour,"yes")==0)
		autoUpdateImageColour = "no"
	else
		autoUpdateImageColour = "yes"
	endif
End

// set global variable for programme control
Function togglesyncCITS()
	createSRSControlVariables()
	SVAR syncCITS = root:WinGlobals:SRSSTMControl:syncCITS
	if (cmpstr(syncCITS,"yes")==0)
		syncCITS = "no"
	else
		syncCITS = "yes"
	endif
End

// set global variable for programme control
Function toggleAutoCITSColour()
	createSRSControlVariables()
	SVAR autoUpdateCITSColour = root:WinGlobals:SRSSTMControl:autoUpdateCITSColour
	SVAR autoUpdateCITSColourExp = root:WinGlobals:SRSSTMControl:autoUpdateCITSColourExp
	if (cmpstr(autoUpdateCITSColour,"yes")==0)
		autoUpdateCITSColour = "no"
	else
		autoUpdateCITSColour = "yes"
		autoUpdateCITSColourExp = "no"
	endif
End

// set global variable for programme control
Function toggleAutoCITSColourExp()
	createSRSControlVariables()
	SVAR autoUpdateCITSColour = root:WinGlobals:SRSSTMControl:autoUpdateCITSColour
	SVAR autoUpdateCITSColourExp = root:WinGlobals:SRSSTMControl:autoUpdateCITSColourExp
	if (cmpstr(autoUpdateCITSColourExp,"yes")==0)
		autoUpdateCITSColourExp = "no"
	else
		autoUpdateCITSColourExp = "yes"
		autoUpdateCITSColour = "no"
	endif
End

// set global variable for programme control
Function toggleCITSLineProfileLog()
	createSRSControlVariables()
	SVAR CITSLineProfileLog = root:WinGlobals:SRSSTMControl:CITSLineProfileLog
	if (cmpstr(CITSLineProfileLog,"yes")==0)
		CITSLineProfileLog = "no"
	else
		CITSLineProfileLog = "yes"
	endif
End


// set global variable for programme control
// "none"; "plane"; "linewise"
Function setdefaultBackground(state)
	String state
	createSRSControlVariables()
	SVAR autoBGnone = root:WinGlobals:SRSSTMControl:autoBGnone
	SVAR autoBGplane = root:WinGlobals:SRSSTMControl:autoBGplane
	SVAR autoBGlinewise = root:WinGlobals:SRSSTMControl:autoBGlinewise
	strswitch(state)
		case "none":
			autoBGnone = "yes"
			autoBGplane = "no"
			autoBGlinewise = "no"
			break
		case "plane":
			autoBGnone = "no"
			autoBGplane = "yes"
			autoBGlinewise = "no"
			break
		case "linewise":
			autoBGnone = "no"
			autoBGplane = "no"
			autoBGlinewise = "yes"
			break
		default:
			autoBGnone = "yes"
			autoBGplane = "no"
			autoBGlinewise = "no"
			break
	endswitch
End


// set global variable for programme control
// "none"; "plane"; "linewise"
Function setdefaultSTSaveraging(state)
	String state
	createSRSControlVariables()
	SVAR stsAveragingNone = root:WinGlobals:SRSSTMControl:stsAveragingNone
	SVAR stsAveraging3x3 = root:WinGlobals:SRSSTMControl:stsAveraging3x3
	SVAR stsAveraging5x5 = root:WinGlobals:SRSSTMControl:stsAveraging5x5
	SVAR stsAveraging9x9 = root:WinGlobals:SRSSTMControl:stsAveraging9x9
	strswitch(state)
		case "none":
			stsAveragingNone = "yes"
			stsAveraging3x3 = "no"
			stsAveraging5x5 = "no"
			stsAveraging9x9 = "no"
			break
		case "3x3":
			stsAveragingNone = "no"
			stsAveraging3x3 = "yes"
			stsAveraging5x5 = "no"
			stsAveraging9x9 = "no"
			break
		case "5x5":
			stsAveragingNone = "no"
			stsAveraging3x3 = "no"
			stsAveraging5x5 = "yes"
			stsAveraging9x9 = "no"
		case "9x9":
			stsAveragingNone = "no"
			stsAveraging3x3 = "no"
			stsAveraging5x5 = "no"
			stsAveraging9x9 = "yes"
			break
		default:
			stsAveragingNone = "no"
			stsAveraging3x3 = "no"
			stsAveraging5x5 = "yes"
			stsAveraging9x9 = "no"
			break
	endswitch
End


// This function dynamically creates menu text depending on the state of the global programma control variables.
Function/S setControlMenuItem(controlVariable)
	String controlVariable
	createSRSControlVariables()
	SVAR state = root:WinGlobals:SRSSTMControl:$controlVariable
	
	String returnStr= " "
	
	strswitch(controlVariable)
		case "autoDisplay":
			strswitch(state)
				case "yes":
					returnStr = "Auto-display flat-file images when loading!"+num2char(18) 
					break
				case "no":
					returnStr = "Auto-display flat-file images when loading"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break
		case "autoSaveImage":
			strswitch(state)
				case "yes":
					returnStr = "Auto-save images when loading!"+num2char(18) 
					break
				case "no":
					returnStr = "Auto-save images when loading"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		
		case "autoBGnone":
			strswitch(state)
				case "yes":
					returnStr = "Auto background subtraction: none!"+num2char(18) 
					break
				case "no":
					returnStr = "Auto background subtraction: none"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		case "autoBGplane":
			strswitch(state)
				case "yes":
					returnStr = "Auto background subtraction: plane!"+num2char(18) 
					break
				case "no":
					returnStr = "Auto background subtraction: plane"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		case "autoBGlinewise":
			strswitch(state)
				case "yes":
					returnStr = "Auto background subtraction: linewise!"+num2char(18) 
					break
				case "no":
					returnStr = "Auto background subtraction: linewise"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		case "commonDataFolder":
			strswitch(state)
				case "yes":
					returnStr = "Load all flat files into MyData!"+num2char(18) 
					break
				case "no":
					returnStr = "Load all flat files into MyData"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		case "stsAveragingNone":
			strswitch(state)
				case "yes":
					returnStr = "STS from CITS averaging mode: none!"+num2char(18) 
					break
				case "no":
					returnStr = "STS from CITS averaging mode: none"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		case "stsAveraging3x3":
			strswitch(state)
				case "yes":
					returnStr = "STS from CITS averaging mode: 3x3!"+num2char(18) 
					break
				case "no":
					returnStr = "STS from CITS averaging mode: 3x3"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break	
		case "stsAveraging5x5":
			strswitch(state)
				case "yes":
					returnStr = "STS from CITS averaging mode: 5x5!"+num2char(18) 
					break
				case "no":
					returnStr = "STS from CITS averaging mode: 5x5"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break
		case "stsAveraging9x9":
			strswitch(state)
				case "yes":
					returnStr = "STS from CITS averaging mode: 9x9!"+num2char(18) 
					break
				case "no":
					returnStr = "STS from CITS averaging mode: 9x9"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break	
		case "lineProfileWidth":
			NVAR lineProfileWidth = root:WinGlobals:SRSSTMControl:lineProfileWidth
			returnStr = "Line profile width, "+num2str(lineProfileWidth) 
			break
		case "normConductanceCurrentLimit":
			NVAR normConductLim = root:WinGlobals:SRSSTMControl:normConductLim
			returnStr = "Low current cut off for normalised diferential conductance, "+num2str(normConductLim) 
			break
		case "kappaForCITSCorrect":
			NVAR CITSKappa = root:WinGlobals:SRSSTMControl:CITSKappa
			returnStr = "Kappa value for CITS correction, "+num2str(CITSKappa) 
			break
		case "autoUpdateImageColour":
			strswitch(state)
				case "yes":
					returnStr = "Auto update image colour range!"+num2char(18) 
					break
				case "no":
					returnStr = "Auto update image colour range"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break
		case "autoUpdateCITSColour":
			strswitch(state)
				case "yes":
					returnStr = "Auto update CITS colour range!"+num2char(18) 
					break
				case "no":
					returnStr = "Auto update CITS colour range"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break
		case "autoUpdateCITSColourExp":
			strswitch(state)
				case "no":
					returnStr = "Auto update CITS colour range by exponential fit"
					break
				case "yes":
					returnStr = "Auto update CITS colour range by exponential fit!"+num2char(18) 
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		case "CITSLineProfileLog":
			strswitch(state)
				case "no":
					returnStr = "Display the logarithm of CITS Line Profile data"
					break
				case "yes":
					returnStr = "Display the Logarithm of CITS Line Profile data!"+num2char(18) 
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		case "syncCITS":
			strswitch(state)
				case "no":
					returnStr = "Sync CITS slices"
					break
				case "yes":
					returnStr = "Sync CITS slices!"+num2char(18) 
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		default:
			returnStr = "error 2"
			break
	endswitch
	return returnStr
End

Function/S setControlMenuItemDefaultColour()
	createSRSControlVariables()
	SVAR defaultImageColours = root:WinGlobals:SRSSTMControl:defaultImageColours
	return "Change default colours ["+defaultImageColours+"]"
End

Function setControlMenuItemLineProfWdth()
	createSRSControlVariables()
	NVAR lineProfileWidth = root:WinGlobals:SRSSTMControl:lineProfileWidth
	Variable width = lineProfileWidth
	Prompt width, "Enter pixel width for line profile"
	DoPrompt "Set width for image line profiles", width
	if (V_Flag)
		return -1 //user cancelled
	endif
	lineProfileWidth = width
End

Function setControlMenuItemNormCondLim()
	createSRSControlVariables()
	NVAR normConductLim = root:WinGlobals:SRSSTMControl:normConductLim
	Variable lim = normConductLim
	Prompt lim, "Enter the low current limit for normalised dI dV"
	DoPrompt "Set low current limit for normalised differential conductance", lim
	if (V_Flag)
		return -1 //user cancelled
	endif
	normConductLim = lim
End

Function setControlMenuItemCITSKappa()
	createSRSControlVariables()
	NVAR CITSKappa = root:WinGlobals:SRSSTMControl:CITSKappa
	Variable kappa = CITSKappa
	Prompt kappa, "Enter the Kappa value"
	DoPrompt "Set the Kappa value", kappa
	if (V_Flag)
		return -1 //user cancelled
	endif
	CITSKappa = kappa
End
