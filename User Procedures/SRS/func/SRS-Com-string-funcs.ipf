//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-Com-string-funcs.ipf
//
// Collection of functions for working with strings
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
// Function/S removeBadChars(str)
// Function/S removeSpace(str)
// Function/S possiblyRemoveQuotes(name)
// Function/S definitelyRemoveQuotes(str)
// Function/S replaceNonSpaceWhitespace(str)
// Function/S sciunit(numStr)
// Function/S EverythingAfterLastColon(str)
// Function/S possiblyRemoveHash(str)
// Function/S replaceHyphen(str)
// Function/S replaceSpace(str)
//Function StringByKeyNumberOfInstances(matchStr,listStr,[sepChar])
//Function/S StringByKeyIndexed(instance,matchStr,listStr,[sepChar])
//
//------------------------------------------------------------------------------------------------------------------------------------
// Above is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------
// Takes a string as input and removes bad characters
// Bad Chars=  
// : ; + = , ( )
//------------------------------------------------------------------------------------------------------------------------------------
Function/S removeBadChars(str)
	String str
	
	Variable len=strlen(str)
	Variable i
	Variable j=0
	String newstr= ""
	String char= ""
	for (i=0; i<len; i+=1)
		char=str[i]
		strswitch(char)
			case ".":
				// Do nothing
				break
			case ":":
				// Do nothing
				break
			case ";":
				// Do nothing
				break
			case "+":
				// Do nothing
				break
			case "=":
				// Do nothing
				break
			case "(":
				// Do nothing
				break
			case ")":
				// Do nothing
				break
			case ",":
				// Do nothing
				break
			default:
				newstr[j]= char
				j+=1
				break
		endswitch
	endfor
	
	return newstr
End

//
// ---
//
Function/S removeEscapeChars(str)
	String str
	
	Variable len=strlen(str)
	Variable i
	Variable j=0
	String newstr= ""
	String char= ""
	for (i=0; i<len; i+=1)
		char=str[i]
		strswitch(char)
			case "\r":
				// Do nothing
				break
			case "\t":
				// Do nothing
				break
			case "\n":
				// Do nothing
				break
			default:
				newstr[j]= char
				j+=1
				break
		endswitch
	endfor
	
	return newstr
End

//
// ---
//
Function/S EscapeLaTeXChars(str)
	String str
	
	Variable len=strlen(str)
	Variable i
	Variable j=0
	String newstr= ""
	String char= ""
	for (i=0; i<len; i+=1)
		char=str[i]
		strswitch(char)
			case "&":
				char="\&"
				newstr[j]= char
				j+=2
				break
			default:
				newstr[j]= char
				j+=1
				break
		endswitch
	endfor
	
	return newstr
End

//
// --- 
// 0 = all lower case
// 1 = all upper case
// 2 = only first letter capitalised
// 3 = Capital words
//
Function/S CheckCaps(str,mode)
	String str
	Variable mode
	
	Variable len=strlen(str)
	Variable i
	Variable j=0
	String newstr= ""
	String char= ""
	Variable capnext=1
	for (i=0; i<len; i+=1)
		char=str[i]
		Switch (mode)
			Case 0:
				// all lower case	
				if ( char2num(char) >= 65 && char2num(char) <= 90)
					newstr[i]= num2char(char2num(char)+32)
				else 
					newstr[i] = char
				endif
				break
			Case 1:
				// all upper case	
				if ( char2num(char) >= 97 && char2num(char) <= 122)
					newstr[i]= num2char(char2num(char)-32)
				else 
					newstr[i] = char
				endif
				break
			Case 2:
				if ( i==0 )
					// capitalise
					if ( char2num(char) >= 97 && char2num(char) <= 122)
						newstr[i]= num2char(char2num(char)-32)
					else 
						newstr[i] = char
					endif
					capnext = 0
				else 
					// lower case	
					if ( char2num(char) >= 65 && char2num(char) <= 90)
						newstr[i]= num2char(char2num(char)+32)
					else 
						newstr[i] = char
					endif
				endif
				break
			Case 3:
				if ( capnext==1 )
					// capitalise
					if ( char2num(char) >= 97 && char2num(char) <= 122)
						newstr[i]= num2char(char2num(char)-32)
					else 
						newstr[i] = char
					endif
					capnext = 0
				else 
					// lower case	
					if ( char2num(char) >= 65 && char2num(char) <= 90)
						newstr[i]= num2char(char2num(char)+32)
					else 
						newstr[i] = char
					endif
				endif
				if (cmpstr(char," ")==0)
					capnext=1
				endif
				break
			Default: 
				Print "ERROR: unknown mode.  0 = all lower case; 1 = all upper case; 2 = only first letter capitalised; 3 = Capital words; "
				newstr = str
				break
		endswitch
	endfor
	
	return newstr
End

//
// --- Si, Ge, etc.
//
Function/S SpecialTitleChars(str)
	String str
	
	Variable len=strlen(str)
	String specialStr, specialStrRep
	Variable sslen 
	Variable i,j
	
	// Could code the below more sensibly, but for the moment I'm doing just a cut and paste the whole block approach (lazy)

	String WList1 = " H ; Li ; Na ; K; Rb ; Cs ; Fr ; Mg ; Ca ; Sr ; Ba ; Ra ; B ; Al ; Ga ; C ; Si ; Ge ; Sn ; Pb ; N ; P ; Sb ; Bi ; O ; S ; Se ; Te ; Po ; F ; Cl ; Be ; Ne ; Ar ; Kr ; Xe ;"
	String WList2 = "Si(;Ge(;)H;):H;P-in-Si;CaC6;"
	String WList3 = " V ; STM ; STS ; STM/STS; DFT "
	
	String WordList= WList1+WList2	+WList3
	Variable items = itemsinlist(WordList,";")	
// -- 
	for ( j=0; j<items;j+=1)
		specialStrRep= stringfromlist(j,WordList)
		specialStr = CheckCaps(specialStrRep,0)
		sslen = strlen(specialStr)
		for (i=0; i<len-sslen+1; i+=1)
			if ( cmpstr(str[i,i+sslen-1],specialStr)==0 )
				str[i,i+sslen-1] = specialStrRep
			endif
		endfor
	endfor
	
	return str
End

Function/S SpecialTitleCharsSRS(str)
	String str
	
	Variable len=strlen(str)
	String specialStr, specialStrRep
	Variable sslen 
	Variable i,j
	
	// Could code the below more sensibly, but for the moment I'm doing just a cut and paste the whole block approach (lazy)

	String W_List1 = "c-type"
	String WRList1 = "C-type"
	
	String W_List2 = "" //"2 x 1"
	String WRList2 = "" //"$2\\times1$"
	
	String W_List3 = "" // "2x1"
	String WRList3 = "" //"$2\\times1$"
	
	String W_List4 = "transformation of C-type"
	String WRList4 = "Transformation of C-type"
	
	String W_List5 = "valence surface electronic states on Ge"
	String WRList5 = "Valence surface electronic states on Ge"
	
	String W_List6 = "P and as dopants"
	String WRList6 = "P and As dopants"
	
	String W_List7 = "CaC6"
	String WRList7 = "CaC$_6$"
	
	String W_List8 = "PH3"
	String WRList8 = "PH$_3$"
	
	String WordList= W_List1+";"+W_List2+";"+W_List3+";"+W_List4+";"+W_List5+";"+W_List6+";"+W_List7+";"+W_List8
	String WordReplacementList= WRList1+";"+WRList2+";"+WRList3+";"+WRList4+";"+WRList5+";"+WRList6+";"+WRList7+";"+WRList8
	Variable items = itemsinlist(WordList,";")	
// -- 
	for ( j=0; j<items;j+=1)
		specialStrRep= stringfromlist(j,WordReplacementList)
		specialStr = stringfromlist(j,WordList)
		sslen = strlen(specialStr)
		for (i=0; i<len-sslen+1; i+=1)
			if ( cmpstr(str[i,i+sslen-1],specialStr)==0 )
				str[i,i+sslen-1] = specialStrRep
			endif
		endfor
	endfor
	
	return str
End



//
// ---
//
Function/S formatAuthor(str)
	String str
	
	String d0, d1, d2, d3, d4, d5, d6, d7, d8, d9
	sscanf str, "%s %s %s %s %s %s %s %s %s %s", d0, d1, d2, d3, d4, d5, d6, d7, d8, d9
	
	String sName, mName, fName, fullName
	Variable sNameLen, mNameLen, fNameLen
	
	// Default allocation
	fullName = str
	
	// Assume surname first, then first name, then middle name
	sName = d0
	fName = d1
	mName = d2
	
	// Print warning if other names present
	if ( strlen(d3+d4+d5+d6+d7+d8+d9)>0 )
		Print "WARNING: some text lost in name:", str
	endif
	
	// Remove "." "," ";" etc
	sName = removeBadChars(sName)
	mName = removeBadChars(mName)	
	fName = removeBadChars(fName)	
	
	// get string lengths
	sNameLen = strlen(sName)
	fNameLen = strlen(fName)
	mNameLen = strLen(mName)
	
	// Make sure correct capitalisation
	sName = CheckCaps(sName,2)
	fName = CheckCaps(fName,2)
	mName = CheckCaps(mName,2)
	
	// replace first and middle names with initial only.
	if ( fNameLen>1 )
		fName = fName[0]
	endif
	if ( mNameLen>1 )
		mName = mName[0]
	endif
	
	If (mNameLen > 0)
		fullName = fName+".~"+mName+".~"+sName
	else
		fullName = fName+".~"+sName
	endif
	
	return fullName
	
End

//------------------------------------------------------------------------------------------------------------------------------------
// Takes a string as input and removes bad characters and replaces them with "_"
// Bad Chars=  
// : ; + = , ( )
//------------------------------------------------------------------------------------------------------------------------------------
Function/S replaceBadChars(str)
	String str
	
	Variable len=strlen(str)
	Variable i
	Variable j=0
	String newstr= ""
	String char= ""
	for (i=0; i<len; i+=1)
		char=str[i]
		strswitch(char)
			case ".":
				newstr[j]= "_"
				j+=1
				break
			case ":":
				newstr[j]= "_"
				j+=1
				break
			case ";":
				newstr[j]= "_"
				j+=1
				break
			case "+":
				newstr[j]= "_"
				j+=1
				break
			case "=":
				newstr[j]= "_"
				j+=1
				break
			case "(":
				newstr[j]= "_"
				j+=1
				break
			case ")":
				newstr[j]= "_"
				j+=1
				break
			case ",":
				newstr[j]= "_"
				j+=1
				break
			default:
				newstr[j]= char
				j+=1
				break
		endswitch
	endfor
	
	return newstr
End


//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
Function/S removeSpace(str)
	String str
	
	Variable len=strlen(str)
	Variable i
	Variable j=0
	String newstr= ""
	String char= ""
	for (i=0; i<len; i+=1)
		char=str[i]
		strswitch(char)
			case " ":
				// Do nothing
				break
			default:
				newstr[j]= char
				j+=1
				break
		endswitch
	endfor
	
	return newstr
End



//--------------------------------------------------------------------------------------------------------------
// Remove the quotes from wave names if they exist
//------------------------------------------------------------------------------------------------------------------------------------
Function/S possiblyRemoveQuotes(name)
	String name
	
	Variable len
	len = strlen(name)

	Variable beginningQuote=0
	if (cmpstr(name[0],"'")==0)
		beginningQuote=1
	endif
	
	Variable endingQuote=0
	if (cmpstr(name[0],"'")==0)
		endingQuote=1
	endif
	
	String newName = name[0+beginningQuote,len-endingQuote-1]
	
	return newName
End


//--------------------------------------------------------------------------------------------------------------
// Remove the quotes from wave names if they exist  *******DELETE THIS ONE AND REPLACE WITH THE ABOVE*****
//Function/S possiblyRemoveQuotesSpecs(name)
//	String name
//	
//	Variable len
//	len = strlen(name)//
//
//	Variable beginningQuote=0
//	if (cmpstr(name[0],"'")==0)
//		beginningQuote=1
//	endif
//	
//	Variable endingQuote=0
//	if (cmpstr(name[0],"'")==0)
//		endingQuote=1
//	endif
//	
//	String newName = name[0+beginningQuote,len-endingQuote-1]
//	
//	return newName
//End

//--------------------------------------------------------------------------------------------------------------
// Remove the quotes from wave names if they exist
//--------------------------------------------------------------------------------------------------------------
Function/S definitelyRemoveQuotes(str)
	String str
	String newstr, substring
	Variable i, j
	
	// Recursive (hold on to your hats!). If string has a single quote, split on that quote,
	// search for another. If you find another, make the text between the quotes "nice"
	// then patch on the bit before the first quote and the removed-quote version of the tail.
	
	
	i = strsearch(str, "'", 0)
	If (i == -1)
		// No quotes found
		return str
	Else
		newstr = str[0,i-1]
		j = strsearch(str, "'", i+1)
		If (j == -1)
			newstr += str[i+1, strlen(str)]
			return newstr
		Else
			substring = removeSpace(removeBadChars(str[i+1,j-1]))
			newstr += substring + definitelyRemoveQuotes(str[j+1,strlen(str)])
			return newstr
		EndIf
	EndIf
End

//--------------------------------------------------------------------------------------------------------------
// Replace non-space whitespace (i.e. evil invisible characters) with spaces.
//--------------------------------------------------------------------------------------------------------------
Function/S replaceNonSpaceWhiteSpace(str)
	String str
	String newstr = ""
	Variable i
	
	// Note: yes, this can also be done recursively in theory, but it runs up against Igor's
	// recursion limit when you actually implement it. Mwahahahahaha.
	For (i=0; i<strlen(str);i+=1)
		If (GrepString(str[i], "\\s"))
			newstr += " "
		Else
			newstr += str[i]
		EndIf
	EndFor
	
	return newstr
End
	

//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
Function/S sciunit(numStr)
	String numStr
	
	Variable num
	String unit
	
	// separate the number from the unit
	sscanf numStr, "%f%s", num, unit
	
	String returnStr
	String newunit = unit
	Variable newnum = num
	
	// milli
	if ( ( abs(num) / 1e-3 >= 1 ) && ( abs(num) / 1 < 1 ))
		newnum = num / 1e-3
		newunit = "m"+unit
	endif
	
	// micro
	if ( ( abs(num) / 1e-6 >= 1 ) && ( abs(num) / 1 < 1e-3 ))
		newnum = num / 1e-6
		newunit = "micro"+unit
	endif
	
	// nano
	if ( ( abs(num) / 1e-9 >= 1 ) && ( abs(num) / 1 < 1e-6 ))
		newnum = num / 1e-9
		newunit = "n"+unit
	endif
	
	// pico 
	if ( ( abs(num) / 1e-12 >= 1 ) && ( abs(num) / 1 < 1e-9 ))
		newnum = num / 1e-12
		newunit = "p"+unit
	endif
	
	// fempto 
	if ( ( abs(num) / 1e-15 >= 1 ) && ( abs(num) / 1 < 1e-12 ))
		newnum = num / 1e-15
		newunit = "f"+unit
	endif
	
	returnStr = num2str(newnum)+" "+newunit
	
	return returnStr
	
End


//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
Function/S EverythingAfterLastColon(str)
	String str
	
	Variable i, c, len
	String returnstr = ""
	
	c = 0
	len = strlen(str)
	for ( i=0; i<len ; i+=1 )
		returnstr[c]= str[i]
		c += 1
		if ( cmpstr(str[i],":") == 0 )
			returnstr = ""
			c = 0
		endif
	endfor
	
	return returnstr
End


//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
Function/S possiblyRemoveHash(str)
	String str
	
	String newstr= ""
	Variable i=0
	Variable j=0
	Variable len= strlen(str)
	for (i=0; i<len;i+=1)
		if (cmpstr(str[i],"#")==0)
			// do nothing
		else
			newstr[j]=str[i]
			j+=1
		endif
	endfor
	return newstr
End
				
		
//------------------------------------------------------------------------------------------------------------------------------------
// Replaces "-" with "_"
//------------------------------------------------------------------------------------------------------------------------------------
Function/S replaceHyphen(str)
	String str
	
	Variable len=strlen(str)
	Variable i
	String newstr= ""
	String char= ""
	for (i=0; i<len; i+=1)
		char=str[i]
		strswitch(char)
			case "-":
				newstr[i]= "_"
				break
			default:
				newstr[i]= char
				break
		endswitch
	endfor
	
	return newstr
End


		
//------------------------------------------------------------------------------------------------------------------------------------
// Replaces " " with "_"
//------------------------------------------------------------------------------------------------------------------------------------
Function/S replaceSpace(str)
	String str
	
	Variable len=strlen(str)
	Variable i
	String newstr= ""
	String char= ""
	for (i=0; i<len; i+=1)
		char=str[i]
		strswitch(char)
			case " ":
				newstr[i]= "_"
				break
			default:
				newstr[i]= char
				break
		endswitch
	endfor
	
	return newstr
End

//----------------------------------------------------------------------------------
// counts the number of times a particular key word appears in a list
//----------------------------------------------------------------------------------
Function StringByKeyNumberOfInstances(matchStr,listStr,[sepChar])
	String matchStr,listStr,sepChar
	
	Variable i // for loops
	Variable instanceCount=0
	String tmpStr
	
	// default to semicolon for the separation character
	if ( paramIsDefault(sepChar) )
		sepChar = ";"
	endif

	// count the instances in the list
	for (i=0; i<999; i+=1 )
		tmpStr = stringFromList(i,listStr,sepChar)
		if ( strlen(tmpStr)==0 )  
			break // reached the end of the list
		endif
		if ( strlen(StringByKey(matchStr,tmpStr))==0 )
			// do nothing
		else 
			instanceCount+=1  // increment the instance count
		endif
	endfor
	
	return instanceCount
	
End

//----------------------------------------------------------------------------------
// counts the number of times a particular key word appears in a list
//----------------------------------------------------------------------------------
Function/S StringByKeyIndexed(instance,matchStr,listStr,[sepChar])
	Variable instance
	String matchStr,listStr,sepChar
	
	// default to semicolon for the separation character
	if ( paramIsDefault(sepChar) )
		sepChar = ";"
	endif
	
	Variable i // for loops
	Variable instanceCount=0
	String tmpStr
	
	// find out how many instances in total
	Variable instanceTotal = StringByKeyNumberOfInstances(matchStr,listStr,sepChar=sepChar)	
	
	if ( instance > instanceTotal-1 )
		Print "ERROR: There are only", instanceTotal, "instances in the list (the first instance is numbered 0)"
		return  ""
	endif
	
	// 	get the instance from the list
	for (i=0; i<999; i+=1 )
		tmpStr = stringFromList(i,listStr,sepChar)
		if ( strlen(StringByKey(matchStr,tmpStr))==0 )
			// do nothing
		else 
			if ( instanceCount >= instance)
				break
			endif
			instanceCount+=1  // increment the instance count
		endif
	endfor
	String returnStr = StringByKey(matchStr,tmpStr)

	return returnStr
	
End









// This is a numerical, not a string function, but I'm putting it in this procedure file for the moment
// since I do not have one of these for numerical things...
Function roundSignificant(val,N)	// round val to N significant figures
	Variable val			// input value to round
	Variable N			// number of significant figures

	if (val==0 || numtype(val))
		return val
	endif
	Variable is,tens
	is = sign(val) 
	val = abs(val)
	tens = 10^(N-floor(log(val))-1)
	return is*round(val*tens)/tens
End