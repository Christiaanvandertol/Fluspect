# Fluspect
Fluspect simulates leaf reflectance (R), transmittance (T) and fluorescence. With this code you can fit R and T to hyperspectral measurements.

With this program, you can retrieve leaf structural parameters from hyperspectral leaf level measurements by inversion of Fluspect.

The model code is in the directory 'Fluspect_retrievals/'


Step 1:
Place your measurement data in 'data/measured/'
: a file with wavelengths, another with reflectance and a third with transmittance transmittance data

Step 2. Edit and save input_data.xlsx.
- Specify how the measurements can be loaded. By default, the example data are loaded.
- Specify which parameters to tune
- Specify which output to tune (reflectance, transmittance, or both)
- Specify initial parameter values

Step 4. 
Run the script 'master' from Matlab
The fitted parameters are stored in a structure 'leafbio'.
The fittes spectra are stored in a structure 'leafopt'.
Type 'leafbio', enter, to inspect the fitted parameters.

The output is also stored in a directory specified in the input spreadsheet.
