function out = elanExtend(in, tier, direction, amount)

% out = elanExtend(in, direction, amount)
%
% Lengthens the annotations from start (1) or stop (2) by the amount (sec) 
%
% 

tmp = in; 

lg = length(tmp.tiers.(tier)); 

if direction == 1; % extending starts backward
       
   if tmp.tiers.(tier)(1).start < amount;  % to avoid negative start times 
        tmp.tiers.(tier)(1).start = 0; %shift to zero
        tmp.tiers.(tier)(1).duration = tmp.tiers.(tier)(1).stop - tmp.tiers.(tier)(1).start;
   else
      tmp.tiers.(tier)(1).start = tmp.tiers.(tier)(1).start - amount;
      tmp.tiers.(tier)(1).duration = tmp.tiers.(tier)(1).stop - tmp.tiers.(tier)(1).start;
   end
   
   for i = 2:lg 
       tmp.tiers.(tier)(i).start = tmp.tiers.(tier)(i).start - amount;
       tmp.tiers.(tier)(i).duration = tmp.tiers.(tier)(i).stop - tmp.tiers.(tier)(i).start;
   end
   
   
elseif direction == 2; % extending stops towards end 
    
   for i = 1:lg-1  
        tmp.tiers.(tier)(i).stop = tmp.tiers.(tier)(i).stop + amount;
        tmp.tiers.(tier)(i).duration = tmp.tiers.(tier)(i).stop - tmp.tiers.(tier)(i).start;
   end
    
   if tmp.range(2)-tmp.tiers.(tier)(lg).stop < amount;  % to avoid annos extending the range
        tmp.tiers.(tier)(lg).stop = tmp.range(2); % shift to end of range
        tmp.tiers.(tier)(lg).duration = tmp.tiers.(tier)(lg).stop - tmp.tiers.(tier)(lg).start;
   else
        tmp.tiers.(tier)(lg).stop = tmp.tiers.(tier)(lg).stop + amount;
        tmp.tiers.(tier)(lg).duration = tmp.tiers.(tier)(lg).stop - tmp.tiers.(tier)(lg).start;
   end
   
end

out = tmp; 
                



