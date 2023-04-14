datapath = 'D:\ARCHIVAGE\PROJETS DE RECHERCHE\ZePAST\THYRO_VOICE\DATA\';

filelist = dir([datapath '\P*\*\*.wa1']);
fs = 44100;

for nfile = 1:length(filelist) % 89
    filefolder = filelist(nfile).folder;
    filename = filelist(nfile).name(1:end-4);
    disp(filename)
    
    [sau, sdsc, adsc, list] = lire_RIFF([filefolder '\' filename '.wa1']);
    fs_au = sdsc.freq_sgl;
    saur = resample(sau,fs,fs_au)/100;
    % plot([0:length(sau)-1]/fs_au,sau,'or', [0:length(saur)-1]/fs,saur,'b-*')
    
    if exist([filefolder '\' filename '.egg'])
        [segg, sdsc, adsc, list] = lire_RIFF([filefolder '\' filename '.egg']);
        fs_egg = sdsc.freq_sgl;
        seggr = resample(segg,fs,fs_egg);
        if strcmp(filename(7:9),'pré')
            filename(7:9) = 'pre';
        end
        
        audiowrite([savedatapath filename '_Voice_EGG.wav'],[saur seggr],fs,  'BitsPerSample',24)
    end
    
end





