% recompile all VISA (viXXX) functions

% TODO try using files from C:\Program Files\IVI Foundation
%   VISA\Win64\Include\visa.h
%   VISA\Win64\Include\visytype.h
%   VISA\Win64\Lib_x64\msc\nivisa64.lib

% clear all assures all files could be written to
clear all

% standard VISA functions packed as oct file
mkoctfile -I. -L. -lvisa -s viOpenDefaultRM.cc
mkoctfile -I. -L. -lvisa -s viOpen.cc
mkoctfile -I. -L. -lvisa -s viSetAttribute.cc
mkoctfile -I. -L. -lvisa -s viGetAttribute.cc
mkoctfile -I. -L. -lvisa -s viWrite.cc
mkoctfile -I. -L. -lvisa -s viRead.cc % might be removed, use viQuery
mkoctfile -I. -L. -lvisa -s viReadBinBlock.cc % might be removed, use viQueryBinBlock
mkoctfile -I. -L. -lvisa -s viClose.cc

% extension: write/read packed as single function to reduce overhead
mkoctfile -I. -L. -lvisa -s viQuery.cc % combined viWrite / viRead
mkoctfile -I. -L. -lvisa -s viQueryBinBlock.cc % combined viWrite viReadBinBlock

% NI example RdWrt.c converted to octave
mkoctfile -I. -L. -lvisa -s VISAtest.cc

