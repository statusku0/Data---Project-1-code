function testingbranches(Tooth1,Tooth2,WhichTeethSequence,rslt_mat)

load(rslt_mat)

WhichTeethSequence = str2num(WhichTeethSequence);

%% WhichTeethstuff
WhichTeethSeq{1} = [5];
WhichTeethSeq{2} = [3,7];
WhichTeethSeq{3} = [2,5,8];
WhichTeethSeq{4} = [1,4,6,9];
WhichTeethSeq{5} = [1,3,5,7,9];
WhichTeethSeq{6} = [1,3,5,6,8,10];
WhichTeethSeq{7} = [1,3,4,6,7,8,10];
WhichTeethSeq{8} = [1,3,4,5,6,7,8,10];
WhichTeethSeq{9} = [1,2,3,4,5,6,7,8,10];
WhichTeethSeq{10} = [1,2,3,4,5,6,7,8,9,10];

% %% preparation
% clear all;
% close all;
% path(pathdef);
% addpath(path,genpath([pwd '/utils/']));

%% settings
DensityRange = 100:50:2000;
% WhichTeeth = [5];
% Tooth1 = 'a10';
% Tooth2 = 'a13';
AngleIncrement = 0.03;

%% calculations
for k1 = 1:length(DensityRange)
    lmkMSEResult{k1} = TestingOneBranch(WhichTeethSeq{WhichTeethSequence},Tooth1,Tooth2,DensityRange(k1),AngleIncrement);
    disp([num2str(DensityRange(k1)) ' Point Density Done'])
end



%% saving results
LMSErslt{WhichTeethSequence} = lmkMSEResult;
save(rslt_mat,'LMSErslt')
disp([num2str(WhichTeethSequence) ' Intermediate Teeth Results Saved']) 
end

