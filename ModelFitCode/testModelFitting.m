function DataSet = testModelFitting
LoadedVariables  = load('DataStruct');

DataSet = LoadedVariables.DataSet; 

model = 'normativeGenerative';

DataSet = modelFitting(DataSet, model);