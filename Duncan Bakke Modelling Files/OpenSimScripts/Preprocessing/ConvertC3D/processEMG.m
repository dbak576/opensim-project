function [proEMG, rectEMG, lowEMG] = processEMG(rawEMG, AnalogRate)
% Purpose:  From raw EMG data as input, the method performs the
%           filtering, rectifying, and normalizing operations needed to
%           obtain an EMG envelope.
% 
% USAGE:  [proEMG, rectEMG] = processEMG(rawEMG, AnalogRate)
%
% Input:   rawEMG are columns of EMG channels
%          AnalogRate is the sampling rate of the raw EMG data
%
% Output:  proEMG is column matrix of normalized EMG envelopes
%          rectEMG (optional) of just norm rectified EMG
%
% NOTE:    rawEMG signals must contain at least 12 data points
%          in order to apply a fourth order lowpass filter
%
% ASeth Nov-07, streamlined version of ASA, 9-05
% Stanford University
%
% NOTE: This code is being saved for use as part of a project
% undertaken by Duncan Bakke at the Auckland Bioengineering Institute.
% The original can be found at
% http://simtk-confluence.stanford.edu:8080/display/OpenSim/Tools+for+Preparing+Motion+Data
% Delp SL, Anderson FC, Arnold AS, Loan P, Habib A, John CT, Guendelman E, Thelen DG. 
% OpenSim: Open-source Software to Create and Analyze Dynamic Simulations of Movement. 
% IEEE Transactions on Biomedical Engineering. (2007) 

[nAnalogFrames, nc] = size(rawEMG);

% Apply 4th order, 0-lag, Butterworth band-pass filter to raw EMG signal.
order = 4;
fs = AnalogRate;
if fs >= 1000
	cutoff = [20 400];                % default
	% cutoff = [80 400];              % use when there is 60 Hz noise
elseif fs == 600                      % For Delaware EMG data
	cutoff = [11 222];                % default
	% cutoff = [44 222];              % use when there is 60 Hz noise
end
[b, a] = butter(order/2, cutoff/(0.5*fs));
bandEMG = filter(b, a, rawEMG, [], 1);  

% Rectify the filtered EMG signal.
rectEMG = abs(bandEMG);

% Apply 4th order, 0-lag, Butterworth low-pass filter to rectified signal.
order = 4;
cutoff = 10;
[b, a] = butter(order, cutoff/(0.5*fs));
lowEMG = filter(b, a, rectEMG, [], 1);  

onesMat = ones(nAnalogFrames,1);
% Normalize rectified and low-pass filtered EMG signals.
nMinSamples = round(0.01 * nAnalogFrames);  
                                % average 1% of samples to get "min".
sortRect = sort(rectEMG);           
minRect = mean(sortRect(1:nMinSamples,:));
normRect = (rectEMG - onesMat*minRect)./(onesMat*(max(rectEMG) - minRect));
sortLow = sort(lowEMG);
minLow = mean(sortLow(1:nMinSamples,:));
normLow = (lowEMG - onesMat*minLow)./ (onesMat*(max(lowEMG) - minLow));
        
% Return processed EMG data.        
rectEMG = normRect;
proEMG = normLow;                

