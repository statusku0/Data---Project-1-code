%%% preparation
clear all;
close all;
path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%%% paths
base_path = 'C:/Users/Kevin/Documents/MATLAB/cPdist-master/';

%%% settings
WhichTeeth = [2,5,8];

%%% gathering original LMSE matrix and taxa table
OrigLMSE = load([base_path 'DistRslts' num2str(length(WhichTeeth)) 'Sample/cPlmkMSEMatrix.mat']);
OrigLMSE = OrigLMSE.cPlmkMSEMatrix;
for k1 = 1:length(WhichTeeth)
    TeethString{k1} = ['_' num2str(WhichTeeth(k1))];
end
TeethString = strcat(TeethString{1:end});
Taxa_Table = load([base_path '/PoissonMSTTeeth/' 'teeth_taxa_table_with_artificial' TeethString '.mat']);
Taxa_Table = Taxa_Table.teeth_taxa_table_with_artificial;

%%% creating LMSE matrix based on branches properly connecting intermediate
%%% teeth
for k1 = 1:116
    progressbar(k1,116,20)
    for k2 = 1:116
        if k1 ~= k2
            ToothName1 = Taxa_Table{k1};
            ToothName2 = Taxa_Table{k2};
            if sum(strcmp(Taxa_Table, [ToothName1 '_' ToothName2 '_0' num2str(WhichTeeth(1))])) ~= 0
                for k3 = 1:length(WhichTeeth)
                    Loc(k3) = find(strcmp(Taxa_Table, [ToothName1 '_' ToothName2 '_0' num2str(WhichTeeth(k3))]));
                end
                IndList = [k1, Loc, k2];
                for k4 = 1:(length(IndList)-1)
                    DistList(k4) = OrigLMSE(IndList(k4),IndList(k4+1));
                end
                NewLMSE(k1,k2) = sum(DistList(k4));
            elseif sum(strcmp(Taxa_Table, [ToothName2 '_' ToothName1 '_0' num2str(WhichTeeth(1))])) ~= 0
                for k3 = 1:length(WhichTeeth)
                    Loc(k3) = find(strcmp(Taxa_Table, [ToothName2 '_' ToothName1 '_0' num2str(WhichTeeth(k3))]));
                end
                IndList = [k2, Loc, k1];
                for k4 = 1:(length(IndList)-1)
                    DistList(k4) = OrigLMSE(IndList(k4),IndList(k4+1));
                end
                NewLMSE(k1,k2) = sum(DistList(k4));
            end
        else 
            NewLMSE(k1,k2) = 0;
        end
    end
end

%%% Taking care of missing MST edges
OrigDist = load([base_path 'DistRslts0Sample/cPDistMatrix.mat']);
OrigDist = OrigDist.cPDistMatrix;
[ST1,~] = ConstructGraph(OrigDist,'MST');
C = [];
for k1 = 1:116
    for k2 = 1:116
        min_path = FindGraphShortestPath(ST1,k1,k2,Taxa_Table,'off');
        if length(min_path) == 2
            C(size(C,1)+1,1) = k1;
            C(size(C,1),2) = k2;
        end
    end
end

for k1 = 1:size(C,1)
    if NewLMSE(C(k1,1),C(k1,2)) == 0
        NewLMSE(C(k1,1),C(k1,2)) = OrigLMSE(C(k1,1),C(k1,2));
    end
end

for k1 = 1:116
    for k2 = 1:116
        if k1 >= k2
            NewLMSE(k1,k2) = 0;
        end
    end
end

[ST2,~] = ConstructGraph(sparse(NewLMSE),'MST');

%%% filling in the rest of the NewLMSE matrix
for k1 = 1:116
    progressbar(k1,116,20)
    for k2 = 1:116
        if k1 > k2 & NewLMSE(k1,k2) == 0
            min_path = FindGraphShortestPath(ST2,k1,k2,Taxa_Table,'off');
            for k3 = 1:(length(min_path)-1)
                MinDistList(k3) = OrigLMSE(k3,k3+1);
            end
            NewLMSE(k1,k2) = sum(MinDistList);
        end
    end
end

%%% symmetrize 
for k1 = 1:116
    for k2 = 1:116
        if k1 < k2
            NewLMSE(k1,k2) = NewLMSE(k2,k1);
        end
    end
end

            

                
                    
            

        