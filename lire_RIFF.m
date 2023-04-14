% [signal, sdsc, adsc, list] = lire_RIFF(nom_RIFF);
% 
% Lecture d'un fichier en format RIFF
% 
% 
% Entrées: 
%   nom_RIFF : nom du fichier (avec son extension implicite)
% 
% Sorties:
%   signal : signal dans l'unité spécifiée dans les entêtes
%   sdsc   : entête de description du signal (SIG_DESC)
%        sdsc.size_sgl   : struct size
%        sdsc.acronym    : parameter's acronym
%        sdsc.par_name   : parameter's description
%        sdsc.unit_name  : parameter's unit name
%        sdsc.nbsampl    : number of samples
%        sdsc.freq_sgl   : acquisition sampling frequency
%        sdsc.smax       : max value of the signal
%        sdsc.smin       : min value of the signal
%        sdsc.cmax       : calibration at max
%        sdsc.czero      : calibration at zero
%        sdsc.imax       : integer part of the value at maximum
%        sdsc.fmax       : floating part x 10^6 of the maximum
%       
%   adsc   : entête de description du setup (ACQ_DESC)
%        adsc.struc_size : struc size
%        adsc.nch        : number of channels
%        adsc.nsamples   : number of samples
%        adsc.freq       : acquisition frequency (???)
%        adsc.bps        : bits per sample
%        adsc.highest    : highest value
%        adsc.lowest     : lowest value
%        adsc.zero       : zero
%        adsc.reccode    : recording program code 
%        adsc.recver     : version of the acquisition program
% 
%   list    : entête d'informations
%       list.total        : chaine complète
%       list.INFO         : 'INFO'
%       list.INAM         : 'INAM'
%       list.ICMT         : Commentaires
%       list.ICRD         : Date de création
%       list.ICOP         : Copyright
%       list.ISFT         : Glottal Efficiency Index
% 
% Refait à partir de CS (28/04/00) le 21/02/2003

function [signal, sdsc, adsc, list] = lire_RIFF(nom_RIFF);

fid = fopen(nom_RIFF);

if (fid == -1)
  error('Erreur dans l''ouverture du fichier');
end

% Entête global
id = fscanf(fid,'%c',4);
if ~strcmp(id, 'RIFF') error('lire_RIFF : fichier non RIFF'); end
size = fread(fid,1,'ulong');
form = fscanf(fid,'%c',4);
if ~strcmp(form, 'WSIG') error('lire_RIFF : fichier non EVA'); end

% Signal Description : SIG_DESC
sub_id2 = fscanf(fid,'%c',4);
if ~strcmp(sub_id2, 'sdsc') error('lire_RIFF : fichier sans SIG_DESC'); end
size_id2 = fread(fid,1,'ulong');
sdsc.size_sgl = fread(fid,1,'ulong');
sdsc.acronym = deblank(fscanf(fid,'%c',4));
sdsc.par_name = deblank(fscanf(fid,'%c',80));
sdsc.unit_name = deblank(fscanf(fid,'%c',16));
sdsc.nbsampl = fread(fid,1,'ulong');
sdsc.freq_sgl = fread(fid,1,'ulong');
sdsc.smax = fread(fid,1,'int16');
sdsc.smin = fread(fid,1,'int16');
sdsc.cmax = fread(fid,1,'int16');
sdsc.czero = fread(fid,1,'int16');
sdsc.imax = fread(fid,1,'int32');
sdsc.fmax = fread(fid,1,'ulong');

% Setup description ACQ_DESC
sub_id3 = fscanf(fid,'%c',4);
size_id3 = fread(fid,1,'ulong');
if ~strcmp(sub_id3, 'adsc') error('lire_RIFF : fichier sans ACQ_DESC'); end
adsc.struc_size = fread(fid,1,'ulong');
adsc.nch = fread(fid,1,'ushort');
adsc.nsamples = fread(fid,1,'ulong');
adsc.freq = fread(fid,1,'ulong');
adsc.bps = fread(fid,1,'ushort');
adsc.highest = fread(fid,1,'int32');
adsc.lowest = fread(fid,1,'int32');
adsc.zero = fread(fid,1,'int32');
adsc.reccode = fread(fid,1,'ushort');
adsc.recver = fread(fid,1,'ushort');

% Liste des infos
sub_id4 = fscanf(fid,'%c',4);
size_id4 = fread(fid,1,'uint32');
if strcmp(sub_id4, 'LIST') 
    [bid, count] = fscanf(fid,'%c',size_id4);
    % count
    list.total = bid;
    %nbc =  4; list.INFO = bid(1:nbc); bid = bid(nbc+1:end);
    %nbc =  4; list.INAM = bid(1:nbc); bid = bid(nbc+1:end);
    %nbc = 29; list.ICMT = bid(1:nbc); bid = bid(nbc+1:end);
    %nbc = 14; list.ICRD = bid(1:nbc); bid = bid(nbc+1:end);
    %nbc = 19; list.ICOP = bid(1:nbc); bid = bid(nbc+1:end);
    %nbc = 29; list.ISFT = bid(1:nbc); bid = bid(nbc+1:end);
    % Données ... enfin !
    sub_id5 = fscanf(fid,'%c',4);
    size_id5 = fread(fid,1,'uint32')/2;
else
    warning('lire_RIFF : fichier sans INFO');
    list = [];
    sub_id5 = sub_id4;
    size_id5 = size_id4/2;
end

if ~strcmp(sub_id5, 'data') error('lire_RIFF : fichier sans donnees'); end
data.dab = fread(fid,size_id5,'int16');

fclose(fid);

% Signal en unités correctes
Ech_dab = (sdsc.imax + 1e-6*sdsc.fmax) / sdsc.cmax;
signal = (data.dab - sdsc.czero) * Ech_dab;

return

% Affichage
sig_plot(naf, sdsc.freq_sgl);
grid on
set(gca, 'YMinorGrid', 'on');
set(gca, 'YMinorTick', 'on');
ylabel([deblank(sdsc.par_name), ' (',deblank(sdsc.unit_name), ')'])
set(gca, 'YTick', [-0.5 :0.1: 0.5])

