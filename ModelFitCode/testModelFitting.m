function DataSet = testModelFitting(DataSet)
% LoadedVariables  = load('DataStruct');
% 
% DataSet = LoadedVariables.DataSet; 
% 
% models = {'normativeGenerative', 'normativeGenerativeAlways', ...
%     'alternativeGenerative', 'alternativeGenerativeAlways'};
% 
% for iModel = 1 : length(models)
    
%     DataSet = modelFitting(DataSet, models{iModel});
DataSet = modelFitting(DataSet);
    
end