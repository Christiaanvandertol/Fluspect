leafbio.Cab     = 40;         % chlorophyll content               [ug cm-2]
leafbio.Cdm     = 0.01;       % dry matter content                [g cm-2]
leafbio.Cw      = 0.01;       % leaf water thickness equivalent   [cm]
leafbio.Cs      = 0.1;        % senescent material                [fraction]
leafbio.Cca     = 10;         % carotenoids                       [mug cm-2]
leafbio.Cant    = 1;          % carotenoids                       [mug cm-2]
leafbio.V2Z     = 0;          % carotenoids                       [mug cm-2]
leafbio.N       = 1;          % leaf structure parameter (affects the ratio of refl: transmittance) []
leafbio.fqe     = 0.01;       % quantum yield
leafbio.Cbc     = 0;
leafbio.Cp      = 0;

load Optipar2021_ProspectPRO_CX.mat

spectral = define_bands;

[leafopt] = fluspect_B_CX(spectral,leafbio,optipar);

plot(spectral.wlP,[leafopt.refl, 1-leafopt.tran])
xlabel('wl (nm)')
ylabel('r, 1-t')