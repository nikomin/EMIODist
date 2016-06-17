This directory contains m-functions for reading and writing files used
in electron microscopy and 3D reconstruction.  The file formats those
used by the IMAGIC software package (Image Science GmbH; EMAN and
Frealign are public-domain programs that also use this format), the
MRC program library, and the Digital Micrograph (Gatan, Inc.) file
format.  These functions were written on what published information we
could find, and work for our limited purposes; they are not supported
by the software authors at all.

The functions generally assume that little-endian files are being read
by a little-endian machine.  However, some functions might still work
with big-endian machines such as PowerPC, as they were originally
written on a Mac computer.

Fred Sigworth, Liguo Wang
Yale University


**ReadImagic**

Loads part or all of the data in an Imagic file pair into a matlab 3-d
array.  This function also returns a data structure with part of the
information from the header.

**WriteImagic**

Writes an entire matlab 3-d array as an Imagic file with float32 data
type.

**ReadImagicHeader**
**MakeImagicHeader**
**WriteImagicHeader**

Create, read or write a datastructure that contains all the
information in an Imagic header.  The structure (a struct of arrays)
allows manipulation of header information. For writing very large
datafiles, the header file can be constructed and written out
separately by these functions.

**ReadDM3**

Read a file generated by Digital Micrograph, version 3.  These files
have a large tree structure, and the code inside this function can be
modified to return any field or fields of this structure.  At present
just the pixel size and number of pixels is returned along with the
raw image.

**ReadMRC**

Read part or all of an MRC-format file (2d or 3d) into a Matlab array;
also retrieves information about the image size.

**WriteMRC**

Write an entire 3d Matlab array into an MRC-format file

**WriteMRCHeader**

Write the header of an MRC-format file, allowing the user to write the
rest of the file directly with the fwrite function.
