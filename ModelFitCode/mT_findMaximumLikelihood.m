function Result = mT_findMaximumLikelihood(PtpntData, DSetSpec, Settings, ...
    SetupValCandidates)
% Find the maximum likelihood fit (at the participant level) for the the model 
% specified in settings.

% Joshua Calder-Travis, j.calder.travis@gmail.com

% INPUT
% PtpntData     DSet.P(iPtpnt).Data from the standard data structure, or file
%               name to load containting this data in a variable called
%               PtpntData.
% DSetSpec      DSet.Spec from the standard data structure, or file
%               name to load containting this data in a variable called
%               PtpntData
% Settings      Struct with fields, or file
%               name to load containting this data in a variable called
%               PtpntData.
%     Algorithm       Which minimisation algorithm to use ('bads',
%                     'fmincon', or 'ga' for genetic algorithm)
%     ModelName
%     NumParams       Number of free parameters to be fitted
%     ComputeTrialLL  Structure with fields...
%           FunName   Function name specified as a string. (Ensure is on path at
%                     time it is called).
%           Args      Cell array, specifying arguments to pass to FunName. For a 
%                     n long cell array, the cell array specifies the first n
%                     arguments passed to the function 'FunName'. 'FunName'
%                     function is passed three additional arguments... (in order)
%                         ParamStrcut     A structure with a field for every
%                                         parameter (or set of parameters) as
%                                         specified in ParamSets. (See README 
%                                         section 'Note on parameter storage'
%                                         for more detail on the structure.)
%                         DSet.P(i).Data  The data field of one participant from
%                                         a Dataset in the standard format.
%                                         Unless chunk trial size is set to 'off'
%                                         all fields must either contain a 
%                                         vector as long as the number of 
%                                         trials, or be a scalar. Only data from a 
%                                         subset of trials, those trials to be 
%                                         evaluated in the current chunk, are passed.
%                                         ComputeTrialLL should not act on this
%                                         in put if possible, in order to
%                                         prevent Matlab from having to make a
%                                         copy in memory of it.
%                         DSet.Spec       See 'Standard data format' in README.
%                     The 'FunName' function should return a vector of log-likelihoods,
%                     one for every trial passed in TrimmedData.
%     ParamSets       Num param sets long strcut array. With fields,
%                         Name
%                         FitLog          (optional) Fit the logarithm of the 
%                                         parameter? If set to true, every time
%                                         the parameters are packed, the
%                                         logarithm of this parameter is taken,
%                                         and everytime they are unpacked, the
%                                         exponential taken. Therefore, the
%                                         liklihood function will still be
%                                         passed ***the plain values***, it is just
%                                         that the fitting algorithm will see
%                                         the logarithm. 
%                         UnpackedShape   What shape array should we use to store the
%                                         params in respective field of 'ParamStruct'.
%                         PackedOrder     Row vector.
%                                         Represents the index of each parameter
%                                         when packed as a single vector. (See 
%                                         notes on parameter storage in README.)
%                         UnpackedOrder   Row vector.
%                                         Represents the linear index of each 
%                                         parameter when unpacked and stored in
%                                         in an array in the relevant field of 
%                                         'ParamStruct'. (See notes on parameter 
%                                         storage.)
%                         InitialVals     See 'UpperBound'
%                         LowerBound      See 'UpperBound'
%                         UpperBound      These three fields should contain a
%                                         function handle. The function
%                                         takes no arguments and returns an array
%                                         of the same shape specified in 
%                                         UnpackedShape.
%                         PLB             Optional
%                         PUB             Optional. PLB and PUB specify 
%                                         plausible upper and lower bounds, and
%                                         should be of the same format as
%                                         UpperBound. Only used when
%                                         Settings.Algorithm is 'bads'.
%     NumStartPoints  How many times to run the maximisation for each participant.
%     NumStartCand    How many candidate points should we draw to determine the
%                     start point. The point with the greatest log-likelihood 
%                     will be used as the start point.
%     TrialChunkSize  How many trials to evaluate the log-likelihood for at the
%                     same time. Data for this many trials is passed to 
%                     Settings.ComputeTrialLL in one go. To pass all data at
%                     once, set to 'off'.
%     FindSampleSize  Function which accepts 'DSet.P(i).Data' and returns the
%                     number of trials for the participant. Note the result will
%                     be used in the calculation of AIC and BIC scores.
%     FindIncludedTrials
%                     Function which accepts 'DSet.P(i).Data' and returns a
%                     *logcial* vector of trials to be included in the LL 
%                     calcuation.
%     FindIfOutOfBounds
%                     If all parameter combinations (within the parameter 
%                     bounds) are permissible this field
%                     should be set to 'none'. Otherwise, should be a function handle.
%                     Function accepts, 'Settings', and 'points', a 
%                     [num points to evaluate x number of parameters] array as
%                     described in BADS documentation for NONBCON. The 
%                     function should return a [num points to evaluate] array, 
%                     where a points which are out of bounds have positive values.
%     SupressOutput   If set to true, information of progress is suppressed. 
%     DebugMode       If set to true, fmincon is the algorithm, and there are 
%                     no 'FindIfOutOfBounds' returns 'none', only a very small
%                     number of search iterations are run in each fit. If set to
%                     true, and particle swarm is the algorithm, plots the fit
%                     as it progresses.
%     ReseedRng       If defined and true, reseeds the random number generator.
%     JobsPerContainer
%                     Only used by mT_scheduleFits to decide how many jobs to
%                     put in each container. This in tern determines how many
%                     jobs are sent to the cluster at a time.
% SetupValsRaw        The output from mT_setUpParamVals, when Settings is
%                     provided as the input,  or file
%                     name to load containting this data in a variable called
%                     SetupVals. Alternatively, can provide a cell array of such
%                     strcutures. The likelihood at each point (one point is
%                     described by one structure) will be evaluated, and the
%                     best one used as the start point for the optimiser.

% OUTPUT
% Result       Results of the fitting.


% Load variables that are saved seperately.
if isstring(PtpntData)
    LoadedVars = load(PtpntData);
    PtpntData = LoadedVars.PtpntData;
end

if isstring(DSetSpec)
    LoadedVars = load(DSetSpec);
    DSetSpec = LoadedVars.DSetSpec;
end

if isstring(Settings)
    LoadedVars = load(Settings);
    Settings = LoadedVars.TheseSettings;
end

if isstring(SetupValCandidates)
    LoadedVars = load(SetupValCandidates);
    SetupValCandidates = LoadedVars.SetupVals;
end


if isfield(Settings, 'ReseedRng') && Settings.ReseedRng
    rng('shuffle')
    Result.RngSettings = rng;
end


% Define the objective function
objectiveFun = @(paramVector) -mT_computeLL(Settings, PtpntData, ...
    DSetSpec, paramVector);


% Are we going to consider a range of candidate start points and pick the best
% one for the optimisation, or just use one?
if iscell(SetupValCandidates) && (length(SetupValCandidates) == 1)
    SetupValsRaw = SetupValCandidates{1};
    
elseif ~iscell(SetupValCandidates)
    SetupValsRaw = SetupValCandidates;

elseif iscell(SetupValCandidates)
   
    % Evaluate the LL at each candidate
    negLL = NaN(length(SetupValCandidates), 1);
    
    for iCand = 1 : length(SetupValCandidates)
        
        % Convert initial params from a strcuture of parameters to a vector
        CandVals = packParamsAndBounds(SetupValCandidates{iCand}, Settings);
        
        negLL(iCand) = objectiveFun(CandVals.InitialVals);
        
        disp(['Start candidate ' num2str(iCand) ' evaluated.'])
        
    end
    
    [~, bestCand] = min(negLL);
    SetupValsRaw = SetupValCandidates{bestCand};
    
end



% Convert initial params from a strcuture of parameters to a vector
SetupVals = packParamsAndBounds(SetupValsRaw, Settings);


% Store the initial parameter values
Result.InitialVals = SetupValsRaw.InitialVals;
Result.InitialCandidates = SetupValCandidates;


% Have we got plausible bounds
if isfield(SetupVals, 'PLB')
    plb = SetupVals.PLB;
    pub = SetupVals.PUB;
else
    plb = [];
    pub = [];
end


% Time to minimise. Are there boundary constriaints?
if strcmp(Settings.FindIfOutOfBounds, 'none')
    
    % Which algorithm to use
    if strcmp(Settings.Algorithm, 'bads')
        
        [fittedParams, negativeLL] = ...
            bads(objectiveFun, SetupVals.InitialVals, ...
            SetupVals.LowerBound, SetupVals.UpperBound, ...
            plb, pub);

    elseif strcmp(Settings.Algorithm, 'anneal')

	[fittedParams, negativeLL] = ...
            simulannealbnd(objectiveFun, SetupVals.InitialVals, ...
            SetupVals.LowerBound, SetupVals.UpperBound);
        
    elseif strcmp(Settings.Algorithm, 'fmincon')
        
        if Settings.DebugMode
            options = optimoptions('fmincon', ...
                'MaxFunctionEvaluations', 3, ...
                'MaxIterations', 3);
            
            
        else
            options = optimoptions('fmincon', ...
                'MaxFunctionEvaluations', 40000, ...
                'MaxIterations', 10000);
            
        end
        
        [fittedParams, negativeLL] = ...
            fmincon(objectiveFun, SetupVals.InitialVals, ...
            [], [], [], [], ...
            SetupVals.LowerBound, ...
            SetupVals.UpperBound, ...
            [], options);
        
        
    elseif strcmp(Settings.Algorithm, 'ga')
        
        if Settings.DebugMode
            options = optimoptions('ga', 'PlotFcn', @gaplotbestf);
        else
            options = optimoptions('ga');
        end
        
        [fittedParams, negativeLL] = ...
            ga(objectiveFun, Settings.NumParams, ...
            [], [], [], [], ...
            SetupVals.LowerBound, ...
            SetupVals.UpperBound, ...
            [], ...
            options);
        
        
    elseif strcmp(Settings.Algorithm, 'simulannealbnd')
        
        if Settings.DebugMode
            options = optimoptions('simulannealbnd','PlotFcns',...
                {@saplotbestx,@saplotbestf,@saplotx,@saplotf});
        else
            options = optimoptions('simulannealbnd');
        end
        
        [fittedParams, negativeLL] = ...
            simulannealbnd(objectiveFun, ...
            SetupVals.InitialVals, ...
            SetupVals.LowerBound, ...
            SetupVals.UpperBound, ...
            options);
        
        
    elseif strcmp(Settings.Algorithm, 'particleswarm')
        
        if Settings.DebugMode
            options = optimoptions('particleswarm', ...
                'PlotFcn',@pswplotbestf);
        else
            options = optimoptions('particleswarm');
        end
        
        [fittedParams, negativeLL] = ...
            particleswarm(objectiveFun, ...
            Settings.NumParams, ...
            SetupVals.LowerBound, ...
            SetupVals.UpperBound, ...
            options);   
        
        
    elseif strcmp(Settings.Algorithm, 'hybrid')
        
        % genetic algorithm followed by fmincon twice
        options = optimoptions('fmincon', ...
                'MaxFunctionEvaluations', 40000, ...
                'MaxIterations', 10000);
            
        [fittedParams, negativeLL] = ...
            ga(objectiveFun, length(SetupVals.InitialVals), ...
            [], [], [], [], ...
            SetupVals.LowerBound, ...
            SetupVals.UpperBound);
        
        Result.IntermediateLL1 = negativeLL;
        Result.InermedParams1 = ...
            mT_packUnpackParams('unpack', Settings, fittedParams);
        
        
        % Star from the result of the last fit
        [fittedParams, negativeLL] = ...
            fmincon(objectiveFun, fittedParams, ...
            [], [], [], [], ...
            SetupVals.LowerBound, ...
            SetupVals.UpperBound, ...
            [], options);
        
        Result.IntermediateLL2 = negativeLL;
        Result.InermedParams2 = ...
            mT_packUnpackParams('unpack', Settings, fittedParams);
        
        
        [fittedParams, negativeLL] = ...
            fmincon(objectiveFun, fittedParams, ...
            [], [], [], [], ...
            SetupVals.LowerBound, ...
            SetupVals.UpperBound, ...
            [], options);
        
    end
    
    
else
    
    
    % Which algorithm to use
    if strcmp(Settings.Algorithm, 'bads')
        
        findIfOutOfBounds = ...
            @(points) Settings.FindIfOutOfBounds(Settings, points);
        
        
        [fittedParams, negativeLL] = ...
            bads(objectiveFun, SetupVals.InitialVals, ...
            SetupVals.LowerBound, SetupVals.UpperBound, ...
            plb, pub, ...
            findIfOutOfBounds);
        
    elseif strcmp(Settings.Algorithm, 'fmincon')
        
        findNonLinearConstraints = ...
            @(points) deal( ...
            Settings.FindIfOutOfBounds(Settings, points), ...
            0);
        
        [fittedParams, negativeLL] = ...
            fmincon(objectiveFun, SetupVals.InitialVals, ...
            [], [], [], [], ...
            SetupVals.LowerBound, ...
            SetupVals.UpperBound, ...
            findNonLinearConstraints);
        
    elseif strcmp(Settings.Algorithm, 'ga') ...
            || strcmp(Settings.Algorithm, 'hybrid')
        
        error('Case not coded up.')
        
    end
    
end


% Defensive programming
if any(isnan(fittedParams)); error(['Bug. Warning: If remove this ' ...
        'calculation of BIC and AIC may be incorrect.']); end

if length(fittedParams) ~= Settings.NumParams; error('Bug'); end


% Store the fitted params and LL
Result.Params = ...
    mT_packUnpackParams('unpack', Settings, fittedParams);

Result.LL = -negativeLL;


% Store some extra info about the fit
Result.SampleSize = Settings.FindSampleSize(PtpntData);

   
% Defensive programming
if sum(Settings.FindIncludedTrials(PtpntData)) ...
        ~= Settings.FindSampleSize(PtpntData)
    error('Bug')
end
    
end


function SetupVals = packParamsAndBounds(SetupValsRaw, Settings)
% Convert initial params from a strcuture of parameters to a vector
specs = {'InitialVals', 'LowerBound', 'PLB', 'UpperBound', 'PUB'};
optionalSpecs = {'PLB', 'PUB'};


for iSpec = 1 : length(specs)
    
    % Some of the specs are optional
    if ismember(specs{iSpec}, optionalSpecs) ...
        && ~(isfield(SetupValsRaw, specs{iSpec}))
        continue
    end
    
    SetupVals.(specs{iSpec}) = ...
        mT_packUnpackParams('pack', Settings, SetupValsRaw.(specs{iSpec}));
    
end

end








