function [wl,measured,include,target,c,wlrange,leafbio,outdirname] = input_data

[d, txt]                = xlsread('input_data.xlsx');
d                       = d(~isnan(d(:,1)),:);

%% Tell me, where do I find your measured reflectance spectrum, and where should I write the results to 
outdirname              = [char(txt(3,2)),char(txt(11,2))];

wlfilename              = [char(txt(2,2)),char(txt(4,2))];
reflfilename            = [char(txt(2,2)),char(txt(5,2))];
tranfilename            = [char(txt(2,2)),char(txt(6,2))];
stdfilename             = [char(txt(2,2)),char(txt(7,2))];
irrfilename             = [char(txt(2,2)),char(txt(8,2))];
Fufilename              = [char(txt(2,2)),char(txt(9,2))];
Fdfilename              = [char(txt(2,2)),char(txt(10,2))];

rowheader               = d(1,1);
columnheader            = d(2,1);

wl                      = load(wlfilename);%dlmread(wlfilename,'',rowheader,0);
measured.refl           = load(reflfilename);%dlmread(reflfilename,'',rowheader,columnheader);
measured.tran           = load(tranfilename);%dlmread(tranfilename,'',rowheader,columnheader);
wl = wl(:,1);

if ~strcmp(txt(7,2),''),   measured.stdmeas = dlmread(stdfilename,'',rowheader,columnheader); else measured.std = .03*ones(length(wl),size(measured.refl,2)); end
if ~strcmp(txt(8,2),''),   measured.E = dlmread(irrfilename,'',rowheader,columnheader); end
if ~strcmp(txt(9,2),''),   measured.Fu = dlmread(Fufilename,'',rowheader,columnheader); end
if ~strcmp(txt(10,2),''),  measured.Fd = dlmread(Fdfilename,'',rowheader,columnheader); end    


%% Which columns in the reflectance/transmittance should I use ?
% in other words: how many spectra do you want to tune?
c               = d(3,:);%-999; % 1: first column ; 2: second column, [1,2]: first and second, ect
                        % -999: all columns in the file

include.Cab     = d(4,1);
include.Cdm     = d(5,1);
include.Cw      = d(6,1);
include.Cs      = d(7,1);
include.Cca     = d(8,1);
include.Cant 	= d(9,1);
include.Cx 	= d(10,1);
include.N       = d(11,1);

%% which outputs should I calibrate?
target          = d(12,1); %#ok<*NASGU> %0: calibrate T&R, 1: calibrate only R; 2: calibrate only T

%% which spectral region should I calibrate?
wlmin           = d(13,1);          % starting wavelength (nm)
wlmax           = d(14,1);         % ending wavelength (nm)

%% initialize parameters for retrieval 
% these will be calibrated to your reflectance data if you said so above
leafbio.Cab     = d(15,1);           % chlorophyll content               [ug cm-2]
leafbio.Cdm     = d(16,1);        % dry matter content                [g cm-2]
leafbio.Cw      = d(17,1);        % leaf water thickness equivalent   [cm]
leafbio.Cs      = d(18,1);          % senescent material                [fraction]
leafbio.Cca     = d(19,1);            % carotenoids                       [mug cm-2]
leafbio.Cant     = d(20,1);            % carotenoids                       [mug cm-2]
leafbio.Cx     = d(21,1);            % carotenoids                       [mug cm-2]
leafbio.N       = d(22,1);          % leaf structure parameter (affects the ratio of refl: transmittance) []
leafbio.fqe     = d(23,1);                     % quantum yield


wlrange.wlmin   = wlmin;
wlrange.wlmax   = wlmax;