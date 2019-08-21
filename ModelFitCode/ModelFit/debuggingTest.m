function debuggingTest

mu = (1/16)*pi;
sigma_s = sqrt(1/7);
SigmaX = 1;
x = 0.5;


conf = (1 / (1 + ((exp(((2)*(x)*(mu))/ (((sigma_s)^2) + ((SigmaX)^2)))))))



chunk1 = log((1./conf)-1);
chunk2 = (((sigma_s)^2) + (SigmaX^2));
numerator = chunk1.*chunk2;

denominator = -2.*mu;
denominator = -denominator;

convertedThreshold = numerator./denominator
