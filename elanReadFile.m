% function elan=elanReadFile(fn, prevElan, offset)
% 
% arguments: fn: filename of elan file as string (can also be a cell array of filename-strings)
%            prevElan: internal, do not use!
%            offset: internal argument, do not use!
% 
% parses the given ELAN file into a struct of tiers and time_slots. The
% time_slots are mostly useless, while the tiers is a struct with all
% annotation according to the tiers, with computed start and end times and
% values. Additionally two tiers "ValidAnnotation"  and "ElanFile" are added to support 
% slicing of files (see help elanSlice).
% If there are linked media files or linked csv files, they will be loaded as well 
% but only if you are working with a single file.
%
% usage:
% elan=elanReadFile('example.eaf')
%
% supports loading of several files at once:
% elan=elanReadFile({'example.eaf','VP01-face-1.eaf'});

function elan=elanReadFile(fn, prevElan, offset)

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
		elan=elanReadFile(fn{i},elan,offset);
	end;
	% return from the recursive calls
	return;
end;

fprintf('reading file "%s"\n', fn);
xDoc=xmlread(fn);
% Find a deep list of all <listitem> elements.
import java.util.*;

%% get date timestamp
%docdate = xDoc.getElementsByTagName('ANNOTATION_DOCUMENT')
%tmp = char(docdate.item(0).getAttribute('DATE'))
%datestr(datenum(tmp,'yyyy-mm-ddTHH:MM:SS'))

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
%elan.timeSlots=timeSlots;


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
	if (exist ('/Users/adierker/svn-checkouts/programming/matlab','file'))
		% ONLY in our special case delete all _001/_002/... endings of tiernames
		if(strfind (tId ,'syllables')) % ignore syllables-tiers
			continue
		end%if
		tId = regexprep(tId,'_00\d','');
	end%if
	if (~isfield(elan.tiers,tId)) % error when tier name begins with number (restrictions from matlab variable names)
		try
			elan.tiers.(tId) = [];
		catch
			error('Please use tier names with no number in the first digit. Invalid tier name: %s',tId);
		end;
	%else
	%	error('tiername %s already exists',tId);
	end;
	
	annoElems = elem.getElementsByTagName('ANNOTATION');
	for i=0:annoElems.getLength-1
		elem=annoElems.item(i).getElementsByTagName('ALIGNABLE_ANNOTATION').item(0);
		anno.startTSR = char(elem.getAttribute('TIME_SLOT_REF1'));
		anno.stopTSR = char(elem.getAttribute('TIME_SLOT_REF2'));
		% TODO why do we work with seconds?
		anno.start = timeSlots.get(anno.startTSR)/1000;
		anno.stop = timeSlots.get(anno.stopTSR)/1000;
		if(exist ('/Users/adierker/svn-checkouts/programming/matlab','file'))
		% very dirty mt9 classification hack! (classification was always 0.6 sec late)
			if(strfind (tId ,'classification'))
				anno.start = (timeSlots.get(anno.startTSR)/1000-0.5);
				anno.stop = (timeSlots.get(anno.stopTSR)/1000-0.5);
			end
		end
		anno.duration = anno.stop - anno.start;
		anno.overlapCase=0;
		anno.overlapSeconds=anno.duration;
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
	fprintf('if you intended to use the timeseries support (you can ignore this warning otherwise):\n -- note that working with serveral files _and_ linked files is not yet supported\n -- ignoring linked files if there are any \n');
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
						% a 'continue' is not nice but still nicer than to throw an error
						% since you can still work with your eaf even if the
						% linkedFile is not present and you don't want to edit the
						% linked_files_section
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
					anno.startTSR = NaN; %this annotation does not exist in the .eaf file
					anno.stopTSR = NaN;
					anno.start = partdata(negative(l),1)/tscorrection;
					anno.stop = partdata(positive(l),1)/tscorrection;
					anno.value = num2str(l);
					anno.duration = anno.stop - anno.start;
					anno.overlapCase = 0;
					anno.overlapSeconds = anno.duration;
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

%% create tier 'AnnotationValid' (see elanSlice)
if (~isfield(elan.tiers,'AnnotationValid'))
	elan.tiers.AnnotationValid=[];
end;
anno.startTSR = NaN; %this annotation does not exist in the .eaf file
anno.stopTSR = NaN;
anno.start = minStart;
anno.stop = maxStop;
anno.duration = maxStop - minStart;
[~, anno.value] = fileparts(fn);
anno.overlapCase = 0;
anno.overlapSeconds = anno.duration;
% when using slicing methods AnnotationValid is also sliced and is, thus, showing the 
% sliced region(s)
elan.tiers.AnnotationValid = [elan.tiers.AnnotationValid anno];
% when using slicing methods ElanFile is not sliced and is, thus, showing the length
% of the original elan file (particularly useful if you use more than one elan file at once)
elan.tiers.ElanFile = elan.tiers.AnnotationValid; %copy 'AnnotationValid' to 'ElanFile'


%%========================================================================
%% %%%%%% private functions

%% private: specialWiiMilesTreatment (ONLY called for special Bielefeld wii or miles csv data!)
% note: this function should only be used in our special case, not in yours!
function [elan,csvdata] = specialWiiMilesTreatment(elan,csvdata,type_associated,fname,loadname,csv_origin)
% if there is another associated file 'miles': load this too
% if the type of the data is wii (not miles)
if (strcmp(type_associated,'wii'))
	% correct the wii data (ignore outlier)
	csvdata = cutOutlier(csvdata);
	
	
	% load the additional miles data and save it to elan struct
	otherloadname = regexprep(loadname,'wii','miles');
	fprintf('reading associated miles file "%s"\n',otherloadname);
	milesdata = elanReadLinkedCSV(otherloadname);
	if (~isempty(csv_origin))
		% recalculate these timestamps
		% Todo: is this correct?
		milesdata(:,1) = milesdata(:,1)-csv_origin;
		milesdata = milesdata(milesdata(:,1)>=0,:);
	end%if
	% downscale milesdata
	%milesdata = milesdata(1:5:end,:);
	% save data into struct
	elan.linkedFiles.merged_mt9_data.data = milesdata;
	elan.linkedFiles.merged_mt9_data.type = 'mt9';
	elan.linkedFiles.merged_mt9_data.tsunit = 'ms';
	elan.linkedFiles.merged_mt9_data.name = regexprep(fname,'wii','miles');
end%if


%% private: loadBaseTimestamp   (ONLY called for special Bielefeld wii or miles csv data!)
function [ismerged, type_associated, eafbaseTS] = loadBaseTimestamp(eafname,eafbaseTS)
% split filename of input file in strings delimited by '-'
[~, tok] = regexp(eafname, '-', 'match','split');
if (length(tok)>=3)
	% test if the tokens are of a set of associated experiment files with
	% equal stem names (e.g. stem = "20100817_1405_20_log"+"-merged-miles.eaf")
	if (strcmp(tok(end-1),'merged') && (any(strfind(tok{end},'miles'))||any(strfind(tok{end},'wii'))))
		baseTSfname = strcat(tok(1),'-basetime.txt');
		ismerged = 1;
		try
			% load base timestamp from external file
			eafbaseTS = load (char(baseTSfname));
			fprintf('reading base timestamp from file "%s"\n', char(baseTSfname));
		catch
			try
				baseTSfname = strcat(argfilepath,baseTSfname);
				eafbaseTS = load (char(baseTSfname));
				fprintf('reading base timestamp from file "%s"\n', char(baseTSfname));
			catch
				% if neither of this worked ignore basetimestamp
			end%try
		end%try
		if (any(strfind(tok{end},'wii')))
			% load merged miles file as well
			type_associated = 'wii';
		else
			type_associated = 'mt9';
		end%if
	else
		type_associated = 'NaN';
		ismerged = NaN;
		eafbaseTS = NaN;
	end%if
else
	type_associated = 'NaN';
	ismerged = NaN;
	eafbaseTS = NaN;
end%if


%% private: cutOutlier     (ONLY called for special Bielefeld wii or miles csv data!)
function csvdata = cutOutlier(csvdata)
dcsvdata = diff(csvdata(:,[2:end]));
dcsvdata = [csvdata(:,1),[zeros(1,size(dcsvdata,2));dcsvdata]];

plotting = false;
for col = 2:size(csvdata,2)
	
	% one
	outlier_d = find (abs(dcsvdata(:,col))>0.03);%vector of row numbers of outliers
	length(outlier_d);
	if (~isempty(outlier_d))
		count = 0;
		radius = 5;
		for out = 1:length(outlier_d)
			
			% test if outlier_d is in the beginning or at the end of csvdata
			if (outlier_d(out)>radius && outlier_d(out)<length(csvdata)-radius)
				
				% test if outlier_d is at the end of outliers-vector (then it must be outlier
				% not gesture since gestures last longer (since their gradient is smaller))
				if (length(outlier_d) < out+radius)
					% interpolate outlier
					tmp = outlier_d(out); % row number of outlier in csvdata
					csvdata([tmp-1;tmp;tmp+1],col) = interp1(csvdata([tmp-2;tmp+2],1), csvdata([tmp-2;tmp+2],col), csvdata([tmp-1;tmp;tmp+1],1));
					
					% test if outlier is really outlier (not a gesture which lasts longer)
				elseif (outlier_d(out+radius) ~= outlier_d(out)+radius)
					% interpolate outlier
					tmp = outlier_d(out);
					
					if plotting == true
						try
							% for plotting
							blub = csvdata([tmp-(radius+5):tmp+(radius+5)],col);
							dblub = dcsvdata(tmp-(radius+5):tmp+(radius+5),col);
						catch
						end
					end%if
					
					csvdata([tmp-(radius-1):tmp+(radius-1)],col) = interp1(csvdata([tmp-radius;tmp+radius],1), csvdata([tmp-radius;tmp+radius],col), csvdata([tmp-(radius-1):tmp+(radius-1)],1));
					
					if plotting == true
						try
							%figure(1);plot( csvdata(tmp-(radius):tmp+(radius),1) ,[csvdata((tmp-2:tmp+2),col),blub],':o')
							plot( csvdata(tmp-(radius+5):tmp+(radius+5),1) ,[csvdata(tmp-(radius+5):tmp+(radius+5),col), blub , dblub],':o')
							axis([ -inf inf -0.5 0.5])
							pause(1)
						catch
						end
					end%if
				else
					count = count+1;
				end%if
			end%if
		end%for
	end%if
end%for



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
