Update = 'on';

%% preparation
path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%% Update
if strcmp(Update,'on')
    D = dir('C:/Users/Kevin/Documents/MATLAB/cPdist-master/NumDensityRslts');
    pairlist = {};
    for k1 = 3:length(D)
        pairlist{(k1-2),1} = strtok(D(k1).name(7:end),'_');
        revname = strtok(D(k1).name(end:-1:7),'_');
        pairlist{(k1-2),2} = revname(end:-1:1);
    end
    for k1 = 1:size(pairlist,1)
        progressbar(k1,size(pairlist,1),size(pairlist,1))
        AnalyzingNumDensityRslts(pairlist{k1,1},pairlist{k1,2},'off','keep')
    end
end

%% load files (adjust third file name accordingly)
load('C:/Users/Kevin/Documents/MATLAB/cPdist-master/DistRslts0Sample/cPDistMatrix.mat')
load('C:/Users/Kevin/Documents/MATLAB/cPdist-master/ratioRank.mat')
load('C:/Users/Kevin/Documents/MATLAB/cPdist-master/TopcoefRank.mat')
load('C:/Users/Kevin/Documents/MATLAB/cPdist-master/TopinterceptRank.mat')
load('C:/Users/Kevin/Documents/MATLAB/cPdist-master/TopDencoefRank.mat')
%% create Dist matrix
Dist = zeros(116,116);
for k1 = 1:116
    for k2 = 1:116
        if ratioRank(k1,k2) ~= 0
            Dist(k1,k2) = cPDistMatrix(k1,k2);
        end
    end
end

co = polyfit(Dist(find(Dist(:))),TopcoefRank(find(ratioRank(:))),1);
xmodel = linspace(0.018,0.05,100);

%% plot results (adjust second option of scatter accordingly) 
figure;scatter(Dist(find(Dist(:))),TopcoefRank(find(ratioRank(:))));
% hold on 
% plot(xmodel,co(1).*xmodel + co(2))
% hold off
title('cPdist vs. Rate of ratio decline (using NumDensity w/ largest r^2)')
xlabel('cPdist')
ylabel('rate of ratio decline (ratio units / intermediate tooth)')

figure;scatter(Dist(find(Dist(:))),TopinterceptRank(find(ratioRank(:))));
title('cPdist vs. Intercept of best-fit linear model (using NumDensity w/ largest r^2)')
xlabel('cPdist')
ylabel('Intercept')

figure;scatter(Dist(find(Dist(:))),TopDencoefRank(find(ratioRank(:))));

