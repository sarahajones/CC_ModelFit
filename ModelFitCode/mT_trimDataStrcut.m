function TrimmedData = trimDataStrcut(DataStrcut, EssentialFields)
% Trim the data strcut so that only essential data remains

% Joshua Calder-Travis, j.calder.travis@gmail.com

TrimmedData = DataStrcut;


for iPtpnt = 1 : length(TrimmedData)
    
    fieldList = fieldnames(TrimmedData(iPtpnt).Raw);
    
    
    for iField = 1 : length(fieldList)
        
        if ~any(strcmp(fieldList{iField}, EssentialFields))
            
            TrimmedData(iPtpnt).Raw = ...
                rmfield(TrimmedData(iPtpnt).Raw, fieldList{iField});
            
            
        end
        
        
    end
    
    
end