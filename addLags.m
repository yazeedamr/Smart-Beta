function crsp=addLags(variableList,k,crsp)
% Function: getLags
% Author: Evan Zhou
% Laste Modified: 2017-11
% Course: Applied Quantitative Finance
% Project: Smart Beta
% Purpose:
%   Return a table of lagged variables
% 
% Inputs:
%                crsp - Input table, sorted by PERMNO, date
%
%                variableList  - Cell Array, names of variables to be
%                lagged. e.g. {'variableA','variableB'}
%
%                k  - number of trading days to lag by.
% 
% outputs:
%                crsp - table with crsp and added lag variables

variableListOut=strcat('lag',num2str(k),variableList);

%Sort by permno, date
crsp=sortrows(crsp,{'PERMNO','datenum'});

% Keep variables to be lagged, along with permnos
crspLag= crsp(:,['PERMNO' variableList]);

%Fill part of crspLag with lag variables
crspLag((k+1):end,:)=crspLag(1:(end-k),:);
%Fill header of crspLag with NaN
crspLag{1:k,:}=NaN;

%Where lagged parmno != current permno, the lag variables should be NaN
crspLag{crspLag.PERMNO~=crsp.PERMNO,variableList}=NaN;

%Weld lagged variables onto output table ''crsp'' with the appropriate
%table names
crsp(:,variableListOut)=crspLag(:,variableList);


end