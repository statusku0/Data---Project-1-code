clear all;
close all;
path(pathdef);
addpath(path,genpath([pwd '/utils/']));
base_path = 'C:/Users/Kevin/Documents/MATLAB/cPdist-master/';

NumSamples = 3;
Type = 'lmk';

for k1 = 0:NumSamples
    lmkmatrix{k1+1} = load(['DistRslts' num2str(k1) 'SampleImproved/' 'cPMSTlmkMSEMatrix.mat']);
    lmkmatrix{k1+1} = lmkmatrix{k1+1}.lmkMSEMatrix;
    figure(k1+1),clf
    imagesc(lmkmatrix{k1+1}./max(lmkmatrix{k1+1}(:))*64)
    axis equal;
    axis([1,116,1,116]);
    if k1 == 1
        title([num2str(k1) ' ' 'Intermediate Tooth'])
    else
        title([num2str(k1) ' ' 'Intermediate Teeth'])
    end
    colorbar
end
%%% ratio matrix
 
temp{1} = lmkmatrix{1};
temp{2} = lmkmatrix{2}(1:116,1:116);
temp{3} = lmkmatrix{3}(1:116,1:116);
for k1 = 1:(NumSamples+1)
    for k2 = 1:116
        for k3 = 1:116
            if k2 == k3
            temp{k1}(k2,k3) = 1;
            end
        end
    end
end

lmk0 = temp{1};
lmk1 = temp{2};
lmk2 = temp{3};

figure;imagesc(lmk1./lmk0);axis equal;axis([1,116,1,116]);
title('Lmk Ratio (1Sample/0Sample)')
colorbar
figure;imagesc(lmk2./lmk0);axis equal;axis([1,116,1,116]);
title('Lmk Ratio (2Sample/0Sample)')
colorbar

dist0 = load([base_path 'DistRslts0SampleImproved/cPMSTDistMatrix.mat']);
dist0 = dist0.ImprDistMatrix;
dist1 = load([base_path 'DistRslts1SampleImproved/cPMSTDistMatrix.mat']);
dist1 = dist1.ImprDistMatrix;
dist2 = load([base_path 'DistRslts2SampleImproved/cPMSTDistMatrix.mat']);
dist2 = dist2.ImprDistMatrix;



for k1 = 1:116
    for k2 = 1:116
        if k1 == k2
            dist0(k1,k2) = 1;
            dist1(k1,k2) = 1;
        end
    end
end

dist1 = dist1(1:116,1:116);
dist2 = dist2(1:116,1:116);
figure;imagesc(dist1./dist0);axis equal;axis([1,116,1,116]);
title('Dist Ratio (1Sample/0Sample)');
figure;imagesc(dist2./dist0);axis equal;axis([1,116,1,116]);
title('Dist Ratio (2Sample/0Sample)');


