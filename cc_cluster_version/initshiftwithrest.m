%% Shift trials incoperate Rest as condition

nsubjects = 16;
nsessions = 9;

shiftinfopth =  '';
savepth = '';

if ~exist(savepth)
       eval(sprintf('!mkdir %s',savepth));
end

% for specific shifts
shiftinfo =  load (fullfile( shiftinfopth,'shifts_brute_force_roi_0.1000s_t00-10.mat'));
varianceshift = shiftinfo.varmaxallidx;

%for case of 0 shift
%varianceshift = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

for subject = 1:nsubjects
    tsvpth = sprintf('',subject); %tsv trial definiton 
    
    folder  = sprintf('sub%02d',subject);
    outpth = fullfile(savepth,folder);
    
    
    if ~exist(outpth)
        eval(sprintf('!mkdir %s',outpth));
    end
    
    myshift = varianceshift(subject);
    
    shiftwithrest(tsvpth,outpth,subject,nsessions,myshift)
    
end