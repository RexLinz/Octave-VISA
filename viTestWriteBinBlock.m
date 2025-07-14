% Test viWriteBinBlock function reading scope setup
% from an Keysight MSO-X 2024 oscilloscope using
% any interface, e.g. USB , LAN (socket) or GPIB connection
% and write back after some user changes
%
% Handling of IEEE 488.2 binary data blocks.
%
% Will most likely work on other Keysight oscilloscopes,
% but need some modification for other devices.

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

  % read setup as binary block
  % number of waveform points returned will depend on the scope settings
  [setupData, status] = viQueryBinBlock(visaDev, ":SYST:SET?\n", 100000);
  if status<0
    error("reading setup failed");
  end

  disp("change any settings, then press any key to restore setup");
  pause;

  % write back to device
  % note MSO2024 requires SPACE after command before binary block starting
  [bytesDone, status] = viWriteBinBlock(visaDev, setupData, ":SYST:SET ");
  if status<0
    error("writing setup failed");
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
clear visaDev; % ensure we could no longer use
status = viClose(visaRM); clear visaRM; % ensure we could no longer use
if status<0
  error("close resource manager failed");
end

