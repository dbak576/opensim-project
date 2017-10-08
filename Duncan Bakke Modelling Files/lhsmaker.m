    boundWidth = 0.02;
    points = 150;
    originalCoords = findHJC('H23s1','r');

    coords = lhsdesign(points,3);
    coords = coords.*boundWidth;
    coords = coords-(boundWidth/2);
    for i = 1:points
        coords(i,:) = coords(i,:)+originalCoords';
    end
    numPoints = points;
    
    hjcfile = fopen('HJCcoords150.txt','w');
    
    for i = 1:numPoints
        newCoords = coords(i,:);
        fprintf(hjcfile,'%f %f %f ',newCoords);
        fprintf(hjcfile,'\n');
    end