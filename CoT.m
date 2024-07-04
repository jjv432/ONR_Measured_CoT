clc
close all
format compact

%% Power and COT

%% Power From I*V

%*** Doesnt seem right!!!!!!!!********************************************

%Rough power estimate.  May not be high fidelity

for i = 1:length(boom.Motors.Recorder.Data)

    
    [current_1(i), current_2(i)] = boom.Motors.Recorder.Data(i).infos.iq_measured;
    [voltage_1(i), voltage_2(i)] = boom.Motors.Recorder.Data(i).infos.bus_voltage;


end

Power_1 = current_1 .* voltage_1;
Power_2 = current_2 .*voltage_2;

% Power_1(Power_1<0) = 0;
% Power_2(Power_2<0) = 0;


%% Power From Torque

Power_1_A = motor_data.motor_vel(:,1) .* motor_data.motor_trq(:,1);
Power_2_A = motor_data.motor_vel(:,2) .* motor_data.motor_trq(:,2);

%delta_P_1 = Power_1 - Power_1_A';

% figure()
%     plot(1:length(delta_P_1), delta_P_1)

%% Average Velocity

orientation = boom_data.orientation; %Degrees??
time = boom_data.time;

% Pulse_per_Rev = 4096;
% Output_Teeth = 198;
% Input_Teeth = 20;
% 
% Angular_Orientation = orientation / (360/(Pulse_per_Rev * 4 * Output_Teeth / Input_Teeth));

corrected_orientation = orientation * 160000/162201.6;

Angular_Orientation = 360 * corrected_orientation;

%% Calculating V


fig = figure;
        plot((time - time(1)), Angular_Orientation);
        title('Sliding Plot')
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

v = 1.14 * (orientation(user_End) - orientation(user_Beginning))/(time(user_End) - time(user_Beginning));


























%% CoT

%using eqn from Ash paper

M  = 10; %%%%Mass of the whole hip
m_l = 1; %%%%Mass of just the leg
g = 9.81;

Power_tot = Power_1 + Power_2;

Cost = Power_tot/((M + m_l)*g*abs(v));

figure()
    plot(Cost)