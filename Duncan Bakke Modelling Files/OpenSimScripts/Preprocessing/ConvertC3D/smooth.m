% smooth.m
% Smooth data using a 2nd order lowpass.
% Usage: Y = smooth(data, cutOff, sampleFreq)   
% Ajay Seth

function Y = smooth(data, Wc, sFreq)

maxF = sFreq/2;

wn = Wc/maxF;

[NF, Nc] = size(data);

[B, A] = butter(2, wn);


for I = 1:Nc,
    y = filtfilt(B, A, data(:,I));
    Y(:,I) = y;			 				
end
