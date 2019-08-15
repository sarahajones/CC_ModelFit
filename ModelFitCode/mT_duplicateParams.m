function ParamInfo = mT_duplicateParams(ParamInfo, down, across)
% Takes one of the fields of ParamSets (defined in the function
% 'mT_findMaximumLikelihood', and duplicates the relevant fields, 
% such that this field of ParamSets now defines a parameter [i*down x j*across]
% array, wherebefore the the field defined an array of size [i x j].
% Properies of the parameters are duplicated downwards, and across, such that, 
% the new parameters are drawn from distributions that correspond
% the dirstibutions used for the original parameters. Note, does this functions
% does not change the field 'PackedOrder'.

% Joshua Calder-Travis, j.calder.travis@gmail.com

% Defensive programming
if ParamInfo.UnpackedShape(end) ~= 1
    error('Parameter array has already more that one column.')
    % This check is only here because some old scripts did not check this in the
    % script itself but assumed this function checked it. Nothing in this
    % function requries there to be only one column.
end

if length(ParamInfo.UnpackedShape) > 3; error('Bug'); end

if ParamInfo.UnpackedOrder(end) ~= ParamInfo.UnpackedShape(1)
    error('Code cannot cope with this case')
end


% Specify a new shape for the parameter array
if length(ParamInfo.UnpackedShape) == 1
    oldColumns = 1;
else
    oldColumns = ParamInfo.UnpackedShape(2);
end

oldRows = ParamInfo.UnpackedShape(1);
ParamInfo.UnpackedShape(1) = oldRows * down;
ParamInfo.UnpackedShape(2) = oldColumns * across;

ParamInfo.UnpackedOrder = ...
    1 : (ParamInfo.UnpackedShape(1)*ParamInfo.UnpackedShape(2));


specs = {'InitialVals', 'LowerBound', 'PLB', 'UpperBound', 'PUB'};
optionalSpecs = {'PLB', 'PUB'};

for iSpec = 1 : length(specs)
    
    % Some of the specs are optional
    if ismember(specs{iSpec}, optionalSpecs)...
        && ~(isfield(ParamInfo, specs{iSpec}))
        warning('PLB and PUB not specified.')
        continue
    end
    
    ParamInfo.(specs{iSpec}) ...
        = @()duplicateFuncCall(ParamInfo.(specs{iSpec}), down, across);
    
    
    % Check that the outputs of the function is now the intended shape
    if size(ParamInfo.(specs{iSpec})()) ~= ParamInfo.UnpackedShape
        error('Bug')
    end

end

end


function duplicatedCall = duplicateFuncCall(funcHandle, down, across)
% Instead of calling a function once, call it [down x across] times and
% concatinate the reults into a matrix.

% What size output does the function produce on its own?
outSize = size(funcHandle());


duplicatedCall = NaN(outSize(1) * down, outSize(2) * across);


% Make the calls
for iCallDown = 1 : down
    
    for iCallAcross = 1 : across
    
        duplicatedCall( ...
            (((iCallDown-1)*outSize(1))+1) : (iCallDown*outSize(1)),  ...
            (((iCallAcross-1)*outSize(2))+1) : (iCallAcross*outSize(2))) ...
            = funcHandle();
            
    end
    
end

end

