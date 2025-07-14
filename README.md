# Set of oct files to communicate with devices using the VISA interface API

## Preface

VISA (Virtual Instrument Software Architecture), is an industry standard API used for communicating with test and measurement instruments.
It allows unified communicaiton to devices mostly independent on the physical interface the device is attached to, e.g. LAN, USB, GPIB, Serial.

This collection is wrapping functions from the C/C++ API into oct files to be used in GNU Octave.

## Functions provided

Please look at file **VISA.m** or type **help VISA** from within Octave for a full list of functions provided.

## Examples

- **viTest.m** showing basic usage.

- **viTestQueryBinBlock.m** reading IEEE 488.2 binary block, e.g. image data

- **viTestWriteBinBlock.m** reading device setup (binary block), write back to device

- **VISAtest.cc** is following the **RdWrt.c** example for the C/C++ API provided by National Instruments.

## Further reading

- **VISA library specification** issued by VXI system alliance

## Compiling

Licencing of the VISA headers and library is not clear to me. So only the code written by myself is provided.
Please follow the instructions in **viCompile.m** to copy the required files from your VISA provider
folders (National Instruments, Keysight, Rhode&Schwarz, ...). Then you can run **viCompile.m** to get the compiled oct files.

To use the functions you won't have to copy the CC files to your application folder.
Your application just need access to the compiled oct files.
So either copy the ones you are actually using to your application folder or add the folder to your path instead.

**NOTE** At the moment binutils coming with Octave up to 10.2 cause mkoctfile to fail linking with the libraries
creates by MSVC compiler. This will be fixed in Octave 10.3.
For now you can use the nightly Octave 10.2.1 build from the **mxe-default section** at [Octave nightly builds](https://nightly.octave.org/#/download).

## Copyright

The files are provides without any warranty in the hope they migth be useful.
You can use, modify and redistribute without restrictions.

