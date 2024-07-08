clc
close all
format compact

%% Power and COT

%{
    Jack Vranicar
    7/8/24
    jjv20@fsu.edu

    This script calculates cost of transport for a trajectory ran on the
    CISCOR boom.
    
    Inputs: you must run the 'loadTrajectory' and 'runTrajectory' functions
    written by J. Boyland to populate the values this code needs.  These
    functions run a trajectory on the CISCOR boom and record various motor
    parameters.

    Outputs: This script outputs: electrical power, mechanical power, and
    cost of transport.

%}

%% Power From I*V

% This loop creates arrays for the electrical current and voltage measured
% across motors 1 and 2
for i = 1:length(boom.Motors.Recorder.Data)
    
    [current_1(i), current_2(i)] = boom.Motors.Recorder.Data(i).infos.iq_measured;
    [voltage_1(i), voltage_2(i)] = boom.Motors.Recorder.Data(i).infos.bus_voltage;

end

%P = I*V
Power_1_electrical = current_1 .* voltage_1;
Power_2_electrical = current_2 .*voltage_2;

%Ignoring negative power.  This is because if the power is negative, that
%means that the other motor is powering it.  If negative values were
%included in a sum (P1 + P2), the fact that one motor is driving another
%would be ignored.
Power_1_electrical(Power_1_electrical<0) = 0;
Power_2_electrical(Power_2_electrical<0) = 0;


%% Power From Torque
%Unfinished.  Unclear if there is a phase shift for mechanical power

%P = tau * omega.  These are the 'commanded' torque and measured omega
%values for each of the motors.
Power_1_mechanical = motor_data.motor_vel(:,1) .* motor_data.motor_trq(:,1);
Power_2_mechanical = motor_data.motor_vel(:,2) .* motor_data.motor_trq(:,2);

%Mechanical losses due to heat and friction
mechanical_loss_1 = Power_1_electrical - Power_1_mechanical;
mechanical_loss_2 = Power_2_electrical - Power_2_mechanical;

figure()
    plot(1:length(mechanical_loss_1), mechanical_loss_1)
    hold on
    plot(1:length(mechanical_loss_2), mechanical_loss_2)
    hold off
    xlabel('Time')
    ylabel("Mechanical Loss (W)")
    title("Mechanical Losses in Motors 1 and 2")
    legend("Motor 1", "Motor 2")

%% Average Velocity

%Orientation is in pulses!
orientation = boom_data.orientation; 
time = boom_data.time;

%This is a (sloppy) fix for the python code used to interpret the encoder
%pulses.  The python code has 160,000 pulses per revolution (PPR), which is
%incorrect. python_PPR is the wrong value, actual_PPR is the correct value.

python_PPR = 160000; %This is the eroneous value in the python code.

encoder_PPR = 4096; %Rated PPR of the encoder
quadrature_factor = 4;
gear_ratio = 198/20; %teeth/teeth
actual_PPR = encoder_PPR * quadrature_factor * gear_ratio;

corrected_orientation = orientation * python_PPR/actual_PPR;

Angular_Orientation = 360 * corrected_orientation; %[degrees]

%% Calculating V

normalized_time = time - time(1);

Angular_Velocity = user_input_velocity(normalized_time, Angular_Orientation);

boom_radius = 1.14; %[m]
linear_velocity = Angular_Velocity * boom_radius;


%% Cost of Transport
%Not finished!! need cost as a single value

%Calculating cost of transport using: COT = P/(m*g*v)

mass_total = 1.7982; %mass in kg of the hip and foot assembly.
g = 9.81; %[m/s/s]

Power_total_electrical = Power_1_electrical + Power_2_electrical;

Cost = Power_total_electrical/((mass_total)*g*abs(v));

figure()
    plot(Cost)