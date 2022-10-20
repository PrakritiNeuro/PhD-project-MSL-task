
%% INITIALIZE SOUND DRIVER & PRELOAD SOUNDS

% Running on PTB-3? Abort otherwise.
AssertOpenGL;

nrchannels = 2;     % 2 channels for stereo output
device = [];        % default sound device 

% Perform basic initialization of the sound driver
InitializePsychSound;

% Open the audio 'device' with default mode [] (== Only playback),
% and a required latencyclass of 1 == standard low-latency mode, as well as
% default playback frequency and 'nrchannels' sound output channels.
% This returns a handle 'pahandle' to the audio device
pahandle = PsychPortAudio('Open', device, [], 1, [], nrchannels);

% Get the full paths to the sound files
% The order is the same as in soundHandSeq
wav_fpaths = cell(1, numel(param.soundHandSeq));
for i = 1:numel(param.soundHandSeq)
    wav_fpaths{i} = fullfile(param.main_dpath, 'stimuli', param.soundHandSeq(i).sound);
end

% Read all sound files, create & fill one dynamic audiobuffer for
% each read soundfile
buffer = [];
for i=1:length(wav_fpaths)
    [audiodata, ~] = psychwavread(char(wav_fpaths(i)));
    [~, ninchannels] = size(audiodata);
    audiodata = repmat(transpose(audiodata), nrchannels / ninchannels, 1);
    buffer(end+1) = PsychPortAudio('CreateBuffer', [], audiodata);
end

%% PLAY SOUND
% Fill playbuffer with content of buffer(i):
PsychPortAudio('FillBuffer', pahandle, buffer(i));

% Set volume
divice_volume = 1; % should be between 0 to 1
PsychPortAudio('Volume', pahandle, divice_volume)

repetitions = 1;
% Initate playback immediately (0) but wait for the actual start (1)
time_playsound = PsychPortAudio('Start', pahandle, repetitions, 0, 1);

%% CLOSE

if exist(pahandle, "var")
    % Wait until end of playback (1) then stop:
    PsychPortAudio('Stop', pahandle, 1);
    
    % Delete all dynamic audio buffers
    PsychPortAudio('DeleteBuffer');
    
    % Close the audio device
    PsychPortAudio('Close', pahandle);
end


