% function [redundantCompTier,numRelevantAnnos,refTierDur] = elanCorrelateTiers(elan,refTierName,compTierName,relevantValuesRefTier,plotOverlaps)
% 
% This function compares the annotations (values and overlap) of two tiers
% more precisely: it computes values and overlap for all annotations of refTier with compTier
%
% NEEDS    : elanComputeOverlap.m
% USED BY  :
%
% ARGUMENTS: elan: should be a valid elan file struct with refTierName and compTierName
%            refTierName: string name of reference Tier (e.g. annotated gestures)
%            compTierName: string name of compare Tier (e.g. automatic classification of gestures)
%            relevantValuesRefTier: (optional) cell array of strings that are interesting 
%                                 for the correlation or empty cell array '{}'
%            plotOverlaps: 0: not plotting, 1: plotting each overlap
% RETURNS  : redundantCompTier: list of annotations (redundant) that overlap
%            numRelevantAnnos: number of relevant annotations (all annos that match
%                              relevantValuesRefTier + the number of redundant overlaps)
%            refTierDur: duration of relevant annos in tier 1
% example:
% 	>> redundantCompTier(2)
% 	ans =     startTSR: 'ts69'
% 				  stopTSR: 'ts76'
% 					 start: 2.0984e+03  <- start timestamp in compare tier
% 					  stop: 2.1009e+03  <- stop timestamp in compare tier
% 				 duration: 2.5600      <- anno duration in compare tier
% 			 overlapCase: 9           <- overlapCase 9 = beginExtend (see help elanValueStats)
% 		 overlapSeconds: 0.1400      <- number overlapping seconds
% 					 value: '1mbh'      <- value of anno in compare tier
% 				 refValue: '3'         <- value of anno in reference tier
% 			 refDuration: 5.8100      <- anno duration in reference tier
%            refStart:             <- start timestamp in reference tier
%             refStop:             <- stop timestamp in reference tier
%          startOnset:             <- (anno start in compTier) - (anno start von refTier)
%          stopOffset:             <- (anno stop in compTier) - (anno stop von refTier)			
% 			overlapMatch: 1           <- 1: match, 0: different values
% 												  to come: ]0,1[ for building of confusion matrix 
% 												  (which values are annotated mostly when wrong)
% adierker / 2011-03-16
% USAGE    : [redundantCompTier,numRelevantAnnos,refTierDur]=elanCorrelateTiers(eaffile,'Kopfgesten_remus','mt9_remus_classification_offline_hg',{'nod','shake','look','tilt'},1);

function [redundantCompTier,numRelevantAnnos,refTierDur] = elanCorrelateTiers(elan,refTierName,compTierName,relevantValuesRefTier,plotOverlaps)
if(nargin <3||~isstruct(elan))
	error('wrong number of arguments, see "help elanCorrelateTiers"');
end
if(nargin <5)
	plotting = 0;
else
	plotting=plotOverlaps;
end;

if (isfield(elan.tiers,refTierName) && isfield(elan.tiers,compTierName)) %first iteration of this function
	if (~isempty(elan.tiers.(refTierName)) && ~isempty(elan.tiers.(compTierName)))
		if (~isempty(relevantValuesRefTier)) %relevantValuesRefTier are given as argument 4
			% (for the following see function_handle (@) help text)
			% string-compare all start.value(s) (= all annotation values of this tier)
			% with the given stop argument(s)   (= annotation values to be sliced)
			% max evaluates if at least one strcmp was 1 (= match);
			% cellfun applies function to each cell in cell array (2nd argument: {start.value} = all annotation values)
			cf=((cellfun(@(x) (max(strcmpi(strtrim(x),relevantValuesRefTier))), {elan.tiers.(refTierName).value})));
			% -> cf is vector of matches/nonmatches for refTier.value with relevantValuesRefTier,
			% find gets all indices for the cases where strcmp was 'true' (all matches)
			selectedIndices=find(cf);
			% => holds indices all relevant annotations
		else
			selectedIndices = [1:length(elan.tiers.(refTierName))]; %choose all indices
		end%if
		
		% compute start/stop indices of relevant annotations
		starts = [elan.tiers.(refTierName)(selectedIndices).start];
		stops = [elan.tiers.(refTierName)(selectedIndices).stop];
		refTierValues = {elan.tiers.(refTierName)(selectedIndices).value};
		refTierDur = sum([elan.tiers.(refTierName)(selectedIndices).duration]);
		
		% compute Overlap for all annotations of refTier with compTier
		if (plotting==1)
			[~,overlaps,redundantCompTier] = elanComputeOverlap(elan.tiers.(compTierName),starts,stops,refTierName,compTierName,refTierValues); %for plotting
		else
			[~,overlaps,redundantCompTier] = elanComputeOverlap(elan.tiers.(compTierName),starts,stops);
		end%if
		[~, refIndex]=find(overlaps);
		
		%length(redundantCompTier)
		%length(refIndex)
		% there is more than one possible way to compute the number of relevant annotations
		%numRelevantAnnos = length(selectedIndices)+(length(redundantCompTier)-length(uniqueCompTier))
		% number of relevant annotations is sum of selectedIndices (all that are not faulty)
		% and the number of annotations that have overlaps with multiple annotations of ref
		numRelevantAnnos = length(selectedIndices)+(length(refIndex)-length(unique(refIndex)));
		
		% check all overlaps and add missing (statistics) fields
		for i=1:length(refIndex)
			redundantCompTier(i).refValue = refTierValues{refIndex(i)};
			redundantCompTier(i).refDuration = elan.tiers.(refTierName)(selectedIndices(refIndex(i))).duration;
			%redundantCompTier(i).numOverlaps = length(refIndex);
			redundantCompTier(i).refStart = elan.tiers.(refTierName)(selectedIndices(refIndex(i))).start;
			redundantCompTier(i).refStop = elan.tiers.(refTierName)(selectedIndices(refIndex(i))).stop;
			redundantCompTier(i).startOnset = redundantCompTier(i).start-redundantCompTier(i).refStart;
			redundantCompTier(i).stopOffset = redundantCompTier(i).stop-redundantCompTier(i).refStop;
			redundantCompTier(i).overlapMatch = NaN;
			
			% now set overlapMatches
			if (exist ('/Users/adierker/svn-checkouts/programming/matlab','file'))
				% only for our special case!
				% TODO create confusion matrix for all values
				% compare values of the overlaps for matches and save a certain value
				% dependent on both values for creation of confusion matrix
				if strcmpi( strtrim(redundantCompTier(i).value),strtrim(refTierValues{refIndex(i)}) )
					redundantCompTier(i).overlapMatch = 1;
				elseif (any(strcmpi(strtrim(redundantCompTier(i).value),{'nod','shake'}) & strcmp(strtrim(refTierValues{refIndex(i)}),{'shake','nod'}) ))
					redundantCompTier(i).overlapMatch = 0.1;
				elseif (any(strcmpi(strtrim(redundantCompTier(i).value),{'nod','tilt'}) & strcmp(strtrim(refTierValues{refIndex(i)}),{'tilt','nod'}) ))
					redundantCompTier(i).overlapMatch = 0.2;
				elseif (any(strcmpi(strtrim(redundantCompTier(i).value),{'shake','tilt'}) & strcmp(strtrim(refTierValues{refIndex(i)}),{'tilt','shake'}) ))
					redundantCompTier(i).overlapMatch = 0.3;
				elseif (any(strcmpi(strtrim(redundantCompTier(i).value),{'nod','look'}) & strcmp(strtrim(refTierValues{refIndex(i)}),{'look','nod'}) ))
					redundantCompTier(i).overlapMatch = 0.4;
				elseif (any(strcmpi(strtrim(redundantCompTier(i).value),{'shake','look'}) & strcmp(strtrim(refTierValues{refIndex(i)}),{'look','shake'}) ))
					redundantCompTier(i).overlapMatch = 0.5;
				elseif (any(strcmpi(strtrim(redundantCompTier(i).value),{'tilt','look'}) & strcmp(strtrim(refTierValues{refIndex(i)}),{'look','tilt'}) ))
					redundantCompTier(i).overlapMatch = 0.6;
				else
					warning('unmodeled case'); %Todo: erase this line before end of work
				end%if
			else
				if strcmpi( strtrim(redundantCompTier(i).value),strtrim(refTierValues{refIndex(i)}) )
					redundantCompTier(i).overlapMatch = 1; %match
				else
					redundantCompTier(i).overlapMatch = -1; % non-match
				end%if
			end%if
		end%for
	else
		warning('empty tier');
		refTierDur = NaN;
		redundantCompTier = [];
		numRelevantAnnos = 0;
	end%if
else
	error('second/third argument has to be valid tier name of first argument')
end%if
end%function
