% Test viReadBinBlock function reading a screenshot (PNG)
% or waveform data from an Keysight MSO-X 2024 oscilloscope using
% any interface, e.g. USB or LAN (socket) connection
%
% a binblock is a binary data transfer allowing faster transfers than
% reading ASCII data

% open resource manager
[rm, status] = viOpenDefaultRM;
if status<0
  error("open resource manager failed");
end

% open connection to device, set terminator to 10 (\n)
[dev, status] = viOpen(rm, "MSO", 2000, 10);
if status<0
  error("open device failed");
end

% using viQery instead of viWrite/viRead
[response, status] = viQuery(dev, "*IDN?\n", 100);
if status<0
  error("query device failed");
end
disp(["query *IDN?\n  " srtrim(response)]); % skip \n

% try to read a waveform from channel 1 as array of WORD
% number of waveform points returned will depend on the scope settings
if 1 % enable or disable
  % set up scope
  viWrite(dev, ":WAV:FORM WORD\n");  % format WORD
  viWrite(dev, ":WAV:BYT LSBF\n");   % LSB first, required for 16 bit data
  viWrite(dev, ":WAV:POINTS MAX\n"); % record length
  % stop acquisition to give time to read all channels
  viWrite(dev, ":STOP\n"); % stop to get all waveforms from same ackquisition

  tic
  disp("reading channel 1 data");
  [y1, t] = ScopeReadWaveform("CHAN1");
  disp("reading channel 2 data");
  [y2, t] = ScopeReadWaveform("CHAN2"); % reduntant time vector
  toc % about 300 ms per channel for 500k points on WiFi

  % restart acquisition
  viWrite(dev, ":RUN\n");

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
if 0
  % set up scope (optional)
  viWrite(dev, ":HARDcopy:INKSaver OFF\n"); % OFF = black background
  % get image in PNG file format
%  viWrite(dev, ":DISP:DATA? PNG,COL\n");
%  [imgData, status] = viReadBinBlock(dev, 200000);
  [imgData, status] = viQueryBinBlock(dev, ":DISP:DATA? PNG,COL\n", 200000); % return uint8
  if status==0
    % write to temporary file
    fid = fopen("viTest.png", "wb");
    fwrite(fid, imgData(1:end-1)); % skip \n
    fclose(fid);
    % display image from file
    figure(2, "name", "Scope Screenshot");
    imshow("viTest.png");
  else
    disp("read image failed");
  end
end

% check if further communication is still fine after readBinBlock
[response, status] = viQuery(dev, "*IDN?\n", 100);
if status<0
  error("regular communication after readBinBlock failes");
end

% not required if you close the resource manager next
status = viClose(dev); clear dev; % ensure we could no longer use
if status<0
  error("close device failed");
end

% close resource manager
status = viClose(rm); clear rm; % ensure we could no longer use
if status<0
  error("close resource manager failed");
end

