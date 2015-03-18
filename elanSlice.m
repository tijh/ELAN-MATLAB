% function newElan=elanSlice(elan,start,stop)
%
% an elan struct (read by elanReadFile for instance, or created by
% elanSlice) is sliced (everything else is omitted) according to the given
% arguments:
%
% examples for slicing possibilities:
% ----------------------------------
%% (1a) slice time interval
% slicedElan=elanSlice(elan, 10, 100);
%
%% (1b) do it with several at once:
%%   first slice starts at 10, end at 100,
%%   second starts at 200, ends at 400
% slicedElan=elanSlice(elan, [10 200], [100 400]);
%
%% (2a) Slicing with Tiers (taking the given tier as reference and slice
%% definition)
% ne=elanSlice(elan,elan.tiers.Blickrichtung_Schokou);
%
%% (2b) slice all annotations of a tier that have a certain value
%ne=(elanSlice(elan,elan.tiers.Blickrichtung_Schokou,'2'));
%% (2c) slice all annotations of a tier that have any of these values
%ne=(elanSlice(elan,elan.tiers.Blickrichtung_Schokou,{'2','3'}));
%

function newElan=elanSlice(elan,start,stop)
% in order to avoid confusion if you use both elanSlice and
% elanTimeseriesSlice which would NOT be wise, we delete the
% timeseries data as a precaution
if isfield(elan,'linkedFiles')
	warning('removing timesieries data as a precaution - we recommend to use elanTimeseriesSlice if you intend to slice the timeseries data as well');
	try
		elan.tiers = rmfield(elan.tiers,'merged_mt9_data_remus');
		elan.tiers = rmfield(elan.tiers,'merged_mt9_data_romulus');
		elan.tiers = rmfield(elan.tiers,'csv_1_all');
		elan = rmfield(elan,'linkedFiles');
	catch
		warning('some of the fields may not have been removed')
	end
end

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
		newElan=elanSlice(elan,[start(selectedIndices).start],[start(selectedIndices).stop]);
	else % example 2a
		% create new struct containing start/stop indices of the annotations
		newElan=elanSlice(elan,[start.start],[start.stop]);
	end;
else % slicing with timestamps / without tiers (example 1)
	fn=fieldnames(elan.tiers);
	newElan=elan;
	% compute for each tier
	for i=1:length(fn)
		f=fn{i};
		stats.(f).count=length(elan.tiers.(f));
		tier=elan.tiers.(f);
		if (isempty(tier))
			newElan.tiers.(f)=[];
			continue;
		end;
		%% check times
		newElan.tiers.(f)=elanComputeOverlap(tier,start,stop);
		%
		%     newElan.tiers.(f)=[];
		%     for j=1:length(start);
		%         inds = find(([elan.tiers.(f).start]>=start(j)) & ([elan.tiers.(f).start]<=stop(j)));
		%         newElan.tiers.(f)=[newElan.tiers.(f) elan.tiers.(f)(inds)];
		%     end;
	end;
	for j=1:length(start); % for all slice time intervals (example 1b)
		newElan.tiers.AnnotationValid(j).start=start(j);
		newElan.tiers.AnnotationValid(j).stop=stop(j);
		newElan.tiers.AnnotationValid(j).duration=stop(j)-start(j);
		newElan.tiers.AnnotationValid(j).overlapSeconds=stop(j)-start(j);
		newElan.tiers.AnnotationValid(j).overlapCase=16;
	end;
end;
