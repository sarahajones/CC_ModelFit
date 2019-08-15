function testTrialLikelihood

model = 'normativeGenerative';


Data.Orientation = [0.1, 0.4, -0.2, 0.9, 0.3, 0.7]';
Data.ContrastLevel = [0.1, 0.2, 0.3, 0.4, 0.8, 0.4]';
Data.numGabors = [1, 1, 1, 2, 2, 2]';
Data.binnedConfidence = [1 4 3 10 8 3]';
Data.KappaS = 7;
Data.BlockType = [0, 0, 0, 1, 1, 1]';
Data.Decision = [ 1, 1, 0, 0, 1, 0]';


findIncludedTrials = true(size(Data.Orientation));


ParamStruct.Variance = [1, 1.1; 0.8, 0.85; 0.4, 0.45; 0.3, 0.3; 0.2, 0.2];
ParamStruct.thresh = [0.1, 0.15, 0.18, 0.2, 0.5, 0.55, 0.6, 0.7, 0.8]';
ParamStruct.Lapse= 1;

DSetSpec.Mu = (1/16)*pi;
DSetSpec.binNum = 10;

trialLikelihood = computeLikelihood(model, findIncludedTrials, ParamStruct, Data, DSetSpec);

end
