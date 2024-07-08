function [MuK, MuS] = ONR_MuKSCalc_V2_240606(Beginning, End, FileName, StaticBool)


%{

    This function calculates the static and kinetic coefficients of
    friction, MuS and MuK respectively, by taking in as inputs the
    Beginning and End of the sampling range, the FileName of the .csv from
    the exported Optitrack file, and StaticBool which determines if
    calculations for MuS should be done.  MuS should not be calculated when
    the slider wasn't slowly elevated until breaking static friction.

    MuS is calculated as tan(phi).

    MuK is calculated using an energy balance, where the estimated linear
    velocity at Beginning and End are used to calculate Kinetic Energies
    and the change in elevation is used to calculate Potential Energy.  

%}

clearvars -except FileName End Beginning StaticBool Slider;

% Reading the 'useful' portions of the exported CSV only
SliderRaw = readmatrix(FileName, 'Range', 'A8');

%% Separating Position 1 (Beginning) and Position 2 (End)

%Columns 4 and 5 correspond to Y and Z values, respectively
Pos2Y = SliderRaw(End, 4);
Pos1Y = SliderRaw(Beginning, 4);

Pos2Z = SliderRaw(End, 5);
Pos1Z = SliderRaw(Beginning, 5);

%% Angle of Elevation Calculation

%Calculating angle from the beginning and end positions selected
phi = atand((Pos1Y - Pos2Y) / (abs(Pos1Z - Pos2Z)));

%% MuS Calculation

%Calculating MuS from tan(phi).  Unreliable is used as MuS values will be
%saved to the .mat file, and it is important to know if old files have
%reliable MuS values or not.
if (StaticBool == 'y') || (StaticBool == 'Y')
    MuS = tand(phi);
else
    MuS = "UNRELIABLE";
end

%% Calculating Linear Distance Traveled

%Calculating r, the linear distance between beginning and end positions of
%the slider.  This is useful for Work non conservative as W_nc = F*d
r = sqrt((Pos2Y - Pos1Y)^2 + (Pos2Z - Pos1Z)^2);

%% Calculating the approximate linear velocities at each pos1 and pos2

%Beginning and end time associated with the positions on the graph that the
%user clicked on
t_not_1 = SliderRaw(Beginning,2);
t_1 = SliderRaw(Beginning + 1, 2); %Useful for the linear approximation of V

t_not_2 = SliderRaw(End, 2);
t_2 = SliderRaw(End+1, 2); %Useful for the linear approximation of V


%Finding Vz at Pos1 (dZ/dt)

Z_not_1 = SliderRaw(Beginning, 5);
Z_1 = SliderRaw(Beginning+1, 5);

Vz_1 = (Z_not_1-Z_1)/(t_not_1-t_1); % Linear approx


%Finding Vz at Pos2

Z_not_2 = SliderRaw(End, 5);
Z_2 = SliderRaw(End+1, 5);

Vz_2 = (Z_not_2-Z_2)/(t_not_2-t_2);


%Finding Vy at Pos1

Y_not_1 = SliderRaw(Beginning, 4);
Y_1 = SliderRaw(Beginning+1, 4);

Vy_1 = (Y_not_1-Y_1)/(t_not_1-t_1);


%Finding Vy at Pos2

Y_not_2 = SliderRaw(End, 4);
Y_2 = SliderRaw(End+1, 4);

Vy_2 = (Y_not_2-Y_2)/(t_not_2-t_2);


%Finding Vtot at both locations (beginning and end)

V_tot_not = sqrt(Vy_1^2 + Vz_1^2);
V_tot = sqrt(Vy_2^2 + Vz_2^2);

%% Mu Calculation
g = 9.81;
delta_h = Pos1Y-Pos2Y; % change in height between the beginning and end

% Value of mu calculated using an energy balance equation where Eo = K + PE
% and E = K + E_nc
MuK = (.5*(V_tot_not^2 - V_tot^2) +g*delta_h) / (g*cosd(phi)*r);

%% Cleanup and Output

close all

fprintf("\n\nKinetic coefficient of friction: %f \n", MuK);

if (StaticBool == 'y') || (StaticBool == 'Y')
    fprintf("Static coefficient of friction: %f \n\n", MuS);
end

end