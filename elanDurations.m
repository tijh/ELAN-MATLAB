function [out labs] = elanDurations(elan, tier); 

% [out labs] = elanDurations(elan, tier); 
%
% calculates the durations split by label 

labels = elanValues(elan, tier);

numannos = length(elan.tiers.(tier)); 

% extracts the durations and labels

for i = 1:numannos; % for each value
    tmp(i,1) = elan.tiers.(tier)(i).duration; 
    tmp2{i,1} = elan.tiers.(tier)(i).value; 
end

% sort the durations under labels

for i = 1:length(labels)
    for j = 1:numannos
        if strcmp(tmp2(j,1), labels{i}) == 1;
            tmp3(j,i) = tmp(j,1);
        end
    end
end

% make output 

% 
% 
% for i = 1:length(labels)
%     assignin('base', labels{i}, labels(i)); 
% end

for i = 1:length(labels)
    out{i,1} = tmp3(tmp3(:,i) ~= 0, 1);
end

labs = labels; 







    
    
    
    
    
    
    
