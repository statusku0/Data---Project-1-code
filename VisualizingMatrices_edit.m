%%% preparation
clear all;
close all;
path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%%% settings
NumSamples = 2;

%%% paths
base_path = 'C:/Users/Kevin/Documents/MATLAB/cPdist-master/';

%%% getting improved distance matrices
for k1 = 0:NumSamples
    dist{k1+1} = load([base_path 'DistRslts' num2str(k1) 'SampleTestImproved/cPMSTDistMatrix.mat']);
    dist{k1+1} = dist{k1+1}.ImprDistMatrix;
    dist{k1+1} = dist{k1+1}(1:116,1:116);
end

%%% getting improved landmark matrices
for k1 = 0:NumSamples
    lmk{k1+1} = load([base_path 'DistRslts' num2str(k1) 'SampleTestImproved/cPMSTlmkMSEMatrix.mat']);
    lmk{k1+1} = lmk{k1+1}.lmkMSEMatrix;
    lmk{k1+1} = lmk{k1+1}(1:116,1:116);
end

%%% visualizing everything 
for k1 = 0:NumSamples
    figure;
    imagesc(dist{k1+1}./max(dist{k1+1}(:))*64);
    title(['Dist' num2str(k1) 'Intermediate Teeth'])
    axis equal
    axis([1,116,1,116])
    figure;
    imagesc(lmk{k1+1}./max(lmk{k1+1}(:))*64);
    title(['Lmk' num2str(k1) 'Intermediate Teeth'])
    axis equal
    axis([1,116,1,116])
end

%%% making diagonals equal 1
for k1 = 0:NumSamples
    moddist{k1+1} = dist{k1+1};
    modlmk{k1+1} = lmk{k1+1};
    for k2 = 1:116
        for k3 = 1:116
            if k2 == k3
            moddist{k1+1}(k2,k3) = 1;
            modlmk{k1+1}(k2,k3) = 1;
            end
        end
    end
end

%%% visualizing ratios
for k1 = 1:NumSamples
    figure;
    imagesc(moddist{k1+1}./moddist{1});
    title(['Dist' num2str(k1) 'Sample/0Sample'])
    axis equal
    axis([1,116,1,116])
    figure;
    imagesc(modlmk{k1+1}./modlmk{1});
    title(['Lmk' num2str(k1) 'Sample/0Sample'])
    axis equal
    axis([1,116,1,116])
end

    