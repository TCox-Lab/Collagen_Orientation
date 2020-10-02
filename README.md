# **CMM Lab - Collagen Fibril Orientation Analyser for SHG images**
### CMM Lab website [Homepage](http://matrixandmetastasis.com)
### CMM Lab GitHub [Homepage](http://www.github.com/tcox-lab)
---
**ImageJ / FIJI script designed to automate the quantification of pixel orientation of two-photon second harmonic generation images of collagen fibres.**  

_Requires ImageJ/FIJI 1.38m or above._  
_Tested working on Mac OSX 10.14 and above._  
_Tested working on Windows 10._

_Last updated: 2nd Oct 2020._

---
**Description:**  
This script wraps the B.I.G. OrientationJ plugin into a batch process  that applies user-defined pre-processing and iterates through entire directories (including all sub-directories) of images outputting the colour survey overlay and text file of histogram values for each image.

_If using multiple sub-directories of images, please ensure that filenames are unique._

**### This scripts requires the `OrientationJ` plugin to run ###**  
See https://github.com/Biomedical-Imaging-Group/OrientationJ

Briefly, the orientation is evaluated for every pixel of the image based on the structure tensor. A histogram of orientations is built taking into account pixels that have a coherency larger than 'min-coherency' and an energy larger than 'min-energy'.

**Citation for original OrientationJ plugin:**  
Rezakhaniha _et al. **Biomech. Model Mechanobiol.**_  (2012)  
_Experimental Investigation of Collagen Waviness and Orientation in the Arterial Adventitia_  
doi: 10.1007/s10237-011-0325-z  
[PubMed link](https://pubmed.ncbi.nlm.nih.gov/21744269/)

**Citation for script:**  
Mayorca-Guiliani AE _et al. **Nature Medicine**_ (2017)  
_ISDoT: in situ decellularization of tissues for high-resolution imaging and proteomic analysis of native extracellular matrix_  
doi: 10.1038/s41467-019-10968-6   
[Pubmed link](https://pubmed.ncbi.nlm.nih.gov/31406163/)

**All processed images should be taken using identical acquisition parameters**  

---
### Installation

Ensure you have ImageJ or FIJI (preferred) installed.
- ImageJ is available from [here](https://github.com/imagej/imagej).
- FIJI is available from [here](https://github.com/fiji/fiji).

The B.I.G. `OrientationJ` tools are also required.  
These are available from https://github.com/Biomedical-Imaging-Group/OrientationJ

Copy the `CMM_Fibril_Orientation_Analyser.ijm` to the ImageJ/FIJI `plugins` directory.  

Restart ImageJ/FIJI.

The script should now appear in the Plugins Dropdown menu.

---
### Basic variables specified by the user include:

Upon launching, the script will ask for the following inputs:

- **File Type** - Specify input image file type (.tif .jpg etc.)*.
- **Tensor** - Minimum structure tensor - Passed to OrientationJ
- **Image pre-processing** (Enable/Disable) - Select image pre-processing options.
- **Advanced Options** (Enable/Disable) - Opens Advanced Options control panel for user input.
-**Enable Batch Mode** (Enable/Disable) - Runs the script silently (_faster_).
-**Launch Memory Monitor** (Enable/Disable) - Mainly for debugging.

_*Output colour overlay files are saved in .png format._  
_Avoid using input files in the .png format where possible._

---
### Image pre-processing steps (_if enabled_) include:

- **8-bit Conversion** - Converts each image to 8-bit
- **Brightness Threshold** - Minimum brightness threshold
- **Sharpen** (Enable/Disable) - Runs the ImageJ/FIJI sharpen command
- **Despeckle** (Enable/Disable) - Runs the ImageJ/FIJI despeckle command
- **Auto Enhance Output Image** (Enable/Disable) - Enhance Brightness/Contrast of **_Output_** images only (_does NOT affect analysis_)

---
### Advanced variables specified by the user (_if enabled_) include:
If enabled in the Basic Parameter window, the script will launch an input window, allowing for customisation of analysis parameters which are passed directly to the OrientationJ plugin:

- **Gradient** - Gradient used (0: Cubic Spline, 1: Finite difference, 2: Fourier; 3: Riesz, 4: Gaussian)
- **Min Coherency** - Minimum Coherency - The ratio between the difference and the sum of the tensor eigenvalues
- **Min Energy** - Minimum Energy value - The energy parameter is the trace of the tensor matrix

---
_**Once basic and advanced options have been chosen, you will be asked to specify the input directory containing the image files to be analysed.**_  

---
### Output Image files
The script will output colour survey overlays (in `.png` format) of each of the analysed images, in the originating directory.  

It will also output a saved version of the pre-processed image file in `.png` format in the originating directory.

(_The original image always remains unchanged_)

---
### Output text files

The analysis will output two text files in the top level directory:  

1. `Parameters.txt` - Contains a list of all the parameters used in the analysis, along with a list of successfully analysed image files.  

2. `Orientation_Results.txt` - Results file containing all of the collated orientations for each file analysed.

---
