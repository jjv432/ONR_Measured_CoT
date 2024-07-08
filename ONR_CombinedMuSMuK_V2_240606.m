clc
clearvars
close all
format compact

%% Notes

%{

    Use this script to call the frameParser and MuKSCalc functions.  This
    file will allow you to use multiple .csv files for each material that
    you tested to calculate the appropriate MuS and MuK values.  Ensure
    that the experimental setup matches the README file.  Also, MuS can
    only be calculated if the sliding angle is slowly increased from zero.
    MuK values are most accurate if held at a constant, steep angle such
    that there is not intermittent pausing as the slider desends.

%}

%%  General Input from the use
NumMaterials = input("Enter the number of materials tested: ");

%% Calculating Mu
fprintf("\n******** WARNING: STATIC COEFF OF FRICTION ONLY RELIABLE IF SLIDER BEGAN AT REST ********\n");
StaticBool = input("With this in mind, do you want to calculate the static coefficient of friction? (Y/N): ", 's');
fprintf("\n\n")

for j = 1:NumMaterials %Allows multiple materials to be analyzed together
    fprintf("Material #%d:\n", j);
    FileName = input("Enter the filename without extension: ", "s");

    %Finding information about the material used, and the number of trials
    %used for this material
    Material = input("Enter the name of the material that you will be using: ", "s");
    MaterialNames(j) = string(Material); %Storing for later
    
    %Using frameParse to find the frame numbers and number of trials for a
    %material
    [Frames, doubleTrials] = ONR_frameParser_240606(FileName);
    
    close all

    tempMuK = [];
    tempMuS = [];

    %Calculating MuK and MuS and storing these values into a struct.
    for a = 1:2:doubleTrials

        [MuK, MuS] = ONR_MuKSCalc_V2_240606(Frames(a), Frames(a+1), strcat(FileName, '.csv'), StaticBool);
        MuKS.(Material).(strcat("Trial", num2str(.5+ a/2 ), 'k')) = MuK;
        MuKS.(Material).(strcat("Trial", num2str(.5+ a/2), 's')) = MuS;
        tempMuK = [tempMuK; MuK];
        tempMuS = [tempMuS; MuS];

    end
    
    %Calculating and storing the mean values for Mu
    tempMeanK = mean(tempMuK);
    MuKS.(Material).AvgMuK = tempMeanK;
    KMeans(j) = tempMeanK;
    
    if (StaticBool == 'Y') || (StaticBool == 'y')
        tempMeanS = mean(tempMuS);
        MuKS.(Material).AvgMuS = tempMeanS;
        SMeans(j) = tempMeanS;
        
    end


    MuKS.(Material).MuKList = tempMuK;
    MuKS.(Material).MuSList = tempMuS;

    clearvars -except MuKS FileName MaterialNames StaticBool KMeans SMeans
end

%Storing the list of materials tested into the struct
MuKS.Materials = MaterialNames;

%Only storing static information if necessary
if (StaticBool == 'Y') || (StaticBool == 'y')
MuKS.SMeans = [MaterialNames', SMeans'];
end

%Storing the means of all the materials together for convenience.
MuKS.KMeans = [MaterialNames', KMeans'];

%Allowing user to save the struct for later review
SaveBool = input("Do you want to save this data struct to a .mat file? (Y/N): ", 's');

if (SaveBool == 'Y')||(SaveBool == 'y')
    SaveName = input("What would you like to name this saved data struct? ", 's');
    save(strcat(SaveName,".mat"),"-struct","MuKS");
    fprintf("\n***Saved to .mat file***\n")
else
    fprintf("\n***Data not saved to .mat file***\n")
end

clear SaveBool MaterialNames