%% Load and Analysis
[engineSound, fs] = audioread('engine_audio_good_1.wav');
fprintf('Sampling Frequency: %d Hz\n', fs);

%play
soundsc(engineSound,fs);

% Normalizing
engineSound = engineSound / max(abs(engineSound));

% Plot original Signal
figure;
subplot(3,1,1);
plot(engineSound);
title('Time-Domain Signal');
xlabel('Sample');
ylabel('Amplitude');

%% designe a 8 order High-Pass Butterworth filter
filterOrder = 8;
cutoffFrequency = 500; % Cutoff frequency in Hz
[b, a] = butter(filterOrder, cutoffFrequency / (fs / 2), 'high');
engineSoundFiltered = filtfilt(b, a, engineSound);

% Plot the filtered Waveshape
subplot(3,1,2);
plot(engineSoundFiltered);
title('Filtered Time-Domain Signal');
xlabel('Sample');
ylabel('Amplitude');

%Fourier Transform of the filtered signal
engineSoundFFT = fft(engineSoundFiltered);
N = length(engineSoundFFT);

% Only using the first half of the FFT results (positive frequencies)
frequencies = (0:(N/2)-1)*(fs/N);
engineSoundFFT = engineSoundFFT(1:N/2);

%% Calculation

% Let Friquency Range of Knocking is 5000 to 7000
knockingFreqRange = [5000 7000];

% Finding indices corresponding to the knocking frequency range
knockingIndices = find(frequencies >= knockingFreqRange(1) & frequencies <= knockingFreqRange(2));

knockingPower = sum(abs(engineSoundFFT(knockingIndices)).^2);

totalPower = sum(abs(engineSoundFFT).^2);

% Normalize the Knocking Power 
normalizedKnockingPower = knockingPower / totalPower;

% Plot the frequency-domain signal
subplot(3,1,3);
plot(frequencies, abs(engineSoundFFT));
title('Frequency-Domain Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
hold on;

plot(frequencies(knockingIndices), abs(engineSoundFFT(knockingIndices)), 'r.', 'MarkerSize', 10);

% Legend to distinguish between the overall spectrum and knocking frequencies
legend('Overall Spectrum', 'Knocking Frequencies');

hold off;

normalizedKnockingThreshold = 0.1; % Adjust based on empirical data

if normalizedKnockingPower > normalizedKnockingThreshold
    fprintf('Bad engine: Knocking detected.\n');
else
    fprintf('Good engine: No significant knocking detected.\n');
end

fprintf('Normalized Knocking Power: %f\n', normalizedKnockingPower);
fprintf('Normalized Knocking Threshold: %f\n', normalizedKnockingThreshold);


