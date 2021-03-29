%% downhill simplex
clear all;

addpath('')% place of scripts 
options = optimset('MaxIter',50,'Display','iter', 'PlotFcn',{@optimplotx,@optimplotfunccount,@optimplotfval});
[x,fval,exitflag,output]= fminsearch(@optimization, 7.25,options);