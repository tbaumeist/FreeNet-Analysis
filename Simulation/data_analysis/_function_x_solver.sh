#! /usr/bin/octave -q

clear all; clf;

% get the the args
the_funct=argv(){1};
is_straight_line=str2num(argv(){2});

global y_solve_value = 0;
global y_funct = the_funct;

function y = f_curve(x)
	global y_solve_value;
	global y_funct;
	y=eval(y_funct) - y_solve_value;
endfunction

if (is_straight_line == 1)
  printf("25%%=-1.000000,50%%=-1.000000,75%%=-1.000000,100%%=-1.000000");
  exit;
endif

f = @(x)f_curve(x);
 
% solve for y 25
y_solve_value=25;
[x25, info] = fsolve(f, 0.2);

% solve for y 50
y_solve_value=50;
[x50, info] = fsolve(f, 0.2);

% solve for y 75
y_solve_value=75;
[x75, info] = fsolve(f, 0.2);

% solve for y 100
y_solve_value=100;
[x100, info] = fsolve(f, 0.2);

printf("25%%=%f,50%%=%f,75%%=%f,100%%=%f\n",x25,x50,x75,x100);
