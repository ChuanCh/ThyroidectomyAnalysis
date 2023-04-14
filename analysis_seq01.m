filename = [patient_name session '10' nseq];

clear Idb* f0* data*

% read data f0
[f0, sdsc, adsc, list] = lire_RIFF([patient_datapath filename '.F0']);
%sampling frequency 25000Hz

% data selection
f0_sel = f0;
ind_max = find(f0>=3*median(f0));
f0_sel(ind_max) = NaN;
ind_min = find(f0<=70);
f0_sel(ind_min) = NaN;
% density calculation (2Hz step)
[nf0,f0bin] = hist(f0_sel,[min(f0_sel):2:max(f0_sel)]);
f0density = nf0/(sum(nf0))*100; % densité en %

% read data Idb
[Idb, sdsc, adsc, list] = lire_RIFF([patient_datapath filename '.int']);
%sampling frequency 12500Hz
Idbr = resample(Idb,25000,12500);
Idb_sel = Idbr;
Idb_sel(ind_max) = NaN;
Idb_sel(ind_min) = NaN;
% density calculation (1dB step)
[nIdb,Idbbin] = hist(Idb_sel,[min(Idb_sel):2:max(Idb_sel)]);
Idbdensity = nIdb/(sum(nIdb))*100; % densité en %
% stairs(Idbbin,Idbdensity)

% data save
data.filename = filename;
data.f0_all = f0;
data.f0 = f0_sel;
data.f0density = f0density;
data.f0bin = f0bin;
data.Idb_all = Idbr;
data.Idb = Idb_sel;
data.Idbdensity = Idbdensity;
data.Idbbin = Idbbin;
save([patient_name '_' nseq '_' session],'data')
