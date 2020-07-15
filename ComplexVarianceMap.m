%%  Complex variance analysis
%   This function maps the complex variance of a series of B-scans, which
%   should help in locating blood vessels.

%   The OCT signal is a complex (real and imaginary components) quantity 
%   that includes the magnitude and phase of the interfered light. The
%   variance of this signal should be high for structures that experience
%   motion, such as blood vessels. 

%   Originated from: Brian E. Applegate and Jack C. Tang
%   Last modified by: Jack C. Tang
%   Last modified on: 2020-07-14

option.command = '';
ProcessSpectralInterferogram(4096, option);
