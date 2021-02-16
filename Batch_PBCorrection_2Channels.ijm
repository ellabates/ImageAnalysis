//Batch Photobleach Correction Macro for stimulated respsonse (2 Channel).
//Ella Bates.
//What it does:
//1)Opens first stack in directory. Creates a Hyperstack of the trimmed stack.
//2)Takes first 40 frames and last 40 frames of the stack and fits an exponential with offset to it.
//3)Extracts the parameters of the exponential fit and extrapolates the fit for n frames.
//4)If b>1 it divides the original stack by each value of the exponential fit at that time.
//5)Relative to the reference fluorescence taken from the Mean grey value of the first frame from the first stack.
//6)Separates the two channels and saves them as seperate tiffs with _green and _red.
//7)Saves the new tif to a second directory with the name _PBCorrected.
//8)Opens next stack in the directory and repeats.
//9)Opens all of the PBCorrected stacks in the second directory, concatenates them in chronological order.
//10)Saves the concatednated file as "Concatenated" in directory 2.

//Reset everything.
roiManager("reset");
run("Clear Results");

//Define directory and path.
dir1 = getDirectory("Choose a Directory ");
dir_green = getDirectory("Choose Green Destination Directory ");
dir_red = getDirectory("Choose Red Destination Directory ");
setBatchMode(false); 

list = getFileList(dir1);

//Open an image from dir1 chronolocically.
i=0
do {
	run("Bio-Formats Importer", "open=["+ dir1 + list[i] +"] color_mode=Default view=Hyperstack stack_order=XYCZT");
	path = getDirectory("image");
	//Reset ROI Manager, Log and Results table. 
	rename("Hyperstack");
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

	//Select each channel.
	s = 1;
	do { 
		//Define yref - the mean grey value of the first frame of your channel.
		selectWindow("Hyperstack");
		setSlice(s);
		Stack.setFrame(1);
		run("Enhance Contrast", "saturated=0.35");
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
    
  	  if (a>2) {
    		//Correct for photobleaching.
			do {      
				y=a*exp(b*f)+c;
				z=y/yref;
				selectWindow("Hyperstack");
				//Stack.setSlice(s);
				Stack.setFrame(f);
				run("Divide...", "value="  + z + " slice");
			
				f = f +1;

			} while(f<=nF);
		}
    
		//Close plots.
		close("Hyperstack-0-0");  
		close("y = a*exp(-bx) + c"); 
	 
		s = s + 1;
	
	} while(s<=2);
         
	//Split Channels and save.
	selectWindow("Hyperstack");
	setSlice(1);
	Stack.setFrame(1);
	run("Duplicate...", "duplicate channels=1");
	run("Green");
	//run("8-bit");
	//Save PB corrected stacks.
	saveAs("Tiff",dir_green+list[i]+"_PBCGreen");

	selectWindow("Hyperstack");
	setSlice(2);
	Stack.setFrame(1);
	run("Duplicate...", "duplicate channels=2");
	run("Red");
	//run("8-bit");
	//Save PB corrected stacks.
	saveAs("Tiff",dir_red+list[i]+"_PBCRed");

	//Close all wondows.
	run("Close All");

	i=i+1;
	}

	while (i < list.length);


