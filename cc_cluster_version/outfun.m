function [stop,options,optchanged] = outfun(options,optimvalues,flag)
scratchpth= ''; % save results here

%get annealings current results
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

switch flag
    case 'init'
%         iterations = [];
%         temperatures = [];
%         currentshifts = [];
%         bestshifts = [];
%         bestshiftvalues = [];
    case 'iter'       
        paths = load('/tmp/paths.mat');
        outfolderpth = paths.outfolder;
        load(fullfile(outfolderpth,'myhistory.mat'),'myhistory');
        myhistory(end+1)  = struct('iterations',iteration,'temperatures',temperature,'currentshifts',myshift,'bestshifts',bestshift,'bestshiftvalues',bestshiftvalue);
        save(fullfile(outfolderpth,'myhistory.mat'));
    case 'done'
        cd(scratchpth);
        t = datetime('now');
        strt= datestr(t,30);
        resultsfoldername = strcat(strt,'/');

        if ~exist(resultsfoldername)
                eval(sprintf('!mkdir %s',fullfile(scratchpth,resultsfoldername)));
                paths = load('/tmp/paths.mat');
                outfolderpth = paths.outfolder;
                me= sprintf('!cp %s %s',fullfile(outfolderpth,'myhistory.mat'),fullfile(scratchpth,resultsfoldername));
                eval(me);
                
        end
        cd(scratchpth);
        fprintf('Everything was copied to to scratch');
        
end
 
stop =false;
optchanged =false;
end