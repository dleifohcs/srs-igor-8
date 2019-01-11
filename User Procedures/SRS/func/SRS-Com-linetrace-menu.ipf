//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-Com-linetrace-menu.ipf
//
// Creates the menu for Line Trace manipulations.  This menu is common to both SRS-STM and SRS-SPECS
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
// Menu items for general line spectra
Menu "Line Trace"
	
	Submenu "Display"
	
		"Display a wave/5", display1DWaves("one")
		help = {"Display a single 1D wave from the current data folder in a new graph window"}
	
		"Append a wave", display1DWaves("appendone")
		help = {"Append a single 1D wave from the current data folder to the top graph window"}
	
		"-"
		"Display All Waves", display1DWaves("all")
		help = {"Display all 1D waves from the current data folder in a new graph window"}
	
		"Append All Waves", display1DWaves("appendall")
		help = {"Append all1D waves from the current data folder to the top graph window"}
	
		"-"
		"Set default cursor positions/1", setDefaultCursors()
		"Remove cursors and fitW from graph", removeAnnotations()
	End
	Submenu "Colours"
		"Make Traces Different",/Q,Execute/P/Q/Z "INSERTINCLUDE <KBColorizeTraces>";Execute/P/Q/Z "COMPILEPROCEDURES ";Execute/P/Q/Z "ShowKBColorizePanel()"
		"-"
		"Colours: Spectrum", MakeTracesDifferentColours("SpectrumBlack")
		"Colours: Blue Red Green", MakeTracesDifferentColours("BlueRedGreen256")
		"Colours: Red Yellow", MakeTracesDifferentColours("YellowHot256")
		"Colours: Grays", MakeTracesDifferentColours("Grays256")
		"Colours: Rainbow", MakeTracesDifferentColours("Rainbow256")
		"Colours: Red", MakeTracesDifferentColours("Red")
		"Colours: Blue", MakeTracesDifferentColours("Blue")
		"Colours: Green", MakeTracesDifferentColours("Green")
		"Colours: Cyan", MakeTracesDifferentColours("Cyan")
		"Colours: Cyan Magenta", MakeTracesDifferentColours("CyanMagenta")
		"Colours: Blue Black Red", MakeTracesDifferentColours("BlueBlackRed")
		"Colours: Geo", MakeTracesDifferentColours("Geo")
	End
	
	"-"
	SubMenu "Organise"
		"Combine two graphs into one", collateTracesFromTwoGraphs()
		"Combine multiple graphs into one/3", collateTracesFromMultipleGraphs()
		"-"
		"Copy traces from graph to root:data", copyWavesToNewDF(newDFName="data")
		"-"
		"Duplicate Graph with New Waves", duplicateLinePlotNewWaves()
		help = {"Copy all traces in the top graph window to a new data folder and then display these waves in a new graph window"}
		
		"Duplicate Graph with Original Waves", duplicateLinePlotOrigWaves()
	End
	
	"-"
	SubMenu "Manipulate"
		"Smooth all traces, Binomial/4", DoSomethingToAllTracesInGraph("",type="smooth-B")
		"Smooth all traces, Savitsky-Golay, 5pt", DoSomethingToAllTracesInGraph("",type="smooth-SG")
		"-"
		"Differentiate all traces",DoSomethingToAllTracesInGraph("",type="differentiate")
		"--"
		"\\M0::Normalised differential conductance, i.e., (dI/dV)/(I/V)",DoSomethingToAllTracesInGraph("",type="differentiateNormalised")
		//setControlMenuItem("normConductanceCurrentLimit"), setControlMenuItemNormCondLim()
		"-"
		"Shift x-axis for all traces", ShiftTracesInGraph("")
		"-"
		"Average all traces in graph", DoSomethingToAllTracesInGraph("",type="average")
		"-"
		"FFT all traces in graph", DoSomethingToAllTracesInGraph("",type="FFT")
		"-"
		"Change x units and scaling of graph", DoSomethingToAllTracesInGraph("",type="xunits")
	End
	
	"-"
	Submenu "Analyse"
		"Extract intensities at given energy/9", getYvaluesFromGraph("")
	End
	
	"-"
	"About", SRSSPECSAbout()
	
	
	
End


