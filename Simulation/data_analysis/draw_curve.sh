#! /usr/bin/octave -q

clear all; clf;
 
% get the the args
the_funct=argv(){1};

% clean up
the_funct=strrep(the_funct,"^",".^");

global y_funct = the_funct;

function y = f_curve(x)
	global y_funct;
	y=eval(y_funct);
endfunction

x = linspace(1, 100, 100);
y = f_curve(x);
 
% Plots
hold on;
plot(x,y);
grid("minor","on");

% add informative text
text(15,10, the_funct);
line([0,100],[25,25]);
line([0,100],[50,50]);
line([0,100],[75,75]);
line([0,100],[100,100]);

pause
