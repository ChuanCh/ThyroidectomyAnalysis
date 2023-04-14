filename = [patient_name session '10' nseq];

clear f0* data*

% read data PIO
[y_pio, sdsc, adsc, list] = lire_RIFF([patient_datapath filename '.pr1']);
fs_pio = sdsc.freq_sgl;
% read data Idb
[Idb, sdsc, adsc, list] = lire_RIFF([patient_datapath filename '.int']);
fs_Idb = sdsc.freq_sgl;
Idb = resample(Idb,fs_pio,fs_Idb);
if length(Idb)>length(y_pio)
    Idb(length(y_pio)+1:end) = [];
elseif length(Idb)<length(y_pio)
    Idb(end+1:length(y_pio)) = NaN;
end

% selection normal / piano / forte


% NORMAL
disp('selection de la première zone (paipaipai normal')
ans = 'n';

while ~strcmp(ans,'o')
    plot([1:length(y_pio)],y_pio,[1:length(y_pio)],(Idb-min(Idb))/(max(Idb)-min(Idb))*max(y_pio),'m')
    [indn,yy] = ginput(2);
    ll = line([indn';indn'],[ylim' ylim']);
    set(ll,'Color','k','LineWidth',2)
    ans = input('Satisfait (o/n) ? ','s');
    if isempty(ans)
        ans = 'o';
    end
end


% data save
data.filename = filename;
data.

data.Idbbin = Idbbin;
save([patient_name '_' nseq '_' session],'data')
