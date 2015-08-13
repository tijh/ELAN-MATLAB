function out = elanSimplifyValues(elan, tier, value, newtier)

% Replaces all values in the given tier with the given value. Can be used
% to simplify a detailed tier with a simpler, biary coding. 
%
% out = elanSimplifyValues(elan, tier, value, newtier)
%
% INPUT arguments: 
%
% elan = ELAN data structure 
% tier = name of the tier to edit
% value = the new value for all annotations on 'tier'
% newtier (optional) = name of the tier to be created for the new annotations 
% if left empty, 'tier' values are replaced by 'value'.  
%
% OUTPUT: 
% out = ELAN data structure, same as the input 'elan', but either 'newtier'
% added or all annotation values on 'tier' replaced. 
%
% Built on the SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 13.8.2015

lg = length(elan.tiers.(tier)); 

if nargin < 4; 
    for i = 1:lg
        elan.tiers.(tier)(i).value = value; 
    end
else
    elan.tiers.(newtier) = elan.tiers.(tier); 
    for i = 1:lg
        elan.tiers.(newtier)(i).value = value; 
    end
end

out = elan;



