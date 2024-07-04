function [Frames, doubleTrials] = ONR_frameParser_240606(FileName)

   %{

        This function takes in as input the FileName of the .csv from the
        Optitrack takes.  The outputs 'Frames' is a list of the Frame
        numbers that the user clicked on in the figure that was created.
        These will later be used as the Beginning and End as used in
        ONR_MuKSCalc_V2_240606.  The 'doubleTrials' output counts the
        number of clicks the user inputs.  It is called double trials as
        there are two clicks per trial, thus this number is twice as large
        as the number of trials.

   %}

    %% Reading and Organizing Raw Data

    SliderRaw = readmatrix(strcat(FileName, '.csv'), 'Range', 'A8');

    %Organizing each column of the exported file.  This is hardcoded because it
    %is assumed that the exported data will only have one marker with no rigid
    %bodies. 
   
    Slider.Time = SliderRaw(:,2);
    
    Slider.Y = SliderRaw(:,4);
    
    %% User Input on Beginning and End Frames

    %Reference to how to use 'datacursormode':
    %https://www.mathworks.com/matlabcentral/answers/408991-how-to-extract-cursor-data-to-a-variable
    
    % This code allows the user to use the 'Data Tips' mode in figures to
    % select the beginning and end of sampling ranges for each trial.
    fig = figure;
        plot(Slider.Time, Slider.Y)
        title('Sliding Plot')
        xlabel('x')
        ylabel('y')
    
    datacursormode on
    dcm_obj = datacursormode(fig);
    
    % Wait while the user to click
    fprintf('Select one point, then shift click for a second point further down, then press "Enter"')
    pause
    % Export cursor to workspace
    info_struct = getCursorInfo(dcm_obj);
    
    %% Organizing User Input

    [~, doubleTrials] = size(info_struct);
    
    %Storing a list of all of the frame numbers
    Frames = [];
    for i = 1:doubleTrials

        Frames = [Frames; info_struct(i).DataIndex];

    end
    
    %Putting variables in the order of trials 
    Frames = sort(Frames, 1);
    
end