function mT_plotAicAndBic(aicData, bicData, figureTitle, individualVals)
% Makes plots of the agregate AIC and BIC, along with the number of
% participants best fit by each model. 

% INPUT
% aicData and bicData   Should be [numModels x numParticipants] arrays
% title                 Figure title
% individualVals        If true then on top of the bar plot of mean AIC/BIC,
%                       also the participant by participant values as line
%                       plots.

% Joshua Calder-Travis, j.calder.travis@gmail.com


figure('Name', figureTitle, 'NumberTitle', 'off')


% Store data in a format we can loop over
infoCrit{1} = aicData;
infoCrit{2} = bicData;
critNames = {'AIC', 'BIC'};


for iCrit = 1 : length(infoCrit)
    
    [CritResultsTable, baselinedCrit] = mT_analyseInfoCriterion(infoCrit{iCrit});
    
    
    % Plot (a) aggregate scores
    subPlotObj = subplot(2, 2, 1 + ((iCrit -1) *2) );
    subPlotObj.LineWidth = 2;
    subPlotObj.FontSize = 25;
    subPlotObj.XAxisLocation = 'origin';
    
    xticks(CritResultsTable{:, 1})
    
    ylabel(['\Delta ' critNames{iCrit}])
    xlabel('Model num')
    
    hold on
    title(['Mean ' critNames{iCrit}]);
    
    barObj = bar(CritResultsTable{:, 1}, CritResultsTable{:, 2});
    barColour = [0 180 235]/255; 
    barObj.FaceColor = barColour;
    barObj.EdgeColor = barColour;
    
    
    erObj = errorbar(CritResultsTable{:, 1}, CritResultsTable{:, 2}, ...
        CritResultsTable{:, 4}, CritResultsTable{:, 3});
    
    erObj.LineStyle = 'none';
    erObj.LineWidth = 5;
    erObj.CapSize = 20;
    errorColour = [255, 149, 0]/255;
    erObj.Color = errorColour;
    box off
    
    % Add line plot of individual participant values if requested
    if individualVals
        for iPtpnt = 1 : size(infoCrit{iCrit}, 2)
            plot(1:size(infoCrit{iCrit}, 1), baselinedCrit(:, iPtpnt), ...
                'Color', [0.7, 0.7, 0.7], 'LineWidth', 1)
        end
    end
    
    % Plot(b) num participants best described
    subPlotObj = subplot(2, 2, 2 + ((iCrit -1) *2) );
    subPlotObj.LineWidth = 2;
    subPlotObj.FontSize = 25;
    subPlotObj.XAxisLocation = 'origin';
    
    xticks(CritResultsTable{:, 1})
    
    hold on
    title(['Best fitting ptpnts ' critNames{iCrit}])
    
    barObj = bar(CritResultsTable{:, 1}, CritResultsTable{:, 5});
    
    barColour = [0 180 235]/255; 
    barObj.FaceColor = barColour;
    barObj.EdgeColor = barColour;
    
      
end
    

