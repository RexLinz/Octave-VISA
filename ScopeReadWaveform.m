% function [y, t, status] = ScopeReadWaveform(visaDev, channel = "CHAN1")
%
% read a waveform from Keysight MSO-X 2024 oscilloscope
% migth work with other brands
%
% function is provided to show usage of viQueryBinBlock

function [y, t, status] = ScopeReadWaveform(visaDev, channel = "CHAN1")

% select source to read
viWrite(visaDev, [":WAV:SOUR " channel "\n"]);
% preamble_block define mapping of data values to actual properties
preAmble   = viQuery(visaDev, ":WAV:PRE?\n", 200);
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

[data, status] = viQueryBinBlock(visaDev, ":WAV:DATA?\n", 2*nPoints+1000);
data = typecast(data, "uint16"); % reinterpret as uint16 (WORD)

%viWrite(visaDev, ":WAV:DATA?\n");             % query waveform data
%y = typecast(viReadBinBlock(visaDev, 1100000), "uint16"); % read and convert to word
y = ( double(data)-yReference)*yIncrement + yOrigin;
t = ((0:nPoints-1)-xReference)*xIncrement + xOrigin;

