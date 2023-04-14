% chemin vers les fonctions appelées par Matlab
addpath('E:\PROJETS DE RECHERCHE\THYRO_VOICE\ANALYSIS\MATLAB_progs')


% datapath -  chemin vers les données
datapath = 'H:\1- Etude THYROVOICE Chaff\1- THYROVOICE patients\Tous patients\';
datafilename_list = dir([datapath '\P*']);

for npatient = 1:size(datafilename_list,1)
    patient_name = datafilename_list(npatient).name;
    
    datapath_patient = [datapath patient_name '\'];
    dd = dir(datapath_patient);
    
    nsession=1;
    for k=1:length(dd)
        if dd(k).isdir == 1&length(dd(k).name)>2
            disp(dd(k).name)
            patient_dir{nsession} = dd(k).name;
            nsession = nsession+1;
        else
        end
    end
    
    % ouverture des fichiers audio
    for ndir = 1:length(patient_dir)
        audiofile_list = dir([datapath_patient patient_dir{ndir} '\*.wa1']);
        
        for naudio = 1:length(audiofile_list)
            
            disp(audiofile_list(naudio).name)
            [sau, sdsc, adsc, list] = lire_RIFF([datapath_patient patient_dir{ndir} '\' audiofile_list(naudio).name]);
            fs = sdsc.freq_sgl;
            
            wavwrite(sau/max(abs(sau))*0.9,fs,[datapath_patient '\' audiofile_list(naudio).name(1:end-1) 'v'])
            
        end
    end
end



