function out=elanSlicer(elan,start,stop)

% To cut slices from an ELAN-MATLAB structure. 
%
% newElan=elanSlicer(elan,start,stop)
%
% INPUT arguments: 
%
% elan = ELAN-MATLAB structure
% start = start time(s) of the slice (seconds)
% stop = stop time(s) of the slice (seconds)
%
% OUTPUT:
%
% out = ELAN-MATLAB structure containing only the sliced bit
%
% usage examples:
%
% slicedElan = elanSlicer(elan, 10, 100);
%
% slicedElan = elanSlicer(elan, [10 200], [100 400]); % multiple slices
%
% newElan = elanSlicer(elan, elan.tiers.C_Facing_MT); % slice based on tier
%
% newElan = (elanSlicer(elan, elan.tiers.C_Facing_MT, 'NF')); % slice based
% on an annotation on a tier (can also use multiple annotations). 
%
% EDIT 18.3.2015 (TH) Removed AnnotationValid tier and added 
% the start and stop times as newElan.range instead to be compatible with
% the rest of the ELAN-MATLAB functions. 
%
% Based on elanSlice.m in SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%  ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 13.8.2015


% begin slicing
% are we slicing with timestamps or with tiers?
if (isstruct(start))
	% if we are slicing with tiers (example 2) compute start/stop indices of
	% "interesting" annotations and call this function again
	if nargin>=3 % example 2b/2c
		% (for the following see function_handle (@) help text)
		% string-compare all start.value(s) (= all annotation values of this tier)
		% with the given stop argument(s)   (= annotation values to be sliced)
		% max evaluates if at least one strcmp was 1 (= match);
		% cellfun applies function to each cell in cell array (2nd argument: {start.value} = all annotation values)
		cf=((cellfun(@(x) (max(strcmp(strtrim(x),stop))), {start.value})));
		% find gets all indices for the cases where strcmp was 'true' (all matches)
		selectedIndices=find(cf);
		% create new struct containing indices where annotation matched stop
		% argument
		out=elanSlicer(elan,[start(selectedIndices).start],[start(selectedIndices).stop]);
	else % example 2a
		% create new struct containing start/stop indices of the annotations
		out=elanSlicer(elan,[start.start],[start.stop]);
	end;
else % slicing with timestamps / without tiers (example 1)
	fn=fieldnames(elan.tiers);
	out=elan;
	% compute for each tier
	for i=1:length(fn)
		f=fn{i};
		stats.(f).count=length(elan.tiers.(f));
		tier=elan.tiers.(f);
		if (isempty(tier))
			out.tiers.(f)=[];
			continue;
		end;
		%% check times
		out.tiers.(f)=elanComputeOverlap(tier,start,stop);
		%
	end;


    out.range = [start stop];


end;
