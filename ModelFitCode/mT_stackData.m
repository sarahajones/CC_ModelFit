function stacked = mT_stackData(DataStruct, structPath)
% Takes the data from a specific field in a struct array, and stacks it along
% the first unused dimention.

% INPUT
% DataStruct    The struct array from which to extract data
% structPath    A function handle. The function should return the field from
%               which to extract data when DataStruct is provided as an argument.
%               Data will be extracted from this field for every struct in the
%               struct array.
%               eg. @(struct) struct.Colour(2).Tail

% Joshua Calder-Travis, j.calder.travis@gmail.com


% If the strct array only has one element no stacking is required
if length(DataStruct) == 1
    
    stacked = structPath(DataStruct);
    
    
    return
    
    
end


% Check the data to concatinate is all of the size shape, and find how many
% dimentions it has
findSize = @(struct) size(structPath(struct));

dataSizes = arrayfun(findSize, DataStruct, 'UniformOutput', false);

dataSizes = cell2mat(dataSizes');


if any(diff(dataSizes))
    
    error('Requested to stack matricies of differing shapes')
    
    
end


% Find the properties of the data
dataShape = dataSizes(1, :);

dataDim = size(dataSizes, 2);

if dataShape(end) == 1
    
    dataShape(end) = [];
    dataDim = dataDim -1;
    
    
end


% Now we know the size, stack he relevant data
stacked = NaN([dataShape, length(DataStruct)]);


% Depending on the number of dimentions in the data, the dimention along which
% we will stack will vary. Create a function to index all the elements of
% stacked a particular points along this new dimention.
findSlice = @(slice) [ repmat({':'}, 1, dataDim), slice ];


% Perform the stacking
for iStruct = 1 : length(DataStruct)
    
    sliceIndex = findSlice(iStruct);
    
    stacked(sliceIndex{:}) = structPath(DataStruct(iStruct));
    
    
end


