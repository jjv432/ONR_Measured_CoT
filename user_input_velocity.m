function [angular_velocity] = user_input_velocity(normalized_time, Angular_Orientation)


fig = figure;
        plot(normalized_time, Angular_Orientation);
        title('Anglular Orientation vs Time')
        xlabel('time')
        ylabel('theta')
    
    datacursormode on
    dcm_obj = datacursormode(fig);
    
    % Wait while the user to click
    fprintf('Select one point, then shift click for a second point further down, then press "Enter"')
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

angular_velocity = (orientation(user_End) - orientation(user_Beginning))/(time(user_End) - time(user_Beginning));

end