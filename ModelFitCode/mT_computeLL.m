function LL = mT_computeLL(Settings, PtpntData, DSetSpec, paramVector)
% Computes the loglikelihood for a participant

% Joshua Calder-Travis, j.calder.travis@gmail.com


if ~Settings.SuppressOutput
    tic
end

% % If the matlab genetic algorith ('ga') is being used for fitting then
% % paramVector will be passed as a row vector. Convert to column.
% if length(size(paramVector))>2 || ~any(size(paramVector)==1); error('Bug'); end
% 
% vecShape = size(paramVector);
% 
% if vecShape(1) == 1; paramVector = paramVector'; end


if ischar(Settings.FindSampleSize)
    findSampleSize = str2func(Settings.FindSampleSize);
    sampleSize = findSampleSize(PtpntData);
else
    sampleSize = Settings.FindSampleSize(PtpntData);
end

% Unpack the parameter vector
ParamStruct = mT_packUnpackParams('unpack', Settings, paramVector);


% Initialise
trialLLs = NaN(sampleSize, 1);


% Are we going to chunk the trials?
if ~strcmp(Settings.TrialChunkSize, 'off')
    
    % Code is vectorised to compute likelihood for several trials (a 'chunk')
    % at once.
    for iChunk = 1 : ceil(sampleSize/Settings.TrialChunkSize)
        
        % Which trials are in this chunk
        chunkTrials = (1 + ((iChunk-1) * Settings.TrialChunkSize)) : ...
            (Settings.TrialChunkSize * iChunk);
        
        
        % In the final chunk we may have fewer than trialChunkSize trials
        chunkTrials(chunkTrials > sampleSize) = [];
        
        
        % Only pass data to computeTrialLL from the current chunk
        fieldList = fieldnames(PtpntData);
        TrimmedData = PtpntData;
        
        for iField = 1 : length(fieldList)
            
            if length(TrimmedData.(fieldList{iField})) == 1
                
                % This is a special field, ignore
                continue
                
            elseif length(TrimmedData.(fieldList{iField})) == sampleSize
                
                % We only want to pass data from trials in the current chunk
                TrimmedData.(fieldList{iField}) = ...
                    TrimmedData.(fieldList{iField})(chunkTrials, :);
                
            else
                
                % Not sure what is going on here!
                error(['If chunking trials the all fields in Data.P(i).Data ', ...
                    'must be vectors of length sample size, or be scalars'])
                
            end
                
        end
            
        % Time to do the actual computations!
        trialLLs(chunkTrials) = feval(Settings.ComputeTrialLL.FunName, ...
            Settings.ComputeTrialLL.Args{:}, ParamStruct, TrimmedData, DSetSpec);
            
    end
    
    
% Otherwsie we are not doing chunking. Just pass all data.
else
    
    % Time to do the actual computations!
    trialLLs = feval(Settings.ComputeTrialLL.FunName, ...
            Settings.ComputeTrialLL.Args{:}, ParamStruct, PtpntData, DSetSpec);
    
end


% Sum the LL, excluding trials if requested
if ischar(Settings.FindIncludedTrials)
    findIncludedTrials = str2func(Settings.FindIncludedTrials);
    includedTrials = findIncludedTrials(PtpntData);
else
    includedTrials = Settings.FindIncludedTrials(PtpntData);
end


% TO DO
% We oten have two copies of FindIndludedTrials. (a) the one above in Settings,
% and the one passed to feval, above that, in Settings.ComputeTrialLL.Args.
% Solution: Always pass find included trials to feval?

if strcmp(includedTrials, 'all')

    LL = sum(trialLLs);
    
else
    
    LL = sum(trialLLs(includedTrials));
   
end

if any(~(trialLLs(includedTrials) <= 0))
    
    error('Bug')
    
end


if ~Settings.SuppressOutput
    disp('1 pass')
    toc
end


if isnan(LL) || LL > 0
    error('Bug')
end


end