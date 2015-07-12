%%% preparation
clear all
close all

path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%%% paths
base_path = 'C:/Users/Kevin/Documents/MATLAB/cPdist-master/';

%%% settings
WhichTeeth = [3,7];

%%% load original landmarks and get indices for taxa table
OrigLmk = load([base_path 'DistRslts0Sample/cPlmkMSEMatrix.mat']);
OrigLmk = OrigLmk.cPlmkMSEMatrix;

taxa_table = load('C:/Users/Kevin/Documents/MATLAB/cPdist-master/PoissonMSTTeeth/teeth_taxa_table_with_artificial_5');
taxa_table = taxa_table.teeth_taxa_table_with_artificial;
for k1 = 117:228
    taxa_table{k1} = taxa_table{k1}(1:(end-3));
end
for k1 = 1:112
    taxa_table{2,k1} = strtok(taxa_table{1,(k1+116)},'_');
    taxa_table{3,k1} = taxa_table{1,(k1+116)}((length(taxa_table{2,k1})+2):end);
end

for k1 = 1:112
toothind1(k1) = find(strcmp(taxa_table(1,1:228),taxa_table{2,k1}) == 1);
toothind2(k1) = find(strcmp(taxa_table(1,1:228),taxa_table{3,k1}) == 1);
end

toothind = [toothind1;toothind2];

%%% Keep Single Branch LMSEs
for k1 = 1:112
    NewLmk(toothind(1,k1),toothind(2,k1)) = OrigLmk(toothind(1,k1),toothind(2,k1));
end

%%% Add the missing 3 Branches
NewLmk(72,68) = OrigLmk(72,68);
NewLmk(92,112) = OrigLmk(92,112);
NewLmk(95,10) = OrigLmk(95,10);

%%% symmetrize
for k1 = 1:116
    for k2 = 1:116
        if NewLmk(k1,k2) ~= 0
            NewLmk(k2,k1) = NewLmk(k1,k2);
        end
    end
end

%%% Creating Tree
[ST,~] = ConstructGraph(NewLmk,'MST');


%%% Creating path matrix
for k1 = 1:length(WhichTeeth)
    TeethString{k1} = ['_' num2str(WhichTeeth(k1))];
end
TeethString = strcat(TeethString{1:end});

taxa_table_with_art = load([base_path 'PoissonMSTTeeth/teeth_taxa_table_with_artificial' TeethString '.mat']);
taxa_table_with_art = taxa_table_with_art.teeth_taxa_table_with_artificial;

NameInd = cell(116,116);
for k1 = 1:size(toothind,2)
    Name1 = taxa_table_with_art{toothind(1,k1)};
    Name2 = taxa_table_with_art{toothind(2,k1)};
    if isempty(find(strcmp(taxa_table_with_art,[Name1 '_' Name2 '_0' num2str(WhichTeeth(1))]))) == 0
        for k2 = 1:length(WhichTeeth)
            IntNameInd(k2) = find(strcmp(taxa_table_with_art,[Name1 '_' Name2 '_0' num2str(WhichTeeth(k2))]));
        end
        NameInd{toothind(1,k1),toothind(2,k1)} = [toothind(1,k1) IntNameInd toothind(2,k1)];
    elseif isempty(find(strcmp(taxa_table_with_art,[Name2 '_' Name1 '_0' num2str(WhichTeeth(1))]))) == 0
        for k2 = 1:length(WhichTeeth)
            IntNameInd(k2) = find(strcmp(taxa_table_with_art,[Name2 '_' Name1 '_0' num2str(WhichTeeth(k2))]));
        end
        NameInd{toothind(2,k1),toothind(1,k1)} = [toothind(2,k1) IntNameInd toothind(1,k1)];
    end
end
for k1 = 1:size(NameInd,1)
    for k2 = 1:size(NameInd,2)
        if isempty(NameInd{k1,k2}) == 1
            NameInd{k1,k2} = [k1,k2];
        end
    end
end

    
        
for k1 = 1:116
    for k2 = 1:116
        MapPaths{k1,k2} = FindGraphShortestPath(ST,k1,k2,taxa_table(1,1:116),'off');
    end
end

for k1 = 1:116
    for k2 = 1:116
        if k1 ~= k2
            Path = MapPaths{k1,k2};
            NewPath = [];
            for k3 = 1:(length(Path) - 1)
                NewPath = [NewPath NameInd{Path(k3),Path(k3+1)}];
            end
            MapPaths{k1,k2} = NewPath;
        end
    end
end
        
            
            
        
%%% save path matrix        
save([base_path 'MapPaths' TeethString '.mat'],'MapPaths')
        

% %%% symmetrize
% for k1 = 1:116
%     for k2 = 1:116
%         if NewLmk(k1,k2) ~= 0
%             NewLmk(k2,k1) = NewLmk(k1,k2);
%         end
%     end
% end
% 
% %%% visualize
% figure;
% imagesc(NewLmk./max(NewLmk(:))*64);
% axis equal;
% axis([1,116,1,116]);





            
