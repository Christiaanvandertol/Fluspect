 function [er,refl, tran,leafopt] = COST_4Fluspect(params,measurement,input)

leafbio = input{1};
optipar = input{2};
spectral = input{3};
include = input{4};
target = input{5};
range  = input{6};

leafbio.Cab = params(1) * include.Cab + (1-include.Cab)*leafbio.Cab;
leafbio.Cdm = params(2) * include.Cdm + (1-include.Cdm)*leafbio.Cdm;
leafbio.Cw = params(3) * include.Cw + (1-include.Cw)*leafbio.Cw;
leafbio.Cs = params(4) * include.Cs + (1-include.Cs)*leafbio.Cs;
leafbio.Cca = params(5) * include.Cca + (1-include.Cca)*leafbio.Cca; % default is 25% of Cab
leafbio.Cant = params(6) * include.Cant + (1-include.Cant)*leafbio.Cant;
leafbio.Cx = params(7) * include.V2Z + (1-include.V2Z)*leafbio.V2Z;
leafbio.N = params(8) * include.N + (1-include.N)*leafbio.N;

%[leafopt] = fluspect_bcar(spectral,leafbio,optipar);
[leafopt] =fluspect_B_CX(spectral,leafbio,optipar);
%[leafopt] = fluspect_b(spectral,leafbio,optipar);

%%
refl  = interp1(spectral.wlP, leafopt.refl ,spectral.wlM,'spline',NaN);
tran  = interp1(spectral.wlP, leafopt.tran ,spectral.wlM,'spline',NaN);

%i = find(spectral.wlM>spectral.wlP(1) & spectral.wlM<spectral.wlP(end));
i = find(spectral.wlM>=range.wlmin & spectral.wlM<=range.wlmax & ~isnan(measurement.refl.*measurement.tran.*refl.*tran));

switch target
    case 0, er = [refl(i) - measurement.refl(i) ; tran(i) - measurement.tran(i)]./[measurement.std(i) ; measurement.std(i)];
    case 1, er = (refl(i) - measurement.refl(i))./measurement.std(i);
    otherwise, er = (tran(i) - measurement.tran(i))./measurement.std(i);
end