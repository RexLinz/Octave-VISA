% testing visa functions
%
% The tests below assume you have either set up a serial line loopback
% or a device at least accepting the "*IDN?" query.

% open resource manager
[rm, status] = viOpenDefaultRM;
if status<0
  error("open resource manager failed");
end

% open connection to device, set terminator to 10 (\n)
[dev, status] = viOpen(rm, "COM3", 2000, 10);
if status<0
  error("open device failed");
end

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
status = viSetAttribute(dev, 0x3FFF0038, 1); % VI_ATTR_TERMCHAR_EN
if status<0
  error("enable termchar failed");
end

% check timeout set by viOpen
[timeout, status] = viGetAttribute(dev,0x3FFF001A); % VI_ATTR_TMO_VALUE
if (status<0) | (timeout~=2000)
  error("get attribute failed");
end
% change timout
status = viSetAttribute(dev, 0x3FFF001A, 5000); % VI_ATTR_TMO_VALUE
if status<0
  error("set attribute failed");
end
% check if change has been successful
[timeout, status] = viGetAttribute(dev,0x3FFF001A); % VI_ATTR_TMO_VALUE
if (status<0) | (timeout~=5000)
  error("get attribute failed");
end

tic
% write *IDN? query to device
status = viWrite(dev, "*IDN?\n");
if status<0
  error("write failed");
end

[response, status] = viRead(dev, 100);
if status<0
  error("read device failed");
end
disp(["write *IDN? / read\n  " srtrim(response)]); % skip \n
toc

% better solution instead of using viWrite/viRead
[response, status] = viQuery(dev, "*IDN?\n", 100);
if status<0
  error("query device failed");
end
disp(["query *IDN?\n  " srtrim(response)]); % skip \n

% not required if you close the resource manager next
status = viClose(dev); clear dev; % ensure we could no longer use
if status<0
  error("close device failed");
end

status = viClose(rm); clear rm; % ensure we could no longer use
if status<0
  error("close resource manager failed");
end

