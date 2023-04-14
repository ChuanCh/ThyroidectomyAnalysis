close all
clear all
serie = 'T01';

datapath = ['E:\ENCADREMENT\MEMOIRE ORTHOPHONIE\2012-2013\Claire LALEVEE\RESULTS\' serie '\'];
figspath = ['E:\ENCADREMENT\MEMOIRE ORTHOPHONIE\2012-2013\Claire LALEVEE\FIGS\' serie '\'];
datafilename_list = dir([datapath '*post*.mat']);


% sauvegarde sous fichier excel des sequences MPT
results_datapath = ['D:\Users\henricna\Documents\PROJETS DE RECHERCHE\THYRO_VOICE\RESULTS\' ];
results_filename = 'results_thyrovoice_201401';
sheet_name = serie;

info_line1 = {'Sujets','pre f0mean','f0min','f0med','f0max','post f0mean','f0min','f0med','f0max','pre Idbmean','Idbmin','Idbmed','Idbmax','post Idbmean','Idbmin','Idbmed','Idbmax'};

[status,msg] = xlswrite([results_datapath results_filename],info_line1,sheet_name,'A1:Q1')


matresultsfilename_list = dir([datapath '\P*.mat']);

for nmat = 1:length(matresultsfilename_list)
    nsujet = str2num(matresultsfilename_list(nmat).name(2:3));
    disp(matresultsfilename_list(nmat).name)
    
    [status,msg] = xlswrite([results_datapath results_filename],{matresultsfilename_list(nmat).name(1:3)},sheet_name,['a' num2str(nsujet+1)]);
    if ~status
        warning(['problème avec le fichier ' matresultsfilename_list(nmat).name '  ...'])
    end

    clear data yres*
    load([datapath matresultsfilename_list(nmat).name]) 
    
    yres_f0 = quantile(data.sf0,[.025 .50 .975]);
    yres_IDB = quantile(data.sidb,[.025 .50 .975]);
    
    yres_f0 = [nanmean(data.sf0) yres_f0];
    yres_IDB = [nanmean(data.sidb) yres_IDB];
    
    if strcmp(matresultsfilename_list(nmat).name(end-11:end-8),'post')
        [status,msg] = xlswrite([results_datapath results_filename],[yres_f0],sheet_name,['F' num2str(nsujet+1) ':I' num2str(nsujet+1)]);
        if ~status
            warning(['Problème avec le fichier ' matresultsfilename_list(nmat).name '  ...'])
        end
        [status,msg] = xlswrite([results_datapath results_filename],[yres_IDB],sheet_name,['N' num2str(nsujet+1) ':Q' num2str(nsujet+1)]);
        if ~status
            warning(['Problème avec le fichier ' matresultsfilename_list(nmat).name '  ...'])
        end
        
    elseif strcmp(matresultsfilename_list(nmat).name(end-10:end-8),'pré')
        [status,msg] = xlswrite([results_datapath results_filename],[yres_f0],sheet_name,['B' num2str(nsujet+1) ':E' num2str(nsujet+1)]);
        if ~status
            warning(['Problème avec le fichier ' matresultsfilename_list(nmat).name '  ...'])
        end
        [status,msg] = xlswrite([results_datapath results_filename],[yres_IDB],sheet_name,['J' num2str(nsujet+1) ':M' num2str(nsujet+1)]);
        if ~status
            warning(['Problème avec le fichier ' matresultsfilename_list(nmat).name '  ...'])
        end
        
    else
        warning(['Pas de pré ou post dans le nom de fichier pour ' matresultsfilename_list(nmat).name '  ...'])
    end
end



