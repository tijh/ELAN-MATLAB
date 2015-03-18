function elanPlotColors(elan, codes, colors, timeunit, optionaltitle)

% elanPlot(elan, codes, colors, timeunit, optionaltitle)
% 
% Plots annotations of elan files tier-sorted on a time line and colors the
% annotations according to their annotation value (equal annotations are
% colored equally)
%
% INPUT ARGUMENTS: 
% codes: Variable 'codes' is a container.Map structure with annotation values
% and their keys. 
%
% colors: Variable 'colors' is an array with color codes (n,3), from which 
% the colors are picked to represent annotations. 
%
% timeunit: x-axis units; 'sec' (default) or 'min'  
%
% optionaltitle: title of the figure (string). If left blank, figure will 
% have no title. 
%
% Example: elanPlotColor(data, associations, colourlist, [], 'My plot')
% - to set a plot title while using default timeunits of seconds.
%
% Change 31.12.2014: AnnotationValid-tier no longer needed, now uses the
% start and stop values from the field elan.range instead (produced by
% newer version of elanRead). 
%
% Change 18.3.2015: x-axis no longer starts from 0, rather from
% start of the elan file or slice, as set in elan.range. Choice of x-axis
% units added.
%
% Last edited (TH) 18.3.2015


if nargin < 4
    timeunit = 'sec'; 
end

fn=fieldnames(elan.tiers); %fieldnames = tier names
%gca;
%cla;
gcf;
clf;
set(gcf,'OuterPosition');
axes('OuterPosition',[.1  .05  .9  .9]);
%f = gcf;
%set(f,'CurrentAxes',gca)
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

annocolors = codes; % the container.Map structure with values and keys

% plot each tier
for i=1:length(fn) % each tier
	f=elan.tiers.(fn{i}); % one tier
	lenf = length(f);
	y=i-0.4;% 'line' in plot where tier will be plotted
	h=0.8; % height for tiers in plot
   
colmap = colors; % this variable contains the list of color codes.

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

        
    
    % text per line (name of tier + number of different annotations)
	tiertext = strcat(fn{i});
%	tiertext2 = strcat('#',num2str(numcolor),' (',num2str(lenf),')');
	% Todo: give also number of anntations
	try
		text(minx-40,i,tiertext,'HorizontalAlignment','right','Interpreter','none','Margin',10,'FontSize',14);
	%	text(maxx,i,tiertext2,'HorizontalAlignment','left','Interpreter','none','Margin',20,'FontSize',8);
 	catch message
 		error('No annotations in tier. Did you save your elan file before importing it?');
 	end%try
 	if (nargin >4)
 		title(optionaltitle,'Interpreter','none')
 	end
	axis([ minx maxx -inf inf ]);
    
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
    
    hold off;
end;
