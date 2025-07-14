// status = viConfigureSerialPort(device, baudrate, databits=8, parity=10, stopBits=0, flowControl=0)

// mkoctfile -I. -L. -lvisa -s viConfigureSerialPort.cc

/* some useful VISA serial attributes and values
VI_ATTR_ASRL_BAUD           (0x3FFF0021UL)
VI_ATTR_ASRL_DATA_BITS      (0x3FFF0022UL)
VI_ATTR_ASRL_PARITY         (0x3FFF0023UL)
  VI_ASRL_PAR_NONE          (0)
  VI_ASRL_PAR_ODD           (1)
  VI_ASRL_PAR_EVEN          (2)
  VI_ASRL_PAR_MARK          (3)
  VI_ASRL_PAR_SPACE         (4)
VI_ATTR_ASRL_STOP_BITS      (0x3FFF0024UL)
  VI_ASRL_STOP_ONE          (10)
  VI_ASRL_STOP_ONE5         (15)
  VI_ASRL_STOP_TWO          (20)
VI_ATTR_ASRL_FLOW_CNTRL     (0x3FFF0025UL)
  VI_ASRL_FLOW_NONE         (0)
  VI_ASRL_FLOW_XON_XOFF     (1)
  VI_ASRL_FLOW_RTS_CTS      (2)
  VI_ASRL_FLOW_DTR_DSR      (4)
*/

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

ViSession instrument = 0;
ViAttrState attrValue = 0;
ViStatus  status = 0;

DEFUN_DLD (viConfigureSerialPort, args, nargout,
  "status = viConfigureSerialPort(device, baudrate, databits=8, parity=10, stopBits=0, flowControl=0)\n\
configure parameters for serial device\n\
see VISA manual for name and value constants (numeric)")
{
  if (args.length()<2)
    error("invalid number of input arguments");

  if (!args(0).is_scalar_type())
    error("expect instrument as 1st argument");
  instrument = args(0).int_value();

  // baud rate is required
  if (!args(1).is_scalar_type())
    error("expect baud rate as 2nd argument");
  attrValue = args(1).int_value();
  status = viSetAttribute(instrument, VI_ATTR_ASRL_BAUD, attrValue);
  if (status<0)
    return octave_value(status);

  // number of data bits (optional)
  attrValue = 8; // default
  if (args.length() > 2)
  {
    if (!args(2).is_scalar_type())
      error("expect baud rate as 3rd argument");
    attrValue = args(2).int_value();
  }
  status = viSetAttribute(instrument, VI_ATTR_ASRL_DATA_BITS, attrValue);
  if (status<0)
    return octave_value(status);

  // parity (optional)
  attrValue = VI_ASRL_PAR_NONE; // default
  if (args.length() > 3)
  {
    if (!args(3).is_scalar_type())
      error("expect parity as 4th argument");
    attrValue = args(3).int_value();
  }
  status = viSetAttribute(instrument, VI_ATTR_ASRL_PARITY, attrValue);
  if (status<0)
    return octave_value(status);

  // number of stop bits (optional)
  attrValue = VI_ASRL_STOP_ONE; // default
  if (args.length() > 4)
  {
    if (!args(4).is_scalar_type())
      error("expect stop bits as 5th argument");
    attrValue = args(4).int_value();
  }
  status = viSetAttribute(instrument, VI_ATTR_ASRL_STOP_BITS, attrValue);
  if (status<0)
    return octave_value(status);

  // flow control (optional)
  attrValue = VI_ASRL_FLOW_NONE;
  if (args.length() > 5)
  {
    if (!args(5).is_scalar_type())
      error("expect flow control as 6th argument");
    attrValue = args(5).int_value();
  }
  status = viSetAttribute(instrument, VI_ATTR_ASRL_FLOW_CNTRL, attrValue);
  return octave_value(status);
}

