function [newelan] = elanInitiate(filename, templatetype, tiers)
% newelan = elanInitiate(filename, templatetype, tiers)
% 
% Creates a txt file that can be read to ELAN, with a set of tiers 
% typically used in NR analyses. 
%    
% INPUT arguments: 
%
% filename: name of the file to be created 
%
% templatetype: 'full' (default), 'brief' or 'custom' selects which tierset
% to use. 
%
% tiers: (optional) if 'custom' templatetype is used, user can input their
% own set of tiers as a cell of strings. 
% 
% OUTPUT: 
%
% Saves a tab delimited txt-file filename.txt that contains the initialised
% tiers, as well as Matlab data structure newelan that can then be 

if nargin < 2; 
    templatetype = 'full'; 
    tiers = []; 
elseif nargin < 3; 
    tiers = []; 
end






end

