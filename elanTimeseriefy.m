function out = elanTimeseriefy(elan, tier, annovalues)  

% A function to change annotations into a time-series, with a resolution of
% 0.01 seconds.
% out = elanTimeseriefy(elan, tier, annovalues);  
%
% INPUT arguments: 
%
% elan = elan data structure
% tier = name of the tier you want to time-seriefy
% annovalues = cell structure containing annotation values (optional)
%
% If annovalues are not defined in the function call, they are extracted
% automatically from the data, setting integers 1...n in alphabetical
% order. 
%
% OUTPUT: 
% 
% out = MATLAB time series object with annotations transformed into numbers
% as data, and the times of their occurrence as 'time'. The annotation
% values are in the out.UserData, they are numbered with integers 1...n in
% this order (alphabetical). 
%
% For re-sampling the data, the interpolation method is set to zero-order
% hold rather than linear, this can be changed using the setinterpmethod
% function on the output. 
%
% Built on the SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 13.8.2015


resolution = 0.01; % in future version this could be made to vary

data.tiers.(tier) = elan.tiers.(tier); 
data.range = elan.range;

numanno = length(data.tiers.(tier)); % how many annotations in total 

% pick data from ELAN-MATLAB structure

times = zeros(numanno,2); % preallocate 
vals = cell(numanno,1); 

for i = 1:numanno
    times(i,1) = data.tiers.(tier)(i).start;
    times(i,2) = data.tiers.(tier)(i).stop;
    vals{i,1} = data.tiers.(tier)(i).value; 
end

range = [data.range(1) data.range(2)];
range = round((range*(1/resolution)))/(1/resolution);
    
% round the times to nearest grain

times = round((times*(1/resolution)))/(1/resolution);

% set value codes 

if nargin == 3; 
    vales = annovalues; 

else
    vales = elanValues(data, tier, 1); % this list of annotation values goes to output
end

values = containers.Map('KeyType', 'char', 'ValueType', 'double');

for i = 1:length(vales);
    values(vales{i}) = i;
end

% run through all the annotations, generate the time values and a list of
% annotation values to match 

timesets = cell(numanno,1); % preallocate
valsets = cell(numanno,1); 

for i = 1:numanno
    timesets{i} = (times(i,1):resolution:times(i,2))'; 
    val = values(data.tiers.(tier)(i).value);
    valsets{i} = repmat(val, size(timesets{i},1), 1); 
end

% put all the times and values together. If annotations are continuous, the
% rounding that was done above will make the end of one to be the same as
% the beginning of the next. These double values will be eliminated by
% checking for such overlap when concatenating the times and values. 


alltimes = timesets{1,1}; % seed
allvals = valsets{1,1}; % seed

for i = 1:numanno-1
    if alltimes(end,1) == timesets{i+1}(1,1); % if continuous annotations, there will be overlap
        alltimes = [alltimes; timesets{i+1,1}(2:end,1)]; % drop the first time of next annotation
        allvals = [allvals; valsets{i+1,1}(2:end,1)]; 
    else
        alltimes = [alltimes; timesets{i+1}];
        allvals = [allvals; valsets{i+1}]; 
    end
end

% add the first and last moments with zero code but test first if the
% annotations start or end at edge, in which case, don't. 

if alltimes(1) > range(1); 
    alltimes = [range(1); alltimes]; 
    allvals = [0; allvals]; 
end

if alltimes(end) < range(2); 
    alltimes = [alltimes; range(2)]; 
    allvals = [allvals; 0];
end


out = timeseries(allvals, alltimes, 'Name', tier);

out = setinterpmethod(out, 'zoh'); % set interpolation method to zero-order hold

out.UserData = vales;   % save the annotation names into structure: the 
                        % values are numbered in this order in the ts data.





