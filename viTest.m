% testing VISA functions
%
% Requires either a SCPI enabled device or a serial loopback device to be connected.
% 1. open the default resource manager
% 2. open connection to device, e.g. serial port
% 3. check reading and writing some attributes (might / will be optional in most cases)
% 4. write an *IDN? query and read the response
% 5. use viQuery() to read the status byte of the device
% 6. if there is an error, close the device and device manager.

% open resource manager
[visaRM, status] = viOpenDefaultRM;
if status<0
  clear visaRM; % ensure we could no longer use
  error("open resource manager failed");
end
% device manager is opened
try
  % open connection to device, set terminator to 10 (\n)
  [visaDev, status] = viOpen(visaRM, "COM3", 3000, 10); % VISA default 9600,N,8,1
%  viConfigureSerialPort(visaDev, baud, databits, parity, stopBits, flowControl)
%  statusSerial = viConfigureSerialPort(visaDev, 1200)
%  [visaDev, status] = viOpen(visaRM, "MSO", 3000, 10);
  [visaDev, status] = viOpen(visaRM, "33250A", 3000, 10); % function generator
  if status<0
    error("open device failed");
  end
  % ...some typical operations

  # some frequently used attribute values from visa.h
  #define VI_ATTR_TMO_VALUE                     (0x3FFF001AUL)

  #define VI_ATTR_TERMCHAR                      (0x3FFF0018UL)
  #define VI_ATTR_TERMCHAR_EN                   (0x3FFF0038UL)

  #define VI_ATTR_RD_BUF_SIZE                   (0x3FFF002BUL)
  #define VI_ATTR_WR_BUF_SIZE                   (0x3FFF002EUL)

  #define VI_ATTR_ASRL_BAUD                     (0x3FFF0021UL)
  #define VI_ATTR_ASRL_DATA_BITS                (0x3FFF0022UL)
  #define VI_ATTR_ASRL_PARITY                   (0x3FFF0023UL)
  #define VI_ATTR_ASRL_STOP_BITS                (0x3FFF0024UL)
  #define VI_ATTR_ASRL_FLOW_CNTRL               (0x3FFF0025UL)

  % should already be done if you use the termchar option in the viOpen function
  status = viSetAttribute(visaDev, 0x3FFF0038, 1); % VI_ATTR_TERMCHAR_EN
  if status<0
    error("enable termchar failed");
  end

  % check timeout set by viOpen
  [timeout, status] = viGetAttribute(visaDev,0x3FFF001A); % VI_ATTR_TMO_VALUE
  if (status<0) | (timeout~=3000)
    error("get attribute failed");
  end
  % change timout
  status = viSetAttribute(visaDev, 0x3FFF001A, 2000); % VI_ATTR_TMO_VALUE
  if status<0
    error("set attribute failed");
  end
  % check if change has been successful
  [timeout, status] = viGetAttribute(visaDev,0x3FFF001A); % VI_ATTR_TMO_VALUE
  if (status<0) | (timeout~=2000)
    error("get attribute failed");
  end

  % write *IDN? query to device
  status = viWrite(visaDev, "*IDN?\n");
  if status<0
    error("write failed");
  end
  % read response
  [response, status] = viRead(visaDev, 100);
  if status<0
    error("read device failed");
  end
  disp(["write '*IDN?', read '" strtrim(response) "'"]); % skip \n

  % easier solution instead of using viWrite/viRead (but about same performance)
  % typical reading for STB? = '+129'
  [response, status] = viQuery(visaDev, "*STB?\n", 100);
  if status<0
    error("query device failed");
  end
  disp(["query '*STB?', read '" strtrim(response) "'"]); % skip \n

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
end_try_catch

clear visaDev; % ensure we could no longer use
% close the resource manager (will also close all device connections)
status = viClose(visaRM); clear visaRM; % ensure we could no longer use
if status<0
  error("close resource manager failed");
end

