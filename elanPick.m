function out = elanPick(elan, tiers) 

% Picks a subset of tiers to a new ELAN structure. 
%
% out = elanPick(elan, tiers) 
%
% INPUT arguments:
%
% elan = ELAN-MATLAB structure 
% tiers = a string containing the name of one tier to pick, or a cell 
% structure containing the names of multiple tiers to be picked from 
% 'elan', to be included in the new 'out' structure.
%
% Output:
%
% out = ELAN-MATLAB structure containing 'tiers' 
%
% Built on the SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 13.8.2015


% if only one tier is picked 
if isstr(tiers)
    tmp{1} = tiers; % assign into a cell struct
    clear tiers; 
    tiers = tmp;
end

num = length(tiers); 

for i = 1:num 
    out.tiers.(tiers{i}) = elan.tiers.(tiers{i}); 
end

out.range = elan.range; 






