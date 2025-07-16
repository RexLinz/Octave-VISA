// read string from VISA device
//
// [response, status] = viStatusDesc(statusCode)

// compile and link:
// mkoctfile -I. -L. -lvisa -s viStatusDesc.cc

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

ViSession instrument = 0;
ViStatus  status = 0;
ViStatus  statusCode = 0;

DEFUN_DLD (viStatusDesc, args, nargout,
  "[response, status] = viStatusDesc(statusCode)")
{
  if (args.length()!=1)
    error("invalid number of input arguments");

  if (!args(0).is_scalar_type())
    error("expect status code as 2nd argument");
  statusCode = args(0).int_value();

  // allocate buffer for response
  char *buffer = new char[500];
  status = viStatusDesc(instrument, statusCode, (ViChar*)buffer);
//  buffer[bytesDone] = 0; // string termination
//  printf("read %d bytes\n", bytesDone);

  octave_value_list retval(2);
  retval(0) = octave_value(reinterpret_cast<const char*>(buffer));
  retval(1) = octave_value(int32NDArray(dim_vector(1,1), status));
  return retval;
}

