//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-SPECS-menu.ipf
//
// Creates the menu for SRS-SPECS
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
// Menu items specific for NEXAFS data
Menu "NEXAFS"
	
	Submenu "Display - NEXAFS"
	
		"Display Double Normalised Spectrum/6", display1DWaves("oneDN")
		help = {"Display a double normalised spectrum from the current data folder in a new graph window.  Igor looks for a wave ending in '_dn', otherwise displays a dialogue."}
	
		"Display Normalised Spectrum", display1DWaves("oneN")
		help = {"Display a double normalised spectrum from the current data folder in a new graph window. Igor looks for a wave ending in '_n', otherwise displays a dialogue."}
	End
	"-"
	Submenu "Manipulate"
		"Pre-edge subtraction: average/7",doSomethingWithSpecsData("leadingAvgSubtraction")
		"Pre-edge subtraction: linear/O7",doSomethingWithSpecsData("leadingSubtraction")
		"Pre-edge subtraction: constant",doSomethingWithSpecsData("leadingConstantSubtraction")
		"-"
		"Post-edge normalisation/8",doSomethingWithSpecsData("postEdgeNormalisation")
		//"Find minimum",doSomethingWithSpecsData("findMinimum")
		//"-"
		//"Divide two waves", divideGraphs()
	End
	"-"
	Submenu "Batch scripts"
		"Display DN NEXAFS then process with constant pre-edge/2", display1DWaves("oneDN"); AutoPositionWindow/E/m=0; doSomethingWithSpecsData("leadingAvgSubtraction"); doSomethingWithSpecsData("postEdgeNormalisation")
	End
	"-"
	Submenu "Make pretty"
		"NEXAFS axes", prettyNEXAFS()
		"-"
		"Carbon energy range", SetAxis/A bottom 280, 320; setNEXAFSyAxis()
		"Nitrogen energy range", SetAxis/A bottom 393, 420; setNEXAFSyAxis(); MakeTracesDifferentColours("CyanMagenta")
		"Define y-axis maximum for NEXAFS axes", setNEXAFSyAxisVariable()
	End
	
	"-"
	"About", SRSSPECSAbout()
	
End


//------------------------------------------------------------------------------------------------------------------------------------
// Menu items specific for XPS data
Menu "XPS"
	
	SubMenu "Energy Calibration"
		"\\M0Measure position of the Au(4f) 7/2 peak", doSomethingWithSpecsData("XPSMeasureAu4f72Offset")
		"\\M0Measure position of the Si(2p) 3/2 peak", doSomethingWithSpecsData("XPSMeasureSi2p32Offset")
		"-"
		"Apply energy calibration to data to Graph", doSomethingWithSpecsData("XPSApplyEnergyOffset")
		"-"
		"Apply energy calibration to all waves in Data Folder", XPSApplyEnergyOffsetToDF()
	End
	
	"-"
	
	SubMenu "Background subtraction"
		"Linear Pre-edge", doSomethingWithSpecsData("leadingSubtraction")
		"Linear", doSomethingWithSpecsData("XPSLinearBackground")
    		"Shirley", doSomethingWithSpecsData("XPSShirleyBackground")
 		// I moved the cursor function to the Line Trace menu
  	End

	"-"
	Submenu "Make pretty"
		"XPS axes", prettyXPS()
		"-"
		"X-axis is kinetic energy - background region", XPSXRangeToBackground("KE"); Label bottom "Kinetic energy (\\U)"
		"X-axis is kinetic energy - full scale", Label bottom "Kinetic energy (\\U)"; SetAxis/A bottom
		"-"
		"X-axis is binding energy - background region", XPSXRangeToBackground("BE"); Label bottom "Binding energy (\\U)"
		"X-axis is binding energy - full scale", Label bottom "Binding energy (\\U)"; SetAxis/A/R bottom
	End
	"-"
	"About", SRSSPECSAbout()
End

//Menu "Test area"
//	"FindTracePeak", doSomethingWithSpecsData("findTracePeakWithGaussian")
//End