% VISA.m
%
% Overview over VISA wrapper functions implemented.
%
% Please use each functions help for more details
% Naming is following the function names from the API.
%
% [defaultRM, status] = viOpenDefaultRM()
%   Open the default VISA recource manager (required to open device connections)
% [instrument, status] = viOpen(defaulRM, devName, timeout, termchar)
%   Open a connection to the named device
% status = viSetAttribute(device, attributeName, attributeValue)
%   Set any attribute
% [attributeValue, status] = viGetAttribute(device, attributeName);
%   Get any attribute.
% status = viConfigureSerialPort(device, baudrate, databits=8, parity=0, stopBits=10, flowControl=0)
%   Configure a serial port.
% [bytesDone, status] = viWrite(instrument, data)
%   Write binary or string data to device.
% status = viFlush(device, mask=(VI_READ_BUF | VI_WRITE_BUF))
%   Flush IO queue(s).
% [response, status] = viRead(instrument, maxBytes)
%   Read up to maxBytes bytes from device.
% [uint8Data, status] = viReadBinBlock(instrument, maxBytes)
%   Read an IEEE 488.2 binary block from the device.
% status = viClose(resource)
%   Close a VISA resource (device or resource manager) connection.
% [response, status] = viStatusDesc(statusCode)
%   Get a text representation of the statusCode.
%
% Useful extensions
% [response, status] = viQuery(instrument, command, maxBytes)
%   Combine viWrite(...) and viRead(...).
% [uint8Data, status] = viQueryBinBlock(instrument, command, maxBytes)
%   Combine viWrite(...) and viReadBinBlock(...) in a single function.
%
% EXAMPLES
% viTest.m
%   Showing basic usage.
% viTestQueryBinBlock
%   Usage of viQueryBinBlock
% VISAtest.cc
%   is following the RdWrt.c example for the C/C++ API provided by National Instruments.

