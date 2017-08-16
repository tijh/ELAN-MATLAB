function [out1, out2] = elanCorrCheck(elan, tier1, tier2, value1, value2) 
% [out1, out2] = elanCorrCheck(elan, tier1, tier2, value1, value2); 
% 
% checks if tier1 value1 has overlaps with tier2 value2 
%
% Example: tier 1 is proposals, tier 2 is fixations
% 
% out1 = number of proposals with fixations 
% out2 = number of proposals without fixations
% 
% work in progress 
%
%
% TH 7.7.2017

%%

% Tiers
t1 = elanPick(elan, tier1); 
t2 = elanPick(elan, tier2); 

% Values
vals1 = elanValues(t1, tier1);

v1 = strcmp(value1, vals1);
v1n = v1 == 0; 
drop = vals1(v1n); 
t1 = elanRemoveLabel(t1, tier1, drop); 


vals2 = elanValues(t2, tier2);

v2 = strcmp(value2, vals2);
v2n = v2 == 0; 
drop2 = vals2(v2n); 

t2 = elanRemoveLabel(t2, tier2, drop2); 

% if either is an empty, return 0 0  

if isempty(t1.tiers.(tier1))
    out1 = 0; 
    out2 = 0; 
elseif isempty(t2.tiers.(tier2))
    out1 = 0; 
    out2 = 0; 
else
% Compare, one annotation of tier1 at a time, make 0 or 1 judgement 


% pick times of the compared tier to then match to each target

    for i = 1:length(t2.tiers.(tier2))
        times(i,1) = t2.tiers.(tier2)(i).start; 
        times(i,2) = t2.tiers.(tier2)(i).stop;
    end
%

    for i = 1:length(t1.tiers.(tier1))
    
        for j = 1:length(times)
   % fixation contained by proposal
            fs(j,1) = times(j,1) > t1.tiers.(tier1)(i).start & times(j,2) < t1.tiers.(tier1)(i).stop; 
        
   % fixation start or stop is within the proposal
        % start
            fs(j,2) = times(j,1) > t1.tiers.(tier1)(i).start & times(j,1) < t1.tiers.(tier1)(i).stop;
        % stop
            fs(j,3) = times(j,2) > t1.tiers.(tier1)(i).start & times(j,2) < t1.tiers.(tier1)(i).stop;

   % proposal contained in fixation 
            fs(j,4) = times(j,1) < t1.tiers.(tier1)(i).start & times(j,2) > t1.tiers.(tier1)(i).stop;
        end
    
        fcc = sum(sum(fs,2)); 
        
        if fcc == 0
            fccc(i,1) = 0; 
        else
            fccc(i,1) = 1; % should be 0 if there is no overlap and 1 if there is 
        end
    end

out1 = sum(fccc); 
out2 = length(fccc)-out1; 

end








