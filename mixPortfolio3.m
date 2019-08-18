%% mixPortfolio3.m
% Author: Yazeed Amr
% Project: Smart Beta
% Purpose:
%     runs the final strategy including longing momentum winner stocks, and 
%     small cap stocks. The weight of the small cap stocks is k/sigma(i), 
%     where k=expected return according to the FF and CAPM models 
%     (took the average of both results), and sigma is the implied
%     daily volatility on said stocks' returns. 
%
% Inputs:
%                crsp - Input table, including stock information.
%                ff3 - Input table, including Fama French factor
%                information
%
% Variables:
%                k - average excess return for main strategy in mind
%                (longing small-cap stocks, in this case). Used for the
%                sake of weights.

%% 

% crsp=readtable('testData.csv');

% %Create testData.csv
% crsp=readtable('crspCompustatMerged_2010_2014_dailyReturns.csv');
% permnoList=unique(crsp.PERMNO);
% permnoList=randsample(permnoList,100);
% crsp=crsp(ismember(crsp.PERMNO,permnoList),:);
% writetable(crsp,'crspTest.csv');

% ff3=readtable('ff3.csv');
% ff3.datenum=datenum(num2str(ff3.date),'yyyymmdd');
% ff3{:,{'mrp','hml','smb'}}=ff3{:,{'mrp','hml','smb'}}/100;
% writetable(ff3(2010<=year(ff3.datenum)&year(ff3.datenum)<=2014,:),'ff3_20102014.csv')

%% Load ff3 data
ff3=readtable('ff3_20102014.csv');
load('sigma.mat');
%%
crsp=readtable('crspTest.csv');
%crsp=readtable('crspCompustatMerged_2010_2014_dailyReturns.csv');

crsp.datenum=datenum(num2str(crsp.DATE),'yyyymmdd');

%% Calculate momentum size and value
% 
crsp=addLags({'ME','BE'},2,crsp);
% 
crsp.size=crsp.lag2ME;
%crsp.value=crsp.lag2BE./crsp.lag2ME;

%Calculate momentum
crsp=addLags({'adjustedPrice'},21,crsp);
crsp=addLags({'adjustedPrice'},252,crsp);
crsp.momentum=crsp.lag21adjustedPrice./crsp.lag252adjustedPrice;

% crsp=addRank({'size','value','momentum'},crsp);
crsp=addRank({'momentum','size'},crsp);


dateList=unique(crsp.datenum);

%Track strategy positions
thisStrategy=table(dateList,'VariableNames',{'datenum'});

%Create empty column of cells for investment weight tables
% thisStrategy{:,'portfolio'}={NaN};


%Create empty column of NaNs for ret
thisStrategy{:,'ret'}=NaN;
thisStrategy{:,'turnover'}=NaN;


%Run first iteration separately since there's no turnover to calculate
i = 1;
    
isRebalance=1;
thisDate=thisStrategy.datenum(i);
winnerMomentumPortfolio=tradeWinnersMomentum(thisDate,crsp,isRebalance);
winnerSizePortfolio=tradeWinnersSize(thisDate,crsp,isRebalance);
k=0.00087268;
wSize=k/sigma(i);
% Ensure that you do not end up shorting other factors (momentum):
if wSize>1
    wSize=1;
end
% Was done since the weight on momentum is (1-wSize)

thisPortfolio=winnerSizePortfolio;
thisPortoflio.w=wSize.*winnerSizePortfolio.w+(1-wSize).*winnerMomentumPortfolio.w; 

% thisStrategy.portfolio(i)={thisPortfolio}; %Bubble wrap the table of investment weights and store in thisStrategy

if (sum(~isnan(thisPortfolio.w))>0)
    %Calculate returns if there's at least one valid position
    thisStrategy.ret(i)=nansum(thisPortfolio.RET.*thisPortfolio.w);
end

fprintf('Running strat on %d trading days \n \n',size(thisStrategy,1));
stratN=size(thisStrategy,1);
reverseStr='\n';
for i = 2:stratN
    msg = sprintf('Running strat: %.2f complete',100*i/stratN);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
    
    isRebalance=~mod(i,252);%Yearly rebalancing every 252 trading days
    thisDate=thisStrategy.datenum(i);
    lastPortfolio=thisPortfolio;
    winnerSizePortfolio=tradeWinnersSize(thisDate,crsp,isRebalance,lastPortfolio);
    winnerMomentumPortfolio=tradeWinnersMomentum(thisDate,crsp,isRebalance,lastPortfolio);
    k=0.00380268;
    wSize=k/sigma(i);
    if wSize>1
        wSize=1;
    end
    %w=[0.75,0.25];
    %w=w./nansum(w);

    thisPortfolio=winnerSizePortfolio;
    thisPortoflio.w=wSize.*winnerSizePortfolio.w+(1-wSize).*winnerMomentumPortfolio.w;    
   % thisStrategy.portfolio(i)={thisPortfolio}; %Bubble wrap the table of investment weights and store in thisStrategy
    
    if (sum(~isnan(thisPortfolio.w))>0)
        %Calculate returns if there's at least one valid position
        thisStrategy.ret(i)=nansum(thisPortfolio.RET.*thisPortfolio.w);
        changePortfolio=outerjoin(thisPortfolio(:,{'PERMNO','w'}),lastPortfolio(:,{'PERMNO','w'}),'Keys','PERMNO');
        %Fill missing positions with zeros
        changePortfolio=fillmissing( changePortfolio,'constant',0);
        thisStrategy.turnover(i)=nansum(abs(changePortfolio.w_left-changePortfolio.w_right))/2;

    end 
    
end

fprintf('\n\n Getting Performance\n')
thisPerformance=evaluateStrategy(thisStrategy,ff3);

save('mixPortfolio3');

%Plot cumulative returns with dateticks
%plot(thisPerformance.thisStrategy.datenum,thisPerformance.thisStrategy.cumLogRet);
%datetick('x','yyyy-mm', 'keepticks', 'keeplimits')
