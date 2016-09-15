function elan2 = elanRemoveLabel(elan, tier, label)  

% Removes annotations with given label from a tier. 
%
% elan2 = elanRemoveLabel(elan, label) 
%
% INPUT arguments: 
% 
% elan: elan data structure 
% tier: tier from which the value labels are removed from
% label: label to be removed from the data structure 
% 
% OUTPUT: 
% elan2: elan data structure with given labels removed from the given tier
% 
% For example, if you have a tier 'colours' with annotations of 'blue', 
% 'green' and 'red', then 
%
% elan2 = elanRemoveLabel(elan, 'colours', {'blue';'red'}); 
%
% will produce elan2.colours tier that only has those annotations that had 
% the value 'green' in them. Otherwise elan2 contains all the same data as 
% elan.  
%
% To remove empty values, just put {''} as value (with curly brackets).
%
% Built on the SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 15.9.2016 

if nargin < 3;
    disp('Too few input arguments:')
    disp('specify the elan structure tier name and labels to remove.'); 
return;
end 

% how many different labels to remove 
rem = size(label, 1);
elan2 = elan; % copy over all the other tiers etc. 

for i = 1:rem; % run this for all labels to remove 

    for j = 1:length(elan2.tiers.(tier))
        ok(j,1) = strcmp(elan2.tiers.(tier)(j).value, label{i}); % lists the ones that match the label
    end

    elan2.tiers.(tier) = elan2.tiers.(tier)(ok == 0); % leaves only those that don't match label
    clear ok;     
end