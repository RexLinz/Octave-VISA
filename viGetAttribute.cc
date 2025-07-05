// get a VISA attribute from device
//
// [attributeValue, status] = viGetAttribute(device, attributeName)
//
// see VISA manual for name and value constants (numeric)

// compile and link:
// mkoctfile -I. -L. -lvisa -s viGetAttribute.cc

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

ViSession instrument = 0;
ViStatus  status = 0;

DEFUN_DLD (viGetAttribute, args, nargout,
  "[attributeValue, status] = viGetAttribute(device, attributeName)")
{
  if (args.length()!=2)
    error("invalid number of input arguments");

  if (!args(0).is_scalar_type())
    error("expect instrument as 1st argument");
  instrument = args(0).int_value();

  if (!args(1).is_scalar_type())
    error("attibute name (see VISA constants) as 2nd argument");
  ViAttr attributeName = args(1).int_value();

  ViAttrState attrValue = 0;
  status = viGetAttribute(instrument, attributeName, &attrValue);

  octave_value_list retval(2);
  retval(0) = octave_value(attrValue);
  retval(1) = octave_value(status);
  return retval;
}

