// [instrument, status] = viOpen(defaulRM, devName, timeout, termchar, accessmode)

// mkoctfile -I. -L. -lvisa -s viOpen.cc

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

ViSession defaultRM = 0;
ViSession instrument = 0;
ViStatus  status = 0;

DEFUN_DLD (viOpen, args, nargout,
  "[instrument, status] = viOpen(defaulRM, devName, timeout, termchar, accessmode)\n\
open a VISA session to device\n\
set timeout if specified and > 0\n\
set and enable termchar if specified and >= 0\n\
specify accessmode=4 to load settings configured in NI-MAX")
{
  if (args.length()<2)
    error("invalid number of input arguments");

  if (!args(0).is_scalar_type())
    error("expect resource manager as 1st argument");
  defaultRM = args(0).int_value();

  if (!args(1).is_string())
    error("visa resource name as 2nd argument");
  const char *VISAname = args(1).string_value().c_str();

// optional parameter for accessmode to load defaults as configured in NI MAX?
  uint32_t accessMode = 0;
  if (args.length()>=5)
  {
    if (!args(4).is_scalar_type())
      error("expect access mode as 5th argument");
    accessMode = args(4).int_value();
  }

//  printf("opening device %s using resource manager %d\n", VISAname, defaultRM);
  status = viOpen(defaultRM, VISAname, accessMode, 3000, &instrument);

  if ((status >= 0) && (args.length()>=3))
  {
    if (!args(2).is_scalar_type())
      error("expect timeout as 3rd argument");
    uint64_t timeout = args(2).int_value();
//    printf("setting timeout %lld ms\n", timeout);
    if (timeout>0)
      status = viSetAttribute(instrument, VI_ATTR_TMO_VALUE, timeout);
  }

  if ((status >= 0) && (args.length()>=4))
  {
    if (!args(3).is_scalar_type())
      error("expect termchar as 4th argument");
    int termchar = args(3).int_value();
    if (termchar>=0)
    {
      //    printf("setting termchar %d\n", termchar);
      status = viSetAttribute(instrument, VI_ATTR_TERMCHAR, termchar);
      status = viSetAttribute(instrument, VI_ATTR_TERMCHAR_EN, 1);
    }
  }

  octave_value_list retval(2);
  retval(0) = octave_value(uint32NDArray(dim_vector(1,1), instrument));
  retval(1) = octave_value(int32NDArray(dim_vector(1,1), status));
  return retval;
}

