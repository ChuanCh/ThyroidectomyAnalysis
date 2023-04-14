% process vrp file, (3.14.2023, remove invalid _S_VRP.csv)
% remove items that are below 60 dB
% remove outrageous outliers

clear all; close all;
% kmeans++ clustering for kinderEGG

%audio_dir = '/Volumes/voicelab/Huanchen/Thyrovoice Dataset/audio/';
audio_dir = 'L:\Huanchen\Thyrovoice Dataset\audio';
output_dir = 'L:\Huanchen\Thyrovoice Dataset\cleanedVRP';
patient_dir = dir(audio_dir);

for i=1:length(patient_dir)
    patient_name = patient_dir(i).name;
    if ~isequal(patient_name, '.') && ~isequal(patient_name, '..') && ~isequal(patient_name, '.DS_Store')
        patient_folder = fullfile(audio_dir, patient_name);
        patient_file = dir(patient_folder);
        for j = 1:length(patient_file)
            csv_name = patient_file(j).name;
            if endsWith(csv_name, 'VRP.csv')
                filename = fullfile(patient_folder, csv_name);
                [names, vrpArray] = FonaDynLoadVRP(filename);
                vrpArray = vrpArray(vrpArray(:, 2)>= 60, :);
                vrpArray(isoutlier(vrpArray(:, 1)), :) = [];
                output_name = fullfile(patient_folder, csv_name);
                FonaDynSaveVRP(output_name, names, vrpArray);
            end
        end
    end
end
