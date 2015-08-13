%% ELAN-MATLAB TIERPLOTTING SCRIPT 
%
%
% HOW TO USE THIS SCRIPT 
%
% You will need to change and customise the code for your purposes.
% Instructions and examples will be provided at each step. The code 
% will also be executed one step at a time. Each step is numbered and
% indicated by the double-dollar sign. To select each step (or cell), you 
% simply click anywhere within its text, or use arrow keys to move the cursor
% there. The selected cell's background turns yellow, unselected cells remain
% white. 
% 
% To execute the code for each step, you can either click the "Run section" 
% button or "Run and Advance" button on the top tool ribbon (under
% "Editor"), or use the keyboard shortcut cmd-enter or cmd-shift-enter 
% (CTRL in Windows machines). 
%
% Add % in front of those lines of code you don't need (this makes the lines 
% into "comments" that MATLAB will ignore when running the script), or 
% remove %'s from lines you do need. Comments, or text that is ignored, 
% is green; the active code is black and purple. 
%
% Places where you need to make edits (usually to input tier names and 
% annotation values) are under headings "EDIT THIS:"; lines that you should
% not touch are marked by "DON'T EDIT THIS". 
%
% Please see tierplotting.pdf for more details. 
%
% Tommi Himberg 
% Last edit: 13.8. 2015
%
% ELAN-MATLAB Toolbox uses parts of the SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 13.8.2015



%% 1. Load ELAN-file
%
% First, navigate to the folder where you have the file. 
% You can do this either by using the "Current folder" -window or 
% typing in the path below. 

% e.g. 

cd /Users/Tommi/Dropbox/Autism_videos/SC_analysis/

% Second, enter your file name into the following line: 
% EDIT THIS:

alldata = elanReadData('SC1_fix.eaf'); 

% 

%% 2. Pick tier 
%
% This plotter processes one or multiple tiers at a time.  
% To first print all the tier names into the command window run the following: 

alldata.tiers

%% 2b. Select tier
%
% Now, from the file you loaded, we select the tiers to be plotted and put
% them to a new structure. 

% N.B.: only select multiple tiers if you want them to be plotted to the
% same image. If you plan to make individual plots from multiple tiers, it
% is advisable to do them one at a time, repeating the steps 2-6 of this
% script for each plot. This is because the color allocation is much easier
% for individual tiers. 

% Enter the tier names below exactly as they appear in the file. You can use
% tab to autofill: position the cursor after alldata.tiers. and hit tab, 
% select the desired tier from the list. 

% EDIT THIS:
data.tiers.toplot = alldata.tiers.C_Travelling___Not_T_N_Outofview_1; % edit your tiername 
data.tiers.toplot2 = alldata.tiers.MT_Travelling___Not_T_N_Outofview_1; % edit tiername 
% you can add more

% DON'T CHANGE THIS:
data.range = alldata.range; 
%
%


%% 3. Clean up the annotations

% When plotting ELAN annotations, you will need to assign each unique
% annotation value with a color. To make this task easier, or to only focus
% on a subset of features, before associating colors to values, you can
% simplify your annotation values. 

%% 3a. Display all unique annotation values: 
%
% First, let's list all the unique annotation values in our tiers. 
% 

values = elanValues(data, 'toplot', 1) 
values2 = elanValues(data, 'toplot2', 1)

% You can edit the 3rd argument above: 1 for displaying tier names 
% alphabetically, 2 for displaying in the order they appear in the tier. 
%
% Select and copy these to the clipboard. If there are many unique values,
% you might want to use a separate text editor for next steps. 

%% 3b. Clean up annotations 

% If there are distinctions made in annotations that you do not want
% reflected in the plot, or annotations you don't want to be visible in the
% plot (that you will plot in white).  

% replace the terms 'oldanno' and 'newanno' with your annotation values. 

data = elanSwap(data, 'tier', 'oldanno', 'newanno');

% For example, if on a tier you have values 'F' 'NF' 'O' and 'NF(?)' and
% you want to just plot the questionmarked annotation along with all the
% other 'NF's, you put: 

% data = elanSwap(data, 'toplot', 'NF(?)', 'NF'); 
 
% This replaces the annotation value 'NF(?)' at the tier 'toplot' with the more common 'NF'
% simplifying the following steps of choosing colors etc. Note that the
% changes are only made to the temporary structure data.tiers, the original
% .eaf file is not affected. If you want to use the simplified / changed
% annotation values only in some plots, you can make a copy of the data and
% only clean up the annotations in the new file, keeping the old version
% with the old annotation values in the workspace: 

% data_cleaned = elanSwap(data, 'toplot', 'NF(?)', 'NF'); 

% In this case, the contents of the variable data are not affected, only the 
% data_cleaned will have the new values. Just remember to use the new 
% variable name in the plotting command. 

% Note also that the swap is tier-specific. If you want to make the same
% swap on multiple tiers, you'll need to run the command on each of the
% tiers, e.g. 

% data = elanSwap(data, 'toplot', 'NF(?)', 'NF');
% data = elanSwap(data, 'toplot2', 'NF(?)', 'NF');

%% 3b2. Only one value

% In some cases, you only care to see when there are annotations without
% bothering what the individual annotation values are (e.g. if you only
% care when someone is playing an instrument but don't care which one). To
% simplify a tier so that all the annotations are given the same value, you
% can use the following: 

data = elanSimplifyValues(data, 'toplot', 'playing');

% this will change all the annotation values of the tier 'toplot' to
% 'playing'. To preserve the more detailed annotations in 'toplot', you can
% generate a new tier to hold the simpler annotations: 

data = elanSimplifyValues(data, 'toplot', 'playing', 'newtiertoplot');

%% 3c. To check your progress, run the value-listing again: 

values = elanValues(data, 'toplot', 1) 

%valuesn = elanValues(data, 'newtiertoplot', 1) 


%% 4. Colors

% In this section, you will need to associate _every_ unique annotation 
% value in EACH TIER with a colour. Multiple values can be given the same
% colour, and if you want to leave out an annotation, assign it to white.

%% 4a. Select color set 

% Depending on how many unique values you want, combined for all the tiers
% you want to plot at once, there are a few colour-batches available, or 
% you can also manually construct your own set.
%
% The colors are defined as RGB-codes, each component ranging from 0 to 1. 
% 
% Some example colors: 
% Red = 1 0 0 
% Green = 0 1 0 
% Blue = 0 0 1 
%
% White = 1 1 1
% Light grey = 0.8 0.8 0.8
% Dark grey = 0.2 0.2 0.2
% Black = 0 0 0 
% 
% Cyan = 0 1 1 
% Magenta = 1 0 1
% Yellow = 1 1 0
%
% Light blue = 0.4 0.8 1
% Light red = 1 0.5 0.5
%
% You can easily make your own palettes of how ever many colors you need by
% editing any of the examples below. The list of colors is put in square
% brackets, each color (three numbers) separated with a semicolon. 
%
%
% UNCOMMENT THE "colors = ..." PART FROM ONE OF THE FOLLOWING, MAKE SURE
% ALL THE OTHERS ARE COMMENTED.

% 1. Two colours 

%colors = [0 0 1; 0 1 0]; 
% 1: blue, 2: green

% 2. Three colours 

% 2a. Blue, green, red, black, grey

%colors = [0 0 1; 0 1 0; 1 0 0; 0 0 0; 0.8 0.8 0.8]; 
% 1: blue, 2: green, 3: white

% 2b. Blue, green, red
colors = [0 0 1; 0 1 0; 1 0 0]; 
% 1: blue, 2: green, 3: white


% 3. Six colors

colors = [0 0 1; 0 1 0; 1 0 0; 0 1 1; 1 0 1; 1 1 1]; 
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


%% 4b. Assign annotation labels to colours
%
% DON'T EDIT THIS
associations = containers.Map('KeyType', 'char', 'ValueType', 'int32');
%
%
% YOUR LIST HERE
%
% Here, you associate each unique label with a color that corresponds with
% a row in your colour set selected in 4. Each unique value

associations('NT') = 1; 
associations('O') = 2; 
associations('T') = 3; 

%
%% 5. Plot 
% 
% Almost there. :)
% If you want, you can add a title to the plot by editing the name below:

plotTitle = 'Testing';

% Now run this to generate your plot. You can then click the icon "Plot
% tools" to open the MATLAB interactive graph editor, where you can keep
% editing the plot, and then you can save it in various image formats from
% File -> Save as. 

timeunit = 'sec'; % change to anything else but 'min' if you want the x-axis 
                  % units to be in seconds rather than minutes

elanPlotColors(data, associations, colors, timeunit, plotTitle)
                  
% to plot the value labels to the right of the axes, printed in the colors 
% they represent in the figure, use the elanPlotColors2 function: 

% elanPlotColors2(data, associations, colors, timeunit, plotTitle)

%% 6. Plot a section of data 

% To plot just a segment of the data instead of the whole file, use the
% following script. 
%

%% 6a. Cut a slice

% First, run steps 1-5 as usual, then cut the desired "slice" of the data:

data2 = elanSlicer(data, 800, 1000); % 800 and 1000 are the start and 
                                   % stop times in seconds (you can enter
                                   % time in minutes by multiplying by 60, 
                                   % e.g. data2 = elanSlice(data, 1*60, 15*60);

                                   
                                   
%% 6b. Plot the slice
                                   
% This simply re-uses the associations and colors from above:

plotTitle = 'MyTitle';

timeunit = 'min'; % change to anything else but 'min' if you want the x-axis 
                  % units to be in seconds rather than minutes

elanPlotColors(data2, associations, colors, timeunit, plotTitle) % NB data2 
                
% with labels:
% elanPlotColors2(data2, associations, colors, timeunit, plotTitle) % NB data2 

%% 