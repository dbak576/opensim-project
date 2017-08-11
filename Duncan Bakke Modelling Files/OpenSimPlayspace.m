z = 0.01; 
y = z; 
x = y;
err = 0;
import org.opensim.modeling.*
model = Model(fullfile(pwd,'H20s1.osim'));
femurName = strcat('femur_',lower(side(1)));
femur = model.getBodySet.get(femurName);
hip = femur.getJoint;
coordinates = hip.get_location_in_parent;
curCoords = zeros(3,1);
for i = 1:3
    curCoords(i) = coordinates.get(i-1);
end
newCoords(1) = curCoords(1) + x;
newCoords(2) = curCoords(2) + y;
newCoords(3) = curCoords(3) + z;
newCoordinates = Vec3.createFrom(newCoords);