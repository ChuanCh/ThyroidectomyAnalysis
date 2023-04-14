clear data*
session = 'pré';
load([patient_name '_' nseq '_' session],'data');
data_pre = data;
session = 'post';
load([patient_name '_' nseq '_' session],'data');
data_post = data;

% f0
stairs(data_pre.f0bin,data_pre.f0density,'b')
hold on 
stairs(data_post.f0bin,data_post.f0density,'r')
hold off
tt = title([patient_name ', T' nseq ' (lecture)']);
set(tt,'FontSize',12,'FontWeight','bold')
xlab = xlabel('f0 frequency (Hz)');
ylab = ylabel('density (%)');
set(xlab,'FontSize',12,'FontWeight','bold')
set(ylab,'FontSize',12,'FontWeight','bold')
ll = legend('pre','post');
set(ll,'FontSize',12,'FontWeight','bold')
print(gcf,'-dpng',[patient_name '_' nseq '_hist_f0'])

% Idb
stairs(data_pre.Idbbin,data_pre.Idbdensity,'b')
hold on 
stairs(data_post.Idbbin,data_post.Idbdensity,'r')
hold off
tt = title([patient_name ', T' nseq ' (lecture)']);
set(tt,'FontSize',12,'FontWeight','bold')
xlab = xlabel('Intensity (dB)');
ylab = ylabel('density (%)');
set(xlab,'FontSize',12,'FontWeight','bold')
set(ylab,'FontSize',12,'FontWeight','bold')
ll = legend('pre','post',2);
set(ll,'FontSize',12,'FontWeight','bold')
print(gcf,'-dpng',[patient_name '_' nseq '_hist_Idb'])
