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
% N.B. the number of items in oldtiers and newtiers must match. Names
% are switched in order, so that oldtiers{1} becomes newtiers {1} etc. 
%
% OUTPUT: 
%
% out = ELAN-MATLAB structure with new tier names.  
%
% Built on the SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 13.8.2015

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

% compare strings in the two sets so that if there are same (unchanged)
% tier names, those are not removed in the end 

cmp = strcmp(newtiers, oldtiers); 


out = elan; 

for i = 1:length(oldtiers)
    out.tiers.(newtiers{i}) = elan.tiers.(oldtiers{i});
    if cmp(i) == 0 
        out.tiers = rmfield(out.tiers, oldtiers{i});
    end
end

out.range = elan.range;