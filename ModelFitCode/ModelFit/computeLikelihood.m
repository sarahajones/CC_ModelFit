function trialLogLikelihood = computeLikelihood(model, ~, paramStruct, Data, DataSetSpec)

paramStruct.thresh = sort(paramStruct.thresh);
paramStruct.thresh = [0; paramStruct.thresh ;1];


%setting thresholds  
threshold1 = paramStruct.thresh(Data.binnedConfidence,1);
threshold2 = paramStruct.thresh((Data.binnedConfidence + 1), 1);


%setting model based decision rules, 0 = bayes, 1=rule based.
decisionRule = NaN(length(Data.Orientation), 1); 
for iTrial = 1:length(Data.Orientation)
    if strcmp(model, 'normativeGenerative')
        if Data.numGabors(iTrial) == 1
            decisionRule(iTrial, 1) = 1;
        else
            decisionRule(iTrial, 1) = 0; 
        end
    elseif strcmp(model, 'normativeGenerativeAlways')
        decisionRule(iTrial,1) = 0;
    
    elseif strcmp(model, 'alternativeGenerative')
          if Data.numGabors(iTrial) == 1
            decisionRule (iTrial, 1) = 0;
        else
            decisionRule(iTrial, 1) = 1; 
          end
    elseif strcmp(model, 'alternativeGenerativeAlways')
        decisionRule(iTrial,1) = 1;
        
    end
end
 
            
%converitng thresholds of probability into values of measurement X

convertedThreshold1 = NaN(length(Data.Orientation), 1);
convertedThreshold2 = NaN(length(Data.Orientation),1); 
thresholdArea = NaN(length(Data.Orientation),1);
sigma_S = sqrt(1/Data.KappaS);
 
 % if real data make sure have subtracted off pi to centre on zero 
 
 
for iTrial = 1: length(Data.Orientation)
     %set variance row of interest based on contrast level
      if Data.ContrastLevel(iTrial) == 0.1
            indexOfInterest = 1;
      elseif Data.ContrastLevel(iTrial) == 0.2
            indexOfInterest = 2;
      elseif Data.ContrastLevel(iTrial) == 0.3
            indexOfInterest = 3;
      elseif Data.ContrastLevel(iTrial) == 0.4
            indexOfInterest = 4;
      elseif Data.ContrastLevel(iTrial) == 0.8
            indexOfInterest = 5;
      end

    %set variance column of interest based on model type
      if Data.BlockType(iTrial) == 0
          columnOfInterest = 1;
      elseif Data.BlockType(iTrial) == 1
          columnOfInterest = 2;
      end
      
      convertedThreshold1(iTrial) = ...
          convertThreshold (DataSetSpec.Mu, ...
          paramStruct.Variance(indexOfInterest, columnOfInterest), ...
          Data.Decision(iTrial), ... 
          threshold1(iTrial), sigma_S, decisionRule(iTrial));
      
      convertedThreshold2(iTrial) = ...
          convertThreshold (DataSetSpec.Mu, ...
          paramStruct.Variance(indexOfInterest, columnOfInterest), ...
          Data.Decision(iTrial), ...
          threshold2(iTrial), sigma_S, decisionRule(iTrial));
      
      
      % On trials in which the response was for C=1, the converted thresholds will now be ordered
      % incorrectly, as coversion has the effect of re-ordering the thresholds in the oposite
      % direction. Correct this now
      if Data.Decision(iTrial) == 0
          
          upperThresh = convertedThreshold1(iTrial);
          lowerThresh = convertedThreshold2(iTrial);
          
          convertedThreshold1(iTrial) = lowerThresh;
          convertedThreshold2(iTrial) = upperThresh;
          
      end
 
      thresholdArea(iTrial) = (normcdf(convertedThreshold2(iTrial), Data.Orientation(iTrial), sqrt(paramStruct.Variance(indexOfInterest, columnOfInterest))))...
          - (normcdf(convertedThreshold1(iTrial), Data.Orientation(iTrial), sqrt(paramStruct.Variance(indexOfInterest, columnOfInterest))));

end
         
         
probConfidence = ((1 - paramStruct.Lapse).*thresholdArea)+((paramStruct.Lapse).*(1/DataSetSpec.binNum));

if any (probConfidence >1 | probConfidence < 0)
    error ('probability out of range - check yourself')
end

trialLogLikelihood = log(probConfidence);       
        
    
   
             
end
    