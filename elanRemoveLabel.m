function elan2 = elanRemoveLabel(elan, tier, label)  

% Removes vertail label values from a tier 
%
% elan2 = elanRemoveLabel(elan, label) 
%
% INPUT arguments: 
% 
% elan: elan data structure 
% tier: tier from which the value labels are removed from
% label: label value or values to be removed from the data structure 
% 
% OUTPUT: 
% elan2: elan data structure with given labels removed from the given tier
%
% WORK IN PROGRESS!!
%
% Built on the SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 13.8.2015 

if nargin < 3;
    disp('Too few input arguments:')
    disp('specify the elan structure tier name and labels to remove.'); 
return;
end 

% count the total number of labels
numlab = length(elan.tiers.(tier)) 

%remlab = length(label); % how many labels to remove

elan2 = elan; 

%elan2 = rmfield(elan2.tiers, tier) % remove the one to be changed 

for i = 1:numlab
    if strcmp('elan.tiers.(tier)(i).value', label) == 1; 
        elan2 = rmfield(elan.tiers.(tier)(i).; 
    end
end



        
        
        
        