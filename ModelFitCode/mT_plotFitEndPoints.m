function numSuccess = mT_plotFitEndPoints(DSet, individualPlots, varargin)
% Plot the final LL produced from all the start points for all the models, on a
% seperate figure for each participant. Also find the sucess rate of fits, where
% a success is ending within tol LLs of the best fit. Plot as participant by 
% model heat map.

% INPUT
% individualPlots: If true, a plot for each participant is produced with more
% detail
% varargin: A participant number, if just want to plot one participant, or row
% vector of particpant numbers.

% Joshua Calder-Travis, j.calder.travis@gmail.com

% How many LLs away from the best fit will we count as sucesses?
tol = 1;

if isempty(varargin)
    toPlot = 1 : length(DSet.P);
else
    toPlot = varargin{1};
end

numPtpnts = length(toPlot);
numModels = length(DSet.P(1).Models);
numSuccess = NaN(numPtpnts, numModels);
numFits = NaN(numPtpnts, numModels);
successRate = NaN(numPtpnts, numModels);
restartsRequired = NaN(numPtpnts, numModels);

for iPlot = 1 : length(toPlot)
    iP = toPlot(iPlot);
    
    if individualPlots
        figure
        hold on
    end
    
    for iM = 1 : length(DSet.P(iP).Models)
        
        fittedLLs = mT_stackData(DSet.P(iP).Models(iM).Fits, @(struct) struct.LL);
        
        
        if individualPlots
            scatter(fittedLLs, ones(size(fittedLLs)) * iM)
        end

        
        restartsRequired(iP, iM) = findMinRequiredSample(fittedLLs);
        

        % How many of the fits ended close to the best fit?
        baseline = max(fittedLLs);
        baselinedLLs = fittedLLs - baseline;
        
        numSuccess(iPlot, iM) = sum(baselinedLLs > -tol);
        numFits(iPlot, iM) = length(baselinedLLs);
        successRate(iPlot, iM) = numSuccess(iPlot, iM)/numFits(iPlot, iM);
        
        if any(isnan(baselinedLLs))
            error('Assume all fits reuslt in a numeric LL')
        end
        
    end
    
    xlabel('Final LL from start point')
    ylabel('Model number')
    ylim([0, iM+1])
    
end

% Success rate heat map
figure
heatmap(numSuccess)
title('numSuccess')

figure
heatmap(numFits)
title('numFits')

figure
heatmap(successRate)
title('Success rate')

figure
heatmap(restartsRequired)
title('Estimated number of starts required')

end


function restartsRequired = findMinRequiredSample(fittedLLs)
% Perform analysis from Acerbi (2018,
% https://doi.org/10.1371/journal.pcbi.1006110) supplimentary material,
% end of section 4.2
globalOptBestEst = max(fittedLLs);

% For 1 to length(fittedLLs) starts, calculate via bootstrap, the
% probability of a regret smaller than 1. Where regret is difference
% between best fit in the sample, and our best estimate of max LL.
probGoodEst = NaN(length(fittedLLs), 1);

for iSampleSize = 1 : length(fittedLLs)
    
    nSims = 10000;
    
    simulatedFittedLLs = NaN(nSims, iSampleSize);
    
    % Draw a random sample
    drawIdx = randsample(length(fittedLLs), nSims * iSampleSize, true);
    simulatedFittedLLs(:) = fittedLLs(drawIdx);
    
    regret = globalOptBestEst - max(simulatedFittedLLs, [], 2);
    
    % What is the probability of having a regret smaller than 1?
    probGoodEst(iSampleSize) = mean(regret < 1);
    
end

% Are any probabilities of a good estiamtion greater than 0.99?
lim = 0.99;

if ~(any(probGoodEst > lim))
    restartsRequired = Inf;
else
    % If so, what sample size do we need for this
    successSampleSizes = probGoodEst > lim;
    successSampleSizes = find(successSampleSizes);
    restartsRequired = successSampleSizes(1);
    
    % Do all samples sizes above this achieve at least the same level of
    % success?
    if any(diff(successSampleSizes) ~= 1)
        warning('A greater sample size did not achive the same success rate')
    end
    
end

end
        