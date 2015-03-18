function elan2 = elanRemoveLabel(elan, tier, label);  

% [] = elanRemoveLabel(elan, label) 
% 
% Removes vertail label values from a tier 
%
% Inputs arguments: 
% 
% elan: elan data structure 
% tier: tier from which the value labels are removed from
% label: label value or values to be remover from the data structure 
% 
% Output: 
% elan2: elan data structure with given labels removed from the given tier
%
%
% Uses the ELAN data structure from SALEM0.1 toolbox 
%
% Tommi Himberg, Aalto University, Matlab R2014b (Mac) Last changed:
% 17.3.2015 

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



        
        
        
        