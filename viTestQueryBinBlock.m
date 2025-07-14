% Test viQueryBinBlock function reading a screenshot (PNG)
% or waveform data from an Keysight MSO-X 2024 oscilloscope using
% any interface, e.g. USB , LAN (socket) or GPIB connection
%
% Handling of IEEE 488.2 binary data blocks.
% It holds two test cases, each of them could be individually enabled.
%
% 1. Reading oscilloscope waveform
% 2. Reading oscilloscope screenshot as PNG
%
% Both have been used on an Keysight MSO-X 2024 mixed signal oscilloscope.
% Most likely they will work on other Keysight oscilloscopes, but will need some modification for other devices.

% A IEEE 488.2 binblock is a binary data transfer allowing
% faster transfers than reading ASCII data from devices

% data format of IEEE 488.2 binary blocks
% # ... ASCII character indicate header
% n ... number of length digits to follow
% x ... n digits of ASCII coded value representing the number of data bytes following
% y ... followed by x data bytes (uint8)
% terminator, typically \n (on most instruments)

% open resource manager
[visaRM, status] = viOpenDefaultRM;
if status<0
  clear visaRM; % ensure we could no longer use
  error("open resource manager failed");
end
% device manager is opened
try
  % open connection to device, set terminator to 10 (\n)
%  [visaDev, status] = viOpen(visaRM, "MSO-USB", 2000, 10); % USB
  [visaDev, status] = viOpen(visaRM, "MSO", 2000, 10); % TCPIP0::mso2024.local::5025::SOCKET - OK
%  [visaDev, status] = viOpen(visaRM, "MSO-SOCK", 2000, 10); % TCPIP0::10.0.0.23::5025::SOCKET - OK
%  [visaDev, status] = viOpen(visaRM, "mso2024", 2000, 10); % TCPIP0::mso2024::inst0::INSTR - OK
%  [visaDev, status] = viOpen(visaRM, "TCPIP0::mso2024::inst0::INSTR", 2000, 10); % TCPIP0::mso2024::inst0::INSTR - OK
  if status<0
    error("open device failed");
  end

  % try to read waveforms as array of WORD
  % number of waveform points returned will depend on the scope settings
  if 1 % enable or disable
    % channels 1 and 2 must be enabled
    viWrite(visaDev, ":CHAN1:DISP ON\n");
    viWrite(visaDev, ":CHAN2:DISP ON\n");
    % set up waveform readout
    viWrite(visaDev, ":WAV:FORM WORD\n");  % format WORD
    viWrite(visaDev, ":WAV:BYT LSBF\n");   % LSB first, required for 16 bit data
    viWrite(visaDev, ":WAV:POINTS MAX\n"); % record length
    % stop acquisition to give time to read all channels
    viWrite(visaDev, ":STOP\n"); % stop to get all waveforms from same ackquisition

    tic
    disp("reading channel 1 data");
    [y1, t] = ScopeReadWaveform(visaDev, "CHAN1");
    disp("reading channel 2 data");
    [y2, t] = ScopeReadWaveform(visaDev, "CHAN2"); % reduntant time vector
    toc
    % per channel timing for 500k points
    % 300-700 ms Notebook WiFi <-> MSO LAN
    % 500 ms Desktop LAN <-> MSO LAN (viQueryBinBlock 220 ms)
    % 150 ms Notebook USB

    % restart acquisition
    viWrite(visaDev, ":RUN\n");

    % create plot
    figure(1, "name", "Scope Waveform");
    plot(
      1000*t, y1, ";CH1;",
      1000*t, y2, ";CH2;"
    );
    grid on;
    xlabel("t [ms]");
  end

  % read a screenshot as PNG from the scope
  if 1 % enable or disable
    % set up scope (optional)
    viWrite(visaDev, ":HARDcopy:INKSaver OFF\n"); % OFF = black background
    % get image in PNG file format
  %  viWrite(visaDev, ":DISP:DATA? PNG,COL\n");
  %  [imgData, status] = viReadBinBlock(visaDev, 200000);
    tic
    [imgData, status] = viQueryBinBlock(visaDev, ":DISP:DATA? PNG,COL\n", 200000); % return uint8
    toc
    % 1200 ms Notebook WiFi <-> MSO LAN
    % 1200 ms Desktop LAN <-> MSO LAN
    % 1200 ms Notebook USB

    if status==0
      % write to temporary file
      fid = fopen("viTest.png", "wb");
      fwrite(fid, imgData);
      fclose(fid);
      % display image from file
      figure(2, "name", "Scope Screenshot");
      imshow("viTest.png");
    else
      disp("read image failed");
    end
  end

  % check if further communication is still fine after read/query BinBlock
  [response, status] = viQuery(visaDev, "*IDN?\n", 100);
  if status<0
    error("regular communication after readBinBlock failed");
  end

catch
  errorMessage = lasterr % show last error message
  statusMessage = viStatusDesc(status) % explain error
  if visaDev>0 % we have an open connection?
    % not required if you close the resource manager next
    status = viClose(visaDev); clear visaDev; % ensure we could no longer use
    if status<0
      error("close device failed");
    end
  end
  clear visaDev; % ensure we could no longer use
end_try_catch

% close resource manager
status = viClose(visaRM); clear visaRM; % ensure we could no longer use
if status<0
  error("close resource manager failed");
end

