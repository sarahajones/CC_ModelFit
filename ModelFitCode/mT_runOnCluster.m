function mT_runOnCluster(jobDirectory, jobFile, varargin)
% Loads and runs the jobs in jobFile. All relevant MATLAB scripts should be in 
% the folder directory/scripts or a subfolder of this directory

% NOTE
% The phrase 'job' should not appear anywhere in the directory of the job
% file, except in the filename itself. Otherwise an error is tirggered.

% INPUT
% varargin: If set to 'debug', MATLAB does not quit on error, and does not
% attempt to set up a parpool. If set to a string other than debug, matlab will
% use this directory as its temporary directory for parpool data.

% Joshua Calder-Travis, j.calder.travis@gmail.com

% Quit matlab if job fails
try
    
if ~isempty(varargin) && strcmp(varargin{1}, 'debug')
    inDebugMode = true;
elseif ~isempty(varargin)
    inDebugMode = false;
    parpoolTempDir = varargin{1};
else
    inDebugMode = false;
end

disp(inDebugMode)

% Load data
warning('off','all') % Hide warnings whilst lots of lost function handles load
LoadedVars = load(jobFile);
warning('on','all')

JobContainer = LoadedVars.JobContainer;


% Add path to scripts
addpath(genpath([jobDirectory '/scripts']))
addpath([jobDirectory '/bads-master']) % In case we are using bads


% How many jobs have we been assigned? If >1 use parrallel computing
numJobs = sum(~isnan(JobContainer.JobSubID));

if (numJobs > 1) && ~inDebugMode
    % Setup parrallel workers
    clusterObj = parcluster('local');
    clusterObj.JobStorageLocation = parpoolTempDir;
    
    PoolObj = parpool(clusterObj, [1, 128]);

end


% Collect required info
funNames = JobContainer.FunName;
ptpntData = JobContainer.PtpntData;
dsetSpec = JobContainer.DSetSpec;
settings = JobContainer.Settings;
setupVals = JobContainer.SetupVals;
saveFile = cell(numJobs, 1);

% Work out where we are on the current system, and replace the old schedule
% folder in the file paths for ptpntData, DSetSpec, and settings with the
% current one. Specify where to save result of analysis.
jobDirString = convertCharsToStrings(jobDirectory);

for iJob = 1 : numJobs

    saveFile{iJob} = [jobFile(1 : end-7), ...
        num2str(JobContainer.JobSubID(iJob)) '_result'];
	
     ptpntData{iJob} = strcat(jobDirString, '/', ptpntData{iJob});

end


% Run the jobs
AllResults = cell(numJobs, 1);

if (numJobs > 1) && ~inDebugMode
    parfor iJob = 1 : numJobs
        
        AllResults{iJob} = feval(funNames{iJob}, ptpntData{iJob}, ...
            dsetSpec{iJob}, settings{iJob}, setupVals{iJob});
        
    end
    
else
    for iJob = 1 : numJobs
        
        AllResults{iJob} = feval(funNames{iJob}, ptpntData{iJob}, ...
            dsetSpec{iJob}, settings{iJob}, setupVals{iJob});
        
    end
    
end

% Save reuslts. Name the container after the first result
AllResults = mT_removeFunctionHandles(AllResults, {'FindSampleSize', 'FindIncludedTrials'});
save(strcat(saveFile{1}, '_PACKED'), 'AllResults', 'saveFile')

% for iJob = 1 : numJobs
%     Result = AllResults{iJob};
%     save(saveFile{iJob}, 'Result')
% end


% Shutdown
rmpath(genpath([jobDirectory '/scripts']))
rmpath([jobDirectory '/bads-master'])
if (numJobs > 1) && ~inDebugMode; delete(PoolObj); end


% Quit unless in debug mode
if ~inDebugMode
	disp('Exiting normally')
    exit
end


catch erMsg
    disp(erMsg)
    for i = 1 : length(erMsg.stack)
        disp(erMsg.stack(i))
    end
    
    % Quit unless in debug mode
    if ~inDebugMode
	disp('Exiting after crash')
        exit
    end

end

disp('Failed to exit')


end


