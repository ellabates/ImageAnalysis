#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//Multiplies each value in a wave by -1
Function Negative(inputwave3,inputwave4)
Wave inputwave3, inputwave4

MatrixOP/O NegativeConcatenated_Green = inputwave3*(-1)
MatrixOP/O NegativeConcatenated_Red = inputwave4*(-1)

Wave NegativeConcatenated_Green = $"NegativeConcatenated_Green"
Wave NegativeConcatenated_Red = $"NegativeConcatenated_Red"
end