function colpars = elanAssociate(elan, tiers) 

% Associates annotation values with plotting colors. 
% 
% codelist = elanAssociate(elan, tiers)
%
% INPUT arguments: 
%
% elan = ELAN-MATLAB structure
% tiers = name of the tier or a cell structure of tiers to pick values from
% 
% OUTPUT:
%
% colpars = a structure containing the color parameters for elanPlotColors
% function. The field colpars.values contains a list of all unique
% annotation values, colpars.colors contains the RGB color codes for each
% of the values. 
%
% Usage: when running the command colpars = elanAssociate(elan, tiers),
% MATLAB prompts the user to enter the color code to associate with each
% value, one at a time. The order in which the codes are presented is
% alphabetical by tier. 
% 
% Color codes: k=black, w=white, r=red, lr=light red, g=green, 
% dg=dark green, b=blue, lb=light blue, y=yellow, dy=dark yellow, m=magenta 
% dm=dark magenta, c=cyan, lgr=light grey, dgr=dark grey
%
% Built on the SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 27.8.2015


if iscell(tiers) == 1; % if there are multiple tiers selected
    lg = length(tiers)
else
    lg = 1; 
end


for i = 1:lg
    tmpvals{i} = elanValues(elan, (tiers{i})); % pick all values
end

colpars.values = vertcat(tmpvals{:}); % puts them all in the same struct

proplist = 'k=black, w=white, r=red, lr=light red, g=green, dg=dark green';
proplist2 = 'b=blue, lb=light blue, y=yellow, dy=dark yellow, m=magenta'; 
proplist3 = 'dm=dark magenta, c=cyan, lgr=light grey, dgr=dark grey';

disp(proplist)
disp(proplist2)
disp(proplist3)
    
prop = 'Pick a color for value '; 
prop2 = ' :';    
    
for i = 1:length(colpars.values); 

    prompt = horzcat(prop, colpars.values{i}, prop2);
    col = input(prompt, 's');

    if strcmp(col, 'k')
        colpars.colors(i,:) = [0 0 0]; %black
    elseif strcmp(col, 'w')
        colpars.colors(i,:) = [1 1 1]; %white

    elseif strcmp(col, 'r')
        colpars.colors(i,:) = [1 0 0]; %red
    elseif strcmp(col, 'lr')
        colpars.colors(i,:) = [1 0.5 0.5]; %light red

    elseif strcmp(col, 'g')
        colpars.colors(i,:) = [0 1 0]; % green
    elseif strcmp(col, 'dg')
        colpars.colors(i,:) = [0 0.6 0]; % dark green

    elseif strcmp(col, 'b')
        colpars.colors(i,:) = [0 0 1]; % blue
    elseif strcmp(col, 'lb')
        colpars.colors(i,:) = [0.4 0.8 1]; % light blue

    elseif strcmp(col, 'y')
        colpars.colors(i,:) = [1 1 0]; % yellow
    elseif strcmp(col, 'dy')
        colpars.colors(i,:) = [0.8 0.8 0]; % dark yellow

    elseif strcmp(col, 'm')
        colpars.colors(i,:) = [1 0 1]; % magenta
    elseif strcmp(col, 'dm')
        colpars.colors(i,:) = [0.4 0 0.4]; % dark magenta

    elseif strcmp(col, 'c') 
        colpars.colors(i,:) = [0 1 1]; % cyan

    elseif strcmp(col, 'lgr') 
        colpars.colors(i,:) = [0.8 0.8 0.8]; % light grey
    elseif strcmp(col, 'dgr') 
        colpars.colors(i,:) = [0.2 0.2 0.2]; % dark grey

    end
end



