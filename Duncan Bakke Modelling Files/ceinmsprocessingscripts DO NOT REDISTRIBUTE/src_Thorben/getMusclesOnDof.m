%__________________________________________________________________________
% Author: Claudio Pizzolato, August 2014
% email: claudio.pizzolato@griffithuni.edu.au
% DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
%

function [ muscleList ] = getMusclesOnDof( dofName, osimModel )

    import org.opensim.modeling.*;
    if ischar(osimModel)
        osimModel = Model(osimModel);
    end

    [jointName, dofFound] = findJointWithDof( dofName, osimModel);
    
    osimMuscles = osimModel.getMuscles();
    muscleList = {};
    for i = 0:osimMuscles.getSize()-1
        currentMuscleName = char(osimMuscles.get(i).getName());
        if osimMuscles.get(i).get_isDisabled == 0 %HXH: skip if muscle is disabled
            jointList = getJointsSpannedByMuscle(osimModel, currentMuscleName);
            if(any(strcmp(jointList, jointName)))
                muscleList = [muscleList, currentMuscleName];
            end
        end
    end
end

