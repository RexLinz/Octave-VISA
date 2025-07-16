// status = viClose(resource)

// mkoctfile -I. -L. -lvisa -s viClose.cc

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

static ViSession resource = 0;
static ViStatus status = 0;

DEFUN_DLD (viClose, args, nargout,
  "status = viClose(resource)\n\
close VISA device or resource manager")
{
  if (args.length()!=1)
    error("invalid number of input arguments");

  if (!args(0).is_scalar_type())
    error("expect resource as 1st argument");
  resource = args(0).int_value();

//  printf("closing %d\n", resource);
  status = viClose(resource);

  return octave_value(int32NDArray(dim_vector(1,1), status));
}

