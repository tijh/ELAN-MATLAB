function out = elanValues(elan, tier, order)

% Extract all unique annotation values from an ELAN-MATLAB structure tier.
%
% out = elanValues(elan, tier, order); 
% 
% INPUT arguments:
%
% elan = ELAN-MATLAB structure
% tier = name of tier
% order = alphabetical (1, default) or order in which they occur 
% in the tier (2).
% 
% OUTPUT:
% OUT = cell structure with annotation values from the tier. 
% 
% Example: vals = elanValue(myelan, 'TierName', 1);
% This produces a N*1 cell array with all annotation values used in tier
% 'TierName', in alphabetical order.
%
% Built on the SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 13.8.2015


if nargin == 2; 
    order = 1; 
end

data = elan.tiers.(tier); 

lg = length(data);

values = cell(1,1);
values{1} = data(1).value; %seed with first value

for i = 2:lg 
    for j = 1:length(values) 
          a(j) = strcmp(data(i).value, values(j)) == 1; 
          % check each new value against all previously listed ones
    end  
    
    if sum(a) < 1;        
         values{length(values)+1} = data(i).value; % if it's new, add to list
    end
end

% variable 'values' now has all unique labels. 

if order == 1  % alphabetise
    out = sort(values)';
else % order of appearance
    out = values';
end





