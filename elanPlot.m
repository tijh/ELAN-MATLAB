function elanPlotColors2(elan, tier, colpars, timeunit, optionaltitle, labels)

% elanPlot(elan, colpars, timeunit, optionaltitle, labels))
% 
% Plots annotations of elan files tier-sorted on a time line and colors the
% annotations according to their annotation value (equal annotations are
% colored equally)
%
% INPUT arguments: 
%
% elan = the ELAN-MATLAB structure to plot 
% tier = the tier or tiers to plot, put 'all' to plot all tiers
% colpars = colour parameter structure produced by elanAssociate
% timeunit =  x-axis units; 'sec' (default) or 'min'  
% optionaltitle: title of the figure (string). If left blank, figure will 
% have no title. 
% labels = 0 don't print labels, 1 print the values in associated colors in the figure. 
%
% Example: elanPlotColor(data, 'C_Facing_MT', colp, [], 'My plot', 0)
% - to set a plot title while using default timeunits of seconds.
%
% Change 26.8.2015: reworked the input params. 
%
% Built on the SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 26.8.2015

if nargin < 6
    labels = 0;
    if nargin < 4
    timeunit = 'sec'; 
    end
end


if strcmp(tier, 'all') == 1; 
    fn=fieldnames(elan.tiers); %fieldnames = tier names
else fn = tier; 
end

    
    
gcf;
clf;
set(gcf,'OuterPosition');
axes('OuterPosition',[.05  .05  .9  .9]);
set(gca,'YTickLabel',[],'YTick',[],'YLim',[0.5 length(fn)+0.5]);
hold on;
minx = elan.range(2);% find end point of one annotation
maxx = elan.range(1);% find start point of one annotation

for i=1:length(fn) %find first annotation on timeline for all tiers
	f=elan.tiers.(fn{i});
	if (~isempty(f))
		minx=min(min([f.start]),minx);
		maxx=max(max([f.stop]),maxx);
	end;
end;

% label colors 
for i = 1:length(fn)
    val{i} = elanValues(elan, fn{i}); 
end

%%


annocolors = contain_r(colpars.values); % makes container.Map structure with values and keys

% plot each tier
for i=1:length(fn) % each tier
	f=elan.tiers.(fn{i}); % one tier
	lenf = length(f);
	y=i-0.4;% 'line' in plot where tier will be plotted
	h=0.8; % height for tiers in plot
   
colmap = colpars.colors; % this variable contains the list of color codes.

		% plot every annotation in tier
		for j=1:lenf; % all annotations in tier
			x=f(j).start; %start point for annotation
			w=f(j).stop-f(j).start; %width for annotation
			key = char(elan.tiers.(fn{i})(j).value);
			
			if (w>0)
				thiscolor  = colmap((annocolors(key)),:);
				thisedgcol = thiscolor; %no edge line
				rectangle('Position',[x y w h],  'EdgeColor',thisedgcol,...
                    'FaceColor',thiscolor,'Curvature',0.2);
			end;
		end;
           
    % text per line (name of tier)
	tiertext = strcat(fn{i});

	try
		text(elan.range(1)-20,i,tiertext,'HorizontalAlignment','right','Interpreter','none','Margin',10,'FontSize',14);
 	catch message
 		error('No annotations in tier. Did you save your elan file before importing it?');
 	end%try
 	if (nargin >4)
 		title(optionaltitle,'Interpreter','none')
 	end
	axis([ minx maxx -inf inf ]);
    
    % labels
    if labels == 1; 
        
    for k = 1:length(val{i});  
        key = char(val{i}{k});
        text(elan.range(2)+30, i+(0.1*length(val{i}))-(k*0.1), strcat(val{i}{k}),...
            'HorizontalAlignment','right','Interpreter','none','Margin',10,...
            'FontSize',14, 'Color', colmap((annocolors(key)),:)); 
    end
    
    end 
    
    % /labels
    
    % x-axis ticks and tick labels 
    % leave on auto if 'sec'
    
    if strcmp(timeunit, 'min') == 1; 
        rg = floor((elan.range(2)-elan.range(1))/60); 
        rgs = floor(elan.range(1)/60);              
        rge = ceil(elan.range(2)/60); 
        
        axis([rgs*60 maxx -inf inf]);
 
        if rg > 15; 
        
        set(gca, 'XTick', rgs*60:300:rge*60); 
        set(gca, 'XTickLabel', rgs:5:rge);
        set(get(gca, 'XLabel'), 'String', 'minutes'); 
       
        else
            
        set(gca, 'XTick', rgs*60:60:rge*60); 
        set(gca, 'XTickLabel', rgs:1:rge);
        set(get(gca, 'XLabel'), 'String', 'minutes'); 
        end    
            
            
   else
        set(get(gca,'XLabel'),'String','seconds');
        
    end
    set(gca, 'FontSize', 16); % title and x-label
    hold off;
end;

%%
function out = contain_r(in); 

out = containers.Map('KeyType', 'char', 'ValueType', 'int32');

for i = 1:length(in)
    out(in{i}) = i; 
end

