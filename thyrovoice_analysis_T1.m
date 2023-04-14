% chemin vers les fonctions appelées par Matlab
addpath('E:\PROJETS DE RECHERCHE\THYRO_VOICE\ANALYSIS\MATLAB_progs')


% datapath -  chemin vers les données
datapath = 'E:\PROJETS DE RECHERCHE\THYRO_VOICE\DATA\PATIENTS\';

patient_code = 'F1';
patient_name = 'SILmar';

patient_datapath = [datapath patient_code '_' patient_name '\'];

% EVA data: 
%   - pr1: Psg
%   - oaf: débit oral
%   - int: intensité
%   - F0: f0
%   - egg:  EGG
%   - wa1: audio

% % PIO
% [y_pio, sdsc, adsc, list] = lire_RIFF([patient_datapath filename '.pr1']);
% fs_pio = sdsc.freq_sgl;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEQ 01 - lecture d'un texte (le petit prince)
% mesure de f0 mean, std ; Idb mean, std ;
% durée voisée/non voisée, du timbre vocalique, de la bitonalité
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nseq = '01';

%%%%%%%%%%%%%%%%%%%%
% ANALYSIS AND SAVE
%%%%%%%%%%%%%%%%%%%%
session = 'pré';
analysis_seq01

session = 'post';
analysis_seq01

%%%%%%%%
% PLOT
%%%%%%%%
plot_seq01


%%%%%%%%%%%%%%%%
% WRITE IN EXCEL
%%%%%%%%%%%%%%%%
% A COMPLETER SOUS MATLAB PLUS RECENT
excelfile = 'thyrovoice_data.xls';

% session pre
f0data = [nanmean(data_pre.f0) nanstd(data_pre.f0) min(data_pre.f0) max(data_pre.f0)];
Idbdata = [nanmean(data_pre.Idb) nanstd(data_pre.Idb) min(data_pre.Idb) max(data_pre.Idb)];

[success,message]=xlswrite(excelfile,patient_name,'seq01','A2')
[success,message]=xlswrite(excelfile,patient_code,'seq01','B2')
[success,message]=xlswrite(excelfile,'pre','seq01','C2')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEQ 02 - lecture d'un texte (le petit prince)
% mesure de f0 mean, std ; Idb mean, std ;
% durée voisée/non voisée, du timbre vocalique, de la bitonalité
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% audio

session = 'pré';
session = 'post';
filename = [patient_name session '10' nseq];

[sau, sdsc, adsc, list] = lire_RIFF([patient_datapath filename '.wa1']);
fs = sdsc.freq_sgl;

soundsc(sau,fs)
