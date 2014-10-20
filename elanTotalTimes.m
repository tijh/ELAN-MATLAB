function output = elanTotalTimes(elan, tier, abs) 
% Extracts the total durations per annotation label in a tier of ELAN file.
%
% function output = elanTotalTimes(elan, tier, abs) 
% 
% Inputs:
% 
% elan = Matlab structure with ELAN data 
% tier = name of tier 
% abs = results either in absolute times (0) or proportion of total annotated
% (1) or proportion of total time in tier (2) (default = 1) 
% 
% Output: 
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
% Uses the data structure of SALEM Toolbox, so the structure needs the 
% target tier and AnnotationValid and ElanFile tiers.
%
% SALEM functions used: 
%
% Tommi Himberg, BRU Aalto University - last changed 20.10.2014

if nargin < 2; 
    return; 
end

if nargin == 2; 
    abs = 1; 
end


tmp.data = elan.tiers.(tier); 
tmp.AnnotationValid = elan.tiers.AnnotationValid; 
tmp.ElanFile = elan.tiers.ElanFile;

durall = tmp.AnnotationValid.duration; % duration of the whole file

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

output.labels = sort(labs)'; % alphabetise

uniques = length(output.labels); % how many different labels


for i = 1:uniques
    for j = 1:numannos
        if strcmp(tmp.data(j).value, output.labels(i)) == 1;
            tmp2(j,1) = tmp.data(j).duration;
        end
    end
    output.times(i,1) = sum(tmp2);
    clear tmp2;
end

if abs == 1;
    output.times = output.times./durann; 
elseif abs == 2; 
    output.times = output.times./durall; 
end












