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

% TODO
% * add help to functions and/or create VISA.m (function overview or just help)

% In some cases mkoctfile could not write output files because
% they have not been proper closed (may happen on error conditions)
% "clear all" usually helps in that case
clear all

% define a function to compile to make changing options more easy
function compile(sourcefile)
  disp(["compiling " sourcefile]);

  % -s to strip debugging in formation
  % -Wno-deprecated to skip deprecated warnings
%  [output, status] = mkoctfile("-I.", "-L.", "-lvisa", sourcefile);
  [output, status] = mkoctfile("-I.", "-L.", "-lvisa", "-s", sourcefile);
%  [output, status] = mkoctfile("-I.", "-L.", "-lvisa", "-s", "-Wno-deprecated", sourcefile);
  if length(output)>0
    disp(output);
  end
  if status<0
    error(["compile failed on file " sourcefile]);
  end
endfunction

% standard VISA functions packed as oct file
compile("viOpenDefaultRM.cc");
compile("viOpen.cc");
compile("viSetAttribute.cc");
compile("viGetAttribute.cc");
compile("viConfigureSerialPort.cc");
compile("viWrite.cc");
compile("viFlush.cc");
compile("viRead.cc"); % consider using viQuery
compile("viReadBinBlock.cc"); % consider using viQueryBinBlock
compile("viClose.cc");
compile("viStatusDesc.cc"); % get text message for status code

% extension: write/read packed as single function to reduce overhead
compile("viQuery.cc"); % combined viWrite / viRead
compile("viQueryBinBlock.cc"); % combined viWrite viReadBinBlock

% NI example RdWrt.c converted to octave
compile("VISAtest.cc");

