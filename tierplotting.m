%% ELAN EXAMPLE SCRIPT 
%
% 
%
% HOW TO USE THIS SCRIPT 
%
% You will need to change and customise the code for your purposes.
% Instructions and examples will be provided at each step. The code 
% will also be executed one step at a time. Each step is numbered and
% indicated by the double-dollar sign. To execute the code for each step,
% you can click the "Run section" button, or "Run and Advance", or use the
% keyboard shortcut cmd-enter / ctrl-enter. 
%
% Add % in front of those lines of code you don't need.
%
% Please see tierplotting.pdf for more details. 
%
%
%
%% 1. Load ELAN-file
%
% First, navigate to the folder where you have the file. 
% You can do this either by using the "Current folder" -window or 
% typing in the path below. 

% e.g. 

cd /Users/Tommi/Dropbox/Autism_videos/SC_analysis/

% Second, enter your file name into the following line: 
% EDIT THIS:

alldata = elanRead('SC1_fix.eaf'); 

% 

%% 2. Pick tier 
%
% This plotter processes one tier at a time. You can plot different tiers
% from the same file by repeating steps 2b - 5. 
% To first print all the tier names into the command window run the following: 

alldata.tiers;

%% 2b. Select tier
%
% enter the tier name below exactly as it appears in the file. You can use
% tab to autofill: position the cursor after alldata.tiers. and hit tab, 
% select the desired tier from the list. 

% EDIT THIS:
data.tiers.toplot = alldata.tiers.CMTfacing; % edit your tiername 


% don't change the following
data.tiers.AnnotationValid = alldata.tiers.AnnotationValid; 
%
%
%% 3. Select color plan 
%
% In this section, you will need to associate _every_ unique annotation 
% value in the tier with a colour. Multiple values can be given the same
% colour, and if you want to leave out an annotation, assign it to white.
%
%% 3a. Display all unique annotation values: 
%
elanValues(data, toplot, 1); % you can edit the 3rd argument: 1 for 
% displaying tier names alphabetically, 2 for displaying in the order 
% they appear in the tier. 
%
% Select and copy these to the clipboard. If there are many unique values,
% you might want to use a separate text editor for next steps. 

%% 3b. Select color set 

% Depending on how many unique values you want, there are a few
% colour-batches available, you can also manually construct your own set.
% The colors are defined as RGB-codes, each component ranging from 0 to 1. 
% 
% White = 1,1,1
%
%
% UNCOMMENT THE "colors = ..." PART FROM ONE OF THE FOLLOWING, MAKE SURE
% THE OTHERS ARE COMMENTED.

% 1. Two colours 

colors = [0 0 1; 0 1 0]; 
% 1: blue, 2: green

% 2. Three colours 

%colors = [0 0 1; 0 1 0; 1 1 1]; 
% 1: blue, 2: green, 3: white

% 3. Six colors

%colors = [0 0 1; 0 1 0; 1 0 0; 0 1 1; 1 0 1; 1 1 1]; 
% 1: blue, 2: green, 3: red, 4: cyan, 5: magenta, 6: white

% 4. Ten colors

% colors = [0 0 1; 0.4 0.8 1;... % dark blue light blue
%     0.8 0.8 0; 1 1 0;... % dark yellow light yellow
%     0 0.6  0; 0 1 0;... % dark green light green
%     0.4 0 0.4; 1 0 1;... % dark magenta light magenta
%     1 1 1; 1 0 0]; % white red  

% 5. Eleven colors

% colors = [0 0 1; 0.4 0.8 1;... % dark blue light blue
%     0 0.6 0; 0 1 0;... % dark green light green
%     1 0 0; 1 0.5 0.5;... % dark red light red
%     0.8 0.8 0; 1 1 0;... % dark yellow light yellow
%     0.4 0 0.4; 1 0 1;... % dark magenta light magenta 
%     1 1 1]; % white


% DON'T CHANGE THIS 

defval = data.tiers.toplot(1).value;
data.tiers.AnnotationValid.value = defval; 


%% 4. Edit annotation values (optional)


%% 5. Assign annotation labels to colours
%
% DON'T EDIT THIS
associations = containers.Map('KeyType', 'char', 'ValueType', 'int32');
%
%






%
%
% Plot 
% 
%
%
%



