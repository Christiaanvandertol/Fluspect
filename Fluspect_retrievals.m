function [er,params0,params1,spectral,reflFluspect,tranFluspect,leafopt,leafbio,leafopt_all, leafbio_all,optipar]= Fluspect_retrievals(leafbio,c,include,target,measured,wl,wlrange,optipar)

%% get constants
global constants
[constants] = define_constants();

%% the input for FLUSPECT
load Optipar2017_ProspectD.mat
%O = dlmread('../data/input/fluspect_data/Optipar_2013.csv',',',1,0);
%O = xlsread('../data/input/fluspect_data/Optipar_2015.xlsx');
% optipar.nr     = O(:,2);
% optipar.Kab    = O(:,3);
% optipar.Kca    = O(:,4);
% optipar.Ks     = O(:,5);
% optipar.Kw     = O(:,6);
% optipar.Kdm    = O(:,7);
% optipar.phiI   = O(:,9);
% optipar.phiII  = O(:,10);
% optipar.KcaV   = O(:,14);
% optipar.KcaZ   = O(:,15);

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

measured.stdP = interp1(spectral.wlM,measured.std,spectral.wlP);

%% define output structures
if length(c)>1
    [leafbio_all.Cab,leafbio_all.Cw,leafbio_all.Cdm, leafbio_all.Cs,leafbio_all.Cant,leafbio_all.Cca,leafbio_all.N,leafbio_all.Cx,leafbio_all.fqe_opt,leafopt_all.er2] = deal(zeros(length(c),1));
    [leafopt_all.refl,leafopt_all.tran] = deal(zeros(length(spectral.wlP),length(c)));
    leafbio_all.STDV = zeros(length(c),6);
end

%% initial parameter values, and boundary boxes
params0         = ones(6,1);
params0(1)      = leafbio.Cab;
params0(2)      = leafbio.Cdm;
params0(3)      = leafbio.Cw;
params0(4)      = leafbio.Cs;
params0(5)      = leafbio.Cca;
params0(6)      = leafbio.Cant;
params0(7)      = leafbio.Cx;
params0(8)      = leafbio.N;

%params0(9)      = fluor.PS;

LB              = [0   .001   0    0   0 0 0 1  ]'; % lower boundaries
UB              = [100 0.5  0.4 0.6   30 5 3 4  ]'; % upper boundaries

%% do the job: fit the model to the data
for j = c
    measurement.refl            = measured.refl(:,j);
    measurement.tran            = measured.tran(:,j);
    measurement.std             = measured.std(:,j);
    measurement.stdP            = measured.stdP;
    
    input           = {leafbio,optipar,spectral,include,target,wlrange};
    if sum(structfun(@(x)x, include)) >0
        f               = @(params)COST_4Fluspect(params,measurement,input);
        tic
        params1    = lsqnonlin(f,params0,LB,UB);
        toc
    else
        params1 = params0;
    end
    J=numjacobian(params1,spectral,leafbio,optipar);

    [JR,JT]  = deal(zeros(length(spectral.wlP),length(params1)));
    JR(:) = J(:,1,:);
    JT(:) = J(:,2,:);
    
    PR = abs((inv(JR.'*JR)) * JR.' * measurement.stdP(:,j));
    PT = abs((inv(JT.'*JT)) * JT.' * measurement.stdP(:,j));
    
    switch target
        case 1
            stdP = PR;
        case 2
            stdP = PT;
        case 0
            stdP = 1./(1./PR+1./PT);
    end  
    
    % done, this is what comes out
    [er,reflFluspect,tranFluspect,leafopt] = COST_4Fluspect(params1,measurement,input);
    
    leafbio.Cab     = params1(1);
    leafbio.Cdm     = params1(2);
    leafbio.Cw      = params1(3);
    leafbio.Cs      = params1(4);
    leafbio.Cca     = params1(5);
    leafbio.Cant    = params1(6);
    leafbio.Cx      = params1(7);
    leafbio.N       = params1(8);
    leafbio.STD     = stdP';
    leafopt.rmse     = sqrt(er'*er./length(er));
    params0(1)      = leafbio.Cab;

    if isfield(measured,'E')
        measurement.E = measured.E(:,j);
%        leafopt.Fu = (leafopt.MbI + leafopt.MbII)*measurement.E;
 %       leafopt.Fd = (leafopt.MfI + leafopt.MfII)*measurement.E;
        leafopt.Fu = leafopt.Mb*measurement.E;
        leafopt.Fd = leafopt.Mf*measurement.E;
 
        if isfield(measured,'Fu')
            Fu = interp1(spectral.wlM,measured.Fu(:,j),spectral.wlF)';
            leafbio.fqe_opt = leafopt.Fu\Fu.*leafbio.fqe;
            leafopt.Fu = leafbio.fqe_opt/leafbio.fqe*leafopt.Fu;
            leafopt.Fd = leafbio.fqe_opt/leafbio.fqe*leafopt.Fd;
            
        end
        
    end
    
    if length(c)>1
        leafbio_all.Cab(j) = leafbio.Cab;
        leafbio_all.Cca(j) = leafbio.Cca;
        leafbio_all.Cdm(j) = leafbio.Cdm;
        leafbio_all.Cw(j)  = leafbio.Cw;
        leafbio_all.Cs(j)  = leafbio.Cs;
 	    leafbio_all.Cant(j) = leafbio.Cant;
        leafbio_all.N(j)   = leafbio.N;
        leafbio_all.Cx(j)   = leafbio.Cx;
        leafbio_all.STD(j,:) = leafbio.STD;
        if isfield(leafbio,'fqe_opt')
            leafbio_all.fqe_opt(j,:) = leafbio.fqe_opt;
        end    
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
