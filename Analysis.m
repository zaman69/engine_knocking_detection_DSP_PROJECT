%% Load and Analysis for Good Engine
[engineSoundGood, fs] = audioread('engine_audio_good_1.wav');
fprintf('Sampling Frequency (Good Engine): %d Hz\n', fs);

% Normalizing
engineSoundGood = engineSoundGood / max(abs(engineSoundGood));

%% Load and Analysis for Bad Engine
[engineSoundBad, fsBad] = audioread('engine_audio_bad_1.wav');
fprintf('Sampling Frequency (Bad Engine): %d Hz\n', fsBad);

% Ensure both signals have the same sampling frequency
if fs ~= fsBad
    error('Sampling frequencies of the two audio files do not match.');
end

% Normalizing
engineSoundBad = engineSoundBad / max(abs(engineSoundBad));

%% Adjust lengths of the signals to be the same
minLength = min(length(engineSoundGood), length(engineSoundBad));
engineSoundGood = engineSoundGood(1:minLength);
engineSoundBad = engineSoundBad(1:minLength);

%% Design a 8-order High-Pass Butterworth filter
filterOrder = 8;
cutoffFrequency = 500; % Cutoff frequency in Hz
[b, a] = butter(filterOrder, cutoffFrequency / (fs / 2), 'high');

% Filter both signals
engineSoundGoodFiltered = filtfilt(b, a, engineSoundGood);
engineSoundBadFiltered = filtfilt(b, a, engineSoundBad);

%% Fourier Transform of the filtered signals
engineSoundGoodFFT = fft(engineSoundGoodFiltered);
engineSoundBadFFT = fft(engineSoundBadFiltered);
N = length(engineSoundGoodFFT);

% Only using the first half of the FFT results (positive frequencies)
frequencies = (0:(N/2)-1) * (fs/N);
engineSoundGoodFFT = engineSoundGoodFFT(1:N/2);
engineSoundBadFFT = engineSoundBadFFT(1:N/2);

%% Calculate the Difference Spectrum
differenceSpectrum = abs(engineSoundGoodFFT) - abs(engineSoundBadFFT);

%% Identify the Frequency Range with Maximum Difference
% Set a threshold for significant difference (this can be adjusted)
threshold = max(abs(differenceSpectrum)) * 0.8;
significantDifferenceIndices = find(abs(differenceSpectrum) > threshold);

% Frequency range with maximum difference
if ~isempty(significantDifferenceIndices)
    freqRangeStart = frequencies(significantDifferenceIndices(1));
    freqRangeEnd = frequencies(significantDifferenceIndices(end));
else
    freqRangeStart = 0;
    freqRangeEnd = 0;
end

%% Plotting Frequency Spectrum of Both Good and Bad Engine Sounds
figure;
plot(frequencies, abs(engineSoundGoodFFT));
hold on;
plot(frequencies, abs(engineSoundBadFFT), 'r');

% Highlight the frequency range with the most difference
if freqRangeStart > 0 && freqRangeEnd > 0
    area([freqRangeStart freqRangeEnd], [max(abs(engineSoundGoodFFT)) max(abs(engineSoundGoodFFT))], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'FaceColor', 'yellow');
end

title('Frequency Spectrum of Good and Bad Engine Sounds');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
legend('Good Engine', 'Bad Engine', 'Max Difference Range');
hold off;

% Print the frequency range with maximum difference
fprintf('Frequency range with maximum difference: %.2f Hz to %.2f Hz\n', freqRangeStart, freqRangeEnd);
