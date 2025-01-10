 % Define ThingSpeak Channel Details
    readChannelID = 2778481;           % Replace with your ThingSpeak channel ID
    readAPIKey = 'WNNJHZFHUNHW8TVB';  % Replace with your ThingSpeak read API key
    fieldNumber = 1;                  % Field number to read from the channel
    Fs = 1000;                        % Sampling frequency (Hz) - adjust based on your data
    
    % Read Data from ThingSpeak
    signal = thingSpeakRead(readChannelID, 'Fields', fieldNumber, ...
                            'NumPoints', 36, 'ReadKey', readAPIKey);
    
    % Check if signal was retrieved
    if isempty(signal)
        error('No data retrieved from ThingSpeak. Check channel ID, field, and API key.');
    end
    
    % Signal Properties
    L = length(signal);    % Length of the signal
    
    % Compute FFT
    Y = fft(signal);       % Compute the Fast Fourier Transform (FFT)
    
    % Compute Two-Sided Spectrum and Single-Sided Spectrum
    P2 = abs(Y / L);       % Two-sided amplitude spectrum
    P1 = P2(1:L/2+1);      % Single-sided amplitude spectrum
    P1(2:end-1) = 2 * P1(2:end-1); % Adjust amplitude for single-sided spectrum
    
    % Frequency Vector
    f = Fs * (0:(L/2)) / L; % Frequency vector corresponding to P1
    
    % Custom Peak Detection (Alternative to findpeaks)
    peakThreshold = max(P1) * 0.5; % Set a threshold to filter significant peaks
    peakIndices = find(P1 > peakThreshold & [0; diff(P1)] > 0 & [diff(P1); 0] < 0); 
    peakValues = P1(peakIndices); % Get the amplitude of the peaks
    
    % Plot Frequency-Domain Signal
    figure;
    plot(f, P1, 'LineWidth', 1.5);
    title('Frequency-Domain Signal');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude |P1(f)|');
    grid on;
    
    % Annotate Peaks on the Graph
    hold on;
    plot(f(peakIndices), peakValues, 'ro'); % Mark peaks with red circles
    for i = 1:length(peakIndices)
        text(f(peakIndices(i)), peakValues(i), ...
             ['(' num2str(f(peakIndices(i)), '%.1f') ' Hz, ' ...
              num2str(peakValues(i), '%.1f') ')'], ...
             'VerticalAlignment', 'bottom', ...
             'HorizontalAlignment', 'right', ...
             'FontSize', 8);
    end
    hold off;
    
    % Optional: Save Peak Frequency and Amplitude Data Back to ThingSpeak
    writeChannelID = 2778481;           % Replace with your ThingSpeak write channel ID
    writeAPIKey = '1TFTBXI21ER3LUPY';  % Replace with your ThingSpeak write API key
    if ~isempty(peakValues)
        peakFrequencies = f(peakIndices); % Frequencies of the peaks
        thingSpeakWrite(writeChannelID, peakFrequencies(1), 'WriteKey', writeAPIKey); % Send first peak
    end