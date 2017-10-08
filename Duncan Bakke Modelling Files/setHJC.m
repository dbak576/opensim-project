function err = setHJC(modelfile,side,newCoords)
%setHJC: Summary of this function goes here
import org.opensim.modeling.*
err = 0;
model = Model(fullfile(pwd,'Output',strcat(modelfile,'.osim')));
femurName = strcat('femur_',lower(side(1)));
femur = model.getBodySet.get(femurName);
hip = femur.getJoint;
coordinates = hip.get_location_in_parent;
for i = 1:3
    coordinates.set(i-1,newCoords(i));
end
model.updJointSet();
model.print(fullfile(pwd,'Output',strcat(modelfile,'.osim')));
clear('model','femurName','femur','hip','coordinates');
end

