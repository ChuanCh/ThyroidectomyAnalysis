% from _Voice_EGG.wav to log.csv, VRP.csv, cluster.csv, cycles.csv.
%
%
clear all;
close all;

wav_path = 'F:\Thyrovoice\audio\';
script_path = 'F:\Thyrovoice\';
script_name = 'F:\Thyrovoice\script.txt';
script = [];
start = ["io.inputType=1";
        "sampen.amplitudeTolerance=0.1";...
        "sampen.amplitudeHarmonics=4";...
        "sampen.phaseHarmonics=4";...
        "sampen.bDrawSampEn=true";...
        "scope.duration=4";...
        "io.keepInputName=true";...
        "io.enabledWriteLog=true";...
        "io.writeLogFrameRate=0"];
patient_path = dir(wav_path);
for i = 1:length(patient_path)
    file_name = patient_path(i).name;
    if ~isequal(file_name, '.') && ~isequal(file_name, '..')
        full_path = fullfile(wav_path, file_name);
        audio_files = dir(full_path);
        for j = 1:length(audio_files)
            audio_name = audio_files(j).name; 
            if endsWith(audio_name, 'wav')
                output_directory = full_path;
                filePathInput = fullfile(full_path, audio_name);
                
                a = [sprintf('general.output_directory="%s"',output_directory)];
                b = ["cluster.initialize=false"
                    "cluster.learn=true"
                    "cluster.reset=true"
                    "cluster.autoReset=true"
                    "io.keepData=false"];
                c = [sprintf('io.filePathInput="%s"',filePathInput)];
                d = ["RUN"
                    "cluster.initialize=true"
                    "cluster.learn=true"
                    "cluster.reset=false"
                    "io.keepData=true"];
                cluster_dir = fullfile(output_directory,[audio_name(1:9), '_clusters.csv']);
                VRP_dir = fullfile(output_directory, [audio_name(1:9), '_VRP.csv']);
                VRP_S_dir = fullfile(output_directory, [audio_name(1:9), '_S_VRP.csv']);
                e = ["RUN"
                    sprintf('SAVE "%s"', cluster_dir)
                    sprintf('SAVE "%s"', VRP_dir)
                    sprintf('SAVE "%s"', VRP_S_dir)];
                script = [script;start; a; b; c; d; c; e];
            end
        end
    end
end
script = replace(script, '\', '/');
lines = splitlines(script);

% Determine the number of chunks needed based on the desired chunk size (250 lines per chunk)
num_chunks = ceil(length(lines) / 250);

% Loop through each chunk and store it in the script(k) cell array
for k = 1:num_chunks
    start_idx = (k - 1) * 250 + 1;
    end_idx = min(k * 250, length(lines));
    separat_script = lines(start_idx:end_idx);
    % Generate a unique filename based on the chunk index
    filename = sprintf('script%d.txt', k);
    
    % Write the chunk to the file
    fid = fopen(filename, 'w');
    fprintf(fid, '%s\n', separat_script{:});
    fclose(fid);
end

