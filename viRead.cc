// read string from VISA device
//
// [response, status] = viRead(instrument, maxBytes)

// compile and link:
// mkoctfile -I. -L. -lvisa -s viRead.cc

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

ViSession instrument = 0;
ViStatus  status = 0;
ViUInt32  bytesRequested = 0;
ViUInt32  bytesDone = 0;

DEFUN_DLD (viRead, args, nargout,
  "[response, status] = viRead(instrument, maxBytes)")
{
  if (args.length()!=2)
    error("invalid number of input arguments");

  if (!args(0).is_scalar_type())
    error("expect instrument as 1st argument");
  instrument = args(0).int_value();

  if (!args(1).is_scalar_type())
    error("expect maximum number of bytes to read as 2nd argument");
  bytesRequested = args(1).int_value();
//  printf("trying to read %d bytes\n", bytesRequested);

  // allocate buffer for response
  char *buffer = new char[bytesRequested+1];
  status = viRead(instrument, (unsigned char*)buffer, bytesRequested, &bytesDone);
  buffer[bytesDone] = 0; // string termination
//  printf("read %d bytes\n", bytesDone);

  octave_value_list retval(2);
  retval(0) = octave_value(reinterpret_cast<const char*>(buffer));
  retval(1) = octave_value(status);
  return retval;
}

