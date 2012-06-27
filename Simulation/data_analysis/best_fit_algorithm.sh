#! /usr/bin/octave -q

clear all; clf;
 
% get the the args
poly_degree=str2num(argv(){1});
data_file=argv(){2};
out_file=argv(){3};
title_name=argv(){4};

% Load in the data
the_data=load(data_file);
x=the_data(:,1);
y=the_data(:,2);
 
% Perform the fit
coeff = polyfit(x,y,poly_degree);
y_fit=polyval(coeff,x);

% Generate equation string
f_str="";
count=poly_degree;
for i=1:poly_degree
  f_str=sprintf("%s %G*x^%d +", f_str, coeff(i), count);
  count--;
end
f_str=sprintf("%s %G", f_str, coeff(poly_degree+1));

% calculate the error
dev = y - mean(y);          % deviations - measure of spread
SST = sum(dev.^2);          % total variation to be accounted for
resid = y - y_fit;          % residuals - measure of mismatch
SSE = sum(resid.^2);        % variation NOT accounted for
Rsq = 1 - SSE/SST;          % percent of error explained

% Print out the results
printf("R^2 = %G | %s\n", Rsq, f_str);

% Plots
hold on;
plot(x,y,'o',x,y_fit);
grid("minor","on");

% add informative text
title(title_name);
text(30,20, sprintf("R^2 = %G", Rsq));
text(15,10, f_str);
line([0,100],[25,25]);
line([0,100],[50,50]);
line([0,100],[75,75]);
line([0,100],[100,100]);

% save plot
print("-dpng", out_file);
