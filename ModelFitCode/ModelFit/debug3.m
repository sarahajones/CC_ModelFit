decision = 1;
decisionRule = 0;
mu = .1963;
sigma_S = .3780;
threshold = .8155;
variance = 19.3911;

thresh = 0:0.01:1;

n = length(thresh);
y = zeros(n, 1);

for i = 1:n
    t = thresh(i);
    
    y(i) = convertThreshold(mu, variance, decision, t, ...
        sigma_S, decisionRule);
end

plot(y)