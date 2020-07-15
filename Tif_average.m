%%  Tif_average.m 
%   This script reads a tif stack and computes the average image. 
%
%   Originated from  : Jack C. Tang
%   Last modified by : Jack C. Tang
%   Last modified on : July 12, 2020

[fname, pname] = uigetfile('./*.*', 'MultiSelect', 'on');
im_filepath = strcat(pname,fname);
A = Tiff(im_filepath);