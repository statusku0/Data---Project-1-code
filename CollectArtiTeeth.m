clear 

%%% path setup
base_path = 'C:\Users\Kevin\Documents\MATLAB\cPdist-master';
data_path = 'C:\Users\Kevin\Documents\MATLAB\cPdist-master\PoissonMSTTeeth';
Names_edges = load([data_path '\Names_edges.mat']);
Names_edges = Names_edges.Names_edges;

%%% settings
WhichTeeth = [1,2,3,4,5,6,7,8,10];
for k1 = 1:length(WhichTeeth)
    TeethString{k1} = ['_' num2str(WhichTeeth(k1))];
end
TeethString = strcat(TeethString{1:end});
DestinationFolder = [data_path '\artificial_teeth_meshes' TeethString '\'];
% DestinationFolder = ['C:\Users\Kevin\Documents\MATLAB\cPdist-master\debugging'];

if ~exist(DestinationFolder)
    mkdir(data_path, ['artificial_teeth_meshes' TeethString]);
end

%%% getting artificial teeth meshes

for k1 = 1:length(WhichTeeth)
    for k2 = 1:112
        if WhichTeeth(k1) < 10
            mesh_dir = [data_path '\' Names_edges{k2} '\off\' Names_edges{k2} '_0' num2str(WhichTeeth(k1)) '.off'];
            copyfile(mesh_dir,DestinationFolder);
            % Rename files from .off to _sas.off
            movefile([DestinationFolder '\' Names_edges{k2} '_0' num2str(WhichTeeth(k1)) '.off'],[DestinationFolder '\' Names_edges{k2} '_0' num2str(WhichTeeth(k1)) '_sas.off']);
        else
            mesh_dir = [data_path '\' Names_edges{k2} '\off\' Names_edges{k2} '_' num2str(WhichTeeth(k1)) '.off'];
            copyfile(mesh_dir,DestinationFolder);
            % Rename files from .off to _sas.off
            movefile([DestinationFolder '\' Names_edges{k2} '_' num2str(WhichTeeth(k1)) '.off'],[DestinationFolder '\' Names_edges{k2} '_' num2str(WhichTeeth(k1)) '_sas.off'])       
        end
    end
end

%%% Create taxa_code file for aritifical teeth
temp1 = dir(DestinationFolder);

for k1 = 3:(2+(112*(length(WhichTeeth))))
    temp2 = temp1(k1).name;
    trunname = temp2(1:(end-8));
    artificial_teeth_taxa_table{k1-2} = trunname;
end

% save(['artificial_teeth_taxa_table' TeethString '.mat'],'artificial_teeth_taxa_table');
% movefile(['artificial_teeth_taxa_table' TeethString '.mat'],base_path);

%%% getting landmarks
artificial_teeth_landmarks = zeros(112*(length(WhichTeeth)),16,3);

for k1 = 1:length(artificial_teeth_taxa_table)
    landmark_file = [data_path '\' artificial_teeth_taxa_table{k1}(1:(end-3)) '\ObLmk\' artificial_teeth_taxa_table{k1} '.csv'];
    m = csvread(landmark_file); 
    for k2 = 1:16
        for k3 = 1:3
            artificial_teeth_landmarks(k1,k2,k3) = m(k2,k3);
        end
    end
end

% save(['artificial_teeth_landmarks' TeethString '.mat'],'artificial_teeth_landmarks');
% movefile(['artificial_teeth_landmarks' TeethString '.mat'],base_path);

%%% adding artificial taxa tables and landmarks to original data
orig = load('C:\Users\Kevin\Documents\MATLAB\cPdist-master\PNAS\landmarks_teeth.mat');
origland = orig.PP;
orignames = orig.names;
NumRowsland = size(origland,1);
NumRowsnames = length(orignames);
for k1 = 1:size(artificial_teeth_landmarks,1)
    for k2 = 1:size(artificial_teeth_landmarks,2)
        for k3 = 1:size(artificial_teeth_landmarks,3)
            origland(NumRowsland+k1,k2,k3) = artificial_teeth_landmarks(k1,k2,k3);
        end
    end
    orignames{NumRowsnames+k1} = artificial_teeth_taxa_table{k1};
end

names = orignames;
PP = origland;
teeth_taxa_table_with_artificial = orignames';

save(['teeth_landmarks_with_artificial' TeethString '.mat'],'names','PP')
save(['teeth_taxa_table_with_artificial' TeethString '.mat'],'teeth_taxa_table_with_artificial')
movefile(['teeth_landmarks_with_artificial' TeethString '.mat'],data_path)
movefile(['teeth_taxa_table_with_artificial' TeethString '.mat'],data_path)

%%% Combining artificial meshes with original meshes and saving in a
%%% Meshes['Sample Size']Sample folder

movefile([data_path '\artificial_teeth_meshes' TeethString '\*'],[base_path '\Meshes' num2str(length(WhichTeeth)) 'Sample']);
copyfile([base_path '\Meshes0Sample\*'],[base_path '\Meshes' num2str(length(WhichTeeth)) 'Sample']);



    

    
    
    
        