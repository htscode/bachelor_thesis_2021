% Find the shift by getting the index of the minima of the mean/median and
% the maxima of the variance 

nsubjects = 16;

varmaxallidx = zeros(nsubjects,1);
medianminallidx = zeros(nsubjects,1);
meanminallidx = zeros(nsubjects,1);

varmaxall = zeros(nsubjects,1);
medianminall = zeros(nsubjects,1);
meanminall = zeros(nsubjects,1);
allsubs = zeros(nsubjects,1);


savepth = '';
datapth = '';

for subject = 1:nsubjects
   data = load(fullfile(datapth, sprintf('brute_force_p%02d_roi_0.1000s_t00-10.mat',subject)));
   results = data.results;
   timearray = data.timearray;
   
   variance = var(results');
   [varmax,varidx] = max(variance);
   [medianmin,medianidx] = min(median(results,2));
   [meanmin,meanidx] = min(mean(results,2));
   
   varmaxallidx(subject) = varidx/10;
   medianminallidx(subject) = medianidx/10;
   meanminallidx(subject) = meanidx/10;    
   
   varmaxall(subject) = varmax;
   medianminall(subject) = medianmin;
   meanminall(subject) = meanmin;    
  
   allsubs(subject)=subject;
end
 
   filename = fullfile( savepth,'shifts_brute_force_roi_0.1000s_t00-10.mat');
   save( filename, 'allsubs','varmaxall', 'medianminall', 'meanminall','varmaxallidx','medianminallidx','meanminallidx');      
