% audio data cleaning: wiener freq reduction. not done..
raw_folder = 'F:\Thyrovoice\audio';
denoised_folder = 'F:\Thyrovoice\denoised_audio';
noise_ref = 'F:\Thyrovoice\Noise-ref.wav';
patient_folder = dir(raw_folder);
fs = 44100;
for i = 1:length(patient_folder)
    patient_name = patient_folder(i).name;
    if ~isequal(patient_name, '.') && ~isequal(patient_name, '..')
        patient_folder = fullfile(raw_folder, patient_name);
        audio_file = dir(patient_folder);
        for j = 1:length(audio_file)
            audio_name = audio_file(j).name;
            if ~isequal(audio_name, '.') && ~isequal(audio_name, '..')
                audio = audioread(fullfile(patient_folder, audio_name));
                audio = audio(:,1);
                %cleaning starts here
                noise = audioread(noise_ref);
                noise = padarray(noise, abs(length(audio)-length(noise)), 0, 'post');
                
                win_length = 256;
                fft_length = length(audio);
                
                % Apply the FFT to the audio and noise signals
                audio_fft = fft(audio, fft_length);
                noise_fft = fft(noise, fft_length);

                % Calculate the power spectral density (PSD) of the audio and noise signals
                audio_psd = abs(audio_fft) .^ 2 / fft_length;
                noise_psd = abs(noise_fft) .^ 2 / fft_length;
                
                % Calculate the Wiener filter using the PSDs of the audio and noise signals
                wiener_filter = conj(noise_fft) ./ (noise_psd + eps);
                wiener_filter = wiener_filter ./ (wiener_filter .* noise_fft + audio_psd);
                
                % Apply the Wiener filter to the audio signal in the frequency domain
                clean_audio_fft = wiener_filter .* audio_fft;
                
                % Apply the inverse FFT to obtain the clean audio signal in the time domain
                clean_audio = real(ifft(clean_audio_fft));
                

                x_dir = fullfile(denoised_folder, patient_name);
                if ~exist(x_dir,'dir')
                    mkdir(x_dir)
                end
                % Save the denoised audio file
                audiowrite(sprintf('denoised_%d.wav', i), clean_audio, fs);
            end
        end
    end
end