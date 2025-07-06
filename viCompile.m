% recompile all VISA (viXXX) functions

% to get the compilation working copy the following files from your VISA
% provider's folder.
% If you have installed National Instruments products
% you will find them in folder
% C:\Program Files (x86)\National Instruments\Shared\CVI
%   include\visa.h
%   include\visatype.h
%   ExtLib\msvc64\visa.lib
% General files from IVI Foundation (headers holding some NI extensions)
% C:\Program Files\IVI Foundation
%   VISA\Win64\Include\visa.h
%   VISA\Win64\Include\visatype.h
%   VISA\Win64\Lib_x64\msc\visa64.lib

% In some cases mkoctfile could not write output files because
% they have not been proper closed (may happen on error conditions)
% "clear all" usually helps in that case
clear all

% standard VISA functions packed as oct file
mkoctfile -I. -L. -lvisa64 -s viOpenDefaultRM.cc
mkoctfile -I. -L. -lvisa64 -s viOpen.cc
mkoctfile -I. -L. -lvisa64 -s viSetAttribute.cc
mkoctfile -I. -L. -lvisa64 -s viGetAttribute.cc
mkoctfile -I. -L. -lvisa64 -s viConfigureSerialPort.cc
mkoctfile -I. -L. -lvisa64 -s viWrite.cc
mkoctfile -I. -L. -lvisa64 -s viFlush.cc
mkoctfile -I. -L. -lvisa64 -s viRead.cc % consider using viQuery
mkoctfile -I. -L. -lvisa64 -s viReadBinBlock.cc % consider using viQueryBinBlock
mkoctfile -I. -L. -lvisa64 -s viClose.cc
mkoctfile -I. -L. -lvisa64 -s viStatusDesc.cc % get text message for status code

% extension: write/read packed as single function to reduce overhead
mkoctfile -I. -L. -lvisa64 -s viQuery.cc % combined viWrite / viRead
mkoctfile -I. -L. -lvisa64 -s viQueryBinBlock.cc % combined viWrite viReadBinBlock

% NI example RdWrt.c converted to octave
mkoctfile -I. -L. -lvisa64 -s VISAtest.cc

