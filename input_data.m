function [wl,measured,include,target,c,wlrange,leafbio,outdirname] = input_data

[d, txt]                = xlsread('input_data.xlsx');
d                       = d(~isnan(d(:,1)),:);

%% Tell me, where do I find your measured reflectance spectrum, and where should I write the results to 
outdirname              = fullfile(txt(3,2),txt(10,2));

wlfilename              = fullfile(txt(2,2),txt(4,2));
reflfilename            = fullfile(txt(2,2),txt(5,2));
tranfilename            = fullfile(txt(2,2),txt(6,2));
irrfilename             = fullfile(txt(2,2),txt(7,2));
Fufilename              = fullfile(txt(2,2),txt(8,2));
Fdfilename              = fullfile(txt(2,2),txt(9,2));

wl                      = load(wlfilename{:});
measured.refl           = load(reflfilename{:});
measured.tran           = load(tranfilename{:});

if ~strcmp(txt(7,2),''),   measured.E = load(irrfilename{:}); end
if ~strcmp(txt(8,2),''),    measured.Fu = load(Fufilename{:}); end
if ~strcmp(txt(9,2),''),    measured.Fd = load(Fdfilename{:}); end    

%% Which columns in the reflectance/transmittance should I use ?
% in other words: how many spectra do you want to tune?
c               = d(1,:);%-999; % 1: first column ; 2: second column, [1,2]: first and second, ect
                        % -999: all columns in the file

include.Cab     = d(2,1);
include.Cdm     = d(3,1);
include.Cw      = d(4,1);
include.Cs      = d(5,1);
include.Cca     = d(6,1);
include.N       = d(7,1);

%% which outputs should I calibrate?
target          = d(8,1); %#ok<*NASGU> %0: calibrate T&R, 1: calibrate only R; 2: calibrate only T

%% which spectral region should I calibrate?
wlmin           = d(9,1);          % starting wavelength (nm)
wlmax           = d(10,1);         % ending wavelength (nm)

%% initialize parameters for retrieval 
% these will be calibrated to your reflectance data if you said so above
leafbio.Cab     = d(11,1);           % chlorophyll content               [ug cm-2]
leafbio.Cdm     = d(12,1);        % dry matter content                [g cm-2]
leafbio.Cw      = d(13,1);        % leaf water thickness equivalent   [cm]
leafbio.Cs      = d(14,1);          % senescent material                [fraction]
leafbio.Cca     = d(15,1);            % carotenoids                       [?]
leafbio.N       = d(16,1);          % leaf structure parameter (affects the ratio of refl: transmittance) []
leafbio.fqe(2)  = d(17,1);                     % quantum yield
leafbio.fqe(1)  = d(18,1);

wlrange.wlmin   = wlmin;
wlrange.wlmax   = wlmax;