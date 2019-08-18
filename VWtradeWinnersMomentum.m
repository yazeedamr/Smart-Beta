


function portfolio=VWtradeWinnersMomentum(thisDate,crsp,isRebalance,lastPortfolio,optionalArgument)
% Function: tradeMomentum
% Author: Yazeed Amr/Evan Zhou
% Laste Modified: 2017-11
% Course: Applied Quantitative Finance
% Project: Smart Beta
% Purpose:
%   Calculate the desired trade positions (investment weights) for longing
%   only momentum losers.
% 
% Inputs:
%                thisDatenum - current date
%                crsp - Input table, sorted by PERMNO, datenum. Should have
%                momentum percentile ranks in variable "momentumRank".
%                optionalArgument - something else to be used. For example
%                coud
%                in
% 
% outputs:
%                portfolio - Struct of current trade positions appended to past trade positions

%% Get date from investible universe
%Match by date
isInvestible= crsp.datenum==thisDate;

%Require that stock is currently still trading (has valid return)
isInvestible= isInvestible & ~isnan(crsp.RET);

%Extrade relevant data from crsp.
thisCrsp=crsp(isInvestible,:);

%% Create table of investment weights

%fill investment weights with zeros
thisCrsp{:,'w'}=0;

%add long only investment weights
%Set weight to 1 for all permnos where the momentum is in the bottom 10th
%percentile

thisCrsp.w(thisCrsp.momentumRank>=.9)=1;


%Standardize investment weights to make sure that 1) There's no short
%position 

thisCrsp{thisCrsp.w<0,'w'}=0;

% and 2) VALUE WEIGHTED weights add up to 1.
thisCrsp.w=thisCrsp.w.*crsp.size(isInvestible);
thisCrsp.w=thisCrsp.w./nansum(thisCrsp.w);


%% Select columns for output
portfolio=thisCrsp(:,{'PERMNO','w','RET'});

if isRebalance
    %Nothing
else
    %Get positions from lastPortfolio
    changePortfolio=innerjoin(portfolio(:,{'PERMNO','w','RET'}),lastPortfolio(:,{'PERMNO','w'}),'Keys','PERMNO');
    
    portfolio=table();
    [portfolio.PERMNO,iA]=unique(changePortfolio.PERMNO);
    portfolio.w=changePortfolio.w_right(iA);
    portfolio.RET=changePortfolio.RET(iA);
    portfolio=fillmissing(portfolio,'constant',0);
    
    %check that weights add up to 1.

    portfolio.w=portfolio.w./nansum(portfolio.w);

    
end



end