//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS.ipf
//
// Initialisation file for SRS macros for Igor Pro
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
#pragma IgorVersion=6.2

Static StrConstant titleSTM=      	"SRS STM: A Macro Package for Igor Pro to Analyse STM and STS Data"
Static StrConstant titleSPECS=   	"SRS SPECS: A Macro Package for Igor Pro to Analyse Photoelectron Spectroscopy Data"
Static StrConstant versioninfo= 	"Version 0.81 (June 2015), writen for Igor Pro 6.37 (on a Macbook Pro running Mac OS X 10.10.4 Yosemite)"
Static StrConstant author=   	"Steven R. Schofield, University College London"
Static StrConstant email=      	"steven.schofield@physics.org"


Menu ""
End

//------------------------------------------------------------------------------------------------------------------------------------
Function SRSSTMAbout()
	print "\r", titleSTM, "\r", versioninfo, "\r", author, "\r", email, "\r\r"
End


//------------------------------------------------------------------------------------------------------------------------------------
Function SRSSPECSAbout()
	print "\r", titleSPECS, "\r", versioninfo, "\r", author, "\r", email, "\r\r"
End


//------------------------------------------------------------------------------------------------------------------------------------
// add menu items to the Analysis menu for loading the package(s)
Menu "Macros"
//	Submenu "Packages"
		"SRS STM", /Q, SRSSTM()
		"SRS SPECS", /Q, SRSSPECS()
//	End
End


//------------------------------------------------------------------------------------------------------------------------------------
Function SRSSTM()
	SRSsetPath()
	Execute/P/Q "SRSSTMAbout()"		// Execute operation executes the contents of cmdStr  as if it had been typed.  /P means wait until nothing else going on.  /Q don't display command on line
	Execute/P/Q "INSERTINCLUDE \"SRS-STM-initialise\""
	Execute/P/Q "COMPILEPROCEDURES "	// COMPILEPROCEDURES does just what it says, compiles procedures
	Execute/P/Q "KillVariables/Z V_Flag"
	SetIgorHook BeforeFileOpenHook = SRSFileOpenHook	//function that Igor calls when a file is about to be opened by Igor because the user dragged it onto the Igor icon
	Execute/P/Q "createSRScontrolvariables(forced=\"yes\")"
	return 0
End


//------------------------------------------------------------------------------------------------------------------------------------
Function SRSSPECS()
	SRSsetPath()
	Execute/P/Q "SRSSPECSAbout()"		// Execute operation executes the contents of cmdStr  as if it had been typed.  /P means wait until nothing else going on.  /Q don't display command on line
	Execute/P/Q "INSERTINCLUDE \"SRS-SPECS-initialise\""
	Execute/P/Q "COMPILEPROCEDURES "	// COMPILEPROCEDURES does just what it says, compiles procedures
	Execute/P/Q "KillVariables/Z V_Flag"
	SetIgorHook BeforeFileOpenHook = SRSFileOpenHook	//function that Igor calls when a file is about to be opened by Igor because the user dragged it onto the Igor icon
	return 0
End


//------------------------------------------------------------------------------------------------------------------------------------
// Create symbolic path links to important directories
Static Function SRSsetPath()
	
	// Get the name of the Igor Pro User Files directory
	String IgorUserProceduresPath = SpecialDirPath("Igor Pro User Files", 0, 0, 0) + "User Procedures:"
	
	// Check that the folder "SRS" exists and make a path shortcut to it
	GetFileFolderInfo/Q/Z(IgorUserProceduresPath+"SRS:")
	if(V_Flag)
		Print "ERROR: SRS procedures folder not found."
		return 1
	else
		String SRSPathStr = S_path
		NewPath/O/Q/Z SRS, SRSPathStr
	endif
	
	// Make path shortcut to the colour table directory
	GetFileFolderInfo/Q/Z (SRSPathStr+"ctab")
	if(V_Flag)
		Print "ERROR: ctab folder not found under SRS folder."
		return 1
	else
		String SRSctabPathStr = S_path
		NewPath/O/Q/Z SRSctab, SRSctabPathStr
	endif
	
	// Make path shortcut to the SRS:func directory
	GetFileFolderInfo/Q/Z (SRSPathStr+"func")
	if(V_Flag)
		Print "ERROR: func folder not found under SRS folder."
		return 1
	else
		String SRSfuncPathStr = S_path
		NewPath/O/Q/Z SRSfunc, SRSfuncPathStr
	endif
	
	// Get the name of the user documents directory
	String documentsPathStr = SpecialDirPath("Documents", 0, 0, 0)
	GetFileFolderInfo/Q/Z (documentsPathStr)
	if(V_Flag)
		Print "ERROR: Documents folder not found"
		return 1
	else
		NewPath/O/Q/Z UserDocuments, documentsPathStr
	endif
	
	// Get the name of the user desktop directory
	String desktopPathStr = SpecialDirPath("Desktop", 0, 0, 0)
	GetFileFolderInfo/Q/Z (desktopPathStr)
	if(V_Flag)
		Print "ERROR: Desktop folder not found"
		return 1
	else
		NewPath/O/Q/Z UserDesktop, desktopPathStr
	endif
	
	// Clean up
	KillVariables/Z V_Flag
	
End
