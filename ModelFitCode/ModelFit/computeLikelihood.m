function trialLogLikelihood = computeLikelihood(model, ~, paramStruct, Data, DataSetSpec)

paramStruct.thresh = sort(paramStruct.thresh);
paramStruct.thresh = [0; paramStruct.thresh ;1];


%setting thresholds  
threshold1 = paramStruct.thresh(Data.binnedConfidence,1);
threshold2 = paramStruct.thresh((Data.binnedConfidence + 1), 1);


%setting model based decision rules, 0 = bayes, 1=rule based.
decisionRule = NaN(length(Data.Orientation), 1); 
oneGaborTrials = Data.numGabors == 1;
   
if strcmp(model, 'normativeGenerative')
    decisionRule(:) = 0;
    decisionRule(oneGaborTrials) = 1;
    
elseif strcmp(model, 'normativeGenerativeAlways')
    decisionRule(:) = 0;
    
elseif strcmp(model, 'alternativeGenerative')
    decisionRule(:) = 1;
    decisionRule(oneGaborTrials) = 0;
    
elseif strcmp(model, 'alternativeGenerativeAlways')
    decisionRule(:) = 1;
    
end

 
            
%converitng thresholds of probability into values of measurement X

convertedThreshold1 = NaN(length(Data.Orientation), 1);
convertedThreshold2 = NaN(length(Data.Orientation),1); 
thresholdArea = NaN(length(Data.Orientation),1);
sigma_S = sqrt(1/Data.KappaS);
 
 % if real data make sure have subtracted off pi to centre on zero 
 

 %set variance row of interest based on contrast level
 indexOfInterest = NaN(length(Data.Orientation), 1);
 contrasts = [0.1, 0.2, 0.3, 0.4, 0.8];
 
 for iLevel = 1 : length(contrasts)
     indexOfInterest(Data.ContrastLevel == contrasts(iLevel)) = iLevel;
 end
    
 
 %set variance column of interest based on model type
 columnOfInterest = ones(length(Data.Orientation), 1);
 columnOfInterest(Data.BlockType == 1) = 2;
 
 
% Convert from substripts for paramStruct.Varance to linear indeces
varLinIndex = sub2ind([size(paramStruct.Variance)], indexOfInterest, columnOfInterest);
trialMeasVariance = paramStruct.Variance(varLinIndex);
 
convertedThreshold1 = ...
    convertThreshold (DataSetSpec.Mu, ...
    trialMeasVariance, ...
    Data.Decision, ...
    threshold1, sigma_S, decisionRule);

convertedThreshold2 = ...
    convertThreshold (DataSetSpec.Mu, ...
    trialMeasVariance, ...
    Data.Decision, ...
    threshold2, sigma_S, decisionRule);

     
% On trials in which the response was for C=1, the converted thresholds will now be ordered
% incorrectly, as coversion has the effect of re-ordering the thresholds in the oposite
% direction. Correct this now
toSwitch = Data.Decision == 0;
    
upperThresh = convertedThreshold1(toSwitch);
lowerThresh = convertedThreshold2(toSwitch);

convertedThreshold1(toSwitch) = lowerThresh;
convertedThreshold2(toSwitch) = upperThresh;


thresholdArea = (normcdf(convertedThreshold2, Data.Orientation, sqrt(trialMeasVariance)))...
    - (normcdf(convertedThreshold1, Data.Orientation, sqrt(trialMeasVariance)));


probConfidence = ((1 - paramStruct.Lapse).*thresholdArea)+((paramStruct.Lapse).*(1/DataSetSpec.binNum));

if any (probConfidence >1 | probConfidence < 0)
    error ('probability out of range - check yourself')
end

trialLogLikelihood = log(probConfidence);       
        
    
   
             
end
    