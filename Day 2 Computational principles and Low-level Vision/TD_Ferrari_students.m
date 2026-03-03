%% A small exercize on STA and LNP model fitting, by U. Ferrari with the help of M. Chalk

% Here the goal is to compute the STA of a signle RGC from the response to a set of
% checkerboad images. 

% Code to be completed by the student starts with '%%%' 

% Note that the code is not intended to be optimized for computational performance. 
% In particular, most of the for cycles can be rewrittenm as vector multiplications 
% which in Matlab are usually much faster. 
% [[Brave students can give it a try, and optimize the code]]

clear all 
close all


%% The data

% Data consist in a set of checkerboard images and the response of a
% ganglion cell

% Before even loading the data, it's good practice to start by looking at
% the file content

whos -file TD_Ferrari.mat

% What's in there? Which dimensions have the vectors?

%% Loading the data

% To load the data file you need to be in the right folder (where the
% data are located)
load('TD_Ferrari.mat');


%% introduction: always start by having a look at the raw data

% Get the size of the stimulus
% nx = size of image patch in one direction
% N =  number of images
[nx, ~, N] = size(stimulus);


% Plot the first checkerboad image
figure('Name', 'example stimulus')
%%% imagesc( ? )
colormap('gray')
set(gca,'FontSize',18);

% Plot the histogram of the response
figure('Name', 'histogram of spike counts')
%%% hist( ? , 100)                          
xlabel('recorded spike counts')
ylabel('number')
set(gca,'FontSize',18);


%% Compute spike triggered average

% Define the sta matrix
%%% sta = zeros( ? );

% Compute the sum of the images weighting on the response and then
% normalize
% [[Can you optimize this?]]
for n=1:N
    %%% sta = sta + ? * ?; 
end
sta = sta/N;
    
% Plot the sta with imagesc
figure('Name', 'STA')
imagesc(sta)
colormap('gray')
set(gca,'FontSize',18);

%% The nonlinear relation between the filtered stimulus and the response: how to fit it?

% compute the filtered stimulus 'signal' by summing the pointwise
% multiplication of the sta matrix with the stimulus image
% [[Can you optimize this?]]
signal = zeros(size(response));
for n=1:N
   %%% signal(n) = sum(sum( ? .* ? ) ); 
end


% Plot signal versus response
figure('Name', 'filter versus spikes')
%%% plot( ? , ? , 'k.');    % Scatter plot of signal (filtered stimulus) versus spike count  
hold on
ylim([0 max(response)*1.05]);
xlabel('signal = sta * x')
ylabel('spike count')
set(gca,'FontSize',18);

%% Compute the anchor points of the non-linearity

% bin the signal in 50 bins
% COUNTS = vector of size nBin counting the number of points per bin
% EDGES = vector of size nBin+1 with the edges of the bins
% BIN = vector of the same size as signal, with the bin number where each
% element fall: BIN(n) = k if signal(n) falls in the kth bin
nBin = 50;
%%% [COUNT,EDGES,BIN] = histcounts( ? , ? );


% compute the middle points between the EDGES by summing the left edge plus
% half the distance to the right edge
anchor_x = EDGES(1:(end-1)) + ( EDGES(2:end) - EDGES(1:(end-1)) )/2;

% compute the average of the response within each bin
anchor_y = zeros([1 nBin]);
for bin = 1:nBin
   %%% anchor_y(bin) = mean( ? ); %Tip: use the vector BIN==bin which tells
   %%% you which responses fall into the bin'th bin
end

% plot signal versus response with anchor points
figure('Name', 'filter versus spikes')
hold on
plot(signal,response, 'k.');    
plot(anchor_x,anchor_y,'r.','MarkerSize',18)
ylim([0 max(response)*1.05]);
xlabel('signal = sta * x')
ylabel('spike count')
set(gca,'FontSize',18);

%% Use SPLINE to construct the non-linear function

% spline allows for constructing a cubic interpolation between (x,y) points
nonlinearity = spline(anchor_x,anchor_y);

% ppval allows for evaluating the spline interpolation at any given point
% points.

% predictions = ppval( ? , ? );         %Tip: use the help command in the prompt to get the ppval syntax

% scatterplot between the responses for all images and the predictions 
figure('Name', 'spike count versus prediction')
hold on
plot(response, predictions, 'k.','MarkerSize',14);            
plot([0, 120], [0, 120], 'k--'); 
ylim([0 max(response)*1.05]);
xlim([0 max(predictions)*1.05]);
ylabel('predicted mean spike count')
xlabel('observed spike count')
set(gca,'FontSize',18);


%% fit a linear-nonlinear-poisson (LNP) model

%
% pred(stim) = exp( filter * stim +b)
% ll( resp | stim  ) = log p(resp | stim) = log Poisson(resp|stim) = r * log( pred(stim) ) - pred(stim) 
% dll/dw = sum_stim ( resp(stim) - pred(stim) ) * stim / Nstim
% dll/db = sum_stim ( resp(stim) - pred(stim)) / Nstim
%


% flatting stimulus
stimulusFlat = reshape(stimulus,[nx^2, N]);

% initiliase parameters
b = 0;                      % initial bias term
w = 1e-9*randn(nx^2, 1);    % initial linear weights (filter)

% parameters for gradient descent
Nit = 300;                  % number of iterations
eta = 1e-2;                 % step size

L = zeros(1, Nit);          % log likelihood
for i = 1:Nit
    
    % computing the predicted firing rate f
    % pred = ?;                % predicted firing rate for each stimulus (vector of size 1 * N)

    % log firing rate
    L(i) = (log(pred)*response' - sum(pred))/N;

    % derivative of log likelihood
    dL_w = stimulusFlat*(response - pred)'/N;
    dL_b = sum(response-pred)/N;

    % update parameters 
    % w =                   % update of the filter parameters
    % b =                   % update of the baseline parameters
end


%% plotting the results


% plot loss function versus trials
figure('Name', 'Loss function')
plot(1:Nit, L)
xlabel('iterations')
ylabel('log likelihood')

                        
figure('Name', 'learned  filter')
% imagesc()                             % 2D plot of the inferred filter
colormap('gray')
set(gca,'FontSize',18);
% How does it compare with the STA?

figure('Name', 'spike count versus prediction')
% plot(?, response, 'k.'); hold on             % compare predicted and observed spike count
plot([0, 120], [0, 120], 'k--'); hold off
xlabel('predicted mean spike count')
ylabel('observed spike count')

%% Which apprach does work better? STA or LNP fit?

% This is left as exercize.
% remember that for fair comparison, you would need to split your data
% into training and testing.
% You can then estimate performance with correlation between data and
% prediction.
% Enjoy!

