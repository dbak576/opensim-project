%__________________________________________________________________________
% Author: Claudio Pizzolato, August 2014
% email: claudio.pizzolato@griffithuni.edu.au
% DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
%

function [ jointName, found ] = findJointWIthDof( dofName, osimModel )

    import org.opensim.modeling.*;
    if ischar(osimModel)
        osimModel = Model(osimModel);
    end

    jointSet = osimModel.getJointSet();
    nJoints = jointSet.getSize();
    jointName = '';
    for i = 0:nJoints-1
        found = hasDof(dofName, jointSet.get(i));
        if(found)
            jointName = char(jointSet.get(i).getName());
            break
        end
    end
end

function [ found ] = hasDof(dofName, osimJoint) 
    coordinateSet = osimJoint.getCoordinateSet();
    nCoordinates = coordinateSet.getSize();
    found = false;
    for i = 0:nCoordinates-1
        name = coordinateSet.get(i).getName(); 
        if name == dofName
            found = true;
            break
        end
    end
end

