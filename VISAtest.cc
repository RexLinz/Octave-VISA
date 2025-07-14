// [retval, status] = VISAtest(devicename, query)

// NOTES
// * Individual functions required are repacked in vi****.cc
// * you have to copy the following files from your VISA installation to the local folder to compile
//   visa.h, visatype.h, visa.lib

// mkoctfile -I. -L. -lvisa -s VISAtest.cc

#include <iostream>
#include <octave/oct.h>
#include <visa.h>

static ViSession defaultRM;
static ViSession instr;
static ViStatus status;
static ViUInt32 retCount = 0;
static ViUInt32 writeCount;
static unsigned char buffer[100] = { '\0' };

DEFUN_DLD (VISAtest, args, nargout,
  "[retval, status] = VISAtest(devicename, query)\n\
Test calling VISA functions packed into GNU Octave oct file\n\
This is following NI example NI-VISA/examples/C/general/RdWrt.c\n\
(folder within C:/Users/Public/Documents/National Instruments)\n\
Does the full job, similar to viTest.m above to do query from a device.\n\
It might be a useful start to build your own functions if you\n\
have just a very simple interface to your device in your application.")
{
  if (args.length()!=2)
    error("invalid number of input arguments");
  if (!args(0).is_string())
    error("visa resource name as first argument");
  if (!args(1).is_string())
    error("expect query string as second argument");
  printf("query %s from device %s\n", args(1).string_value().c_str(), args(0).string_value().c_str());

  // First we must call viOpenDefaultRM to get the resource manager
  // handle.  We will store this handle in defaultRM.
  status = viOpenDefaultRM (&defaultRM);
  if (status < 0)
    error("Could not open a session to the VISA resource manager!\n");

  /*
  * Now we will open a VISA session to a device at Primary Address 2.
  * You can use any address for your instrument. In this example we are
  * using GPIB Primary Address 2.
  *
  * We must use the handle from viOpenDefaultRM and we must
  * also use a string that indicates which instrument to open.  This
  * is called the instrument descriptor.  The format for this string
  * can be found in the NI-VISA User Manual.
  * After opening a session to the device, we will get a handle to
  * the instrument which we will use in later VISA functions.
  * The two parameters in this function which are left blank are
  * reserved for future functionality.  These two parameters are
  * given the value VI_NULL.
  *
  * This example will also work for serial or VXI instruments by changing
  * the instrument descriptor from GPIB0::2::INSTR to ASRL1::INSTR or
  * VXI0::2::INSTR depending on the necessary descriptor for your
  * instrument.
  */
  const char *VISAname = args(0).string_value().c_str();
  status = viOpen(defaultRM, VISAname, VI_NULL, 5000, &instr);
  if (status < VI_SUCCESS)
    printf ("Cannot open a session to the device.\n");
  else {
    // Set timeout value to 1000 milliseconds (1 seconds).
    status = viSetAttribute (instr, VI_ATTR_TMO_VALUE, 2000);
    if (status < VI_SUCCESS)
      printf("error setting timeout");
    else {
      status = viSetAttribute(instr, VI_ATTR_TERMCHAR, '\n');
      status = viSetAttribute(instr, VI_ATTR_TERMCHAR_EN, 1);
      /*
      * At this point we now have a session open to the instrument at
      * Primary Address 2.  We can use this session handle to write
      * an ASCII command to the instrument.  We will use the viWrite function
      * to send the string "*IDN?", asking for the device's identification.
      */
      const char *queryString = args(1).string_value().c_str();
      status = viWrite (instr, (ViBuf)queryString, (ViUInt32)strlen(queryString), &writeCount);
      if (status < VI_SUCCESS)
        printf("Error writing to the device\n");
      else {
        /*
         * Now we will attempt to read back a response from the device to
         * the identification query that was sent.  We will use the viRead
         * function to acquire the data.  We will try to read back 100 bytes.
         * After the data has been read the response is displayed.
         */
        status = viRead (instr, buffer, 100, &retCount);
        printf("read %d bytes\n", retCount);
         if (status < VI_SUCCESS)
            printf("Error reading a response from the device\n");
         else
            printf("Data read: %*s\n", retCount, buffer);
      }
    }
  }
  /*
  * Now we will close the session to the instrument using
  * viClose. This operation frees all system resources.
  */
  viClose(instr);
  viClose(defaultRM);

  octave_value_list retval(2);
  retval(0) = octave_value(reinterpret_cast<const char*>(buffer));
  retval(1) = octave_value(status);
  return retval;
}
