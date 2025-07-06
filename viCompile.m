% recompile all VISA (viXXX) functions

% TODO
% * Try using files from C:\Program Files\IVI Foundation
%   VISA\Win64\Include\visa.h
%   VISA\Win64\Include\visytype.h
%   VISA\Win64\Lib_x64\msc\nivisa64.lib
% * Add README.md and make public after testing

% In some cases mkoctfile could not write output files because
% they have not been proper closed (may happen on error conditions)
% "clear all" usually helps in that case
clear all

% standard VISA functions packed as oct file
mkoctfile -I. -L. -lvisa -s viOpenDefaultRM.cc
mkoctfile -I. -L. -lvisa -s viOpen.cc
mkoctfile -I. -L. -lvisa -s viSetAttribute.cc
mkoctfile -I. -L. -lvisa -s viGetAttribute.cc
mkoctfile -I. -L. -lvisa -s viConfigureSerialPort.cc
mkoctfile -I. -L. -lvisa -s viWrite.cc
mkoctfile -I. -L. -lvisa -s viFlush.cc
mkoctfile -I. -L. -lvisa -s viRead.cc % might be removed, use viQuery
mkoctfile -I. -L. -lvisa -s viReadBinBlock.cc % might be removed, use viQueryBinBlock
mkoctfile -I. -L. -lvisa -s viClose.cc
mkoctfile -I. -L. -lvisa -s viStatusDesc.cc % get text message for status code

% extension: write/read packed as single function to reduce overhead
mkoctfile -I. -L. -lvisa -s viQuery.cc % combined viWrite / viRead
mkoctfile -I. -L. -lvisa -s viQueryBinBlock.cc % combined viWrite viReadBinBlock

% NI example RdWrt.c converted to octave
mkoctfile -I. -L. -lvisa -s VISAtest.cc

