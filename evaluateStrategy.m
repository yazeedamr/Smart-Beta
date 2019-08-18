function thisPerformance=evaluateStrategy(thisStrategy,ff3)
% Function: getLags
% Author: Evan Zhou
% Laste Modified: 2017-11
% Course: Applied Quantitative Finance
% Project: Smart Beta
% Purpose:
%   Return a table of lagged variables
% 
% Inputs:
%                thisStrategy - Strategy history, with returns, turnover,
%                and datenum
%
%                ff3  - table with datenum, risk free rate 'rf', and fama
%                french factors: 'mrp', 'hml', 'smb'
% 
% outputs:
%                thisPerformance - structure with fields:
%                   thisStrategy - Strategy history, with returns turnover
%                   cumulative log returns and datenum
%                   sharpeRatio - Annualized sharpe ratio
%                   modelCAPM - capm regression (alpha, beta...etc)
%                   modelFF3 - Fama French 3 factor regression (alpha, betas ...etc)

thisStrategy=innerjoin(thisStrategy,ff3,'Keys','datenum');

thisStrategy.excessRet=thisStrategy.ret-thisStrategy.rf;

%CAPM Regression
modelCAPM=fitlm(thisStrategy,'excessRet~mrp');

%FF3 Regression
modelFF3=fitlm(thisStrategy,'excessRet~mrp+hml+smb');

%Calculate annualized average holding period, in days.
averageHoldingPeriod=1/nanmean(thisStrategy.turnover);

%Calculate annualized SHarpe Ratio
sharpeRatio=nanmean(thisStrategy.excessRet)/nanstd(thisStrategy.excessRet)*sqrt(252);

%Calculate cumulative log returns
thisStrategy{:,'cumLogRet'}=NaN;
thisStrategy.cumLogRet(~isnan(thisStrategy.ret))=cumsum(log(1+thisStrategy.ret(~isnan(thisStrategy.ret))));

%Create empty struct and fill with outputs
thisPerformance=[];

thisPerformance.thisStrategy=thisStrategy;
thisPerformance.sharpeRatio=sharpeRatio;
thisPerformance.averageHoldingPeriod=averageHoldingPeriod;
thisPerformance.modelCAPM=modelCAPM;
thisPerformance.alphaCAPM=(252)*thisPerformance.modelCAPM.Coefficients.Estimate(1);
thisPerformance.informationRatio=sqrt(252)*thisPerformance.modelCAPM.Coefficients.Estimate(1)/nanstd(thisPerformance.modelCAPM.Residuals.Raw);
thisPerformance.modelFF3=modelFF3;
thisPerformance.alphaFF3=(252)*thisPerformance.modelFF3.Coefficients.Estimate(1);
end
