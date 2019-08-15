function DSet = mT_scheduleFits(mode, DSet, Settings, scheduleFolder)

% INPUT
% mode          'cluster', schedule for the cluster, or 'local' runs
%               straight away
% DSet          Should follow the standard data format. See repo README.
% Settings      See documentation for 'mT_fitndMaximumLikelihood'. If Settings
%               is an array of such structures, a fit is scheduled for each
%               strcuture. (One structure describes one model.)
% scheduleFolder    
%               Optional; used in 'cluster' mode. Specifies the folder in
%               which to store schedued jobs.

% OUTPUT
% DSet      Results of modelling are stored in DSet.P(i).Models, unless this 
%           already exists, in which case 'Models' becomes a strct array and 
%           the current results are placed in the first free space.

% Joshua Calder-Travis, j.calder.travis@gmail.com

jobsPerContainer = Settings.JobsPerContainer;


for iSet = 1 : length(Settings)
    if strcmp(mode, 'cluster') ...
            && (~isfield(Settings(iSet), 'ReseedRng') ...
            || ~Settings(iSet).ReseedRng)
        
        error(['Rng shuffle not selected by jobs sent to cluster. ', ...
            'Cluster may use same random seed repeatedly.'])
        
    end
end


% Work out where we will store the results of the modelling? This depends
% of how many different models have been applied previously.
if ~isfield(DSet.P(1), 'Models'); prevModels = 0;
else; prevModels = length(DSet.P(1).Models); end


% Check that all participants have had the same number of models applied
if isfield(DSet.P(1), 'Models') && ...
        (length(unique(arrayfun( @(struct) length(struct.Models), DSet.P))) ~= 1)
    error('Bug')
end


% If we will be running on the cluster we need to store the requested
% function runs for later execution.
if strcmp(mode, 'cluster')
    
    funNum = 1;
    jobContainerCount = 1;
    JobContainer = generateJobContainer(jobsPerContainer, jobContainerCount, ...
        scheduleFolder);

end


% Save participant data for later use
PtpntDataSaveDir = cell(length(DSet.P), 1);

if strcmp(mode, 'cluster')
    for iPtpnt = 1 : length(DSet.P)
        PtpntData = DSet.P(iPtpnt).Data;
        PtpntDataSaveDir{iPtpnt} = tempname(scheduleFolder);
        PtpntData = mT_removeFunctionHandles(PtpntData, ...
            {'FindSampleSize', 'FindIncludedTrials'});
        save(PtpntDataSaveDir{iPtpnt}, 'PtpntData')
    end
end


for iModel = 1 : length(Settings)
    
    TheseSettings = Settings(iModel);
    
    for iPtpnt = 1 : length(DSet.P)
        
        % Store the settings used for modelling below
        DSet.P(iPtpnt).Models(prevModels + iModel).Settings = TheseSettings;
        
        BoundaryVals = mT_setUpParamVals(TheseSettings);
        BoundaryVals = rmfield(BoundaryVals, 'InitialVals');
        DSet.P(iPtpnt).Models(prevModels + iModel).Settings.ParamBounds ...
            = BoundaryVals;
        
        
        % If requested in 'TheseSettings', run the minimisation several times from
        % different start points.
        for iStartPoint = 1 : TheseSettings.NumStartPoints
            
            % Draw parameter start points, and set parameter bounds. If a search
            % through initial random candidates for the best start point 
            % has been requested,
            % set this up.
            SetupVals = cell(TheseSettings.NumStartCand, 1);
            
            for iStartCand = 1 : TheseSettings.NumStartCand
                SetupVals{iStartCand} = mT_setUpParamVals(TheseSettings);
            end
            
            disp('One start point set up')
            
            DSetSpec = DSet.Spec;
            
            if strcmp(mode, 'local')
                % If we are on the local machine we wont have saved the participant
                % data for later loading, instead we need to find it now.
                PtpntData = DSet.P(iPtpnt).Data;
            end
            
            if strcmp(mode, 'local')
                
                DSet.P(iPtpnt).Models(prevModels + iModel).Fits(iStartPoint) ...
                    = mT_findMaximumLikelihood(PtpntData, DSetSpec, ...
                    TheseSettings, SetupVals);
                
            elseif strcmp(mode, 'cluster')
                
                JobContainer.JobSubID(funNum) = funNum;
                
                JobContainer.FunName{funNum} = 'mT_findMaximumLikelihood';
                
                % Save the filenames of relevant files as strings
                PtpntDataSaveDir{iPtpnt} = convertCharsToStrings(PtpntDataSaveDir{iPtpnt});
                [~, PtpntDataSaveFile, ~] = fileparts(PtpntDataSaveDir{iPtpnt});
                
                JobContainer.PtpntData{funNum} = PtpntDataSaveFile;
                JobContainer.DSetSpec{funNum} = DSetSpec;
                JobContainer.Settings{funNum} = TheseSettings;
                JobContainer.SetupVals{funNum} = SetupVals;
                
                
                % Store the ID number in the corresponding location in DSet
                DSet.P(iPtpnt).Models(prevModels + iModel).Fits(iStartPoint).JobContainerID ...
                    = JobContainer.ID;
                DSet.P(iPtpnt).Models(prevModels + iModel).Fits(iStartPoint).JobSubID ...
                    = JobContainer.JobSubID(funNum);
                
                
                funNum = funNum +1;
                
                
                % Have we filled the job container?
                if funNum > jobsPerContainer
                    
                    % Save the JobContainer ready for execution later
                    JobContainer = mT_removeFunctionHandles(JobContainer, ...
                        {'FindSampleSize', 'FindIncludedTrials'});
                    save(JobContainer.SaveDir, 'JobContainer')
                    
                    % Set up a new job container
                    funNum = 1;
                    jobContainerCount = jobContainerCount +1;
                    JobContainer = generateJobContainer(jobsPerContainer, ...
                        jobContainerCount, ...
                        scheduleFolder);
                    
                end
                
            end
            
        end
        
    end
    
end

% Save the final job container
if strcmp(mode, 'cluster') && ~(funNum == 1)
    JobContainer = mT_removeFunctionHandles(JobContainer, ...
        {'FindSampleSize', 'FindIncludedTrials'});
    save(JobContainer.SaveDir, 'JobContainer')
end


% If we are running in local mode then during the execution of this script
% we will have already fit all models, so we can do some extra analysis
% with these results, and find the best fit resulting from any start point.
if strcmp(mode, 'local') 
    DSet = mT_findBestFit(DSet);
    
end


% If we are running in cluster mode save DSet, as this now contains job IDs
% which link to the scheduled jobs.
if strcmp(mode, 'cluster') 
    
    now = string(datetime);
    now = now{1};
    now([3, 7, 15, 18]) = [];
    
    tic
    DSet = mT_removeFunctionHandles(DSet, {'FindSampleSize', 'FindIncludedTrials'});
    save([scheduleFolder '/_' now '_DataStruct'], 'DSet')
    diff = toc;
    
    % If saving the files has been particularly quick, wait 1 second to ensure
    % that if this function is called again immediately, no JobContainers will
    % be given the same name as an existing one (these are based on the time in
    % seconds).
    if diff < 1; pause(1); end
    
end

end


function JobContainer = generateJobContainer(jobsPerContainer, ...
    jobContainerCount, scheduleFolder)
% Generate a strcuture to store requested jobs

% Generate a job ID number 
now = string(datetime);
now = now{1};
now([3, 7, 15, 18]) = [];
now(10)='_';

jobContrainerID = [now '_' num2str(jobContainerCount)];

JobContainer.ID = jobContrainerID;

% Where will we save the job container later?
JobContainer.SaveDir = [scheduleFolder '/' JobContainer.ID '_job.mat'];

% Check this file doesn't already exist
if isfile(JobContainer.SaveDir)
    error('bug')
end

% Initialise
JobContainer.JobSubID  = NaN(jobsPerContainer, 1);


end

    
    
    