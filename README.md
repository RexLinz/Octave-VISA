# Set of oct files to communicate with devices using the VISA interface API 

## Preface
VISA (Virtual Instrument Software Architecture), is an industry standard API used for communicating with test and measurement instruments. 
It allows unified communicaiton to devices mostly independent on the physical interface the device is attached to, e.g. LAN, USB, GPIB, Serial.

The files in this collection are provided without any warranty in the hope they migth be useful. You can use, modify and redistribute without restrictions.

## Functions provided
At the moment all API functions to do basic communication with VISA enabled devices are packed
from the C/C++ API to oct files. Naming is following the function names from the API.

- **[defaultRM, status] = viOpenDefaultRM();** \
  Open the default VISA recource manager (required to open device connections)
  
- **[instrument, status] = viOpen(defaulRM, devName, timeout, termchar);** \
  Open a connection to the named device, optionally setting the device timeout and termination character (automatically enabling termination character if specified).

- **status = viSetAttribute(device, attributeName, attributeValue);** \
  Set any attribute. See the VISA documentation for a list of the attributeName and attributeValue constants.

- **[attributeValue, status] = viGetAttribute(device, attributeName);** \
  Get any attribute. See the VISA documentation for a list of the attributeName and attributeValue constants.

- **status = viConfigureSerialPort(device, baudrate, databits=8, parity=0, stopBits=10, flowControl=0);** \
  Configure a serial port. See the VISA documentation or cc file for attribute value constants.
  Defaults shown above equal to baudrate,8,N,1, no flow control.

- **[bytesDone, status] = viWrite(instrument, data);** \
  Write binary or string data to device.
  If you have enabled a termination character (most devices expect 10 = \n) do not forget to append to the string written.

- **status = viFlush(device, mask=(VI_READ_BUF | VI_WRITE_BUF));** \
  Flush IO queue(s). Default is read and write buffer.

- **[response, status] = viRead(instrument, maxBytes);** \
  Read up to maxBytes bytes from device. If a terminator is configured, enabled and received the function will stop reading.\
  **NOTE** The terminator read will not be removed.\
  **NOTE** Consider to use viQuery instad to combine sending the command with the read.

- **[uint8Data, status] = viReadBinBlock(instrument, maxBytes);** \
  Read an IEEE 488.2 binary block from the device. You might have to typecast the response to the actual data format of your device,
  e.g. typecast(uint8Data, "uint16") to get 16 bit data
  **NOTE** Consider to use viQuery instad to combine sending the command with the read.

- **status = viClose(resource);** \
  Close a VISA resource (device or resource manager) connection.
  **NOTE** If you miss to close your device you might not be able to open another session to that device before restarting Octave.

- **[response, status] = viStatusDesc(statusCode);** \
  Get a text representation of the statusCode. This might be useful to identify error codes (negative) or warning codes (positive).

**Useful extensions**

- **[response, status] = viQuery(instrument, command, maxBytes);** \
  Combine viWrite(instrument, command) and viRead(instrument, maxBytes) in a single function.

- **[uint8Data, status] = viQueryBinBlock(instrument, command, maxBytes)**; \
  Combine viWrite(instrument, command) and viReadBinBlock(instrument, maxBytes) in a single function.

## Examples

File **viTest.m** showing basic usage. It requires either a SCPI enabled device or a serial loopback device to be connected.
1. open the default resource manager
2. open connection to device, e.g. serial port
3. check reading and writing some attributes (might / will be optional in most cases)
4. write an *IDN? query and read the response
5. use viQuery() to read the status byte of the device
6. if there is an error, close the device and device manager. 

File **viTestQueryBinBlock** showing handling of IEEE 488.2 binary data blocks. 
It holds two test cases, each of them could be individually enabled.

1. Reading oscilloscope waveform
2. Reading oscilloscope screenshot as PNG

Both have been used on an Keysight MSO-X 2024 mixed signal oscilloscope. 
Most likely they will work on other Keysight oscilloscopes, but will need some modification for other devices.

File **VISAtest.cc** is following the **RdWrt.c** example for the C/C++ API provided by National Instruments. 
It does the full job, similar to **viTest.m** above to do query from a device. 
It might be useful to extend or modify if you have just a very simple interface to your device in your application.
The interface to Octave is **[retval, status] = VISAtest(devicename, query);**

## Compiling
Licencing of the VISA headers and library is not clear to me. So only the code written by myself is provided.
Please follow the instructions in **viCompile.m** to copy the required files from your VISA provider
folders (National Instruments, Keysight, Rhode&Schwarz, ...). Then you can run **viCompile.m** to get the compiled oct files.

To use the functions you won't have to copy the CC files to your application folder.
Your application just need access to the compiled oct files.
So either copy the ones you are actually using to your application folder or add the folder to your path instead.
