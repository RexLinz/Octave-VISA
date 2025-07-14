// status = viFlush(device, mask=(VI_READ_BUF | VI_WRITE_BUF))

// mkoctfile -I. -L. -lvisa -s viFlush.cc

/* useful constants defined in VISA.h, mask could combine values from below
#define VI_READ_BUF                 (1)
#define VI_WRITE_BUF                (2)
#define VI_READ_BUF_DISCARD         (4)
#define VI_WRITE_BUF_DISCARD        (8)
#define VI_IO_IN_BUF                (16)
#define VI_IO_OUT_BUF               (32)
#define VI_IO_IN_BUF_DISCARD        (64)
#define VI_IO_OUT_BUF_DISCARD       (128)
*/

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

ViSession instrument = 0;
ViStatus  status = 0;

DEFUN_DLD (viFlush, args, nargout,
  "status = viFlush(device, mask=(VI_READ_BUF | VI_WRITE_BUF))\n\
flush input and/or output queue of device\n\
see VISA manual for name and value constants (numeric)")
{
  if (args.length()<1)
    error("invalid number of input arguments");

  if (!args(0).is_scalar_type())
    error("expect instrument as 1st argument");
  instrument = args(0).int_value();

  ViUInt16 mask = (VI_READ_BUF | VI_WRITE_BUF);
  if (args.length()>1)
  {
    if (!args(1).is_scalar_type())
      error("expect mask as 2nd argument");
    mask = args(1).int_value();
  }
  status = viFlush(instrument, mask);
  return octave_value(status);
}

