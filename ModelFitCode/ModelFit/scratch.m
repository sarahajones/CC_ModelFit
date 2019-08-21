function scratch()


for iSimModel = 1 : 4
    
    DataSet = simulateDataStruct(iSimModel);
 
    DataSet = modelFitting(DataSet);

    
end