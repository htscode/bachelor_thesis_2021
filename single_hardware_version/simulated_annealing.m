%% simulated  annealing 


addpath('')%path to scripts 
options = optimoptions(@simulannealbnd,'OutputFcn',@outfun,'MaxTime',28800,'TemperatureFcn',@temperaturefast, 'PlotFcn',{@saplotbestf,@saplotbestx,@saplotf,@saplotx,@saplotstopping,@saplottemperature});
%annealing 
[x,fval,exitFlag,output]=simulannealbnd(@optimization,7.25,3.5,11,options); % 3.5 start point, 7-11 as limits
