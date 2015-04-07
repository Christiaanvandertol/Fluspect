With this program, you can retrieve leaf structural parameters from hyperspectral leaf level measurements by inversion of Fluspect.

The model code is in the directory 'Fluspect_retrievals/'


Step 1:
Place your measurement data in 'data/measured/'
Some example files are already there: a file with wavelengths, reflectance and transmittance

Step 2. Edit and save input_data.xlsx.
- Specify how the measurements can be loaded. By default, the example data are loaded.
- Specify which parameters to tune
- Specify which output to tune (reflectance, transmittance, or both)
- Specify initial parameter values

Step 4. 
Run the script 'master' from Matlab, or alternatively, run 'fluspect_retrieval.exe'
The fitted parameters are stored in a structure 'leafbio'.
The fittes spectra are stored in a structure 'leafopt'.
Type 'leafbio', enter, to inspect the fitted parameters.

The output is also stored in a directory specified in the input spreadsheet.