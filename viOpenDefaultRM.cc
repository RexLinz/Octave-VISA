// open default VISA resource manager
//
// [defaultRM, status] = viOpenDefaultRM()
//
// this function must be called before any other VISA functions


// compile and link:
// mkoctfile -I. -L. -lvisa -s viOpenDefaultRM.cc

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

ViSession defaultRM = 0;
ViStatus  status = 0;

DEFUN_DLD (viOpenDefaultRM, args, nargout,
  "[defaultRM, status] = viOpenDefaultRM()")
{
  if (args.length()!=0)
    error("invalid number of input arguments");

  // First we must call viOpenDefaultRM to get the resource manager
  // handle.  We will store this handle in defaultRM.
  status = viOpenDefaultRM(&defaultRM);

  octave_value_list retval(2);
// TODO return uint32
//  uint32NDArray rm(dim_vector(1,1));
//  rm(1,1) = reinterpret_cast<uint64_t>(defaultRM);
//  retval(0) = octave_value(rm);
  retval(0) = octave_value(defaultRM);

//  uint32NDArray state(dim_vector(1,1));
//  state(1,1) = status;
//  retval(0) = octave_value(defaultRM);
  retval(1) = octave_value(status);
  return retval;
}

