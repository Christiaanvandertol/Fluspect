function [er,params0,params1,spectral,reflFluspect,tranFluspect,leafopt,leafbio,leafopt_all, leafbio_all]= Fluspect_retrievals(leafbio,c,include,target,measured,wl,wlrange)

%% get constants
global constants
[constants] = define_constants();

%% the input for FLUSPECT
O = dlmread('../data/input/fluspect_data/Optipar_2013.csv',',',1,0);
optipar.nr     = O(:,2);
optipar.Kab    = O(:,3);
optipar.Kca    = O(:,4);
optipar.Ks     = O(:,5);
optipar.Kw     = O(:,6);
optipar.Kdm    = O(:,7);
optipar.phiI   = O(:,9);
optipar.phiII  = O(:,10);

%% Define spectral regions
spectral        = define_bands;
nwlP            = length(spectral.wlP);
nwlT            = length(spectral.wlT);
spectral.IwlP   = 1 : nwlP;
spectral.IwlT   = nwlP+1 : nwlP+nwlT;
spectral.wlM    = wl;

if isfield(measured,'E')
    measured.E      = interp1(spectral.wlM,measured.E,spectral.wlE); 
end
%% define output structures
if length(c)>1
    [leafbio_all.Cab,leafbio_all.Cw,leafbio_all.Cdm, leafbio_all.Cs,leafbio_all.Cca,leafbio_all.N,leafopt_all.er2] = deal(zeros(length(c),1));
    [leafopt_all.refl,leafopt_all.tran] = deal(zeros(length(spectral.wlP),length(c)));
end

%% initial parameter values, and boundary boxes
params0         = ones(6,1);
params0(1)      = leafbio.Cab;
params0(2)      = leafbio.Cdm;
params0(3)      = leafbio.Cw;
params0(4)      = leafbio.Cs;
params0(5)      = leafbio.Cca;
params0(6)      = leafbio.N;

%params0(7)      = fluor.PSI;
%params0(8)      = fluor.PSII;

LB              = [0     0   0    0   0 1    ]'; % lower boundaries
UB              = [100 0.5  0.4 0.6   30 4  ]'; % upper boundaries

%% do the job: fit the model to the data
for j = c
    measurement.refl            = measured.refl(:,j);
    measurement.tran            = measured.tran(:,j);
    
    input           = {leafbio,optipar,spectral,include,target,wlrange};
    if sum(structfun(@(x)x, include)) >0
        f               = @(params)COST_4Fluspect(params,measurement,input);
        tic
        params1         = lsqnonlin(f,params0,LB,UB);
        toc
    else
        params1 = params0;
    end
    
    % done, this is what comes out
    [er,reflFluspect,tranFluspect,leafopt] = COST_4Fluspect(params1,measurement,input);
    
    leafbio.Cab     = params1(1);
    leafbio.Cdm     = params1(2);
    leafbio.Cw      = params1(3);
    leafbio.Cs      = params1(4);
    leafbio.Cca     = params1(5);
    leafbio.N       = params1(6);
    
    leafopt.rmse     = sqrt(er'*er./length(er));
    
    if isfield(measured,'E')
        measurement.E = measured.E(:,j);
        leafopt.Fu = (leafopt.MbI + leafopt.MbII)*measurement.E;
        leafopt.Fd = (leafopt.MfI + leafopt.MfII)*measurement.E;
    end
    
    if length(c)>1
        leafbio_all.Cab(j) = leafbio.Cab;
        leafbio_all.Cca(j) = leafbio.Cca;
        leafbio_all.Cdm(j) = leafbio.Cdm;
        leafbio_all.Cw(j)  = leafbio.Cw;
        leafbio_all.Cs(j)  = leafbio.Cs;
        leafbio_all.N(j)   = leafbio.N;
        
        leafopt_all.rmse(j) = leafopt.rmse;
        leafopt_all.refl(:,j) = leafopt.refl;
        leafopt_all.tran(:,j) = leafopt.tran;
        if isfield(leafopt,'Fu')
            leafopt_all.Fu(:,j) = leafopt.Fu;
            leafopt_all.Fd(:,j) = leafopt.Fd;
        end
        
    else
        leafopt_all = leafopt; 
        leafbio_all = leafbio;
    end
    
end
