function DataSet = simulateConfUsingLikelihood(DataSet, model)

% ParamStruct.Variance = ([1, 1.25, 1.5, 1.75, 2;
%             1.1, 1.35, 1.6, 1.85, 2.1]');
% 
% ParamStruct.thresh = [0.5046 0.5093 0.5148 0.5214 0.5303 0.5449 0.5761 0.6205 0.6807]';
% %[0.5000 0.5025 0.5051 0.5080 0.5109 0.5141 0.5178 0.5223 0.5281 0.5373 0.6119]




for iP = 1 : length(DataSet.P)
    
    
    % Find simulation parameters
    ParamStruct.Lapse = 0;
    ParamStruct.Variance = DataSet.P(iP).Data.SigmaX_array.^2;
    ParamStruct.thresh = DataSet.P(iP).Data.breaks';
    
    
    numTrials = length(DataSet.P(iP).Data.Confidence);
    
    % How many confidence bins are there?
    confBins = 10;
    
    
    % For each bin, find the probability of a confidence report in that bin
    probBin = NaN(numTrials, confBins);
    
    
    for iBin = 1 : confBins
        
        HypotheticalData = DataSet.P(iP).Data;
        HypotheticalData.binnedConfidence = repmat(iBin, [numTrials, 1]);
        
        trialLL = computeLikelihood(model, [], ParamStruct, ...
            HypotheticalData, DataSet.Spec);
        
        probBin(:, iBin) = exp(trialLL);
        
    end
    
    % Now draw confidence reports according to their probability
    cumulativeProb = cumsum(probBin, 2);
    
    tol = 10^(-5);
    if ~all((cumulativeProb(:, end) > (1-tol)) & ...
            (cumulativeProb(:, end) < (1+tol)))
        
        problems = ~((cumulativeProb(:, end) > (1-tol)) & ...
            (cumulativeProb(:, end) < (1+tol)))
        
        error('Bug')
    end
    
    cumulativeProb = [zeros(numTrials, 1), cumulativeProb(:, 1:(end-1))];
    
    drawnBin = rand(numTrials, 1) > cumulativeProb;
    DataSet.P(iP).Data.SimConf = sum(drawnBin, 2);

end