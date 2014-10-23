function OUT = elanValues(elan, tier, order)

% Extract all unique annotation values from an ELAN file tier.
%
% OUT = elanValues(elan, tier, order); 
% 
% INPUT ARGUMENTS:
% elan = elan file structure
% tier = name of tier
% order = alphabetical (1, default) or order in which they occur 
% in the tier (2).
% 
% OUTPUT ARGUMENTS:
% OUT = cell structure with annotation values from the tier. 
% 
% Example: vals = elanValue(myelan, 'TierName', 1);
% This produces a N*1 cell array with all annotation values used in tier
% 'TierName', in alphabetical order.
%
% Uses data structure of the SALEM 0.1beta toolbox. 
%
% Tommi Himberg, BRU / Aalto University. Last changed 23.10.2014 

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
    OUT = sort(values)';
else % order of appearance
    OUT = values';
end





