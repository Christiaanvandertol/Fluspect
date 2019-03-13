function J=numjacobian(x,spectral,leafbio,optipar)

n=length(x); 
[r,t]=calc_fluspect_bcar(x,spectral,leafbio,optipar); % 
fx = [r,t];
step=1e-6; % 
J = zeros(length(r),2,n);

for i=1:n
   xstep = x;
   xstep(i)=x(i)+step;
   [r,t] = calc_fluspect_bcar(xstep,spectral,leafbio,optipar); 
   fxstep = [r,t];
   J(:,:,i)= (fxstep-fx)./step;
end;
end

function [r,t] = calc_fluspect_bcar(params,spectral,leafbio,optipar)

leafbio.Cab     = params(1);
leafbio.Cdm     = params(2);
leafbio.Cw      = params(3);
leafbio.Cs      = params(4);
leafbio.Cca     = params(5);
leafbio.N       = params(6);

leafopt = fluspect_B_CX_PSI_PSII_combined(spectral,leafbio,optipar);
r = leafopt.refl;
t = leafopt.tran;

end