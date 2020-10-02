// #### CMM Lab Fibril Orientation Analyser ####
// #### CMM Lab website (www.matrixandmetastasis.com) ####
// #### CMM Lab GitHub (www.github.com/tcox-lab) ####

// This script is designed to automate the quantification of pixel orientation of two-photon second harmonic generation imaging of collagen fibres
// It wraps the B.I.G. OrientationJ plugin into a batch process script that applies pre-processing and iterates through entire directories including 
// all sub-directories of images outputting the colour overlay and text file of histogram values.
// #### This scripts requires the OrientationJ plugin to run ####
// See https://github.com/Biomedical-Imaging-Group/OrientationJ for more information on the OrientationJ Plugin
// Briefly, the orientation is evaluated for every pixel of the image based on the structure tensor. A histogram of orientations is built taking 
// into account pixels that have a coherency larger than 'min-coherency' and an energy larger than 'min-energy'. 

//Set script version number
ver = "1.16"
requires("1.38m"); // Check for compatible ImageJ/FIJI version

// Create Date and Time stamps for the output files
MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
TimeString = "";
if (dayOfMonth<10) {TimeString = TimeString+"0";}
TimeString = TimeString+dayOfMonth+" "+MonthNames[month]+" "+year+" ";
if (hour<10) {TimeString = TimeString+"0";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute;

// For cross-platform applicability
fs = File.separator;

// Close all currently open images
run("Close All");

// Setup variables for analysis
FiTy=".xxx";
ImTen = 4; // Minimum Tensor value - value of the standard deviation of the Gaussian local window of the structure tensor
ImGra = 0; // Gradient used (0: Cubic Spline, 1: Finite difference, 2: Fourier; 3: Riesz, 4: Gaussian)
ImCoh = 1; // Minimum Coherency - The ratio between the difference and the sum of the tensor eigenvalues
ImEne = 1; // Minimum Energy value - The energy parameter is the trace of the tensor matrix
EditAdv = 0; // Edit advance settings
EditPre = 0; // Edit pre-processing steps
Pre8b = 0; // Pre-processing Convert to 8-bit
PreSh = 0; // Pre-processing Sharpen
PreDe = 0; // Pre-processing Despeckle
PostEn = 0; // Enhance Brightness/Contrast of Output Images (does NOT affect analysis)
BrTh = 10; // Brightness minimum threshold
MemMon = 0; // Launch memory monitor (debugging)
Bat = 0; // Batch mode setting for silent processing

// Create Dialog window to accept user inputs
Dialog.create("CMM Lab Orientation Analyser Settings");
Dialog.addString("Specify File Type", FiTy);
Dialog.addNumber("Tensor:", ImTen);
Dialog.addCheckbox("Image Pre-Processing", true);
Dialog.addCheckbox("Advanced Settings", false);
Dialog.addCheckbox("Launch Memory Monitor [Debugging]", false);
Dialog.addCheckbox("Batch mode on [Faster]", true);
Dialog.show();
FiTy = Dialog.getString();
ImTen = Dialog.getNumber();
EditPre = Dialog.getCheckbox();
EditAdv = Dialog.getCheckbox();
Mem = Dialog.getCheckbox();
Bat = Dialog.getCheckbox();
if (EditPre==true) EditPre = 1;
if (EditAdv==true) EditAdv = 1;
if (Mem==true) MemMon = 1;
if (Bat==true) Bat = 1;
if (EditPre==1){
	Dialog.create("Pre-Processing Steps");
	Dialog.addMessage("Only change these settings\nif you know what you are doing");
	Dialog.addCheckbox("8-bit Conversion", true);
	Dialog.addNumber("Brightness Threshold (8-bit):", BrTh);
	Dialog.addCheckbox("Sharpen", false);
	Dialog.addCheckbox("Despeckle", false);
	Dialog.addCheckbox("Auto Enhance output image", false);
	Dialog.show();
	Pre8b = Dialog.getCheckbox();
	BrTh = Dialog.getNumber();
	PreSh = Dialog.getCheckbox();
	PreDe = Dialog.getCheckbox();
	PostEn = Dialog.getCheckbox();
	if (Pre8b==true) Pre8b = 1;
	if (PreSh==true) PreSh = 1;
	if (PreDe==true) PreDe = 1;
	if (PostEn==true) PostEn = 1;
	}

if (EditAdv==1){
	Dialog.create("Advanced Settings");
	Dialog.addMessage("Only change these settings\nif you know what you are doing");
	Dialog.addNumber("Gradient:", ImGra);
	Dialog.addNumber("Min Coherency (%):", ImCoh);
	Dialog.addNumber("Min Energy (%):", ImEne);
	Dialog.show();
	ImGra = Dialog.getNumber();
	ImCoh = Dialog.getNumber();
	ImEne = Dialog.getNumber();
	}

// Clear Memory and Results Window before starting
run("Collect Garbage");
updateResults();
run("Clear Results");
if (MemMon==1){
	doCommand("Monitor Memory...");
	}

// Ask user to select target directory --- Will recurse through ALL subdirectories too
setOption("JFileChooser", true); 
dir = getDirectory("Choose the Directory containing your images files to be analysed");

// Set batch mode to speed up processing
if (Bat==1){
	setBatchMode(true);
	}
else { 
	setBatchMode(false);
	}

// Generate list of files to process
count = 0;
countFiles(dir);
n = 0;
processFiles(dir);
function countFiles(dir) {
	list = getFileList(dir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/"))
		countFiles(""+dir+list[i]);
		else
		count++;
		}
	}
function processFiles(dir) {
	list = getFileList(dir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/"))
		processFiles(""+dir+list[i]);
		else {
			showProgress(n++, count);
			path = dir+list[i];
			processFile(path);
			}
		}
	}
function processFile(path) {
	if (endsWith(path, FiTy)) {
		open(path);

// Get file info 
		name=getTitle;
		fname=File.nameWithoutExtension; 
		String.copy(name);

// Apply user selected Pre-processing steps
		if (Pre8b==1){
			run("8-bit"); // Convert image to 8-bit for processing
			}
		setMinAndMax(BrTh, 255);
		if (PreSh==1){
			run("Sharpen"); // Runs the ImageJ/FIJI sharpen command
			}
		if (PreDe==1){
			run("Despeckle"); // Runs the ImageJ/FIJI Despeckle command
			}
	
// Save pre-processed file
		saveAs("PNG",dir + fname+"_processed");
		close();
		open(dir + fname+"_processed.png");

// Call and run fibril orientation analysis
		run("OrientationJ Distribution", "tensor=["+ImTen+"] gradient=["+ImGra+"] min-coherency=["+ImCoh+"] min-energy=["+ImEne+"] harris-index=off color-survey=on s-distribution=on hue=Orientation sat=Coherency bri=Original-Image");
		selectWindow(fname+"_processed.png");
		close();
		
// Save outputs and close windows
		Plot.getValues(x, y);
		for (e=0; e<x.length; e++)
		setResult(fname, e, y[e]);
		selectWindow("Color-survey-1");
		if (PostEn==1){ // If Post-analysis enhance selected, runs this on the OUTPUT image (does not affect analysis - purely for aesthetics)
			run("Enhance Contrast", "saturated=0.35");
			}
		saveAs("PNG",dir + fname+"_overlay");
		run("Close");
		selectWindow("S-Distribution-1");
		run("Close");
		print(name);	
		}
	}

// Save results file
selectWindow("Results");
saveAs("Results",dir +"Orientation_Results.txt");
run("Close");
		
// Save an output file with the parameters used
title="Parameters";
run("Text Window...", "name="+title);
print("[Parameters]","CMM Lab Orientation Analyser v"+ver+" - Run Date: "+TimeString+"\n");
print("[Parameters]","CMM Lab website (www.matrixandmetastasis.com)"+"\n");
print("[Parameters]","CMM Lab GitHub (www.github.com/tcox-lab)"+"\n\n");
print("[Parameters]","File Type Used = "+FiTy+"\n\n");
print("[Parameters]","Tensor = "+ImTen+"\n");
print("[Parameters]","Brightness Threshold = "+BrTh+"\n\n");
print("[Parameters]","Gradient = "+ImGra+"\n");
print("[Parameters]","Min Coherency (%) = "+ImCoh+"\n");
print("[Parameters]","Min Energy (%) = "+ImEne+"\n\n");
if (EditPre==1){
	print("[Parameters]","Pre-processing steps carried out:\n");	
	if (Pre8b==1){
		print("[Parameters]","8 bit conversion\n"); 
		}
	if (PreSh==1){
		print("[Parameters]","Sharpen\n");
		}
	if (PreDe==1){
		print("[Parameters]","Despeckle\n");
		}
	if (PostEn==1){
		print("[Parameters]","Auto Enhance Contrast (Output Image)\n");
		}
	}
print("[Parameters]", "\nFiles successfully analysed:\n\n");
print("[Parameters]", getInfo("log"));
selectWindow("Log");
run("Close");
selectWindow("Parameters");
saveAs("Text",dir+"Parameters.txt");
run("Close");
