%Filenames and location of measured spectra and output results				
measdir = 'data\measured\exampledata\';			% Directory of measurements
outdirname = 'data\retrieved\test\';              % directory to store the output
wlfilename = 'wl.txt';                          % file with the wavelengths
reflfilename = 'reflectance.txt';                 % Measured reflectance [0,1]
tranfilename = 'transmittance.txt';              % measured transmittance [0,1]
stdfilename = '';                           %Standard deviaton of measured r and t				
irrfilename     = '';                           %Incident light [W m-2 um-1]				OPTIONAL: the model needs this for the calculation of fluoresence (not for reflectance and transmittance)
Fufilename = '';                                %Measured fluorescence up				OPTIONAL: this file is not used in the calculation but only for plotting
Fdfilename = '';                                %Measured fluorescence down				OPTIONAL: this file is not used in the calculation but only for plotting

Simulation_name = 'test';                   %A subdirectory will be created in the output directory with this name

rowheader     = 1;
columnheader   = 0;
					
%% Which columns in the reflectance/transmittance should I use ?				
%in other words: how many spectra do you want to tune?				
c=	-999;%		 1: first column ; 2: second column, [1,2]: first and second, ect, -999: all columns in the file	
                      				
%which parameters should I tune?				
include.Cab	=1	;		
include.Cdm	=1	;		
include.Cw	=1	;		
include.Cs	=1	;		
include.Cca	=1	;		
include.Cant=0;			
include.V2Z	=0	;		
include.N	=1	;		
				
%Which outputs should I calibrate?				
target =   	0	;%	0: calibrate T and R, 1: calibrate only R; 2: calibrate only T	
				
%Which spectral region should I calibrate (measured wavelengths can span longer range, but the range specified here is used for calibration				
wlmin=	400	;	%starting wavelength (nm)	
wlmax=	2400;	%	ending wavelength (nm)	
	
%%
%Initialize parameters for retrieval 				
%These will be calibrated to your reflectance data if you said so above				
leafbio.Cab     =	28	;	%chlorophyll content               [ug cm-2]	
leafbio.Cdm     =	0.001;	%	dry matter content                [g cm-2]	
leafbio.Cw	    =   0.002		;%leaf water thickness equivalent   [cm]	
leafbio.Cs      = 	0.015;		%senescent (brown) pigments                [unitless]	
leafbio.Cca     =	4	;	%carotenoids                       [mug cm-2]	
leafbio.Cant    =	1	;	%anthocyanin content [mug cm-2]	
leafbio.V2Z      =	0	;	%xanthophyll cycle status [0-3]	
leafbio.N 	    = 1.5	;	%leaf structure parameter (affects the ratio of refl: transmittance) []
leafbio.Cp      = 0; % new PROSPECT-PRO parameter (read lastest PROSPECT paper)
leafbio.Cbc     = 0;% new PROSPECT-PRO parameter (read lastest PROSPECT paper)
leafbio.fqe     =	0.01;	%	Fluorescence quantum yield efficiency	


%% Edit the text below only if needed

wl                      = load([measdir wlfilename]);
measured.refl           = load([measdir reflfilename]);
measured.tran           = load([measdir tranfilename]);
wl = wl(:,1);

% another example, read data from an XLSX file
% R = xlsread('data/measured/corn/leaf_corn_ASD_sphere.xlsx','Toprefl');
% T = xlsread('data/measured/corn/leaf_corn_ASD_sphere.xlsx','Toptransm');
% wl = R(6:end,1);
% measured.refl = R(6:end,2:end);
% measured.tran = R(6:end,2:end);

%%
load data/parameters/Optipar2021_ProspectPRO_CX.mat;
[spectral] = define_bands;

%%
if ~isempty(stdfilename),   measured.stdmeas = dlmread([measdir stdfilename],'',rowheader,columnheader); else measured.std = .03*ones(length(wl),size(measured.refl,2)); end %#ok<*DLMRD> 
if ~isempty(irrfilename),   measured.E = dlmread([measdir irrfilename],'',rowheader,columnheader); end
if ~isempty(Fufilename),   measured.Fu = dlmread([measdir Fufilename],'',rowheader,columnheader); end
if ~isempty(Fdfilename),  measured.Fd = dlmread([measdir Fdfilename],'',rowheader,columnheader); end  

wlrange.wlmin   = wlmin;
wlrange.wlmax   = wlmax;