function elan = elanReadData(fn, prevElan, offset)

% Reads in ELAN-data (.eaf files), produces the ELAN-MATLAB data structure.
% elan = elanReadData(fn, prevElan, offset)
% 
% INPUT arguments: 
% 
% fn = filename of ELAN file as string (can also be a cell array of filename-strings)
% prevElan & offset = internal arguments, don't use
% 
% If there are linked media files or linked csv files, they will be loaded as well 
% but only if you are working with a single file.
%
% usage:
% elan = elanReadData('anno_example.eaf')
%
% supports loading of several files at once:
% elan=elanReadData({'example.eaf','VP01-face-1.eaf'});
%
% EDIT 16.1.2015 (TH) Added field elan.range to include the start and stop
% times so that the AnnotationValid-tier is not needed in plotting.
% EDIT 3.8.2015 (TH) Removed unnecessary private functions, the code no
% longer produces TSR or overlap fields, and no AnnotationValid or ElanData 
% tiers. 
%
% Based on the elanRead.m SALEM 0.1beta toolbox (Uni Bielefeld) 
%
%   ~~ ELAN-MATLAB Toolbox ~~~~ github.com/tijh/ELAN-MATLAB ~~
% Tommi Himberg, NBE / Aalto University. Last changed 13.8.2015


if nargin<2
	prevElan=[];
else
	bool_several = 1;
end;
if nargin<3
	offset=0;
else
	bool_several = 1;
end;

elan=prevElan;

if (iscell(fn)) % if there are several files at once
	bool_several = 1;
	for i=1:length(fn)
		% then, an offset is calculated in order to synchronize
		offset=findMaxTimestamp(elan);
		elan=elanReadData(fn{i},elan,offset);
	end;
	% return from the recursive calls
	return;
end;

fprintf('reading file "%s"\n', fn);
xDoc=xmlread(fn);
% Find a deep list of all <listitem> elements.
import java.util.*;


%% parse time order
timeOrderElem = xDoc.getElementsByTagName('TIME_ORDER');
timeSlotElems = timeOrderElem.item(0).getElementsByTagName('TIME_SLOT');

timeSlots = java.util.HashMap;
timeSlots.clear();


for i=0:timeSlotElems.getLength-1
	elem=timeSlotElems.item(i);
	ts = elem.getAttribute('TIME_SLOT_ID');
	tv = elem.getAttribute('TIME_VALUE');
	timeSlots.put(ts, str2num(tv)+offset*1000);
end


%% parse elan annotations
if (~isfield(elan,'tiers'))
	elan.tiers = struct();
end;

tierElems = xDoc.getElementsByTagName('TIER');
minStart=realmax;
maxStop=0;
for i=0:tierElems.getLength-1
	elem=tierElems.item(i);
	tId = char(elem.getAttribute('TIER_ID'));
	tId = regexprep(strtrim(tId),'[^\w]','_');
	
	if (~isfield(elan.tiers,tId)) % error when tier name begins with number (restrictions from matlab variable names)
		try
			elan.tiers.(tId) = [];
		catch
			error('Please use tier names with no number in the first digit. Invalid tier name: %s',tId);
		end;
	
	end;
	
	annoElems = elem.getElementsByTagName('ANNOTATION');
	for i=0:annoElems.getLength-1
		elem=annoElems.item(i).getElementsByTagName('ALIGNABLE_ANNOTATION').item(0);
		tmp1 = char(elem.getAttribute('TIME_SLOT_REF1'));
		tmp2 = char(elem.getAttribute('TIME_SLOT_REF2'));
		
		anno.start = timeSlots.get(tmp1)/1000;
		anno.stop = timeSlots.get(tmp2)/1000;
		
		anno.duration = anno.stop - anno.start;
		
		anno.value=char(elem.getElementsByTagName('ANNOTATION_VALUE').item(0).getTextContent());
		anno.value=regexprep(anno.value,{'/',' '},'');
		if (anno.start>=0)
			elan.tiers.(tId)=[elan.tiers.(tId) anno];
			minStart=min(minStart,anno.start);
			maxStop=max(maxStop,anno.stop);
		end;
	end
end

%% parse linked files if there is only one eaf file in argin
if (exist('bool_several','var'))
	%fprintf('if you intended to use the timeseries support (you can ignore this warning otherwise):\n -- note that working with serveral files _and_ linked files is not yet supported\n -- ignoring linked files if there are any \n');
else
	% media files (videos)
	mediaFilesElem = xDoc.getElementsByTagName('MEDIA_DESCRIPTOR');
	if ((mediaFilesElem.getLength)>0)
		elan.mediaFiles = struct();
		mediacount = 0;
		for i=0:mediaFilesElem.getLength-1
			mediacount=mediacount+1;
			media_origin = str2num(mediaFilesElem.item(0).getAttribute('TIME_ORIGIN'));
			mediumID = strcat('medium_',num2str(mediacount),'_origin');
			elan.mediaFiles.(mediumID) = media_origin;
			% you can add code here that allows to import the linked media files
			% (video/audio) in matlab as well
			% put media files in mf_0, mf_1 and so on
		end%for
	end%if
	
	% other linked files (csv files)
	linkedFilesElem = xDoc.getElementsByTagName('LINKED_FILE_DESCRIPTOR');
	% if there are any linked files create linkedFiles struct
	if ((linkedFilesElem.getLength-1)>0)
		if (~isfield(elan,'linkedFiles'))
			elan.linkedFiles = struct();
		end%if
		
		if (~exist ('/Users/adierker/svn-checkouts/programming/matlab','file'))
			type_associated = 'NaN';
			ismerged = NaN;
		else %this means it is special data that has to get special treatment
			% get external base timestamp for this .eaf-file if available
			eafbaseTS = [];
			% split eaf filename in fileparts
			[argfilepath,eafname,~] = fileparts(fn);
			[ismerged, type_associated, eafbaseTS] = loadBaseTimestamp(eafname,eafbaseTS);
		end%if
		elan.eaf_basetime = eafbaseTS;
		
		csvcount = 0;
		% put linked files in csv_0, csv_1 and so on according to csvcount
		for i=0:linkedFilesElem.getLength-1
			elem=linkedFilesElem.item(i);
			
			% find the right files
			fileurl = char(elem.getAttribute('LINK_URL'));
			relfileurl = char(elem.getAttribute('RELATIVE_LINK_URL'));
			[~,relfilename,relfextension] = fileparts(relfileurl);
			% ignore "file://" in beginning of filename
			filepath = fileurl(8:end);
			[~, ~, fextension] = fileparts(filepath);
			if (~strcmp(fextension, '.xml') && ~strcmp(fextension,'.pfsx')) % ignore config files "*tsconf.xml" and "*.pfsx"
				% concatenate filename with possible paths/extensions
				fname = strcat(relfilename,relfextension);
				fname2 = strcat(argfilepath,'/',fname);
				fname3 = strcat('miles-files/',fname);
				fname4 = strcat('miles-data/',fname);
				% test if any of these find a valid file
				[ftype,validfid] = max([exist(fname,'file'), exist(fname2,'file'), exist(fname3,'file'), exist(fname4,'file'), exist(filepath,'file')]==2);
				if (ftype~=1) % if no file exists
					validfid = -1;
				end
				% load data from file (TODO allow loading of original data)
				switch (validfid)
					case 1
						loadname = fname;
					case 2
						loadname = fname2;
					case 3
						loadname = fname3;
					case 4
						loadname = fname4;
					case 5
						loadname = filepath;
					otherwise
						warning('file "%s" not found in relative or absolute path\n',fname);
						
						continue;
				end%switch
				fprintf('reading linked file "%s"\n', loadname);
				csvdata = elanReadLinkedCSV(loadname);
				
				if  (exist('csvdata','var'))
					% sequential name for csv file in struct
					csvcount = csvcount+1;
					csvID = strcat('csv_',num2str(csvcount));
					csv_origin = str2num(elem.getAttribute('TIME_ORIGIN'));
					
					% find average timestamp interval
					[tsinterval,tsunit,csv_origin,eafbaseTS] = findTimestampInterval(csvdata(:,1),csv_origin,eafbaseTS);
					
					% and recalculate timestamps if necessary
					if (~isempty(csv_origin))
						% recalculate timestamps for csv_origin
						% TODO is it a good idea to recalculate them _here_ not in elanTimeseriesSlice etc?
						csvdata(:,1) = csvdata(:,1)-csv_origin;
						% snip origin data: now all data < 0
						startline = find(csvdata(:,1)>=0);
						csvdata = csvdata(csvdata(:,1)>=0,:);
						% note: a negative origin will not happen since it is not
						% possible to shift the timeseries data in Elan to the
						% negative
						fprintf('snipping csv offset data: %s lines from offset %s. TSinterval %s assuming %s\n',num2str(startline(1)),num2str(csv_origin),num2str(tsinterval),tsunit);
					end%if
					
					% ONLY if the data is OUR special data apply further treatments
					if (exist ('/Users/adierker/svn-checkouts/programming/matlab','file'))
						% this means it is special data that has to get special treatment
						[elan,csvdata] = specialWiiMilesTreatment(elan,csvdata,type_associated,fname,loadname,csv_origin);
					end
					
					% save into struct
					elan.eaf_basetime = eafbaseTS;
					elan.linkedFiles.(csvID) = struct();
					elan.linkedFiles.(csvID).name = fname; % filename without path
					elan.linkedFiles.(csvID).successful_loadname = loadname; % filename with path
					elan.linkedFiles.(csvID).initialorigin = csv_origin; % origin used for recalculation
					elan.linkedFiles.(csvID).type = type_associated; % type of data if known (wii/mt9)
					elan.linkedFiles.(csvID).tsunit = tsunit; % unit s or ms for timestamps used
					elan.linkedFiles.(csvID).data = csvdata; % data from file
					clear csvdata;
				end%if
			end%if
		end%for
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		%% create annotations from timeseries data
		csvitems = fieldnames(elan.linkedFiles);
		% over all linked Files
		for i=1:length(csvitems)
			csvdata = elan.linkedFiles.(csvitems{i}).data;
			
			% allow ts correction according to tsunit if this is known
			tsunit = elan.linkedFiles.(csvitems{i}).tsunit;
			if (strcmp(tsunit,'ms'))
				tscorrection = 1000;
			elseif tsunit == 's'
				tscorrection = 1;
			else % tsunit == NaN
				tscorrection = 1;
			end
			
			columns = {};
			if (ismerged == 1 && size(csvdata,2)>7)
				% note: since elan does not work with more than one linked file
				% (saving/presentation problems) we merged our two csv data files into one
				% extending the number of columns. Now we have to differentiate these columns
				% again (thus, this part of the code could be ignored by others)
				columns{1} = 2:(size(csvdata,2)-1)/2+1;
				columns{2} = (size(csvdata,2)-1)/2+2:size(csvdata,2);
			else % if the data is not merged
				columns{1} = [2:size(csvdata,2)];
			end%if
			
			for m=1:length(columns) % for each part of the merged csv (normally only one)
				% new variable with the actual part of the data
				partdata = csvdata(:,[1,columns{m}]);
				if (m == 1 && length(columns)==2)
					subject = 'remus';
				elseif (m == 2)
					subject = 'romulus';
				else
					subject = 'all';
				end%if
				tId = strcat(csvitems{i},'_',subject);
				if (~isfield(elan.tiers,tId))
					elan.tiers.(tId) = [];
				%else
				%	error('tiername %s already exists',tId);
				end%if
				column = 2; % the column where to look for NaN values
				% TODO: find better way to determine missing data than looking into _one_ column
				
				% Check for NaN values and snip associated rows
				nans = isnan(partdata(:,column)); % vector of 0s and 1s
				csvAnno = find(nans, 1); % vector of row numbers of NaNs
				if (~isempty(csvAnno)) % if there are NaN values
					edges = diff(nans); % find change-points from NaN to non-NaN or vice versa
					positive = find(edges ==  1); % ending elements
					negative = find(edges == -1); % starting elements
					if (~(isempty(positive) && isempty(negative))) % not only NaNs but any valid data
						% find all intervals of valid data and add start or end elements
						if (isempty(positive))
							positive = [length(partdata)]; %add end element
						end%if
						if (positive(end) ~= length(partdata))
							positive = [positive;length(partdata)]; %add end element
						end%if
						if (isempty(negative))
							negative = [1]; %add start element
						end%if
						if (negative(1) ~= 1 && negative(1) > positive(1))
							negative = [1;negative]; %add start element
						end%if
					end%if
				else % if there are _no_ NaN values add annotation for whole csv data length
					positive = [length(partdata)]; % end elment
					negative = [1];  % starting element
				end%if
				% process all intervals of valid data (beginning with items of negative) 
				% and add annotations for each of them
				for l = 1:length(negative)
					%anno.startTSR = NaN; %this annotation does not exist in the .eaf file
					%anno.stopTSR = NaN;
					anno.start = partdata(negative(l),1)/tscorrection;
					anno.stop = partdata(positive(l),1)/tscorrection;
					anno.value = num2str(l);
					anno.duration = anno.stop - anno.start;
					%anno.overlapCase = 0;
					%anno.overlapSeconds = anno.duration;
					if (anno.start>=0)
						elan.tiers.(tId) = [elan.tiers.(tId) anno];
						minStart = min(minStart,anno.start);
						maxStop = max(maxStop,anno.stop);
					end%if
				end%for
			end%for
		end%for
	end%if
end%if


anno.start = minStart;
anno.stop = maxStop;
anno.duration = maxStop - minStart;
[~, anno.value] = fileparts(fn);

elan.range = [minStart, maxStop];




%% %%%%%% private functions


%% %%%%%% these private functions are called for all .eaf files with csv data

%% private: findMaxTimestamp
function currMax=findMaxTimestamp(elan)
if (isfield(elan,'tiers'))
	fn=fieldnames(elan.tiers);
	currMax=0;
	for i=1:length(fn)
		f=fn{i};
		if (~isempty(elan.tiers.(f)))
			currMax=max(currMax,max([elan.tiers.(f).stop]));
		end;
	end;
else
	currMax=0;
end;


%% private: findTimestampInterval
function [tsinterval,tsunit,csv_origin,eafbaseTS]= findTimestampInterval(csvdata,csv_origin,eafbaseTS)
% Take csv time_origin into account
% Note: The positive origin is denoted as the number of milliseconds
% that the linked file is starting *later* bzw. #ms that are
% skipped from the file get origin from .eaf
%
% what about a potential second timeseries file, does it get an extra origin?
% Not until now (Elan Version 4.0.0) since second timeseries files
% are not getting moved/synchronized either so there should not
% be a problem with this method, yet ;-)

if csv_origin < 0
	error ('csv_origin < 0. This should not be possible. Something is wrong.')
end%if

try
	tsinterval = (csvdata(10001,1)-csvdata(1,1))/1000;
catch
	tsinterval = (csvdata(1001,1)-csvdata(1,1))/100;
end%try
% calculate an average timestamp interval. In the old files this should
% be exactly 0.1 whereas in the newer files this is between 50 and
% 60 because of the merging (2 streams in one file)

% find out if timestamps are in seconds or in milliseconds
if (tsinterval < 0.09)
	warning ('timestamp format in csv is unknown %s .. assuming s',num2str(tsinterval));
	tsunit = 's';
	csv_origin = csv_origin/1000;
elseif (tsinterval > 115)
	warning ('timestamp format in csv is unknown: %s .. assuming ms',num2str(tsinterval));
	tsunit = 'ms';
	eafbaseTS = eafbaseTS *1000;
elseif (tsinterval < 0.115)
	% old -ela2 file, timestamps are in seconds with  0.01 steps
	% convert origin to seconds since timestamps are in seconds too
	tsunit = 's';
	csv_origin = csv_origin/1000;
elseif (tsinterval > 90)
	% new logs2eaf csv file, timestamps are in milliseconds
	tsunit = 'ms';
	eafbaseTS = eafbaseTS *1000;
elseif (tsinterval >= 40)
	tsunit = 'ms';
	eafbaseTS = eafbaseTS *1000;
	fprintf('timestamp interval: %s assuming merged files with 200Hz\n',num2str(tsinterval))
elseif (tsinterval <1)
	tsunit = 's';
	csv_origin = csv_origin/1000;
	warning('timestamp format unknown: %s assuming s',num2str(tsinterval))
else
	error('timestamp format unknown: %s assuming s',num2str(tsinterval))
end%if
%if (~isempty(eafbaseTS))
%	recalculate timestamps for eaf basetimestamp
%	csvdata(:,1) = csvdata(:,1)+eafbaseTS;
%end%if

%% private: elanReadLinkedCSV
function newData1 = elanReadLinkedCSV(fileToRead1)
%IMPORTFILE1(FILETOREAD1)
%  Imports data from the timeseries file
%  FILETOREAD1:  file to read

%  Auto-generated by MATLAB
%DELIMITER = ';';
%HEADERLINES = 1;

% Import the file without giving any parameters (delimiter etc. because the csvs
% sometimes have headerlines (newer versions) and sometimes not (oder versions)
newData1 = importdata(fileToRead1);%, DELIMITER, HEADERLINES);

% if there is a headerline the resulting data will be a struct.
if (isstruct(newData1))
	% only return the data, forget the other struct parts
	newData1 = newData1.data;
end%if
% Create new variables in the base workspace from those fields.
%vars = fieldnames(newData1);
%for i = 1:length(vars)
%    assignin('base', vars{i}, newData1.(vars{i}));
%end
%end%function

%%suppressed Matlab code warnings
%#ok<*WNTAG>
%#ok<*CTCH>
%#ok<*AGROW>



