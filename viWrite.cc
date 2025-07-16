// [bytesDone, status] = viWrite(instrument, data)

// mkoctfile -I. -L. -lvisa -s viWrite.cc

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

ViSession instrument = 0;
ViStatus  status = 0;
ViUInt32  writeCount = 0;

DEFUN_DLD (viWrite, args, nargout,
  "[bytesDone, status] = viWrite(instrument, data)\n\
write string to VISA device")
{
  if (args.length()!=2)
    error("invalid number of input arguments");

  if (!args(0).is_scalar_type())
    error("expect instrument as 1st argument");
  instrument = args(0).int_value();

  if (!args(1).is_string())
    error("expect string as 2nd argument");
  const char *writeString = args(1).string_value().c_str();

  status = viWrite(instrument, (ViBuf)writeString, (ViUInt32)strlen(writeString), &writeCount);

  octave_value_list retval(2);
  retval(0) = octave_value(uint32NDArray(dim_vector(1,1), writeCount));
  retval(1) = octave_value(int32NDArray(dim_vector(1,1), status));
  return retval;
}

