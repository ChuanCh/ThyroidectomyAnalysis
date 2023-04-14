pre = 'L:\Huanchen\Thyrovoice Dataset\MAT_data\AMOlilpre1001_Voice_EGG.wav';
post = 'L:\Huanchen\Thyrovoice Dataset\MAT_data\AMOlilpost1001_Voice_EGG.wav';
pre_file = audioread(pre);
audio = pre_file(:,1);
rms_val = rms(audio);
ref_val = 20e-6;
SPL = 20*log10(rms_val/ref_val);

