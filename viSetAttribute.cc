// status = viSetAttribute(device, attributeName, attributeValue)

// mkoctfile -I. -L. -lvisa -s viSetAttribute.cc

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

ViSession instrument = 0;
ViStatus  status = 0;

DEFUN_DLD (viSetAttribute, args, nargout,
  "status = viSetAttribute(device, attributeName, attributeValue)\n\
set a VISA attribute for device\n\
see VISA manual for name and value constants (numeric)")
{
  if (args.length()!=3)
    error("invalid number of input arguments");

  if (!args(0).is_scalar_type())
    error("expect instrument as 1st argument");
  instrument = args(0).int_value();

  if (!args(1).is_scalar_type())
    error("expect attibute name (see VISA constants) as 2nd argument");
  ViAttr attributeName = args(1).int_value();

  if (!args(2).is_scalar_type())
    error("expect attibute value (see VISA constants) as 3rd argument");
  ViAttrState attrValue = args(2).int_value();

  status = viSetAttribute(instrument, attributeName, attrValue);

  return octave_value(int32NDArray(dim_vector(1,1), status));
}

