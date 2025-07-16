// [bytesDone, status] = viWriteBinBlock(instrument, data, preamble)

// mkoctfile -I. -L. -lvisa -s viWriteBinBlock.cc

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

ViSession instrument = 0;
ViStatus  status = 0;
ViUInt32  writeCount = 0;

DEFUN_DLD (viWriteBinBlock, args, nargout,
  "[bytesDone, status] = viWriteBinBlock(instrument, data, preamble)\n\
write binary block to VISA device, optionally prepend with preamble string")
{
  if (args.length()<2)
    error("invalid number of input arguments");

  if (!args(0).is_scalar_type())
    error("expect instrument as 1st argument");
  instrument = args(0).int_value();

// temporary disable termination character
  ViUInt32 termCharEnabled = 0;
  status = viGetAttribute(instrument, VI_ATTR_TERMCHAR_EN, &termCharEnabled);
  if (status>=0)
    status = viSetAttribute(instrument, VI_ATTR_TERMCHAR_EN, 0);

  if (args.length()>2) // send a command like "SYST:STA " before binary data?
  {
    if (!args(2).is_string())
      error("expect string for preamble");
    const char *preString = args(2).string_value().c_str();
    status = viWrite(instrument, (ViBuf)preString, (ViUInt32)strlen(preString), NULL);
//    printf("query command: %s\n", preString);
  }

  if (!args(1).isnumeric())
    error("expect binary data to write");
  uint8NDArray uint8Data = args(1).array_value();
  uint8_t *src = reinterpret_cast<uint8_t*>(uint8Data.rwdata()); //uInt8
  uint32_t numBytes = uint8Data.numel();
//  printf("binary data holding %d bytes\n", numBytes);
  char header[11] = "#8l2345678"; // create a fixed length header block
  sprintf(header, "#8%08d", numBytes);
//  printf("header = %s\n", header);

  if (status>=0)
    status = viWrite(instrument, (ViBuf)header, 10, NULL); // header
  if (status>=0)
    status = viWrite(instrument, (ViBuf)src, (ViUInt32)numBytes, &writeCount); // binary data
  if (status>=0)
    status = viWrite(instrument, (ViBuf)"\n", 1, NULL); // terminator

  // restore terminator if enabled
  if (status>=0)
    status = viSetAttribute(instrument, VI_ATTR_TERMCHAR_EN, termCharEnabled);

  octave_value_list retval(2);
  retval(0) = octave_value(uint32NDArray(dim_vector(1,1), writeCount));
  retval(1) = octave_value(int32NDArray(dim_vector(1,1), status));
  return retval;
}

