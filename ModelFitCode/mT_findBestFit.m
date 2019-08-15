function DSet = mT_findBestFit(DSet)
% Find the best fit out of all the fits produced from different start points.

% INPUT 
% DSet          Should follow the standard data format. See repo README.
%               Models should have been fitted.

% OUTPUT 
% DSet          The script looks through all participants and models finding
%               the best fit for each model, and specifying this model in a
%               new field DSet.P(i).Models(j).BestFit. Some additional
%               statistics are computed.

% Joshua Calder-Travis, j.calder.travis@gmail.com

for iPtpnt = 1 : length(DSet.P)
    
    for iModel = 1 : length(DSet.P(iPtpnt).Models)
        
        % Find the start point that led to the very best fit.
        allLL = mT_stackData(DSet.P(iPtpnt).Models(iModel).Fits, ...
            @(strArray) strArray.LL);
        
        [~, bestFit] = max(allLL);
        
        
        % Defensive programming
        if any(allLL > 0); error('Bug'); end
        
        
        % Store a copy of the data for this fit seperately for easy access
        DSet.P(iPtpnt).Models(iModel).BestFit.InitialVals = ...
            DSet.P(iPtpnt).Models(iModel).Fits(bestFit).InitialVals;
        
        DSet.P(iPtpnt).Models(iModel).BestFit.Params = ...
            DSet.P(iPtpnt).Models(iModel).Fits(bestFit).Params;
        
        DSet.P(iPtpnt).Models(iModel).BestFit.LL = ...
            DSet.P(iPtpnt).Models(iModel).Fits(bestFit).LL;
        
        DSet.P(iPtpnt).Models(iModel).BestFit.SampleSize = ...
            DSet.P(iPtpnt).Models(iModel).Fits(bestFit).SampleSize;
        
        
        % Compute BIC and AIC
        ThisModel = DSet.P(iPtpnt).Models(iModel);
        
        sampleSize = mT_stackData(ThisModel.Fits, @(Struct) Struct.SampleSize);
        sampleSize = unique(sampleSize);
        
        if size(sampleSize) ~= [1 1]; error('bug'); end
        
        
        DSet.P(iPtpnt).Models(iModel).BestFit.Bic = ...
            (log(sampleSize) * ThisModel.Settings.NumParams) - ...
            (2*DSet.P(iPtpnt).Models(iModel).BestFit.LL);
        
        DSet.P(iPtpnt).Models(iModel).BestFit.Aic = ...
            (2*ThisModel.Settings.NumParams) - ...
            (2*DSet.P(iPtpnt).Models(iModel).BestFit.LL);
        
    end
    
end
    