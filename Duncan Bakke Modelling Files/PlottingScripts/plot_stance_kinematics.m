function err = plot_stance_kinematics(leftTrajectory,rightTrajectory,leftStDev,rightStDev,forPlotting, name)
% This will plot the stance data (left and right if it exists)
err = 0;
plot_R = 'y';
plot_L = 'y';
subject_name = name;
hipFlexionIndex = find(ismember(forPlotting,'hip_flexion'))+1;
hipAdductionIndex = find(ismember(forPlotting,'hip_adduction'))+1;
hipRotationIndex = find(ismember(forPlotting,'hip_rotation'))+1;
kneeFlexionIndex = find(ismember(forPlotting,'knee_angle'))+1;
ankleFlexionIndex = find(ismember(forPlotting,'ankle_angle'))+1;
ankleRotationIndex = find(ismember(forPlotting,'subtalar_angle'))+1;

%%%%%%%%%%%%%%%%% PLOT HIP FLEXION ANGLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_R == 'y'
    mean_m=rightTrajectory(:,hipFlexionIndex);
    stdev_m=rightStDev(:,hipFlexionIndex);
else
    mean_m=leftTrajectory(:,hipFlexionIndex);
    stdev_m=leftStDev(:,hipFlexionIndex);
end
x=[1:101]';
zero_line=zeros(1,101)';
tmpx = [x ; flipud(x) ; x(1)];
tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
%% Figure 1 Hip Joint Flexion
figure1 = figure('Color',[1 1 1],'Position',[385 306 560 462]);
%% Create axes
axes1 = axes(...
    'FontName','Arial',...
    'Position',[0.1 0.65 0.21 0.17],...
    'XColor',[0.502 0.502 0.502],...
    'YColor',[0.502 0.502 0.502],...
     'Parent',figure1);
axis(axes1,[1 100 -inf inf]);
title(axes1,'Hip Flexion');
xlabel(axes1,'% Stride');
ylabel(axes1,'Angle [deg]');
hold(axes1,'all');
plot1=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes1);
box on

% Plot the peak values on the graph

% imin = find(min(mean_m) == mean_m);		% Find the index of the min and max
% imax = find(max(mean_m) == mean_m);
% text(x(imin),mean_m(imin),[num2str(round(mean_m(imin)))],...
%     'VerticalAlignment','bottom',...
% 	'HorizontalAlignment','right',...
% 	'FontSize',8);
% text(x(imax),mean_m(imax),[num2str(round(mean_m(imax)))],...
% 	'VerticalAlignment','bottom',...
% 	'HorizontalAlignment','right',...
% 	'FontSize',8);

hold on
fill(tmpx,tmpy,[0.39 0.47 0.64],'LineStyle','none');
plot(mean_m,'LineWidth',1,'Parent',axes1);
plot(zero_line,'k','Parent',axes1);
if plot_L == 'y'
    mean_m=leftTrajectory(:,hipFlexionIndex);
    stdev_m=leftStDev(:,hipFlexionIndex);
    tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
    plot1=plot(x,mean_m,'-'); %tmpx,tmpy,'Parent',axes1);
    fill(tmpx,tmpy,[0.58 0.39 0.39],'LineStyle','none'); % or 
    plot(mean_m,'r','LineWidth',1,'Parent',axes1);
    alpha(0.5)
    
end

h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(.1,0.98,['Walking Kinematics :: ' subject_name])
text(.92,0.98,['Left (red) Right (blue)'],'HorizontalAlignment','right');

hold off

%%%%%%%%%%%%%%%%% PLOT HIP ADDUCTION ANGLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_R == 'y'
    mean_m=rightTrajectory(:,hipAdductionIndex);
    stdev_m=rightStDev(:,hipAdductionIndex);
else
    mean_m=leftTrajectory(:,hipAdductionIndex);
    stdev_m=leftStDev(:,hipAdductionIndex);
end
x=[1:101]';
zero_line=zeros(1,101)';
tmpx = [x ; flipud(x) ; x(1)];
tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
axes2 = axes(...
  'FontName','Arial',...
  'Position',[0.4 0.65 0.21 0.17],...
  'XColor',[0.502 0.502 0.502],...
  'YColor',[0.502 0.502 0.502],...
  'Parent',figure1);
axis(axes2,[1 100 -inf inf]);
title(axes2,'Hip Adduction');
xlabel(axes2,'% Stride');
ylabel(axes2,'Angle [deg]');
hold(axes2,'all');
plot2=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes2);
box on
hold on
fill(tmpx,tmpy,[0.39 0.47 0.64],'LineStyle','none');
plot(mean_m,'LineWidth',1,'Parent',axes2);
plot(zero_line,'k','Parent',axes2);
if plot_L == 'y'
    mean_m=leftTrajectory(:,hipAdductionIndex);
    stdev_m=leftStDev(:,hipAdductionIndex);
    tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
    plot1=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes2);
    fill(tmpx,tmpy,[0.58 0.39 0.39],'LineStyle','none');
    plot(mean_m,'r','LineWidth',1,'Parent',axes2);
    alpha(0.5)
end
hold off


%%%%%%%%%%%%%%%%% PLOT HIP ROTATION ANGLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_R == 'y'
    mean_m=rightTrajectory(:,hipRotationIndex);
    stdev_m=rightStDev(:,hipRotationIndex);
else
    mean_m=leftTrajectory(:,hipRotationIndex);
    stdev_m=leftStDev(:,hipRotationIndex);
end
x=[1:101]';
zero_line=zeros(1,101)';
tmpx = [x ; flipud(x) ; x(1)];
tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
axes3 = axes(...
  'FontName','Arial',...
 'Position',[0.7 0.65 0.21 0.17],...
  'XColor',[0.502 0.502 0.502],...
  'YColor',[0.502 0.502 0.502],...
  'Parent',figure1);
axis(axes3,[1 100 -inf inf]);
title(axes3,'Hip Rotation');
xlabel(axes3,'% Stride');
ylabel(axes3,'Angle [deg]');
hold(axes3,'all');
plot3=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes3);
box on
hold on
fill(tmpx,tmpy,[0.39 0.47 0.64],'LineStyle','none');
plot(mean_m,'LineWidth',1,'Parent',axes3);
plot(zero_line,'k','Parent',axes3);
if plot_L == 'y'
    mean_m=leftTrajectory(:,hipRotationIndex);
    stdev_m=leftStDev(:,hipRotationIndex);
    tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
    plot1=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes3);
    fill(tmpx,tmpy,[0.58 0.39 0.39],'LineStyle','none');
    plot(mean_m,'r','LineWidth',1,'Parent',axes3);
    alpha(0.5)
end
hold off

%%%%%%%%%%%%%%%%% PLOT KNEE FLEXION ANGLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_R == 'y'
    mean_m=rightTrajectory(:,kneeFlexionIndex);
    stdev_m=rightStDev(:,kneeFlexionIndex);
else
    mean_m=leftTrajectory(:,kneeFlexionIndex);
    stdev_m=leftStDev(:,kneeFlexionIndex);
end
x=[1:101]';
zero_line=zeros(1,101)';
tmpx = [x ; flipud(x) ; x(1)];
tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];

%% Create axes
axes4 = axes(...
  'FontName','Arial',...
 'Position',[0.1 0.38 0.21 0.17],...
  'XColor',[0.502 0.502 0.502],...
  'YColor',[0.502 0.502 0.502],...
  'Parent',figure1);
axis(axes4,[1 100 -inf inf]);
title(axes4,'Knee Flexion');
xlabel(axes4,'% Stride');
ylabel(axes4,'Angle [deg]');
hold(axes4,'all');
plot4=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes4);
box on
hold on
fill(tmpx,tmpy,[0.39 0.47 0.64],'LineStyle','none');
plot(mean_m,'LineWidth',1,'Parent',axes4);
plot(zero_line,'k','Parent',axes4);
if plot_L == 'y'
    mean_m=leftTrajectory(:,kneeFlexionIndex);
    stdev_m=leftStDev(:,kneeFlexionIndex);
    tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
    plot1=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes4);
    fill(tmpx,tmpy,[0.58 0.39 0.39],'LineStyle','none');
    plot(mean_m,'r','LineWidth',1,'Parent',axes4);
    alpha(0.5)
end
hold off


%%%%%%%%%%%%%%%%% PLOT ANKLE FLEXION ANGLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_R == 'y'
    mean_m=rightTrajectory(:,ankleFlexionIndex);
    stdev_m=rightStDev(:,ankleFlexionIndex);
else
    mean_m=leftTrajectory(:,ankleFlexionIndex);
    stdev_m=leftStDev(:,ankleFlexionIndex);
end
x=[1:101]';
zero_line=zeros(1,101)';
tmpx = [x ; flipud(x) ; x(1)];
tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
axes5 = axes(...
  'FontName','Arial',...
 'Position',[0.4 0.38 0.21 0.17],...
  'XColor',[0.502 0.502 0.502],...
  'YColor',[0.502 0.502 0.502],...
  'Parent',figure1);
axis(axes5,[1 100 -inf inf]);
title(axes5,'Ankle Angle');
xlabel(axes5,'% Stride');
ylabel(axes5,'Angle [deg]');
hold(axes5,'all');
plot5=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes5);
box on
hold on
fill(tmpx,tmpy,[0.39 0.47 0.64],'LineStyle','none');
plot(mean_m,'LineWidth',1,'Parent',axes5);
plot(zero_line,'k','Parent',axes5);
if plot_L == 'y'
    mean_m=leftTrajectory(:,ankleFlexionIndex);
    stdev_m=leftStDev(:,ankleFlexionIndex);
    tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
    plot1=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes5);
    fill(tmpx,tmpy,[0.58 0.39 0.39],'LineStyle','none');
    plot(mean_m,'r','LineWidth',1,'Parent',axes5);
    alpha(0.5)
end
hold off

%%%%%%%%%%%%%%%%% PLOT KNEE INT/EXT ROT ANGLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_R == 'y'
    mean_m=rightTrajectory(:,ankleRotationIndex);
    stdev_m=rightStDev(:,ankleRotationIndex);
else
    mean_m=leftTrajectory(:,ankleRotationIndex);
    stdev_m=leftStDev(:,ankleRotationIndex);
end
x=[1:101]';
zero_line=zeros(1,101)';
tmpx = [x ; flipud(x) ; x(1)];
tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];

axes6 = axes(...
  'FontName','Arial',...
 'Position',[0.7 0.38 0.21 0.17],...
  'XColor',[0.502 0.502 0.502],...
  'YColor',[0.502 0.502 0.502],...
  'Parent',figure1);
axis(axes6,[1 100 -inf inf]);
title(axes6,'Ankle Rotation');
xlabel(axes6,'% Stride');
ylabel(axes6,'Moment [Nm/kg]');
hold(axes6,'all');
plot6=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes6);
box on
hold on
fill(tmpx,tmpy,[0.39 0.47 0.64],'LineStyle','none');
plot(mean_m,'LineWidth',1,'Parent',axes6);
plot(zero_line,'k','Parent',axes6);
if plot_L == 'y'
    mean_m=leftTrajectory(:,ankleRotationIndex);
    stdev_m=leftStDev(:,ankleRotationIndex);
    tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
    plot1=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes6);
    fill(tmpx,tmpy,[0.58 0.39 0.39],'LineStyle','none');
    plot(mean_m,'r','LineWidth',1,'Parent',axes6);
    alpha(0.5)
end
hold off


% %%%%%%%%%%%%%%%%% PLOT ANKLE FLEX/EXT ANGLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if plot_R == 'y'
%     mean_m=mean_R_ankleFlexion';
%     stdev_m=std_R_ankleFlexion';
% else
%     mean_m=mean_L_ankleFlexion';
%     stdev_m=std_L_ankleFlexion';
% end
% x=[1:101]';
% zero_line=zeros(1,101)';
% tmpx = [x ; flipud(x) ; x(1)];
% tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
% 
% axes7 = axes(...
%   'FontName','Arial',...
%  'Position',[0.7 0.65 0.21 0.17],...
%   'XColor',[0.502 0.502 0.502],...
%   'YColor',[0.502 0.502 0.502],...
%   'Parent',figure1);
% axis(axes7,[1 100 -inf inf]);
% title(axes7,'Ankle Dorsiflexion');
% hold(axes7,'all');
% plot7=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes7);
% box on
% hold on
% fill(tmpx,tmpy,[0.39 0.47 0.64],'LineStyle','none');
% plot(mean_m,'LineWidth',1,'Parent',axes7);
% plot(zero_line,'k','Parent',axes7);
% if plot_L == 'y'
%     mean_m=mean_L_ankleFlexion';
%     stdev_m=std_L_ankleFlexion';
%     tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
%     plot1=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes7);
%     fill(tmpx,tmpy,[0.58 0.39 0.39],'LineStyle','none');
%     plot(mean_m,'r','LineWidth',1,'Parent',axes7);
%     alpha(0.5)
% end
% hold off
% 
% 
% %%%%%%%%%%%%%%%%% PLOT ANKLE ADDUCTION ANGLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if plot_R == 'y'
%     mean_m=mean_R_ankleAdduction';
%     stdev_m=std_R_ankleAdduction';
% else
%     mean_m=mean_L_ankleAdduction';
%     stdev_m=std_L_ankleAdduction';
% end
% x=[1:101]';
% zero_line=zeros(1,101)';
% tmpx = [x ; flipud(x) ; x(1)];
% tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
% 
% axes8 = axes(...
%   'FontName','Arial',...
%  'Position',[0.7 0.38 0.21 0.17],...
%   'XColor',[0.502 0.502 0.502],...
%   'YColor',[0.502 0.502 0.502],...
%   'Parent',figure1);
% axis(axes8,[1 100 -inf inf]);
% title(axes8,'Ankle Adduction');
% hold(axes8,'all');
% plot8=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes8);
% box on
% hold on
% fill(tmpx,tmpy,[0.39 0.47 0.64],'LineStyle','none');
% plot(mean_m,'LineWidth',1,'Parent',axes8);
% plot(zero_line,'k','Parent',axes8);
% if plot_L == 'y'
%     mean_m=mean_L_ankleAdduction';
%     stdev_m=std_L_ankleAdduction';
%     tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
%     plot1=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes8);
%     fill(tmpx,tmpy,[0.58 0.39 0.39],'LineStyle','none');
%     plot(mean_m,'r','LineWidth',1,'Parent',axes8);
%     alpha(0.5)
% end
% hold off
% 
% 
% %%%%%%%%%%%%%%%%% PLOT ANKLE INT/EXT ROTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if plot_R == 'y'
%     mean_m=mean_R_ankleInversion';
%     stdev_m=std_R_ankleInversion';
% else
%     mean_m=mean_L_ankleInversion';
%     stdev_m=std_L_ankleInversion';
% end
% x=[1:101]';
% zero_line=zeros(1,101)';
% tmpx = [x ; flipud(x) ; x(1)];
% tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
% 
% axes9 = axes(...
%   'FontName','Arial',...
%  'Position',[0.7 0.11 0.21 0.17],...
%   'XColor',[0.502 0.502 0.502],...
%   'YColor',[0.502 0.502 0.502],...
%   'Parent',figure1);
% axis(axes9,[1 100 -inf inf]);
% title(axes9,'Ankle Inversion');
% xlabel(axes9,'% Stride');
% hold(axes9,'all');
% plot9=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes9);
% box on
% hold on
% fill(tmpx,tmpy,[0.39 0.47 0.64],'LineStyle','none');
% plot(mean_m,'LineWidth',1,'Parent',axes9);
% plot(zero_line,'k','Parent',axes9);
% if plot_L == 'y'
%     mean_m=mean_L_ankleInversion';
%     stdev_m=std_L_ankleInversion';
%     tmpy = [mean_m+stdev_m ; flipud(mean_m-stdev_m) ; mean_m(1)+stdev_m(1)];
%     plot1=plot(x,mean_m,'-'); %,tmpx,tmpy,'Parent',axes9);
%     fill(tmpx,tmpy,[0.58 0.39 0.39],'LineStyle','none');
%     plot(mean_m,'r','LineWidth',1,'Parent',axes9);
%     alpha(0.5)
% end
% hold off
% 
% 
% % Plot logo on top middle of graphs
% axes10 = axes('Visible','off','Parent',figure1,...
%     'Position',[0.5 1.5 0.2 0.2],...
%     'MinorGridLineStyle','none',...
%     'DataAspectRatio',[1 1 1]);
%    
% % 
% % %'ZColor',[1 1 1],...
% %     %'YDir','reverse',...
% %     %'YColor',[1 1 1],...
% %     %'XColor',[1 1 1],...
% %    % 'Units','pixels',...
% % %imagesc(logo)
% % 
% % 
% % Create image
% image(logo,'Parent',axes10,'CDataMapping','scaled');
% colormap(map)
% 
% print_filename = [results_folder '\' subject_name];
% 
% if data_to_plot == 'jog'
%  print_filename = [print_filename '_KinematicsJog'];
%  print('-dpng','-r300', print_filename)
% end
% if data_to_plot == 'run'
%  print_filename = [print_filename '_KinematicsRun'];
% print('-dpng','-r300', print_filename)
% end
% if data_to_plot == 'wlk'
%  print_filename = [print_filename '_KinematicsWalk'];
%   print('-dpng','-r300', print_filename)
end
