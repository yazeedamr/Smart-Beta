%Lag returns

crsp=addLags({'RET'},2,crsp);

crsp=addEWMA({'lag2RET'},252,crsp);%Average return, span of 1 year = 252 days
crsp.RET2=(crsp.RET-crsp.ewma252lag2RET).^2;
crsp=addEWMA({'RET2'},42,crsp);%variance=Average (r-mu)^2, span of 2 months = 42 days
crsp.sigma=sqrt(crsp.ewma42RET2);


%Bandaid application to strat

thisStrategy{:,'PERMNO'}=12345;

thisStrategy=addLags({'ret'},2,thisStrategy);

thisStrategy=addEWMA({'lag2ret'},252,thisStrategy);%Average return, span of 1 year = 252 days
thisStrategy.RET2=(thisStrategy.ret-thisStrategy.ewma252lag2ret).^2;
thisStrategy=addEWMA({'RET2'},42,thisStrategy);%variance=Average (r-mu)^2, span of 2 months = 42 days
thisStrategy.sigma=sqrt(thisStrategy.ewma42RET2);

