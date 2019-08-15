Data.Orientation = [0.1, 0.4, -0.2, 0.9, 0.3, 0.7]';
Data.ContrastLevel = [0.1, 0.2, 0.3, 0.4, 0.8, 0.4]';
Data.numGabors = [1, 1, 1, 2, 2, 2]';
Data.binnedConfidence = [1 4 3 10 8 3]';
Data.KappaS = 7;
sigma_S = sqrt(1/Data.KappaS);


Data.Decision = [0 1];

findIncludedTrials = true(size(Data.Orientation));


ParamStruct.Variance = [15.940242270059645,13.353637323187352;...
    19.257814792859005,6.942852084025719;...
    9.511408187855963,35.393399055516710;...
    28.525029855147860,14.581152268595376;...
    15.434884926961350,15.903533623392510];

testHolds = [0 0.1049;
    0.1724 0.5060;
    0.1724 0.5060;
    0.5060 0.5268;
    0.7359 0.7790;
    0.9312 1.0000];


ParamStruct.thresh = [0:0.01:1]';
ParamStruct.Lapse= 1;

DSetSpec.Mu = (1/16)*pi;

convertedThreshold  = zeros(100,2);

decisions = 2;
trials = 6;
variances = 5;
n = decisions * trials * variances;

outThreshold = zeros(n, 1);
outDecision = zeros(n, 1);
outVariance = zeros(n, 1);
outConverted = zeros(n, 1);

for d = 1:decisions
    for v = 1:variances
        variance = ParamStruct.Variance(v,2);
        for i = 1:trials
            %threshold = ParamStruct.thresh(i);
            threshold = testHolds(i, 2);
            
            chunk1 = log((1/threshold)-1);
            chunk2 = ((sigma_S)^2).* variance;
            numerator = chunk1.*chunk2;

            if Data.Decision(d) == 0 
               denominator = (-2).*(DataSetSpec.Mu);
            else 
                denominator = (2).*(DataSetSpec.Mu);
            end
            
            x = trials * variances * (d - 1) + trials * (v - 1) + i;
            outThreshold(x) = threshold;
            outDecision(x) = Data.Decision(d);
            outVariance(x) = variance;
            outConverted(x) = numerator / denominator;
        end
    end
end

out = [outThreshold outDecision outVariance outConverted];

for d = 0:1
    figure
    hold on
    for v = 1:variances
        m = outDecision == d & outVariance == ParamStruct.Variance(v,2);
        plot(outThreshold(m), outConverted(m));
    end
end