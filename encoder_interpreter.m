function [Angular_Orientation] = encoder_interpreter(orientation)
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
end