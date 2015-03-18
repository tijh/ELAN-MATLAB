% elanPlot(elan, codes, colors, optionaltitle)
% 
% Plots annotations of elan files tier-sorted on a time line and colors the
% annotations according to their annotation value (equal annotations are
% colored equally)
% Variable 'codes' is a container.Map structure with annotation values and
% their keys. Variable 'colors' is an array with color codes (n,3), from which the
% colors are picked to represent annotations. 
%
% Change 31.12.2014: AnnotationValid-tier no longer needed, now uses the
% start and stop values from the field elan.range instead (produced by
% newer version of elanRead).
% 
% Last edited (TH) 31.12.2014


function elanPlotColors(elan, codes, colors, optionaltitle)
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
set(get(gca,'XLabel'),'String','seconds');
hold on;
minx=max([elan.range(2)]);% find end point of one annotation
maxx=min([elan.range(1)]);% find start point of one annotation
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
				rectangle('Position',[x y w h],  'EdgeColor',thisedgcol, 'FaceColor',thiscolor,'Curvature',0.2);
				
				
			end;
		end;

        
    
    % text per line (name of tier + number of different annotations)
	tiertext = strcat(fn{i});
%	tiertext2 = strcat('#',num2str(numcolor),' (',num2str(lenf),')');
	% Todo: give also number of anntations
	try
		text(minx-20,i,tiertext,'HorizontalAlignment','right','Interpreter','none','Margin',10,'FontSize',14);
	%	text(maxx,i,tiertext2,'HorizontalAlignment','left','Interpreter','none','Margin',20,'FontSize',8);
 	catch message
 		error('No annotations in tier. Did you save your elan file before importing it?');
 	end%try
 	if (nargin >1)
 		title(optionaltitle,'Interpreter','none')
 	end
	axis([ minx maxx -inf inf ]);
	hold off;
end;
