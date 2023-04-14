close all;
clear all;

% concatenate audio files per patient pre and post
% folder = '/Volumes/voicelab/Huanchen/Thyrovoice Dataset/MAT_data/';
% pre_post_folder = '/Volumes/voicelab/Huanchen/Thyrovoice Dataset/pre-post data/';
folder = 'H:/Download/data_MAT (1)/data_MAT/';
output_folder = 'L:/Huanchen/Thyrovoice Dataset/pre-post data/';
output_folder = 'F:/Thyrovoice/audio/';

files = dir(fullfile(folder, '*.mat'));
patient_names = {};
for i = 1:numel(files)
    patient_name = files(i).name(1:6);
    if ~ismember(patient_name, patient_names)
        patient_names = [patient_names, patient_name];
    end
end

disp(patient_names)
gain = 10^(-10/20); % decrease SPL by 10 dB

% loop through each file
for i = 1:numel(patient_names)
    patient = patient_names(i);
    pre = loadmat(patient, 'pre', 44100, gain, folder);
    if ~isempty(pre)
        outfolder = fullfile(strjoin([output_folder, string(patient),'\'],''));
        if ~exist(outfolder,'dir')
            mkdir(outfolder)
        end
        output_filename_pre = fullfile(strjoin([outfolder, patient,'pre', '_Voice_EGG.wav'], ''));
        audiowrite(output_filename_pre, pre, 44100);
        % nest a audiowrite for post files if pre exists
        post = loadmat(patient, 'post', 44100, gain, folder);
        if ~isempty(post)
            output_filename = fullfile(strjoin([outfolder, patient,'post', '_Voice_EGG.wav'], ''));
            audiowrite(output_filename, post, 44100);
        end
    end
end


function [outputs] = loadmat(patient, type, Fs, gain, input_dir)
    outputs = [];
    status = strjoin([patient, type], '');
    patient_files = dir(strjoin(fullfile([string(input_dir), string(status), '*.mat']), ''));
    if isempty(patient_files)
        return;
    end
    % all 'pai' are removed because the F0 looks very strange, HNR too low.
    % 's' 'z' are removed because no vibration.
    exclude = {'1002', '1003', '1004', '1010', '1011','1012','1013','1014'}; 
    for i = 1:length(patient_files)
        mat_name = patient_files(i).name;
        if ~any(contains(mat_name, exclude))
            mat = load(strjoin({input_dir, mat_name}, ''));
            audio = mat.sau;
            egg = mat.segg;
            if isempty(audio)||isempty(egg)
                return
            end
            audio = audio * gain;
            audio = resample(audio, Fs, mat.fs_au);
            egg = resample(egg/2, Fs, mat.fs_egg);
            output =  [audio, egg];
        end
        outputs = [outputs; output];
    end
end