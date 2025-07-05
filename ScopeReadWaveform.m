function [y, t, status] = ScopeReadWaveform(dev, channel = "CHAN1")

tic
viWrite(dev, [":WAV:SOUR " channel "\n"]);
% preamble_block define mapping of data values to actual properties
preAmble   = viQuery(dev, ":WAV:PRE?\n", 200);
preValues  = strsplit(preAmble, ","); % split into tokens
wavFormat  = str2num(preValues{1});   % <format 16-bit NR1>, 0=BYTE, 1=WORD, 2=ASCII
wavType    = str2num(preValues{2});   % <type 16-bit NR1>,
nPoints    = str2num(preValues{3});   % <points 32-bit NR1>,
wavCount   = str2num(preValues{4});   % <count 32-bit NR1>,
xIncrement = str2num(preValues{5});   % <xincrement 64-bit floating point NR3>,
xOrigin    = str2num(preValues{6});   % <xorigin 64-bit floating point NR3>,
xReference = str2num(preValues{7});   % <xreference 32-bit NR1>,
yIncrement = str2num(preValues{8});   % <yincrement 32-bit floating point NR3>,
yOrigin    = str2num(preValues{9});   % <yorigin 32-bit floating point NR3>,
yReference = str2num(preValues{10});  % <yreference 32-bit NR1>

[data, status] = viQueryBinBlock(dev, ":WAV:DATA?\n", 2*nPoints+1000);
data = typecast(data, "uint16"); % reinterpret as uint16 (WORD)

%viWrite(dev, ":WAV:DATA?\n");             % query waveform data
%y = typecast(viReadBinBlock(dev, 1100000), "uint16"); % read and convert to word
y = ( double(data)-yReference)*yIncrement + yOrigin;
t = ((0:nPoints-1)-xReference)*xIncrement + xOrigin;

