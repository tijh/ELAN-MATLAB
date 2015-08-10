function out = elanSwap(elan, tier, oldval, newval)

% Replace annotation values in ELAN files 
%
% out = elanSwap(elan, tier, oldval, newval) 
%
% INPUT arguments: 
% 
% elan = ELAN-MATLAB structure 
% tier = name of the tier where the swap will be made (string)
% oldval = the value that will be removed (string)
% newval = the value that will be inserted in place of 'oldval' (string)
%
% OUTPUT
% 
% out = ELAN-MATLAB structure 
%
% Uses the data structure of the SALEM 0.1beta toolbox. 
%
% Requires elanValues.m from ELAN-MATLAB toolbox
%
% Tommi Himberg, NBE / Aalto University. Last changed 10.8.2015

if nargin < 4; 
    disp('Not enough input arguments: out = elanSwap(elan, tier, oldval, newval)')
    return; 
end

% pick the tier to operate with 

data.tiers.tmp = elan.tiers.(tier);
data.range = elan.range; % just in case? 

vals = elanValues(data, 'tmp'); % alphabetical list of values 

% check that the value to be replaced exists
if sum(strcmp(oldval,vals)) ~= 1; 
    disp('The value to be replaced is not found')
    return;
end

% replace 
for i = 1:length(data.tiers.tmp)
    if strcmp(oldval, data.tiers.tmp(i).value) == 1; 
        data.tiers.tmp(i).value = newval; 
    end    
end

% assign
elan.tiers.(tier) = data.tiers.tmp; 

out = elan; 













