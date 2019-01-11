//------------------------------------------------------------------------------------------------------------------------------------
//
// KOD-SPECS-special-funcs.ipf
//
// Collection of specialized functions for fitting.
//
//------------------------------------------------------------------------------------------------------------------------------------
//
// Copyright 2013 Kane O'Donnell
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

#pragma rtGlobals=1		// Use modern global access method

//------------------------------------------------------------------------------------------------------------------------------------
// Below is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------
//
//--------------------------------------------------
// Functions for fitting NEXAFS intensity variations
//--------------------------------------------------
// Function Stohr916a(w,theta)
// Function Stohr923(w,theta)
// Function Stohr918a(w,theta)
//
//--------------------------------------------------
// Functions that add to MultiPeak functionality.
//--------------------------------------------------
// Function/S ErfStep_PeakFuncInfo(InfoDesired)
// Function GaussToErfStepGuess(w)
// Function ErfStepPeak(w, yw, xw)
// Function ErfStepPeakParams(cw, sw, outWave)
// Function/S GaussLorentz_PeakFuncInfo(InfoDesired)
// Function GaussToGaussLorentz(w)
// Function GaussLorentzPeak(w, yw, xw)
// Function GaussLorentzPeakParams(cw, sw, outWave)

//------------------------------------------------------------------------------------------------------------------------------------


// Provides Equation 9.16a from Stohr's "NEXAFS Spectroscopy" as a fitting
// function. Theta is the experimental angle between the sample surface normal
// and the polarization vector of the X-Ray beam. Alpha is the tilt angle of the 
// orbital axis with respect to the surface normal vector. Both are in degrees.
Function Stohr916a(w,theta) : FitFunc
	Wave w
	Variable theta

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(theta) = I0 * (1 + 0.5 * (3 * cos(theta*pi/180)^2 - 1) * (3 * cos(alpha*pi/180)^2 - 1))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ theta
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = I0
	//CurveFitDialog/ w[1] = alpha

	return w[0] * (1 + 0.5 * (3 * cos(theta*pi/180)^2 - 1) * (3 * cos(w[1]*pi/180)^2 - 1))
End

// Provides Equation 9.23 from Stohr's "NEXAFS Spectroscopy" as a fitting
// function. Parameters as above for Stohr916a. Equation 9.23 is the general
// case and should give identical angles to 9.16a for the SXR beamline because
// in our case P = 1. Just a good cross-check.
Function Stohr923(w,theta) : FitFunc
	Wave w
	Variable theta

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(theta) = A * ((cos(theta * pi / 180) ^ 2) * (1 - 1.5 * sin(alpha * pi / 180) ^ 2) + 0.5 * sin(alpha * pi / 180) ^ 2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ theta
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = alpha

	return w[0] * ((cos(theta * pi / 180) ^ 2) * (1 - 1.5 * sin(w[1] * pi / 180) ^ 2) + 0.5 * sin(w[1] * pi / 180) ^ 2)
End

// Provides Equation 9.18a from Stohr's "NEXAFS Spectroscopy" as a fitting function.
// Equation 9.18a is 9.16a modified to give two angles alpha1 and alpha2 that reflect
// some spread in angles (say, due to thermal motion). Requires at least 3 data points
// for fitting.
Function Stohr918a(w,theta) : FitFunc
	Wave w
	Variable theta

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(theta) = A * (1 + 0.5 * (3 * cos(theta * pi / 180) ^ 2 - 1) * (cos(alpha1 * pi / 180) ^ 2 + cos(alpha2 * pi / 180) ^ 2 + cos(alpha1 * pi / 180) * cos(alpha2 * pi / 180) - 1))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ theta
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = alpha1
	//CurveFitDialog/ w[2] = alpha2

	return w[0] * (1 + 0.5 * (3 * cos(theta * pi / 180) ^ 2 - 1) * (cos(w[1] * pi / 180) ^ 2 + cos(w[2] * pi / 180) ^ 2 + cos(w[1] * pi / 180) * cos(w[2] * pi / 180) - 1))
End

// Provides a error function step fit for the MultiPeak package. This is equation 
// 7.9a and b from Stohr using exponential decay after the step.
Function/S ErrorStep_PeakFuncInfo(InfoDesired)
	Variable InfoDesired
	
	String info=""
	
	// NOTE: I needed to use integers here because we want to be able
	// to load the SRS macros without having to load Multipeak first.
	// Here are the conversions:
	//constant PeakFuncInfo_ParamNames = 0
	//constant PeakFuncInfo_PeakFName = 1
	//constant PeakFuncInfo_GaussConvFName = 2
	//constant PeakFuncInfo_ParameterFunc = 3
	//constant PeakFuncInfo_DerivedParamNames = 4
	Switch (InfoDesired)
		case 0:
			info = "Location;Width;Height;Decay"
			break;
		case 1:
			info = "ErrorStepPeak"
			break;
		case 2:
			info = "GaussToErrorStepGuess"
			break;
		case 3:
			info = "ErrorStepPeakParams"
			break;
		case 4:
			info = "Location;Height;Area;FWHM;"		// just the standard derived parameters
			break;
		default:
			break;
	endSwitch
	
	return info
End

// This is a mandatory function for adding to Multipeak - specifying
// how to convert the parameters of a gaussian into the parameters for
// our erf step.
Function GaussToErrorStepGuess(w)
	Wave w
	
	Variable x0 = w[0]
	Variable width = w[1]
	Variable height = w[2]
	
	Redimension/N=4 w
	
	w[0] = x0
	w[1] = width
	w[2] = height
	// Guess a long decay so small decay constant
	w[3] = 0.01
	return 0
End

//	Another mandatory function for the Multipeak fitting. This function
// provides an erf step in yw over the x range of xw with parameters w.
Function ErrorStepPeak(w, yw, xw)
	Wave w
	Wave yw, xw
	
	// First step is to do the erf part
	yw = w[2] * (0.5 + 0.5 * erf((xw[p] - w[0]) / (w[1] / 2 * sqrt(ln(2)))))
	
	// Now construct a decaying exponential for x > w[0]
	Wave dw
	Make/N=(numpnts(xw)) /FREE dw
	
	dw = 1
	// You know, Stohr says to only do the decaying exponential thing above the ionization
	// edge, but it results in a discontinuity (sometimes quite extreme). So I include 
	// it for the whole range. Doesn't seem to affect the edge very much at all.
	//dw[x2pnt(xw,w[0]+w[1]),numpnts(xw)] *= exp(-1 * w[3] * (xw[p] - w[0] - w[1]))
	dw *= exp(-1 * w[3] * (xw[p] - w[0] - w[1]))
	
	yw *= dw
End

// Yet another mandatory multipeak fit function. This function provides
// the derived parameters (location and height) for our function. Area
// is not very useful, nor is FWHM.
// NOTE: the parameters are STUPIDLY NAMED here - use the documentation
// source code to figure out why I've put things where as there are too many
// to document.
Function ErrorStepParams(cw, sw, outWave)
	Wave cw, sw, outWave
	
	// Location
	outWave[0][0] = cw[0]
	outWave[0][1] = sqrt(sw[0][0])
	
	// Height
	outWave[1][0] = cw[2]
	outWave[1][1] = sqrt(sw[2][2])
	
	// Area: just use the left half (ie, the bit before the edge, half a gaussian)
	// because we don't really care about the area.
	outWave[2][0] = cw[2] * cw[1] * sqrt(Pi) / 2
	outWave[2][1] = NaN // Don't use this as an error estimate since we're fudging.
	
	// FWHM - again, use the gaussian width and the standard formula.
	outWave[3][0] = cw[1] * 2 * sqrt(ln(2))
	outWave[3][1] = NaN
End

// Provides a gaussian-lorentzian (the sum verion G+L).
Function/S GaussLorentz_PeakFuncInfo(InfoDesired)
	Variable InfoDesired
	
	String info=""
	
	// NOTE: I needed to use integers here because we want to be able
	// to load the SRS macros without having to load Multipeak first.
	// Here are the conversions:
	//constant PeakFuncInfo_ParamNames = 0
	//constant PeakFuncInfo_PeakFName = 1
	//constant PeakFuncInfo_GaussConvFName = 2
	//constant PeakFuncInfo_ParameterFunc = 3
	//constant PeakFuncInfo_DerivedParamNames = 4
	Switch (InfoDesired)
		case 0:
			info = "Location;GaussWidth;LorentzWidth;Height;Mix"
			break;
		case 1:
			info = "GaussLorentzPeak"
			break;
		case 2:
			info = "GaussToGaussLorentzGuess"
			break;
		case 3:
			info = "GaussLorentzPeakParams"
			break;
		case 4:
			info = "Location;Height;Area;FWHM;"		// just the standard derived parameters
			break;
		default:
			break;
	endSwitch
	
	return info
End

// This is a mandatory function for adding to Multipeak - specifying
// how to convert the parameters of a gaussian into the parameters for
// our gaussian+lorentzian.
Function GaussToGaussLorentzGuess(w)
	Wave w
	
	Variable x0 = w[0]
	Variable width = w[1]
	Variable height = w[2]
	
	Redimension/N=5 w
	
	w[0] = x0
	w[1] = width
	w[2] = width // Initially set them to equal widths
	w[3] = height
	// Guess a 15% Lorentzian mix
	w[4] = 0.15
	return 0
End

//	Another mandatory function for the Multipeak fitting. This function
// provides the sum of a gaussian and lorentzian in yw over the x range of xw with parameters w.
Function GaussLorentzPeak(w, yw, xw)
	Wave w
	Wave yw, xw
	
	print "GL with w = ", w
	Variable g_prefactor  = 1.0 / (w[1] * sqrt(2*Pi))
	Variable l_prefactor = w[2] / (2 * Pi)
	// Gaussian bit - this is NOT normalized (so that the width
	// and height are decoupled).
	yw = w[3] * (1 - w[4]) * exp(-1.0 * (xw[p] - w[0])^2 / (2.0 * w[1]^2))
	
	// Lorentzian bit - again, not normalized and height is decoupled from
	// width so the maximum is just the height * mixing fraction
	yw += w[3] * w[4] / (1 + 4 * (xw[p] - w[0])^2 / (w[2]^2))
	
End

// Yet another mandatory multipeak fit function. This function provides
// the derived parameters (location and height) for our function.
// NOTE: the parameters are STUPIDLY NAMED here - use the documentation
// source code to figure out why I've put things where as there are too many
// to document.
Function GaussLorentzParams(cw, sw, outWave)
	Wave cw, sw, outWave
	
	// Because we've defined our Gaussian and Lorentzians differently here we
	// need to be careful - can't just copy from the MultiPeak functions.
	
	// Convenience unpack of the variables
	Variable s = cw[1]
	Variable G = cw[2]
	Variable h = cw[3]
	Variable m = cw[4]
	Variable dh = sqrt(sw[3][3])
	Variable dm = sqrt(sw[4][4])
	Variable ds = sqrt(sw[1][1])
	Variable dG = sqrt(sw[2][2])
		
	// Location
	outWave[0][0] = cw[0]
	outWave[0][1] = sqrt(sw[0][0])
	
	// Height
	outWave[1][0] = h
	outWave[1][1] = sqrt(sw[3][3])
	
	// Area: this is just the weighted sum of the two
	// bits.
	// The usual error expression based on differentials with respect to all the
	// variables.
	outWave[2][0] =h * ((1 - m) * s * sqrt(2*Pi) + m * (Pi * G) / 2)
	outWave[2][1] = ((1 - m) * sqrt(2 * Pi) * s + m * Pi * G / 2) * dh + (h * Pi * G / 2 - h * sqrt(2 * Pi) * s) * dm + h * (1 - m) * sqrt(2 * Pi) * ds + (h * m * Pi / 2) * dG
	//outWave[2][1] = NaN
	
	// FWHM -One day will actually fill this in...for now it is
	// the FWHM of the gaussian component. 
	outWave[3][0] = cw[1] * 2 * sqrt(ln(2))
	outWave[3][1] = NaN
	
	print "Variables:"
	print cw[0], s, G, h, m, outWave[2][1]
End