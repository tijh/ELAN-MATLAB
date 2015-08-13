function [out1, out2, out3] = elanSegmentTimes(in, tier, key1, key2, key3) 

% Extracts the start and stop times for three different labels of annotations 
% from an elan file. 
% 
% [out1, out2, out3] = elanSegmentTimes(in, tier, key1, key2, key3)
%
% INPUT arguments: 
%
% in = ELAN-data (ELAN-MATLAB toolbox data structure 
% tier = name of the tier in ELAN-data that is investigated (string)
% key1, key2, key3 = strings of values to include, in the order in which the 
% times will be included
%
% OUTPUT arguments:
% 
% out1, out2, out3 = n*2 arrays of start and stop times, where n = number of 
% annotations with a corresponding value (out1 - key1, out2 - key2, out3 -
% key3) 
%
% Built on the SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 13.8.2015

adata = in.tiers.(tier); 

for i = 1:length(adata)
    tmp1(i,1) = strcmp(adata(i).value, key1);
    tmp2(i,1) = strcmp(adata(i).value, key2); 
    tmp3(i,1) = strcmp(adata(i).value, key3);
    times(i,1) = adata(i).start;
    times(i,2) = adata(i).stop;
end

out1 = times(tmp1 == 1, :);
out2 = times(tmp2 == 1, :);
out3 = times(tmp3 == 1, :);

