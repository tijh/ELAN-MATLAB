% function [newCompTier,overlaps,redundantCompTier]=elanComputeOverlap(compTier,refStartTS,refStopTS,refTierValues,numOverlap)
% 
% compare compTier with arrays of timestamps (e.g. from refTier): [refStartTS] and [refStopTS];
% compute overlap cases (CCCCC is the compTier/annotation, RRR is the
% refTier that actually is sliced)
% case 1: "extend" (overlapCase 3)
% CCCCCCCCCCCCCC
%    RRRRRRR
% case 2: "end extends" (overlapCase 5)
%       CCCCCCCC
%    RRRRRRR
% case 3: "begin extends" (overlapCase 9)
%  CCCCCC
%    RRRRRRR
% case 4: "include" (overlapCase 17)
%     CCCC
%   RRRRRRRRR
% feature request: function argument that specifies a min number frames to
% overlap that leads to an overlap situation
function [newCompTier,overlaps,redundantCompTier]=elanComputeOverlap(compTier,refStartTS,refStopTS,refTierName,compTierName,refTierValues,minOverlap)

% create four grids (one for each start/stop value list)
% e.g. refStartMat: width=length(refStartTS) length=length(compTier) with refStartTS values
% e.g. compStartMat: width=length(refStartTS) length=length(compTier) with compTier.start values
[refStartMat, compStartMat] = meshgrid(refStartTS,[compTier.start]);
[refStopMat, compStopMat] = meshgrid(refStopTS,[compTier.stop]);

% identify all annotations that at least touch somehow
overlaps=double((compStartMat < refStopMat) & (compStopMat > refStartMat));

[compIndex, refIndex]=find(overlaps); %[row, col] = find(X)

% set all overlapSeconds to zero
for i=1:length(refIndex)
	compTier(compIndex(i)).overlapSeconds=0;
end;



% check all overlaps for their overlapCase and plot them
for i=1:length(refIndex)
	rStart=refStartTS(refIndex(i));
	rStop=refStopTS(refIndex(i));
	rDur=rStop-rStart;

	if nargin > 3 % for plotting of overlaps: RefTier
		gcf;
		%clf;
		% plot this annotation
		annoval = strcat(' "',refTierValues{refIndex(i)},'" id: ',num2str(refIndex(i)));
		lineval = strcat(' ',refTierName,' (refTier)');
		z = 2;
		x=rStart; %start point for annotation
		w=rDur; %width for annotation
		y=z-0.4;% 'line' in plot where tier will be plotted
		h=0.6; % height for tiers in plot
		grey = [.7 .7 .7];
		rectangle('Position',[x y w h],'EdgeColor','none','FaceColor',grey);%,'Curvature',0.2);
		text(x,z,annoval,'Color',[0 0 0],'Interpreter','none');
		text(x,z-0.25,lineval,'Color',[0 0 0],'Interpreter','none');
		hold on;
	end
	
	cStart=compTier(compIndex(i)).start;
	cStop=compTier(compIndex(i)).stop;
	cDur=cStop-cStart;
	overDur=0;


	
	% case 1:
	% CCCCCCCCCCCCCC
	%    RRRRRRR
	if (cStart < rStart && cStop > rStop)
		overlaps(compIndex(i), refIndex(i)) = bitor(overlaps(compIndex(i), refIndex(i)), 2);
		overDur=rDur; % duration of overlap
		% case 2:
		%       CCCCCCCC
		%    RRRRRRR
	elseif (cStart >= rStart && cStop > rStop)
		overlaps(compIndex(i), refIndex(i)) = bitor(overlaps(compIndex(i), refIndex(i)), 4);
		overDur=rStop-cStart;
		% case 3:
		%  CCCCCC
		%    RRRRRRR
	elseif (cStart < rStart && cStop <= rStop)
		overlaps(compIndex(i), refIndex(i)) = bitor(overlaps(compIndex(i), refIndex(i)), 8);
		overDur=cStop-rStart;
		% case 4:
		%     CCCC
		%   RRRRRRRRR
	elseif (cStart >= rStart && cStop <= rStop)
		overlaps(compIndex(i), refIndex(i)) = bitor(overlaps(compIndex(i), refIndex(i)), 16);
		overDur=cDur;
	else
		warning('unmodeled case');
	end;
	compTier(compIndex(i)).overlapCase=overlaps(compIndex(i), refIndex(i));
	compTier(compIndex(i)).overlapSeconds=compTier(compIndex(i)).overlapSeconds+overDur;
	
	
	if nargin > 3 % for plotting of overlaps: CompTier
		% plot overlap case
		blue = [0.30 0.40 0.6];
		text(x,1.4,strcat('OverlapCase:  ',num2str(overlaps(compIndex(i)), refIndex(i))),'Color',[0 0 0],'BackgroundColor',blue,'FontWeight','bold','FontSize',14,'EdgeColor','none','Interpreter','none');
		% plot this annotation
		annoval = strcat(' "',compTier(compIndex(i)).value,'" id: ',num2str(compIndex(i)));
		lineval = strcat(' ',compTierName,' (compTier)');
		z = 1;
		x=cStart; %start point for annotation
		w=cDur; %width for annotation
		y=z-0.4;% 'line' in plot where tier will be plotted
		h=0.6; % height for tiers in plot
		grey = [.7 .7 .7];
		rectangle('Position',[x y w h],'FaceColor',grey,'EdgeColor','none');%,'Curvature',0.2); 
		text(x,z,annoval,'Color',[0 0 0],'Interpreter','none');
		text(x,z-0.25,lineval,'Color',[0 0 0],'Interpreter','none');
		hold off;
		pause(2.5);
	end
end;

% prepare return variables redundantCompTier and newCompTier
selectedCompInd=unique(compIndex); 
newCompTier=compTier(selectedCompInd);  % single elements (for slicing)
redundantCompTier = compTier(compIndex); % repeated elements (only important for elanCorrelateTiers)
