n = 6;
nDecisions = 2;
y = zeros(n, nDecisions);
for i = 1:n
    for d = 1:nDecisions
        t = paramStruct.thresh(i + 3);
        y(i, d) = convertThreshold (i, DataSetSpec, paramStruct, ...
            Data, indexOfInterest, columnOfInterest, t, sigma_S, ...
            d - 1);
    end
end

y