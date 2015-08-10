function out = elanRenameTiers(elan, oldtiers, newtiers) 

% Rename tiers in ELAN-MATLAB structure 
% out = elanRenameTiers(elan, oldtiers, newtiers) 
%
% INPUT arguments: 
%
% elan = ELAN-MATLAB structure
% oldtiers = string or a cell structure containing the tier names to be
% replaced 
% newtiers = string or a cell structure containing the new tier names. 
%
% N.B. the number of items in oldtiers and newtiers must be the same. Names
% are switched in order, so that oldtiers{1} becomes newtiers {1} etc. 
%
% Output: 
%
% out = ELAN-MATLAB structure with new tier names.  
%
% Uses data structure of the SALEM 0.1beta toolbox. 
%
% Tommi Himberg, BRU / Aalto University. Last changed 23.10.2014 

%%

if isstr(oldtiers)
    if ~isstr(newtiers) % if they don't match, break 
        disp('Oldtier and newtier must both be either strings or cell structures')
        return; 
    elseif isstr(newtiers) 
        tmp{1} = oldtiers; % if both are strings, put them into cells
        tmp2{1} = newtiers; 
        clear oldtiers newtiers 
        oldtiers = tmp; 
        newtiers = tmp2; 
    end
end

out = elan; 

for i = 1:length(oldtiers)
    out.tiers.(newtiers{i}) = elan.tiers.(oldtiers{i});
    out = rmfield(out.tiers, oldtiers{i});     
end

out.range = elan.range;