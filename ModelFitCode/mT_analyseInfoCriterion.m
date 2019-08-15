function [ResultsTable, baselinedCrit] = mT_analyseInfoCriterion(infoCrit)
% Takes information criterion values in (numModels)x(numParticipants) array and 
% produces a table containing the mean info criterion, confidence intervals
% from an ANOVA, and num participants with the smallest value of the criterion. 

% OUTPUT
% ResultsTable: Various results
% baselinedCrit: The information criterion with the (overall) best fitting model
% subtracted off

% Joshua Calder-Travis, j.calder.travis@gmail.com

% Enumerate model numbers
modelNums = [1 : size(infoCrit, 1)]';


% Aggregate infoCrit
[baselineMean, baselineModel] = min(nanmean(infoCrit, 2));
baselinedCrit = infoCrit - infoCrit(baselineModel, :);

meanInfoCrit = nanmean(baselinedCrit, 2);

% Defensive programming
if meanInfoCrit ~= (nanmean(infoCrit, 2) - baselineMean)
    error('bug')
end


% Confidence intervals around agregate
meanCI = NaN(size(infoCrit, 1), 2);

for iModel = 1 : size(infoCrit, 1)
    
    % There are no error bars around the baseline model as all values for the
    % baseline model are zero
    if iModel == baselineModel; continue; end
    
    critVals = baselinedCrit(iModel, :)';
    
    meanCI(iModel, :) = bootci(10000, @(vals) nanmean(vals), critVals);
    
end

errorAbove = meanCI(:, 2) - meanInfoCrit;
errorBelow = meanCI(:, 1) - meanInfoCrit;

% Defensive programming
if any(meanCI(:, 2) < meanCI(:, 1)); error('Different ordering assumed.'); end
if any(errorBelow > 0); error('bug'); end

% Switch sign ready for MATLAB error bar function
errorBelow = abs(errorBelow); 


% Number of participants best fit by the model
infoCritWithNoNans = infoCrit;
infoCritWithNoNans(:, all(isnan(infoCrit), 1)) = [];


% Defensive programming
if any(isnan(infoCritWithNoNans)); error('Bug'); end


% For a particular partipant the best fitting model will have the lowest
% information criterion
[~, bestFit] = min(infoCritWithNoNans); 


numBestFit = NaN(length(modelNums), 1);


for iModel = modelNums'
    
    numBestFit(iModel) = nansum(bestFit == iModel);
    
    
end


ResultsTable = table(modelNums, meanInfoCrit, errorAbove, errorBelow, numBestFit);


%% Conduct within-sibjects ANOVA on the BIC and AIC values

% repeatedMeasures = array2table(infoCritWithNoNans');
% 
% 
% varNames = repeatedMeasures.Properties.VariableNames;
% 
% 
% rmModel = fitrm(repeatedMeasures, [varNames{1} '-' varNames{end} ' ~ 1']);
% 
% 
% rmResults = ranova(rmModel);
% 
% 
% if height(rmModel.WithinDesign) > 1
%     
%     multcompare(rmModel, 'Time', 'ComparisonType', 'bonferroni');
%     
%     multcompare(rmModel, 'Time', 'ComparisonType', 'tukey-kramer');
%     
%     multcompare(rmModel, 'Time', 'ComparisonType', 'lsd');
%     
%     
% end

