function DataSet = modelFitting(DataSet)

models = {'normativeGenerative', 'normativeGenerativeAlways', ...
    'alternativeGenerative', 'alternativeGenerativeAlways'};

for iModel = 1 : length(models)
    
    model = models{iModel};

Settings(iModel).Algorithm = 'fmincon';
Settings(iModel).NumStartPoints = 10;
Settings(iModel).NumStartCand = 100;
Settings(iModel).TrialChunkSize = 'off';
Settings(iModel).FindSampleSize = @(Data) length(Data.Orientation); %returns the number of trials
Settings(iModel).FindIncludedTrials = @(Data) true(size(Data.Orientation));
Settings(iModel).SuppressOutput = true;
Settings(iModel).ReseedRng = true;
Settings(iModel).DebugMode = false;
Settings(iModel).JobsPerContainer = 128;

Settings(iModel).ModelName = model;
Settings(iModel).ComputeTrialLL.FunName = 'computeLikelihood';
Settings(iModel).ComputeTrialLL.Args = {model, Settings(iModel).FindIncludedTrials};
Settings(iModel).FindIfOutOfBounds = 'none';


%setting up variance param struct structure
Param(1).Name = 'Variance';
Param(1).UnpackedShape = [5 2];
Param(1).UnpackedOrder = 1:10 ;
Param(1).PackedOrder = 1:10 ;
Param(1).InitialVals = @() randBetweenPoints(((pi/200)^2), ((2*pi)^2), 0, 5, 2);
Param(1).LowerBound = @() repmat(((pi/200)^2), 5, 2);
Param(1).UpperBound = @() repmat (((2*pi)^2), 5, 2);

%setting up threshold param struct structure
Param(2).Name = 'thresh';
Param(2).UnpackedShape = [9 1];
Param(2).UnpackedOrder = 1:9;
Param(2).PackedOrder = 11:19;
Param(2).InitialVals = @() randBetweenPoints(0.5, 1, 0, 9, 1);
Param(2).LowerBound = @() zeros(9, 1) + 0.5;
Param(2).UpperBound = @() ones(9, 1);

%setting up variance param struct structure
Param(3).Name = 'Lapse';
Param(3).UnpackedShape = [1 1];
Param(3).UnpackedOrder = 1:1;
Param(3).PackedOrder = 20;
Param(3).InitialVals = @() randBetweenPoints(1/600, 500/600, 0, 1, 1);
Param(3).LowerBound = @() 1/600;
Param(3).UpperBound = @() 500/600;


Settings(iModel).Params = Param;
Settings(iModel).NumParams = 20;

end

mode = 'local';
% saveLoc = 'D:\Code\CC_ModelFit\ModelFitCode\Cluster';
DataSet = mT_scheduleFits(mode, DataSet, Settings);

end

function n = randBetweenPoints(lower, upper, epsilon, sizeD1, sizeD2)
% Draw a random number from [lower + epsilon, upper - epsilon]

% INPUT
% sizeD1 and sizeD2     size of the output along dimention 1 and 2.
%                       If not specified uses 1, 1.

if nargin == 3
    size = {1, 1};
    
else
    size = {sizeD1, sizeD2};
    
end 
    

range = upper - lower - (2*epsilon);

n = (rand(size{:})*range) + lower + epsilon;


end
