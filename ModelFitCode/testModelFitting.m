function DataSet = testModelFitting(modelNum)
% LoadedVariables  = load('DataStruct');
% 
% DataSet = LoadedVariables.DataSet; 
% 
% models = {'normativeGenerative', 'normativeGenerativeAlways', ...
%     'alternativeGenerative', 'alternativeGenerativeAlways'};
% 
% for iModel = 1 : 4
    
    DataSet = simulateDataStruct(modelNum);
    
    DataSet = modelFitting(DataSet);
    
end