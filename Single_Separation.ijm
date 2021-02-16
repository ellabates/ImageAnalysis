//Separates two channels and saves them.
i=1

//Define directory and path.
dir2 = getDirectory("Choose Green/red Destination Directory ");
//setBatchMode(false); 


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
	saveAs("Tiff",dir2+i+"_PBCGreen");

	selectWindow("Hyperstack");
	setSlice(2);
	Stack.setFrame(1);
	run("Duplicate...", "duplicate channels=2");
	run("Red");
	//run("8-bit");
	//Save PB corrected stacks.
	saveAs("Tiff",dir2+i+"_PBCRed");

	//Close all wondows.
	run("Close All");