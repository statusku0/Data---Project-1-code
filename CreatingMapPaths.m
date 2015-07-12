%% preparation
clear all
close all

path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%%% settings
WhichTeeth = [5];

for k1 = 1:length(WhichTeeth)
    TeethString{k1} = ['_' num2str(WhichTeeth(k1))];
end
TeethString = strcat(TeethString{1:end});

%%% paths
base_path = 'C:/Users/Kevin/Documents/MATLAB/cPdist-master/';
data_path = [base_path 'PoissonMSTTeeth/'];
result_path = [base_path 'DistRslts1000NumPts0.01Angle/DistRslts1Sample/']; 
rslts_path = [base_path 'Rslts/rslts1SampleAccurate/'];
cPDistMatrix_path = [base_path 'DistRslts1000NumPts0.01Angle/DistRslts1Sample/cPDistMatrix'];

%%% load taxa codes
taxa_file = [data_path 'teeth_taxa_table_with_artificial' TeethString '.mat'];
% taxa_file = [base_path 'PNAS/teeth_taxa_table.mat'];
taxa_code = load(taxa_file);
taxa_code = taxa_code.teeth_taxa_table_with_artificial;
% taxa_code = taxa_code.taxa_code;
GroupSize = length(taxa_code);
chunk_size = 228;

%%% loading stuff
cPDistMatrix = load(cPDistMatrix_path);
cPDistMatrix = cPDistMatrix.cPDistMatrix;

%% Create New Tree
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

disp('New Tree Created')

%% Creating Path Matrix (also modifies NewLmk to act as a marker signaling which maps to keep in the new maps matrix)
taxa_table_with_art = load([base_path 'PoissonMSTTeeth/teeth_taxa_table_with_artificial' TeethString '.mat']);
taxa_table_with_art = taxa_table_with_art.teeth_taxa_table_with_artificial;

%%% write out paths for each branch that has intermediate teeth in NameInd
%%% / also modifies NewLmk to signify which intermediate teeth and normal teeth are directly
%%% connected with each other 
NameInd = cell(116,116);
for k1 = 1:size(toothind,2)
    progressbar(k1,size(toothind,2),20)
    Name1 = taxa_table_with_art{toothind(1,k1)};
    Name2 = taxa_table_with_art{toothind(2,k1)};
    if isempty(find(strcmp(taxa_table_with_art,[Name1 '_' Name2 '_0' num2str(WhichTeeth(1))]))) == 0
        for k2 = 1:length(WhichTeeth)
            IntNameInd(k2) = find(strcmp(taxa_table_with_art,[Name1 '_' Name2 '_0' num2str(WhichTeeth(k2))]));
        end
        NameInd{toothind(1,k1),toothind(2,k1)} = [toothind(1,k1) IntNameInd toothind(2,k1)];
        nametemp = NameInd{toothind(1,k1),toothind(2,k1)};
        for k3 = 1:(length(nametemp)-1)
            NewLmk(nametemp(k3),nametemp(k3+1)) = 1;
        end     
    elseif isempty(find(strcmp(taxa_table_with_art,[Name2 '_' Name1 '_0' num2str(WhichTeeth(1))]))) == 0
        for k4 = 1:length(WhichTeeth)
            IntNameInd(k4) = find(strcmp(taxa_table_with_art,[Name2 '_' Name1 '_0' num2str(WhichTeeth(k4))]));
        end
        NameInd{toothind(2,k1),toothind(1,k1)} = [toothind(2,k1) IntNameInd toothind(1,k1)];
        nametemp = NameInd{toothind(1,k1),toothind(2,k1)};
        for k5 = 1:(length(nametemp)-1)
            NewLmk(nametemp(k5),nametemp(k5+1)) = 1;
        end  
    end
end

%%% symmetrize 
for k1 = 1:size(NewLmk,1)
    progressbar(k1,size(NewLmk,1),20)
    for k2 = 1:size(NewLmk,2)
        if NewLmk(k1,k2) ~= 0
            NewLmk(k2,k1) = NewLmk(k1,k2);
        end
    end
end

%%% get rid of connections between original teeth
for k1 = 1:116
    progressbar(k1,116,20)
    for k2 = 1:116
        NewLmk(k1,k2) = 0;
    end
end

%%% accounts for branches w/o intermediate teeth by setting up paths
%%% between all teeth pairs that don't have intermediate teeth (preparation
%%% for NewPath step)
for k1 = 1:size(NameInd,1)
    progressbar(k1,size(NameInd,1),20)
    for k2 = 1:size(NameInd,2)
        if isempty(NameInd{k1,k2}) == 1
            NameInd{k1,k2} = [k1,k2];
        end
    end
end

    
%%% Finds the best path between any two teeth along the original hand-made tree        
for k1 = 1:116
    progressbar(k1,116,20)
    for k2 = 1:116
        MapPaths{k1,k2} = FindGraphShortestPath(ST,k1,k2,taxa_table(1,1:116),'off');
    end
end

%%% Adds intermediate teeth where necessary
for k1 = 1:116
    progressbar(k1,116,20)
    for k2 = 1:116
        if k1 ~= k2
            Path = MapPaths{k1,k2};
            NewPath = [];
            for k3 = 1:(length(Path) - 1)
                if isempty(NewPath) == 1;
                    NewPath = [NewPath NameInd{Path(k3),Path(k3+1)}];
                else
                    NewPath = [NewPath NameInd{Path(k3),Path(k3+1)}(2:end)];
                end
            end
            MapPaths{k1,k2} = NewPath;
        end
    end
end

disp('Paths Matrix Created')

%% Creating New Maps Matrix
cPMapsMatrix = cell(GroupSize,GroupSize);
invcPMapsMatrix = cell(GroupSize,GroupSize);

cnt = 0;
job_id = 0;
for k1=1:GroupSize
    progressbar(k1,GroupSize,20);
    for k2=1:GroupSize
        if mod(cnt,chunk_size)==0
            job_id = job_id+1;
            load([rslts_path 'rslt_mat_' num2str(job_id)]);
        end
        if NewLmk(k1,k2) ~= 0 | k1 == k2
            cPMapsMatrix{k1,k2} = cPrslt{k1,k2}.cPmap;
            invcPMapsMatrix{k1,k2} = cPrslt{k1,k2}.invcPmap;
        end
        
        cnt = cnt+1;
    end
end

%%% symmetrize
for j=1:GroupSize
    progressbar(j,GroupSize,20);
    for k=1:GroupSize
        if cPDistMatrix(j,k)<cPDistMatrix(k,j)
            cPMapsMatrix{k,j} = invcPMapsMatrix{j,k};
        else
            cPMapsMatrix{j,k} = invcPMapsMatrix{k,j};
        end
    end
end

disp('New Maps Matrix Created')
       
%% save path matrix and maps matrix       
save([result_path 'MapPaths' TeethString '.mat'],'MapPaths')
save([result_path 'cPMapsMatrix.mat'],'cPMapsMatrix');
