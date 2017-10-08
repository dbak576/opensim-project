originalHJC = findHJC('H23s1','r');
x = zeros(length(hjcsuffixes),1);
y = x;
z = y;
for i = 1:length(hjcsuffixes)
curString = hjcsuffixes{i};
inds = strfind(curString,'_');
curx = str2double(curString((inds(1)+1):(inds(2)-1)));
cury = str2double(curString((inds(2)+1):(inds(3)-1)));
curz = str2double(curString((inds(3)+1):end));
x(i) = (curx-originalHJC(1))*1000;
y(i) = (cury-originalHJC(2))*1000;
z(i) = (curz-originalHJC(3))*1000;
end
minimumAdd = round(min(maxAdduction),1);
maximumAdd = round(max(maxAdduction),1);
vals = linspace(minimumAdd,maximumAdd,5);
for i = 1:5
strvals{i} = strcat(num2str(vals(i)),' Nm');
end

maxAddFigure = plot4(x,y,z,maxAdduction,'x');
hold on
title('Maximum Hip Adduction Moment (R) for the range of tested HJC locations');
xlabel('Change in HJC Location in x direction (mm)');
ylabel('Change in HJC Location in y direction (mm)');
zlabel('Change in HJC Location in z direction (mm)');
colorbar('Ticks',[0,0.25,0.5,0.75,1],...
         'TickLabels',{strvals{1},strvals{2},strvals{3},strvals{4},strvals{5}});