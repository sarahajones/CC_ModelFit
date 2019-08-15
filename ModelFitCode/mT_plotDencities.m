function xLimits = mT_plotDencities(Data, findVar, findIncTrials, ...
    findCorrect, estimate)
% Plot the dencities of the requested variables


% INPUT
% Data          DSet.P(i).Data
% findVar       Function handle. The function outputs a vector of the variable 
%               of interest when DSet.P(i).Data is provided as input.
% findIncTrials Function handle. The function outputs a locigal vector as long
%               as the dataset specifying which trials to include when passed 
%               DSet.P(i).Data.
% findCorrect   Function handle. The function outputs a locigal vector as long
%               as the dataset specifying which trials resulted in "correct" responses 
%               when passed DSet.P(i).Data.
% estimate      Kernel density ('kernel') or a histogram ('hist')

% Joshua Calder-Travis, j.calder.travis@gmail.com

figure; hold on

% Collect info
incTrials = findIncTrials(Data);
relData = findVar(Data);

minVal = min(relData(incTrials));
maxVal = max(relData(incTrials));


% Find the number of correct and error responses. To use when scaling the
% correct and error densities later.
correctTrials = findCorrect(Data);

numCorrect = sum(correctTrials(incTrials) == 1);
numError = sum(correctTrials(incTrials) == 0);

scaling{2} = numCorrect / (numCorrect + numError);
scaling{1} = numError / (numCorrect + numError);


% Plot seperately for correct and errors
accCurveColours = {'r', 'g'};

for acc = [1 0]
    
    currentTrials = (correctTrials == acc) & incTrials;
    
    
    if strcmp(estimate, 'kernel')
        
        % Find kernal densitiy estimates for the full range of data
        evalLocations = linspace(minVal, maxVal);
        
        
        densityEst{acc + 1} = ksdensity(relData(currentTrials), ...
            evalLocations, 'Bandwidth', (maxVal-minVal)/40);
        
        
        disp('No boundary correction applied')
        
        
        % Scale this density estimate so that the correct and error
        % densities sum to 1 together
        densityEst{acc +1} = densityEst{acc +1} * scaling{acc +1};
        
        
        % Plot...
        plot(evalLocations, densityEst{acc + 1}, ...
            accCurveColours{acc +1})
        
        ylabel('Prob density');
        
        
    elseif strcmp(estimate, 'hist')
        
        % Instead of an estimate for the density just plot a simple
        % histogram in the left figure
        Hist = histogram(relData(currentTrials), 'Normalization', 'countdensity');
        %         'BinWidth', 1);
        
        Hist.FaceColor = accCurveColours{acc +1};
        ylabel('Num responses');
        
        
    else
        
        error('Incorrect use of input arguments')
        
        
    end
    
    
    % For use later
    xLimits = xlim;
    
    
end

