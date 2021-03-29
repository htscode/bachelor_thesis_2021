function [stop,options,optchanged] = outfun(options,optimvalues,flag)

myshift = optimvalues.x;
temperature = optimvalues.temperature;
iteration = optimvalues.iteration;
bestshift = optimvalues.bestx;
bestshiftvalue = optimvalues.bestfval;

fprintf('This is iteration ');
fprintf('%g \n',iteration);
fprintf('The temperature is ');
fprintf('%g \n', temperature);
fprintf('The current shift is ');
fprintf('%g \n', myshift);
fprintf('The best shift so far was ');
fprintf('%g \n', bestshift);
fprintf('The best best shift value so far was ');
fprintf('%g \n', bestshiftvalue);

%% keep track of info
info = load( fullfile( '','optimizationinfo.mat'));
fprintf('====Stats==== \n ');
fprintf('h: %g p: %g \n', info.stats{1,1},info.stats{1,2});
fprintf('====FFA Info==== \n');
fprintf('famous length:%g unfamiliar length: %g Scrambled length: %g \n', length(info.ffa{1,5}),length(info.ffa{1,6}),length(info.ffa{1,7}));


stop =false;
optchanged =false;
end