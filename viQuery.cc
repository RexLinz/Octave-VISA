// [response, status] = viQuery(instrument, command, maxBytes)

// mkoctfile -I. -L. -lvisa -s viQuery.cc

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

ViSession instrument = 0;
ViStatus  status = 0;
ViUInt32  writeCount = 0;
ViUInt32  bytesRequested = 0;
ViUInt32  bytesDone = 0;

DEFUN_DLD (viQuery, args, nargout,
  "[response, status] = viQuery(instrument, command, maxBytes)\n\
write string to VISA device, read response data")
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

  // allocate buffer for response
  char *buffer = new char[bytesRequested+1];
  status = viRead(instrument, (unsigned char*)buffer, bytesRequested, &bytesDone);
  buffer[bytesDone] = 0; // string termination
//  printf("read %d bytes\n", bytesDone);

  octave_value_list retval(2);
  retval(0) = octave_value(reinterpret_cast<const char*>(buffer));
  retval(1) = octave_value(int32NDArray(dim_vector(1,1), status));
  return retval;
}

