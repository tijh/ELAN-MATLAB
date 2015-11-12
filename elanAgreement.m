function out = elanAgreement(elan1, elan2, tiers); 

% Calculates the percentage of agreement between two annotations of the
% same tier in two elan files. 
%
% INPUT arguments: 
%
% elan1 = ELAN-MATLAB data structure 1 containing annotations by rater1 
% elan2 = ELAN-MATLAB data structure 2 containing annotations by rater2 
% tiers = name of the tier (or tiers) to compare 
% 
% OUTPUT:
%
% out = row vector containing the percentages of samples that the two
% raters agreed. 
%
% Warning: check with elanValues that the two raters have used the same
% annotation values in the tiers, and that all the same values are present.
% Otherwise this simpleton function will not produce correct results. 
%
% Warning2: compares the tiers from the beginning, if one is longer than
% the other, ignores the end of the longer one. 
%
% Uses: elanTimeseriefy.m
%
% Built on the SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 13.8.2015

lgtiers = length(tiers);

for i = 1:lgtiers
    ts1{i} = elanTimeseriefy(elan1, tiers{i});
    ts2{i} = elanTimeseriefy(elan2, tiers{i});
end


for i = 1:lgtiers
    % this will hopefully be not needed, just matching the sizes... 
    lg1 = length(ts1{i}.Data);
    lg2 = length(ts2{i}.Data);
    
    if lg1>lg2
        tss1 = ts1{i}.Data(1:lg2);
        tss2 = ts2{i}.Data;
    else 
        tss1 = ts1{i}.Data; 
        tss2 = ts2{i}.Data(1:lg1); 
    end
    % this calculates the differences
    diffs{i} = tss1 - tss2; 
    lg = length(diffs{i});
    sames = length(diffs{i}(diffs{i} == 0));
    perc(i) = sames/lg;
end
   
out = perc*100;




