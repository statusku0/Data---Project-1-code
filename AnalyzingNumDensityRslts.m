function AnalyzingNumDensityRslts(Tooth1,Tooth2,Figures,CloseAll)
if nargin <= 3
    CloseAll = 'keep';
    if nargin == 2
        Figures = 'off';
    elseif nargin <= 1 
        error('Not enough inputs.')
    end
end

%% preparation
% clear all;
if strcmp(CloseAll,'close')
    close all;
end
path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%% settings (add ranges as necessary)
NumDensityRange{1} = 100:50:2000;
% NumDensityRange{2} = 100:50:2000; 
% Tooth{1} = 'K04';
% Tooth{2} = 'K05';
% Figures = 'on';
Tooth{1} = Tooth1;
Tooth{2} = Tooth2;

%% checks
D = dir('C:/Users/Kevin/Documents/MATLAB/cPdist-master/NumDensityRslts');
namecheck{1} = [];
namecheck{2} = [];
pairlist = {};
for k1 = 3:length(D)
    pairlist{(k1-2),1} = strtok(D(k1).name(7:end),'_');
    revname = strtok(D(k1).name(end:-1:7),'_');
    pairlist{(k1-2),2} = revname(end:-1:1);
end
for k1 = 1:2
    for k2 = 1:size(pairlist,1)
        for k3 = 1:size(pairlist,2)
            if strcmp(pairlist{k2,k3},Tooth{k1})
                namecheck{k1} = [namecheck{k1};k2,k3];
            end
        end
    end
end
if isempty(namecheck{1}) == 0
    for k1 = 1:size(namecheck{1},1)
        tempcheck1(k1) = namecheck{1}(k1,1);
    end
else
    tempcheck1 = [];
end
if isempty(namecheck{2}) == 0
    for k1 = 1:size(namecheck{2},1)
        tempcheck2(k1) = namecheck{2}(k1,1);
    end
else
    tempcheck2 = [];
end
if strcmp(Tooth{1},Tooth{2}) == 1
    error('Same tooth used in pair')
end
if isempty(intersect(tempcheck1,tempcheck2)) == 1 
    fprintf('Here are a list of teeth pairs that are available:\n')
    for k1 = 3:length(D)
        fprintf([D(k1).name(7:end) '\n'])
    end
    if isempty(namecheck{1}) == 1 & isempty(namecheck{2}) == 0 
        error('Tooth1 name not found')
    elseif isempty(namecheck{2}) == 1 & isempty(namecheck{1}) == 0
        error('Tooth2 name not found')
    elseif isempty(namecheck{1}) == 0 & isempty(namecheck{2}) == 0
        error('Neither tooth name was found')
    end
    error('Tooth pair not found')
end
        

%% paths (add rslt_paths as necessary)
base_path = 'C:/Users/Kevin/Documents/MATLAB/cPdist-master/';
row = intersect(tempcheck1,tempcheck2);
if namecheck{2}(find(tempcheck2 == row),2) < namecheck{1}(find(tempcheck1 == row),2)
    name1 = Tooth{2};
    name2 = Tooth{1};
else 
    name1 = Tooth{1};
    name2 = Tooth{2};
end
rslt_path{1} = [base_path 'NumDensityRslts/rslts_' name1 '_' name2 '/'];
% rslt_path{2} = [base_path 'NumDensityRslts2/'];

%% load rslts and combine
for j = 1:length(rslt_path)
    for k1 = 1:10
        load([rslt_path{1} 'rslt_mat_' num2str(k1) '.mat'])
        CombLMSErslt{k1} = LMSErslt{k1};
    end
    for k1 = 1:10
        for k2 = 1:length(NumDensityRange{1})
            NewLMSErslt{k1,k2} = CombLMSErslt{k1}{k2};
        end
    end
    CombagainLMSErslt{j} = NewLMSErslt;
end
MegaLMSErslt = [];
for k1 = 1:length(CombagainLMSErslt)
    MegaLMSErslt = [MegaLMSErslt CombagainLMSErslt{k1}];
end

%% plot rslts
x = [];
for k1 = 1:length(NumDensityRange)
    x = [x NumDensityRange{k1}];
end
ratiomat = zeros(10,size(MegaLMSErslt,2));
for k1 = 1:10
    for k2 = 1:size(MegaLMSErslt,2)
        ratiomat(k1,k2) = (MegaLMSErslt{k1,k2}(2))./(MegaLMSErslt{k1,k2}(1));
    end
end
if strcmp(Figures,'on') 
    figure;
    for k1 = 1:10
        subplot(2,5,k1)
        plot(x,ratiomat(k1,:))
        hold on
        plot(x,ones(length(x)))
        axis([x(1),x(end),min(ratiomat(:)),max(ratiomat(:))])
        xlabel('NumDensity')
        ylabel('Ratio')
        title([num2str(k1) ' Int. Teeth: NumDensity vs. Ratio'])
        hold off
    end
end

%% find NumDensity with the highest r^2 and neg coef
coef = zeros(1,size(ratiomat,2));
r2 = zeros(1,size(ratiomat,2));
for k1 = 1:size(ratiomat,2)
    tempcoef = polyfit([1:10]',ratiomat(:,k1),1); 
    coef(k1) = tempcoef(1);
    intercept(k1) = tempcoef(2);
    model = fitlm([1:10]',ratiomat(:,k1)); 
    r2(k1) = model.Rsquared.Ordinary;
end

if strcmp(Figures,'on')
    figure;scatter([1:10]',ratiomat(:,find(r2 == max(r2))))
    title(['Num of Int. Teeth vs. Ratio for ' num2str(x(find(r2 == max(r2)))) ' NumDensity (NumDensity w/ largest r^2)'])
    xlabel('Num of Int. Teeth')
    ylabel('Ratio')
    figure;scatter([1:10]',ratiomat(:,find(abs(coef) == max(abs(coef)))))
    title(['Num of Int. Teeth vs. Ratio for ' num2str(x(find(abs(coef) == max(abs(coef))))) ' NumDensity (NumDensity w/ largest neg coef)'])
    xlabel('Num of Int. Teeth')
    ylabel('Ratio')
end

%% other graphs
if strcmp(Figures,'on')
    figure;scatter(x,coef)
    title('NumDensity vs. coef')
    xlabel('NumDensity')
    ylabel('coef')
    figure;hist(coef)
    title('histogram of coef')
end

%% rank (r2Rank ranks NumDensity values based on their resultant r2s (best -> worst))
%%% (coefRank ranks NumDensity values based on their the magnitude of their coef (highest -> lowest))
r2ordered = sort(-1.*r2);
r2Rank = zeros(1,length(r2));
for k1 = 1:length(r2)
    check = x(find((-1.*r2) == r2ordered(k1)));
    if size(check,2) > 1
        k3 = 1;
        while isempty(find(r2Rank(1:k1-1) == check(k3))) == 0
            k3 = k3 + 1;
        end
        r2Rank(k1) = check(k3);
    else
        r2Rank(k1) = x(find((-1.*r2) == r2ordered(k1)));
    end
end

coefordered = sort(coef);
coefRank = zeros(1,length(coef));
for k1 = 1:length(coef)
    check2 = x(find(coef == coefordered(k1)));
    if size(check2,2) > 1
        k3 = 1;
        while isempty(find(coefRank(1:k1-1) == check2(k3))) == 0
            k3 = k3 + 1;
        end
        coefRank(k1) = check(k3);
    else
        coefRank(k1) = x(find(coef == coefordered(k1)));
    end
end

%% save some results
load([base_path 'Totalr2Rank.mat'])
taxa_code = load([base_path 'PNAS/teeth_taxa_table.mat']);
taxa_code = taxa_code.taxa_code;
loc1 = find(strcmp(taxa_code,Tooth{1}));
loc2 = find(strcmp(taxa_code,Tooth{2}));
Totalr2Rank{loc1,loc2} = r2Rank;
Totalr2Rank{loc2,loc1} = r2Rank;
save([base_path 'Totalr2Rank.mat'],'Totalr2Rank')

load([base_path 'TopcoefRank.mat'])
TopcoefRank(loc1,loc2) = coef(((r2Rank(1)-100)/50)+1);
TopcoefRank(loc2,loc1) = TopcoefRank(loc1,loc2);
save([base_path 'TopcoefRank.mat'],'TopcoefRank')

load([base_path 'TopDencoefRank.mat'])
TopDencoefRank(loc1,loc2) = coefRank(1);
TopDencoefRank(loc2,loc1) = TopDencoefRank(loc1,loc2);
save([base_path 'TopDencoefRank.mat'],'TopDencoefRank')

load([base_path 'Mostnegcoef.mat'])
Mostnegcoef(loc1,loc2) = min(coef(:));
Mostnegcoef(loc2,loc1) = Mostnegcoef(loc1,loc2);
save([base_path 'Mostnegcoef.mat'],'Mostnegcoef')

load([base_path 'ratioRank.mat'])
ratiolimit = 0.8;
ratioRank(loc1,loc2) = (ratiolimit - intercept(((r2Rank(1)-100)/50)+1))/coef(((r2Rank(1)-100)/50)+1);
ratioRank(loc2,loc1) = ratioRank(loc1,loc2);
save([base_path 'ratioRank.mat'],'ratioRank')

load([base_path 'TopinterceptRank.mat'])
TopinterceptRank(loc1,loc2) = intercept(((r2Rank(1)-100)/50)+1);
TopinterceptRank(loc2,loc1) = TopinterceptRank(loc1,loc2);
save([base_path 'TopinterceptRank.mat'],'TopinterceptRank')

%% save some variables to workspace
assignin('base','r2',r2)
assignin('base','r2ordered',r2ordered)
assignin('base','r2Rank',r2Rank)
assignin('base','coef',coef)
assignin('base','coefordered',coefordered)
assignin('base','coefRank',coefRank)
assignin('base','NumDensityRange',NumDensityRange)
assignin('base','MegaLMSErslt',MegaLMSErslt)
assignin('base','ratiomat',ratiomat)
assignin('base','pairlist',pairlist)
assignin('base','intercept',intercept)
end






    

    