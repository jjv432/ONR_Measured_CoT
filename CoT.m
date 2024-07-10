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

current_1 = motor_data.bus_current(:,1);
current_2 = motor_data.bus_current(:,2);

voltage_1 = motor_data.bus_voltage(:,1);
voltage_2 = motor_data.bus_voltage(:,2);

%P = I*V
Power_1_electrical = current_1 .* voltage_1;
Power_2_electrical = current_2 .*voltage_2;

%% Average Velocity

%Orientation is in pulses!
orientation = boom_data.orientation; 

%Angular Orientation is in degrees
Angular_Orientation = encoder_interpreter(orientation);


%% Calculating V

user_time = boom_data.time;
normalized_time = user_time - user_time(1);

%Angular velocity in rad/s
Angular_Velocity = user_input_velocity(normalized_time, Angular_Orientation);

boom_radius = 1.14; %[m]
linear_velocity = Angular_Velocity * boom_radius;


%% Cost of Transport
%Calculating cost of transport using: COT = P/(m*g*v)

mass_total = 1.7982; %mass in kg of the hip and foot assembly.
g = 9.81; %[m/s/s]

Power_total_electrical = Power_1_electrical + Power_2_electrical;

Cost = mean(Power_total_electrical)/((mass_total)*g*abs(linear_velocity));

fprintf("The cost is %f \n\n", Cost)
    