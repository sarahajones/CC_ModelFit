# ModellingTools
Tools that are helpful for a wide range of computation modelling situations

## Standard data format
DSet            Struct with fields...
    P           [numPtpnt] long strcut array with fields...
        Data    Contain a field for every measured/manipulated variable, and
                derived variables.
        Sim     If data was simulated, describes the parameters used. Has fields...
            Params
                Has field for every model parameter. Should be stored in the 
                same form as is used for modelling. Specifically these
                should be in the same form as the unpacked 'ParamStrcut'.
                See 'mT_findMaximumLikelihood' for more information.
        Models  Num models long struct array containing modelling results. 
                Contains fields...
            Fits        [num start points] long strcut array of each attempted fit
            BestFit     The best fit out of the fits
    Spec        Dateset wide settings. At a minimum must contain, fields...
        TimeUnit    'none' or time unit used in dataset given in seconds per unit
    FitSpec     General model fitting procedure settings
    SimSpec Structure array describing the true properties of the data if 
            the data was simulated. It should have a fields...
        Name    Model naming system should match that used for modelling. 


All time quantities should be store in units of seconds.


## Notes on parameter storage
Parameters are stored and passed in two forms, packed and unpakced. When 'unpacked'
they are stored in struct array called ParamStrcut. ParamStrcut
contains fields named after those sets. These feilds store sets of parameters
as numeric arrays. When 'packed' all
parameters from every set are stored in a single parameter vector.

    
	
