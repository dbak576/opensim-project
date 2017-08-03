function GRFTz_byLimb = clean_grfs(GRFTz_byLimb, DataRate, CutOffFrequency, tInfo, aTime, vTime)
%% clean_grfs
% This function filters forces data with a 2nd order butterworth filter
% and fits a spline using a number of datam points to match the marker data

%% INPUTS:
% GRFTz_byLimb = the ground reaction force data to be cleaned
% DataRate = rate at which the force data was captured
% CutOffFrequency = cut-off frequency of the butterworth filter
% nInterpolationPoints = rate at which the marker data was captured

%% OUTPUTS:
% the filtered and data rate matched ground reaction force data

%%

Wn=CutOffFrequency/(DataRate/2);
[B,A]=butter(2,Wn);

rIndices = strmatch('R', tInfo.limb);
lIndices = strmatch('L', tInfo.limb);

for i=tInfo.FP
    if any(i==lIndices)
        filteredFx = filtfilt(double(B),double(A),GRFTz_byLimb.L.Fx);
        filteredFy = filtfilt(double(B),double(A),GRFTz_byLimb.L.Fy);
        filteredFz = filtfilt(double(B),double(A),GRFTz_byLimb.L.Fz);
        filteredTz = filtfilt(double(B),double(A),GRFTz_byLimb.L.Tz);
        filteredCOPx = filtfilt(double(B),double(A),GRFTz_byLimb.L.COPx);
        filteredCOPy = filtfilt(double(B),double(A),GRFTz_byLimb.L.COPy);
        
        % interpolate using the cubic spline
        GRFTz_byLimb.L.Fx = spline(aTime,filteredFx,vTime);
        GRFTz_byLimb.L.Fy = spline(aTime,filteredFy,vTime);
        GRFTz_byLimb.L.Fz = spline(aTime,filteredFz,vTime);
        GRFTz_byLimb.L.Tz = spline(aTime,filteredTz,vTime);
        GRFTz_byLimb.L.COPx = spline(aTime,filteredCOPx,vTime);
        GRFTz_byLimb.L.COPy = spline(aTime,filteredCOPy,vTime);
        GRFTz_byLimb.L.startIndex = round(GRFTz_byLimb.L.startIndex / (length(aTime)/length(vTime)));
        GRFTz_byLimb.L.stopIndex = round(GRFTz_byLimb.L.stopIndex / (length(aTime)/length(vTime)));
    elseif any(i==rIndices)
        filteredFx = filtfilt(double(B),double(A),GRFTz_byLimb.R.Fx);
        filteredFy = filtfilt(double(B),double(A),GRFTz_byLimb.R.Fy);
        filteredFz = filtfilt(double(B),double(A),GRFTz_byLimb.R.Fz);
        filteredTz = filtfilt(double(B),double(A),GRFTz_byLimb.R.Tz);
        filteredCOPx = filtfilt(double(B),double(A),GRFTz_byLimb.R.COPx);
        filteredCOPy = filtfilt(double(B),double(A),GRFTz_byLimb.R.COPy);
        
        % interpolate using the cubic spline
        GRFTz_byLimb.R.Fx = spline(aTime,filteredFx,vTime);
        GRFTz_byLimb.R.Fy = spline(aTime,filteredFy,vTime);
        GRFTz_byLimb.R.Fz = spline(aTime,filteredFz,vTime);
        GRFTz_byLimb.R.Tz = spline(aTime,filteredTz,vTime);
        GRFTz_byLimb.R.COPx = spline(aTime,filteredCOPx,vTime);
        GRFTz_byLimb.R.COPy = spline(aTime,filteredCOPy,vTime);
        GRFTz_byLimb.R.startIndex = round(GRFTz_byLimb.R.startIndex / (length(aTime)/length(vTime)));
        GRFTz_byLimb.R.stopIndex = round(GRFTz_byLimb.R.stopIndex / (length(aTime)/length(vTime)));
    end
end

return;
    
    
