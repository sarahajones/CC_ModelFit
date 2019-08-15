function DSet = mT_collectResults(DSet, scheduleFolder, allowMissing, ...
    alreadyUnpacked)
% Collects the results files after analysis on the cluster has completed

% INPUT
% DSet      This should be the dataset saved by 'mT_fitScheduler' which
%           contains job ID's in places in the structure where there is a
%           corresponding result file to be loaded and the reuslts added
%           into DSet.
% scheduleFolder    
%               Specifies the folder in which jobs and job results are 
%               stored.
% allowMissing  (optional; default: False) Does not give up if files are 
%               missing, just issues a warning.
% alreadyUnpacked
%           If the result files have already been unpacked can skip this.

% Joshua Calder-Travis, j.calder.travis@gmail.com

% Defaults
if nargin < 3
    allowMissing = false;
end

if allowMissing
    excludedPtpnts = [];
end
    
if ~alreadyUnpacked
    mT_unpackResultsFiles(scheduleFolder)
end


% Loop through DSet looking for all identifiers
for iPtpnt = 1 : length(DSet.P)
    
    for iModel = 1 : length(DSet.P(iPtpnt).Models)
        
        for iStart = 1 : length(DSet.P(iPtpnt).Models(iModel).Fits)
            
            containerID ...
                = DSet.P(iPtpnt).Models(iModel).Fits(iStart).JobContainerID;
            subID ...
                = DSet.P(iPtpnt).Models(iModel).Fits(iStart).JobSubID;
            
            % Load the associated result file
            fileToLoad = [scheduleFolder ...
                '/' containerID '_' num2str(subID) '_result.mat'];
            
            if ~isfile(fileToLoad)
                
                if ~allowMissing
                    error('bug')
                    
                elseif allowMissing
                    
                    excludedPtpnts(end+1) = iPtpnt;
                    
                    continue 
                    
                end
                
            end
            
            LoadedVars = load(fileToLoad);
            FitResult = LoadedVars.Result;
            
            % Store the reuslts
            mandFields = {'RngSettings', 'InitialVals', 'Params', ...
                'LL', 'SampleSize'};
            optFields = {'InitialCandidates'};
            
            for iField = 1 : length(mandFields)
                
                DSet.P(iPtpnt).Models(iModel).Fits(iStart).(mandFields{iField}) ...
                    = FitResult.(mandFields{iField});
                
            end
            
            for iField = 1 : length(optFields)
                
                if isfield(FitResult, optFields{iField})
                
                    DSet.P(iPtpnt).Models(iModel).Fits(iStart...
                        ).(optFields{iField}) ...
                        = FitResult.(optFields{iField});
                    
                end
                
            end
            
        end
        
    end
    
end

% Exclude participants with missing analysis results
if allowMissing && ~isempty(excludedPtpnts)
    excludedPtpnts = unique(excludedPtpnts);
    DSet.P(excludedPtpnts) = [];
    warning(['Participants EXCLUDED as data not analysed yet: '])
    disp(excludedPtpnts)
end


% Find the best fits resulting from any start point
DSet = mT_findBestFit(DSet);


% Check all paticipants have the same models applied, in the same order
mT_findAppliedModels(DSet)

end



function mT_unpackResultsFiles(directory)
% Searches directory for "packed" results files (ending in _PACKED.mat), and
% unpacks them. This involves saving each element of the cell array AllResults,
% with the corresponding filename in the cell array saveFile.


packedFiles = dir([directory, '/*_PACKED.mat']);

for iFile = 1 : length(packedFiles)

    LoadedFiles = load([directory '/' packedFiles(iFile).name]);
    
    AllResults = LoadedFiles.AllResults;
    saveFile = LoadedFiles.saveFile;
    
    % Need to change the save file paths to have the current directory
    for iSave = 1 : length(saveFile)
        [~, newName, ~] = fileparts(saveFile{iSave});
        saveFile{iSave} = [directory '/' newName];
    end
    
    
    for iJob = 1 : length(AllResults)
        Result = AllResults{iJob};
        Result = mT_removeFunctionHandles(Result, {'FindSampleSize', 'FindIncludedTrials'});
        save(saveFile{iJob}, 'Result')
    end
    
end
    
end            