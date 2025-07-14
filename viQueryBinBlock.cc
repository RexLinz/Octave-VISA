// [uint8Data, status] = viQueryBinBlock(instrument, command, maxBytes)

// Data format of IEEE 488.2 binary blocks
// # ... ASCII character indicate header
// n ... number of length digits to follow
// x ... n digits of ASCII coded value representing the number of data bytes following
// y ... followed by x data bytes (uint8)
// terminator, typically \n (on most instruments

// mkoctfile -I. -L. -lvisa -s viQueryBinBlock.cc

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

ViSession instrument = 0;
ViStatus  status = 0;
ViUInt32  writeCount = 0;
ViUInt32  bytesRequested = 0;
ViUInt32  bytesDone = 0;

DEFUN_DLD (viQueryBinBlock, args, nargout,
  "[uint8Data, status] = viQueryBinBlock(instrument, command, maxBytes)\n\
read IEEE binary data block from VISA device\n\
   you might have to typecast the result to other data types in octave\n\
   e.g. y = typecast(uint8Data, 'int16') to combine two bytes each")
{
  if (args.length()!=3)
    error("invalid number of input arguments");

  if (!args(0).is_scalar_type())
    error("expect instrument as 1st argument");
  instrument = args(0).int_value();

  if (!args(1).is_string())
    error("expect string as 2nd argument");
  const char *writeString = args(1).string_value().c_str();
  status = viWrite(instrument, (ViBuf)writeString, (ViUInt32)strlen(writeString), &writeCount);

  if (!args(2).is_scalar_type())
    error("expect maximum number of bytes to read as 2nd argument");
  bytesRequested = args(2).int_value();
//  printf("trying to read %d bytes\n", bytesRequested);

  ViUInt32 termCharEnabled = 0;
  status = viGetAttribute(instrument, VI_ATTR_TERMCHAR_EN, &termCharEnabled);
  if (status>=0)
    status = viSetAttribute(instrument, VI_ATTR_TERMCHAR_EN, 0);

  // allocate buffer for response
  char *buffer = new char[bytesRequested+1];

  // response should start with #n
  if (status>=0)
    status = viRead(instrument, (unsigned char*)buffer, 2, &bytesDone);
// printf("%d bytes, header %c, lengthCode %d\n", bytesDone, buffer[0], buffer[1]);

  if ((status>=0)
  && ((bytesDone!=2) || (buffer[0]!='#') || (buffer[1]<'1') || (buffer[1]>'9')))
    error("invalid binblock header");
  int numLen = buffer[1]-'0'; // number of length bytes
// printf("%d length bytes\n", numLen);

  if (status>=0)
    status = viRead(instrument, (unsigned char*)buffer, numLen, &bytesDone);
  if ((status>=0) && (bytesDone!=numLen))
    error("failed to read block size");
  buffer[numLen] = 0;
  int dataLen = atoi(buffer);
// printf("length info %s, %d data bytes\n", buffer, dataLen);

  if(status>=0)
    status = viRead(instrument, (unsigned char*)buffer, dataLen, &bytesDone);
  if ((status>=0) && (bytesDone!=dataLen))
    error("received less bytes than expected");
// printf("read %d bytes\n", bytesDone);

  // Create an NDArray to return to Octave
  uint8NDArray uint8Data(dim_vector(1, bytesDone));  // row vector
  for (int i = 0; i < bytesDone; ++i)
    uint8Data(i) = buffer[i];
  delete []buffer;

  if ((status>=0) && termCharEnabled)
  {
    unsigned char terminator;
    status = viRead(instrument, &terminator, 1, &bytesDone);
    if ((status>=0) && (terminator!='\n'))
      error("received invalid terminator");
  }

  if (status>=0)
    status = viSetAttribute(instrument, VI_ATTR_TERMCHAR_EN, termCharEnabled);

  octave_value_list retval(2);
  retval(0) = octave_value(uint8Data);
  retval(1) = octave_value(status);
  return retval;
}

