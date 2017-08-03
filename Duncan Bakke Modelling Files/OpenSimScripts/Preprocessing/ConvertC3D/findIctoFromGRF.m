function [icFromGRF, toFromGRF] = findIctoFromGRF(verticalGRF, rel_thresh)
% Purpose:  Detects events corresponding to initial contact and 
%           toe-off from the vertical GRF data that is passed in. 
%           Read from the C3D files.  
%
%           Better detection will be achieved with filtered data.
%
% Usage:   [icFromGRF, toFromGRF] = findIctoFromGRF(verticalGRF, rel_thresh)
%
% Input:    verticalGRF, pre-sected columns of the experimental data
%           rel_thresh is the percent of the max vertical force, i.e. 0.01 
%
% Output:   icFromGRF(fpHitNum) and toFromGRF(fpHitNum) return arrays of 
%               IC and TO events, in analog frames, one per FP hit, 
%               in the order specified by tInfo.FP.
%
% Aseth Sep-07, streamlined from ASA, 9-05
%
% NOTE: This code is being saved for use as part of a project
% undertaken by Duncan Bakke at the Auckland Bioengineering Institute.
% The original can be found at
% http://simtk-confluence.stanford.edu:8080/display/OpenSim/Tools+for+Preparing+Motion+Data
% Delp SL, Anderson FC, Arnold AS, Loan P, Habib A, John CT, Guendelman E, Thelen DG. 
% OpenSim: Open-source Software to Create and Analyze Dynamic Simulations of Movement. 
% IEEE Transactions on Biomedical Engineering. (2007) 

[nf, nFP] = size(verticalGRF);

% get the rate of change of the vertical ground reacction forces
dVgrf = deriv(verticalGRF, 1);

% get block of vertical forces greater than a threshold, indicating 'contact'
threshold = rel_thresh*max(max(verticalGRF));     % in units of Newtons
in_contact = (verticalGRF > threshold);
% get blocks for making or breaking contact;
make_contact = in_contact & (dVgrf > 0);
break_contact = in_contact & (dVgrf < 0);
   

% for each 
for I = 1:nFP,
    % Get first making contact frame corresponding to IC events.
    make_inds = find(make_contact(:,I));
    if ~isempty(make_inds)
        icFromGRF(I) = min(make_inds);
    end
    % Get last breaking contact frame corresponding to TO events.
        break_inds = find(break_contact(:,I));
    if ~isempty(break_inds)
        toFromGRF(I) = max(break_inds);
    end
end
    
