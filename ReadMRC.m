function [map,s,mi,ma,av]=ReadMRC(filename,startSlice, numSlices,test)
% function map=ReadMRC(filename);  --all defaults.   Or, with every
% parameter,
% function [map,s,mi,ma,av]=ReadMRC(filename,startSlice, numSlices,test)
%
% Read a 3D map from a little-endian .mrc file
% and return a structure containing various parameters read from the file.
% This function reads 2d and 3d real maps in byte, int16 and float32 modes.
% Added interpretation of the extended header (length = c(2) which is important with imod and
% serialEM at Brandeis.  lw 15 Aug 07
% Added error tests.  fs 2 Sep 07
% Added the ability to read selected slices, and read big-endian files
% fs 17 Sep 09
% Changed the a array so that the returned s values are doubles.  5 Nov 09
% Added data mode 6 (unsigned int16) fs 20 Jan 10
% Changed s fields to doubles fs 20 Feb 10

if nargin<2
    startSlice=1;
end;
if nargin<3
    numSlices=inf;
end;
if nargin<4
    test=0;
end;

% We first try for little-endian data
f=fopen(filename,'r','ieee-le');
if f<0
    error(['in ReadMRC the file could not be opened: ' filename])
end;

% Get the first 10 values, which are integers:
% nc nr ns mode ncstart nrstart nsstart nx ny nz
a=fread(f,10,'*int32');

if abs(a(1))>1e5  % we must have the wrong endian data.  Try again.
    fclose(f);
    f=fopen(filename,'r','ieee-be');
    a=fread(f,10,'int32');  % convert to doubles
end;

if test
    a(1:10)
end;

mode=a(4);

% Get the next 6 (entries 11 to 17), which are floats.
% the first three are the cell dimensions, the second three are
% angles.
[b,cnt]=fread(f,6,'float32');
if test
   b
end;
s.xlen = b(1);
s.ylen = b(2);
s.zlen = b(3);
s.rez=double(b(1)); % cell size x, in A.
s.alpha = b(4);
s.beta = b(5);
s.gamma = b(6);

% get next 3 ints ("These need to be set to 1, 2, and 3 for pixel
% spacing to be interpreted correctly")
aux1 = fread(f, 3, 'int32');
s.mapc = aux1(1);
s.mapr = aux1(2);
s.maps = aux1(3);

% next 3 floats: min, max and mean pixel value
aux2 = fread(f, 3, 'float32');
mi=aux2(1); % minimum value
ma=aux2(2); % maximum value
av=aux2(3);  % average value

% get 2 ints,
aux3 = fread(f, 2, 'int32');
s.ispg = aux3(1); % space group number, ignored by IMOD
s.next = aux3(2); % number of bytes in extended header

% get 1 shortint: "used to be an ID number, is 0 as of IMOD 4.2.23"
s.creatid = fread(f, 1, 'int16');

% get the next 30 bytes
% extra data  (not used by IMOD, first two bytes should be 0)
[c,cnt]=fread(f,30,'char');

% the next two are supposed to be character strings.
[d,cnt]=fread(f,2,'int16');
s.nint = d(1);
s.nreal = d(2);

% get the next 20 bytes
% extra data  (not used by IMOD)
[aux4,cnt]=fread(f,20,'char');

% get 2 ints,
aux5 = fread(f, 2, 'int32');
s.imodStamp = aux5(1);
s.imodFlags = aux5(2);

% here we consider the new-style header (IMOD 2.6.20 and above)
aux6 = fread(f, 3, 'float32');
aux7 = fread(f, 2, 'char');
aux8 = fread(f, 1, 'float32');

% 10 strings of 80 characters each
for i=1:10
	[g,cnt]=fread(f,80,'char');
	str(i,:)=char(g)';
end;

% disp('header:'); disp(' ');
% disp(str(1:ns,:));
% disp(' ');
s.header=str;

% Get ready to read the data.
s.nx=double(a(1));
s.ny=double(a(2));
s.nz=double(a(3));
% Grid size in X, Y, and Z
s.mx=a(8);
s.my=a(9);
s.mz=a(10);
switch mode
    case 0
        string='*uint8';
        pixbytes=1;
    case 1
        string='*int16';
        pixbytes=2;
    case 2
        string='*float32';
        pixbytes=4;
    case 6
        string='*uint16';
    otherwise
        error(['ReadMRC: unknown data mode: ' num2str(mode)]);
        string='???';
        pixbytes=0;
end;

if(s.next>0)
    [ex_header,cnt]=fread(f,s.next,'char');
    disp(['Read extra header of ',num2str(c(2)),' bytes!'])
%    disp((ex_header'));
end

skipbytes=0;
nz=s.nz;
if startSlice>1
    skipbytes=(startSlice-1)*s.nx*s.ny*pixbytes;
    fseek(f,skipbytes,'cof');
    nz=min(s.nz-(startSlice-1),numSlices);
end;
ndata=s.nx * s.ny * nz;
if test
    string
    ndata
end;
[map,cnt]=fread(f,ndata,string);
fclose(f);
if cnt ~= ndata
    error('ReadMRC: not enough data in file.');
end;
map=reshape(map,s.nx,s.ny,nz);
