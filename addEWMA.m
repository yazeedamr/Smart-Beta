function crsp=addEWMA(variableList,k,crsp)
% Function: getLags
% Author: Yazeed Amr
% Project: Smart Beta
% Purpose:
%   Return a table of lagged variables
% 
% Inputs:
%                crsp - Input table, sorted by PERMNO, date
%
%                variableList  - Cell Array, names of variables to calculated EWMA for. e.g. {'variableA','variableB'}
%
%                k  - Span of EWMA in number of trading days .
% 
% outputs:
%                crsp - table with crsp and added lag variables

variableListOut=strcat('ewma',num2str(k),variableList);

%Sort by permno, date
crsp=sortrows(crsp,{'PERMNO','datenum'});

%Create empty columns
crsp{:,variableListOut}=NaN;

permnoList=unique(crsp.PERMNO);

for thisPermno = permnoList'
    %Fill in EWMA for one permno at a time
    whichRows=crsp.PERMNO==thisPermno&(~sum(isnan(crsp{:,variableList}),2));
    thisCrsp=crsp{whichRows,variableList};
    if k<size(thisCrsp,1)
        crsp{whichRows,variableListOut}=tsmovavg(thisCrsp,'e',k,1);
    else
        crsp{whichRows,variableListOut}=NaN;
    end
end


end
