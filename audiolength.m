tot_folder = 'F:\Thyrovoice\audio';
pat_folder = dir(tot_folder);
audiolen = 0;
for i = 1:length(pat_folder)
    file_name = pat_folder(i).name;
    if ~isequal(file_name, '.') && ~isequal(file_name, '..')
        full_path = fullfile(tot_folder, file_name);
        audio_files = dir(full_path);
        for j = 1:length(audio_files)
            audio_name = audio_files(j).name; 
            if endsWith(audio_name, 'wav')
                filePathInput = fullfile(full_path, audio_name);
                [y, fs] = audioread(filePathInput);
                len = length(y) / fs;
                audiolen = audiolen + len;
            end
        end
    end
end
audiolen_minute = audiolen / 60;
audiolen_hour = audiolen_minute / 60;
print('Audio length is %s in minute', audiolen_minute);
print('Audio length is %s in hour', audiolen_hour);