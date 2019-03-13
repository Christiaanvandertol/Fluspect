function [er,params0,params1,spectral,reflFluspect,tranFluspect,leafopt,leafbio,leafopt_all, leafbio_all,optipar] = master
close all
progressbar
[wl,measured,include,target,c,wlrange,leafbio,outdirname] = input_data; 

if c==-999; c = (1:size(measured.refl,2)); 
else
    if min(c)<0, fprintf('%s \r', 'negative incides are not allowed (except -999 for all spectra), program ends'), return, end
    if max(c)>size(measured.refl,2), fprintf('%s \r', ['you only have ' num2str(size(measured.refl,2)) ' spectra, not ' num2str(max(c)) ' in your measurement file, program ends']), return, end
end      
[er,params0,params1,spectral,reflFluspect,tranFluspect,leafopt,leafbio,leafopt_all, leafbio_all, optipar]  = Fluspect_retrievals(leafbio,c,include,target,measured,wl,wlrange);

%%
%leafbio_all.fqe = 0.02*ones(length(leafbio_all.Cab));
leafbio.fqe = 0.01;
%[params0,params1,spectral,leafbio,measurement,leafopt2,P]= Fluspect_retrievals_phi(leafbio_all,target,measured,wl,optipar);
%%

%% save the output
string          = clock;
Output_dir      =fullfile(outdirname, sprintf('%4.0f-%02.0f-%02.0f-%02.0f%02.0f/',[string(1) string(2) string(3) string(4) string(5)]));
%Output_dir      = Output_dir{1};
mkdir(Output_dir)
copyfile('input_data.xlsx',[Output_dir, 'output_data.xlsx'],'f')
outfile = [Output_dir, 'output_data.xlsx'];

progressbar(1/4)
xlswrite(outfile,leafopt_all.refl,'Rmod','B2'  )
xlswrite(outfile,leafopt_all.tran,'Tmod','B2'  )
xlswrite(outfile,measured.refl,'Rmeas','B2'  )
xlswrite(outfile,measured.tran,'Tmeas','B2'  )

progressbar(1/2)
xlswrite(outfile,spectral.wlP','Rmod','A2'  )
xlswrite(outfile,spectral.wlP','Tmod','A2'  )
xlswrite(outfile,spectral.wlM,'Rmeas','A2'  )
xlswrite(outfile,spectral.wlM,'Tmeas','A2'  )

if isfield(measured,'Fu')
    measured.Fu = interp1(spectral.wlM,measured.Fu,spectral.wlF);
    xlswrite(outfile,spectral.wlF','Fup_meas','A2'  )
    xlswrite(outfile,measured.Fu,'Fup_meas','B2'  )
end
if isfield(measured,'Fd')
    measured.Fd = interp1(spectral.wlM,measured.Fd,spectral.wlF);
    xlswrite(outfile,spectral.wlF','Fdown_meas','A2'  )
    xlswrite(outfile,measured.Fd,'Fdown_meas','B2'  )
end
if isfield(leafopt_all,'Fu')
    xlswrite(outfile,spectral.wlF','Fup_mod','A2'  )
    xlswrite(outfile,leafopt_all.Fu,'Fup_mod','B2'  )
    xlswrite(outfile,spectral.wlF','Fdown_mod','A2'  )
    xlswrite(outfile,leafopt_all.Fd,'Fdown_mod','B2'  )
end

progressbar(3/4)
xlswrite(outfile,leafbio_all.Cab','output','B2'  )
xlswrite(outfile,leafbio_all.Cw','output','B3'  )
xlswrite(outfile,leafbio_all.Cdm','output','B4'  )
xlswrite(outfile,leafbio_all.Cs','output','B5'  )
xlswrite(outfile,leafbio_all.Cca','output','B6'  )
xlswrite(outfile,leafbio_all.Cant','output','B7'  )
xlswrite(outfile,leafbio_all.Cx','output','B8'  )
xlswrite(outfile,leafbio_all.N','output','B9'  )
xlswrite(outfile,leafopt_all.rmse,'output','B10'  )
%xlswrite(outfile,leafbio_all.STD','output','B11'  )

progressbar(1)

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

