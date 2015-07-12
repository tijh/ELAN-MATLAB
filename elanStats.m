function output = elanStats(elan, tier) 

% Calculates number of annotations, total and relative durations of annotations
% in an ELAN file.
% output = elanStats(elan, tier) 
% tier optional 

tierlist = fieldnames(elan.tiers);

loops = length(tierlist); 

for i = 1:loops % this loops the tiers
       tmp = elanTotalTimes(elan, tierlist(i), 0);      
       durations{i}.name = tierlist{i}; 
       for j = 1:length(tmp); % this loops the labels
            
           durations{i}.(tierlist{i}).
       
       



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





