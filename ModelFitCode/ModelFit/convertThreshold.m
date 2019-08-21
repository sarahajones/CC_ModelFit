function  convertedThreshold = convertThreshold (mu, variance, decision,...
    threshold, sigma_S, decisionRule)

convertedThreshold = NaN(size(decisionRule));

% Which which trials are to use the Bayesian and rule based strategy
bayesTrials = decisionRule == 0;
ruleTrials = ~bayesTrials;


% Process Bayes trials
chunk1 = log((1./threshold(bayesTrials))-1);
chunk2 = (((sigma_S)^2) + variance(bayesTrials));
numerator = chunk1.*chunk2;

denominator = -2.*mu;
denominator = repmat(denominator, sum(bayesTrials), 1);
denominator(decision(bayesTrials) == 0) = -denominator(decision(bayesTrials) == 0);

convertedThreshold(bayesTrials) = numerator./denominator;


% Process rule based trials
chunk1 = (-1)*(sqrt(variance(ruleTrials)));

ruleTrialThresholds = threshold(ruleTrials);

argument = 1 - ruleTrialThresholds;
argument(decision(ruleTrials)==0) = ruleTrialThresholds(decision(ruleTrials)==0);

chunk2 = norminv(argument);

convertedThreshold(ruleTrials) = chunk1.*chunk2;
