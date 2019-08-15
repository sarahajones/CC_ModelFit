function DataSet = modelFitting (DataSet, model)

Settings.Algorithm = 'fmincon';
Settings.NumStartPoints = 3;
Settings.NumStartCand = 10;
Settings.TrialChunkSize = 'off';
Settings.FindSampleSize = @(Data) length(Data.Orientation); %returns the number of trials
Settings.FindIncludedTrials = @(Data) true(size(Data.Orientation));
Settings.SuppressOutput = false;
Settings.ReseedRng = true;
Settings.DebugMode = true;
Settings.JobsPerContainer = [];

Settings.ModelName = model;
Settings.ComputeTrialLL.FunName = 'computeLikelihood';
Settings.ComputeTrialLL.Args = {model, Settings.FindIncludedTrials};
Settings.FindIfOutOfBounds = 'none';


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
Param(2).InitialVals = @() randBetweenPoints(0, 1, 0, 9, 1);
Param(2).LowerBound = @() zeros(9, 1);
Param(2).UpperBound = @() ones(9, 1);

%setting up variance param struct structure
Param(3).Name = 'Lapse';
Param(3).UnpackedShape = [1 1];
Param(3).UnpackedOrder = 1:1;
Param(3).PackedOrder = 20;
Param(3).InitialVals = @() randBetweenPoints(1/600, 500/600, 0, 1, 1);
Param(3).LowerBound = @() 1/600;
Param(3).UpperBound = @() 500/600;


Settings.Params = Param;
Settings.NumParams = 20;

mode = 'local';
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
