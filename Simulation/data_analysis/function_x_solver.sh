#! /usr/bin/octave -q

clear all; clf;

% get the the args
the_funct=argv(){1};

global y_solve_value = 0;
global y_funct = the_funct;

function y = f_curve(x)
	global y_solve_value;
	global y_funct;
	y=eval(y_funct) - y_solve_value;
endfunction
 
% solve for y 25
y_solve_value=25;
[x25, info] = fsolve("f_curve", 2);

% solve for y 50
y_solve_value=50;
[x50, info] = fsolve("f_curve", 2);

% solve for y 75
y_solve_value=75;
[x75, info] = fsolve("f_curve", 2);

% solve for y 100
y_solve_value=100;
[x100, info] = fsolve("f_curve", 2);

printf("25%%=%f,50%%=%f,75%%=%f,100%%=%f\n",x25,x50,x75,x100);
