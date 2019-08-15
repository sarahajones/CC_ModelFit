function outData = mT_packUnpackParams(direction, Settings, inData)
% Pack the parameters into a vector, or unpack into a strcuture with a field for
% each set of params

% INPUT
% direction         'pack' or 'unpack'
% Settings          The standard settings struct. See findMaximumLikelihood
%                   instrcutions. The field 'Params' is used to determine how
%                   to pack and unpack.
% inData            The param data

% Joshua Calder-Travis, j.calder.travis@gmail.com

if length(Settings) ~= 1; error('Incorrect use of input arguments'); end


% Find the information on the intended location of the parameters when packed
% and when unpacked. This information is given in settings.
paramNames = cell(length(Settings.Params), 1);
packedParamOrder = cell(1, length(Settings.Params));
unpackedParamOrder = cell(1, length(Settings.Params));

for iParam = 1 : length(Settings.Params)
    
    paramNames{iParam} = Settings.Params(iParam).Name;
    packedParamOrder{iParam} = Settings.Params(iParam).PackedOrder;
    unpackedParamOrder{iParam} = Settings.Params(iParam).UnpackedOrder;

    
end


%% Packing and unpacking
if strcmp(direction, 'unpack')
    
    % Check input
    if ~(isnumeric(inData) && size(inData, 1) == 1)
        
        error('With unpacking selected, the input must be a row vector.')
        
        
    end
    
    
    % Time to unpack...
    for iParam = 1 : length(paramNames)
        
        outData.(paramNames{iParam}) = ...
            NaN(Settings.Params(iParam).UnpackedShape);
        
        
        % Is the parameter stored on a log scale when packed? If so exponentiate
        % as we unpack it.
        if isfield(Settings.Params, 'FitLog') && Settings.Params(iParam).FitLog
            
            theseParams = exp(inData(packedParamOrder{iParam}));
            
        else
            theseParams = inData(packedParamOrder{iParam});
            
        end
        
        outData.(paramNames{iParam})(unpackedParamOrder{iParam}) = theseParams;
        
    end
    
    
elseif strcmp(direction, 'pack')
    
    % Check input
    if ~isstruct(inData)
        
        error(['With packing selected, the input must be a stuct containing' ...
            'fields for the paramters.'])
        
        
    end

    
    % Initialise the row vector to pack
    outData = NaN(1, max(cellfun(@max, packedParamOrder)));
    
    
    % Time to pack...
    for iParam = 1 : length(paramNames)
        
        % Is the parameter stored on a log scale when packed?
        if isfield(Settings.Params, 'FitLog') && Settings.Params(iParam).FitLog
            
            outData(packedParamOrder{iParam}) = ...
                log(inData.(paramNames{iParam})(unpackedParamOrder{iParam}));
            
        else
            
            outData(packedParamOrder{iParam}) = ...
                inData.(paramNames{iParam})(unpackedParamOrder{iParam});
            
        end
        
    end
    
    
else
    
    error('Bug: Input arguments likely incorrect.')
    
    
end