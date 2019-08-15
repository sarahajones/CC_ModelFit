function  convertedThreshold = convertThreshold (mu, variance, decision,...
    threshold, sigma_S, decisionRule)

if decisionRule == 0 %i.e. if we are Bayesian
    
    chunk1 = log((1./threshold)-1);
    chunk2 = (((sigma_S)^2).* variance);
    numerator = chunk1.*chunk2;
    
    if decision == 0
        denominator = (2).*(mu);
    else
        denominator = (-2).*(mu);
    end
    
    convertedThreshold = numerator/denominator;
    
else %i.e. if we are using rule based strategy
    
    chunk1 = (-1)*(sqrt(variance));
    
    if decision == 0
        chunk2 = norminv(threshold);
    else
        chunk2 = norminv(1-threshold);
    end
    
    convertedThreshold = chunk1*chunk2;
    
end