function resultsTable = analyseParams(paramData)
% Analyse the parameters inferred for a single model. paramData specified in a 
% (numParams)*(numParticipants) array.

% Joshua Calder-Travis, j.calder.travis@gmail.com


avParamVal = NaN(size(paramData, 1), 1);
lowerCI = NaN(size(paramData, 1), 1);
upperCI = NaN(size(paramData, 1), 1);
pValue = NaN(size(paramData, 1), 1);
varience = NaN(size(paramData, 1), 1);
compToPredecis = NaN(size(paramData, 1), 1);


for iParam = 1 : size(paramData, 1)
    
    avParamVal(iParam) = nanmean(paramData(iParam, :));
    
    
    [~, pValue(iParam), CI] = ttest(paramData(iParam, :));
    
    
    lowerCI(iParam) = CI(1);
    upperCI(iParam) = CI(2);
    
    
    varience(iParam) = (nanstd(paramData(iParam, :))^2);
    
    
end


% t-test comparison
% [~, compToPredecis(10)] = ttest2(paramData(9, :), paramData(10, :));

% names = {'thresh1', 'thresh2', 'thresh3', 'thresh4', 'RT', 'RTseg2', 'RTseg3', ...
%     'RTseg4', 'Predecis', 'Pipeline', 'Postdecis', 'Accuracy', ...
%      'timeDiscounting', 'rootTDiscount', ...
%      '1/preResp', 'Rt/preResp', 'preResp/rootRt', 'rootRt/preResp', ...
%      'onlyTDiscount', 'onlyRootTDiscount', 'unit'};
%  
% 
% names = names(1 : size(paramData, 1));

names(1 : size(paramData, 1)) = {'name'};

    
resultsTable = table(names', avParamVal, lowerCI, upperCI, pValue, varience, compToPredecis);