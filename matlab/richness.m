close all; clear all;

filename = '/Volumes/voicelab/fonadyn/FonaDynInstall-3-0-1/Test files/test_Log.aiff';
[data, samplerate] = audioread(filename);
qdelta = data(:, 12);
HarmonicsAmplitude = db2mag(data(:, 15:23) .* 10);
HarmonicsAmplitudeRest = db2mag(data(:, 15:24) .*10);
FundAmplitude = db2mag(data(:, 14) .*10);

richness = sum(HarmonicsAmplitude, 2) ./ FundAmplitude;
richnessRest = sum(HarmonicsAmplitudeRest, 2) ./ FundAmplitude;

scatter(qdelta, richness);
xlabel('Qd');
ylabel('Richness');

figure
scatter(qdelta, richnessRest);
xlabel('Qd');
ylabel('Richness with Hrest');

R = corrcoef(qdelta, richness);
R2 = corrcoef(qdelta, richnessRest);
