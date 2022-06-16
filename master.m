close all

input_data; 

if c==-999; c = (1:size(measured.refl,2)); 
else
    if min(c)<0, fprintf('%s \r', 'negative incides are not allowed (except -999 for all spectra), program ends'), return, end
    if max(c)>size(measured.refl,2), fprintf('%s \r', ['you only have ' num2str(size(measured.refl,2)) ' spectra, not ' num2str(max(c)) ' in your measurement file, program ends']), return, end
end      
[er,params0,params1,spectral,reflFluspect,tranFluspect,leafopt,leafbio,leafopt_all, leafbio_all, optipar]  = Fluspect_retrievals(leafbio,c,include,target,measured,wl,wlrange,optipar,spectral);

%%
% Uncomment this code to calibrate the fluorescence spectrum in optipar.
%leafbio.fqe = 0.01;
%[params0,params1,spectral,leafbio,measurement,leafopt2,P]= Fluspect_retrievals_phi(leafbio_all,target,measured,wl,optipar);

%% save the output
string          = clock;
Output_dir      =fullfile(outdirname, sprintf('%4.0f-%02.0f-%02.0f-%02.0f%02.0f/',[string(1) string(2) string(3) string(4) string(5)]));
mkdir(Output_dir)
copyfile('input_data.m',[Output_dir, 'output_data.m'],'f')

dlmwrite([Output_dir, 'MEAS_reflectance.csv'],[spectral.wlM,measured.refl],'delimiter',','); %#ok<*DLMWT> 
dlmwrite([Output_dir, 'MEAS_transmittance.csv'],[spectral.wlM,measured.tran],'delimiter',','); 
dlmwrite([Output_dir, 'FLUSPECT_reflectance.csv'],[spectral.wlP',leafopt_all.refl],'delimiter',',');
dlmwrite([Output_dir, 'FLUSPECT_transmittance.csv'],[spectral.wlP',leafopt_all.tran],'delimiter',',');

if isfield(measured,'Fu')
    measured.Fu = interp1(spectral.wlM,measured.Fu,spectral.wlF);
    dlmwrite([Output_dir, 'MEAS_Fu.csv'],[spectral.wlF',measured.Fu],'delimiter',',');
end
if isfield(measured,'Fd')
    measured.Fu = interp1(spectral.wlM,measured.Fu,spectral.wlF);
    dlmwrite([Output_dir, 'MEAS_Fd.csv'],[spectral.wlF',measured.Fd],'delimiter',',');
end
if isfield(leafopt_all,'Fu')
    dlmwrite([Output_dir, 'FLUSPECT_Fu.csv'],[spectral.wlF',measured.Fu],'delimiter',',');
    dlmwrite([Output_dir, 'FLUSPECT_Fu.csv'],[spectral.wlF',measured.Fu],'delimiter',',');
end

writetable(struct2table(leafbio_all), [Output_dir, 'RetrievedLeafProperties.csv'])


%% plotting
for j = c
    figure(j), clf
    plot(spectral.wlM,[measured.refl(:,j),1-measured.tran(:,j)],'x'), hold on
    if length(c)>1
        plot(spectral.wlP,[leafopt_all.refl(:,j), 1-leafopt_all.tran(:,j)])
    else
        plot(spectral.wlP,[leafopt.refl, 1-leafopt.tran])
    end
    set(gca,'ylim',[0,1])
    xlabel('wl (nm)')
    ylabel('reflectance, 1-transmittance')
    
    if isfield(measured,'Fu') && isfield(leafopt_all,'Fu')
        figure(j+max(c))
        if length(c)>1
            subplot(211), plot(spectral.wlF,[measured.Fu(:,j),leafopt_all.Fu(:,j)]), legend('measurement','model'), title('Up')
            subplot(212), plot(spectral.wlF,[measured.Fd(:,j),leafopt_all.Fd(:,j)]), legend('measurement','model'), title('Down')
        else
            subplot(211), plot(spectral.wlF,[measured.Fu(:,j),leafopt.Fu]), legend('measurement','model'), title('Up')
            subplot(212), plot(spectral.wlF,[measured.Fd(:,j),leafopt.Fd]), legend('measurement','model'), title('Down')
        end
    end
    
end

