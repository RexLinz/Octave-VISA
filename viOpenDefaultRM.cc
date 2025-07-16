// [defaultRM, status] = viOpenDefaultRM()

// mkoctfile -I. -L. -lvisa -s viOpenDefaultRM.cc

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

ViSession defaultRM = 0; // uint32
ViStatus  status = 0; // int32

DEFUN_DLD (viOpenDefaultRM, args, nargout,
  "[defaultRM, status] = viOpenDefaultRM()\n\
open default VISA resource manager\n\
This function must be called before any other VISA functions")
{
  if (args.length()!=0)
    error("invalid number of input arguments");

  // First we must call viOpenDefaultRM to get the resource manager
  // handle.  We will store this handle in defaultRM.
  status = viOpenDefaultRM(&defaultRM);

  octave_value_list retval(2);
  retval(0) = octave_value(uint32NDArray(dim_vector(1,1), defaultRM));
  retval(1) = octave_value(int32NDArray(dim_vector(1,1), status));
  return retval;
}

