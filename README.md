# Overview

The functions in this repo are used to measure the COT of the 5 bar linkage when ran on the boom.  

## CoT.m

This script calculates cost of transport for a trajectory ran on the CISCOR boom.
Inputs: you must run the 'loadTrajectory' and 'runTrajectory' functions written by J. Boyland to populate the values this code needs.  These functions run a trajectory on the CISCOR boom and record various motor parameters.

Outputs: This script outputs: electrical power and cost of transport.

**The funciton encoder_interpreter relies on a piece of python code being wrong for the boom encoder.  If this has been fixed, you'll need to remove the correction that is made in that function. If not, your angles will not be calculated correctly.  More details are in the function encoder_interpreter.m**

## encoder_interpreter.m

This function outputs the angular orientation of the boom given the output of the boom.
