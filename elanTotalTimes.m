function out = elanTotalTimes(elan, tier, abs) 
% Extracts the total durations per annotation label in a tier of ELAN file.
% 
% out = elanTotalTimes(elan, tier, abs) 
% 
% INPUT arguments:
% 
% elan = ELAN-MATLAB structure 
% tier = name of tier 
% abs = results either in absolute times (0) or proportion of total annotated
% (1) or proportion of total time in tier (2) (default = 1) 
% 
% OUTPUT: 
% 
% Data structure with output.labels = annotation labels and output.times =
% corresponding durations / proportions. 
% 
% Example: 
% 
% mytimes = elanTotalTimes(mydata, 'P1_sound', 2); 
% 
% This produces structure mytimes, reads the P1_sound tier from mydata,
% which is a MATLAB structure produced e.g. by elanReadFile. Option 2 gives
% the times as proportion of total duration of the tier.
% 
% Built on the SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 13.8.2015

if nargin < 2; 
    return; 
end

if nargin == 2; 
    abs = 1; 
end


tmp.data = elan.tiers.(tier); 

durall = elan.range(2)-elan.range(1); % duration of the whole file

numannos = length(tmp.data); % number of annotations on tier
tmp.durann = zeros(numannos, 1); % preallocate
tmp.val = cell(numannos, 1); % preallocate

for i = 1:numannos 
    tmp.durann(i,1) = tmp.data(i).duration; % duration of annotations total
    tmp.val{i,1} = tmp.data(i).value; 
end

durann = sum(tmp.durann); % total annotation duration

% Find and list unique labels 

labs = cell(1,1);
labs{1} = tmp.data(1).value; %seed with first value

for i = 2:numannos 
    for j = 1:length(labs) 
          a(j) = strcmp(tmp.data(i).value, labs(j)) == 1; 
          % check each new value against all previously listed ones
    end  
    
    if sum(a) < 1;        
         labs{length(labs)+1} = tmp.data(i).value; % if it's new, add to list
    end
end

% variable 'labs' now has all unique labels. 

out.labels = sort(labs)'; % alphabetise

uniques = length(out.labels); % how many different labels


for i = 1:uniques
    for j = 1:numannos
        if strcmp(tmp.data(j).value, out.labels(i)) == 1;
            tmp2(j,1) = tmp.data(j).duration;
        end
    end
    out.times(i,1) = sum(tmp2);
    clear tmp2;
end

if abs == 1;
    out.times = out.times./durann; 
elseif abs == 2; 
    out.times = out.times./durall; 
end












