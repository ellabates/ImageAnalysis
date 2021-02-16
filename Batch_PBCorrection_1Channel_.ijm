//Batch Photobleach Correction Macro for stimulated respsonse (1 Channel).
//Ella Bates.
//What it does:
//1)Opens first stack in directory. Creates a Hyperstack of the trimmed stack.
//2)Takes first 40 frames and last 40 frames of the stack and fits an exponential with offset to it.
//3)Extracts the parameters of the exponential fit and extrapolates the fit for n frames.
//4)If b<1 it divides the original stack by each value of the exponential fit at that time.
//5)Relative to the reference fluorescence taken from the Mean grey value of the first frame from the first stack.
//6)Saves the new tif to a second directory with the name _PBCorrected.
//7)Opens next stack in the first directory and repeats.
//8)Opens all of the PBCorrected stacks in the second directory, concatenates them in chronological order.
//9)Saves the concatednated file as "Concatenated" in directory 2.

//Reset everything.
roiManager("reset");
run("Clear Results");

//Define directory and path.
dir1 = getDirectory("Choose a Directory ");
dir2 = getDirectory("Choose Destination Directory ");

list = getFileList(dir1);

//Open an image from dir1 chronolocically.
i=0;

do {
	//run("Bio-Formats Importer", "open= + dir1 + list[i] color_mode=Default view=Hyperstack stack_order=XYCZT");
 
	open(dir1+list[i]);
	path = getDirectory("image");

	//Reset ROI Manager, Log and Results table. 
	rename("Hyperstack");
	run("Enhance Contrast", "saturated=0.35");
	roiManager("reset");	
	run("Select None");
	run("Clear Results");

	//Set to measure mean intensity values of ROIs, select tool.
	run("Set Measurements...", "  mean redirect=None decimal=12");
	setTool("rectangle");

	//Set ROI of the entire image and add it. 
	run("Select All");
	roiManager("Add");
	roiManager("Select", 0);

	//Get the stack dimentions.
	getDimensions(width, height, channels, slices, frames);
	nF = frames;

	//Define yref - the mean grey value of the first frame.
	selectWindow("Hyperstack");
	Stack.setFrame(1);
	roiManager("Measure"); 
	yref = getResult("Mean",0);


	//Get the x,y valyes of the current slice.
	run("Plot Z-axis Profile", "profile=time");
	Plot.getValues(xpoints, ypoints);

	//Create an array of the first 40 and last 40 points.
	xstart= Array.slice(xpoints, 0, 5);
	ystart= Array.slice(ypoints, 0, 5);

	xend= Array.slice(xpoints, xpoints.length-5);
	yend= Array.slice(ypoints, ypoints.length-5);

	v = Array.concat(xstart, xend);
	w = Array.concat(ystart, yend);

	//Fit Exponential.
	Fit.doFit("Exponential with Offset", v, w);
	Fit.plot;

	//Get parameters.
	a=Fit.p(0);
	b=Fit.p(1);
	c=Fit.p(2);

	//Set frame to 1.
    f = 1;
    
//    if (a>2) {
    	//Correct for photobleaching.
		do {      
			y=a*exp(-b*f)+c;
			z=y/yref;
			selectWindow("Hyperstack");
			Stack.setFrame(f);
			run("Divide...", "value="  + z + " slice");
			f = f +1;

			} while(f<=nF);

//    }

	run("Enhance Contrast", "saturated=0.35");
    
	//Close plots.
	close("Hyperstack-0-0");  
	close("y = a*exp(-bx) + c"); 

	//Save PB corrected stacks.
	saveAs("Tiff",dir2+list[i]+"_PBCorrected");

	//Close all wondows.
	run("Close All");

	i=i+1;
	}
	while (i < list.length);

//Open all the PB Corrected images in directory2.
list = getFileList(dir2);

open(list[0]);
rename("Img1");

//Concatenate all of the PB Corrected images.
for (i=1; i<list.length; i++) {
	open(list[i]);
	rename("Img2");
	run("Concatenate...", " title=[Img1] open image1=Img1 image2=Img2");

	}

run("Enhance Contrast", "saturated=0.35");
//Save all of the PB Corrected images.
saveAs("Tiff",dir2+"Concatenated");
run("Close All");
