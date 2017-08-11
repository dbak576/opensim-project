function coords = findHJC(modelfile,side)
%findHJC: Retrieve HJC coords for model
import org.opensim.modeling.*
model = Model(fullfile(pwd,strcat(modelfile,'.osim')));
femurName = strcat('femur_',lower(side(1)));
femur = model.getBodySet.get(femurName);
hip = femur.getJoint;
coordinates = hip.get_location_in_parent;
coords = zeros(3,1);
for i = 1:3
    coords(i) = coordinates.get(i-1);
end
end

