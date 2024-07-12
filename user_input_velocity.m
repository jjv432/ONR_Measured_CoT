function [angular_velocity] = user_input_velocity(normalized_time, Angular_Orientation)

%{

    This allows the user to pick the starting and ending positions of the
    robot.  This ensures that any recorded time that is spent in an idle
    state is not used in the calculations for cost.

%}
fig = figure;
    subplot(2, 1, 1)
    polarplot(normalized_time, Angular_Orientation);
    title('Anglular Orientation vs Time')
    subplot(2, 1, 2)
    plot(normalized_time, Angular_Orientation);
    title('Anglular Orientation vs Time')
    xlabel('time')
    ylabel('theta')

datacursormode on
dcm_obj = datacursormode(fig);

% Wait while the user to click
fprintf('Select one point, then shift click for a second point further down, then press "Enter"\n')
pause

% Export cursor to workspace
info_struct = getCursorInfo(dcm_obj);
[~, doubleTrials] = size(info_struct);

%Storing a list of all of the frame numbers
Frames = [];
for i = 1:doubleTrials

    Frames = [Frames; info_struct(i).DataIndex];

end

%Putting variables in the order of trials
Frames = sort(Frames, 1);


user_Beginning = Frames(1);
user_End = Frames(end);

%Because angular orientation is in degrees, converting so that angular
%velocity is rad/s
angular_velocity = (pi/180)*(Angular_Orientation(user_End) - Angular_Orientation(user_Beginning))/(normalized_time(user_End) - normalized_time(user_Beginning));

end