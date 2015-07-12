function lmkMSEResult = TestingOneBranch(WhichTeeth,Tooth1,Tooth2,NumDensityPnts,AngleIncrement) 
%%% settings
% WhichTeeth = [5];
% Tooth1 = 'a10';
% Tooth2 = 'a13';
options.NumDensityPnts = NumDensityPnts;
options.AngleIncrement = AngleIncrement;

for k1 = 1:length(WhichTeeth)
    TeethString{k1} = ['_' num2str(WhichTeeth(k1))];
end
TeethString = strcat(TeethString{1:end});

%%% paths
base_path = '/home/class/mthdata-01/data-24/Work/cPdist/';
mesh_path = [base_path 'PoissonMSTTeeth/Meshes/Meshes10Sample/'];
landmarks_path = [base_path 'PoissonMSTTeeth/Landmarks/Landmarks' num2str(length(WhichTeeth)) 'Sample/teeth_landmarks_with_artificial' TeethString '.mat'];
samples_path = [base_path 'samples/PoissonMSTTeeth/'];
data_path = [base_path 'PoissonMSTTeeth/TaxaCodes/'];

%%% load taxa codes
taxa_file = [data_path 'teeth_taxa_table_with_artificial' TeethString '.mat'];
taxa_code = load(taxa_file);
taxa_code = taxa_code.teeth_taxa_table_with_artificial;

%% calculate rslt (lmkMSE and maps for all pairwise teeth)
TAXAind1 = find(strcmp(taxa_code,Tooth1));
TAXAind2 = find(strcmp(taxa_code,Tooth2));
loc = find(strcmp(taxa_code,[Tooth1 '_' Tooth2 '_0' num2str(WhichTeeth(1))]));
if isempty(loc) == 1
    error('Teeth Pair Not Found')
end
for k1 = 1:length(WhichTeeth)
    if WhichTeeth(k1) < 10
        TAXAintind(k1) = find(strcmp(taxa_code,[Tooth1 '_' Tooth2 '_0' num2str(WhichTeeth(k1))]));
        if k1 == length(WhichTeeth)
            TAXApath = [TAXAind1 TAXAintind TAXAind2];
        end
    else
        TAXAintind(k1) = find(strcmp(taxa_code,[Tooth1 '_' Tooth2 '_' num2str(WhichTeeth(k1))]));
        if k1 == length(WhichTeeth)
            TAXApath = [TAXAind1 TAXAintind TAXAind2];
        end
    end
end

for k1 = 1:length(TAXApath)
    for k2 = 1:length(TAXApath)
        G1 = [samples_path taxa_code{TAXApath(k1)} '.mat'];
        G2 = [samples_path taxa_code{TAXApath(k2)} '.mat'];
        
        GM = load(G1);
        GM = GM.G;
        GN = load(G2);
        GN = GN.G;
        
        options.NumLandmark = 16;
        options.FeatureType = 'ConfMax';
        options.NumFeatureMatch = 4;
        options.GaussMinMatch = 'off';
        options.ProgressBar = 'off';
        
        LandmarksPath = landmarks_path;
        MeshesPath = mesh_path;
        MeshSuffix = '_sas.off';
        
        rslt = GM.ComputeContinuousProcrustes(GN,options);
        
        if isstruct(rslt) == 0
            options.FeatureType = 'GaussMax';
            rslt = GM.ComputeContinuousProcrustes(GN,options);
            if isstruct(rslt) == 0
                options.FeatureType = 'ADMax';
                rslt = GM.ComputeContinuousProcrustes(GN,options);
                if isstruct(rslt) == 0
                    options.ConfMaxLocalWidth = 5;
                    options.FeatureType = 'ConfMax';
                    while isstruct(rslt) == 0 & options.ConfMaxLocalWidth > 0
                        GM.ExtractFeatures(options);
                        GN.ExtractFeatures(options);
                        rslt = GM.ComputeContinuousProcrustes(GN,options);
                        options.ConfMaxLocalWidth = options.ConfMaxLocalWidth - 1;
                    end
                    if isstruct(rslt) == 0
                        options.GaussMaxLocalWidth = 9;
                        options.GaussMinLocalWidth = 6;
                        options.FeatureType = 'GaussMax';
                        while isstruct(rslt) == 0 & options.GaussMinLocalWidth > 0
                            GM.ExtractFeatures(options);
                            GN.ExtractFeatures(options);
                            rslt = GM.ComputeContinuousProcrustes(GN,options);
                            options.GaussMaxLocalWidth = options.GaussMaxLocalWidth - 1;
                            if options.GaussMaxLocalWidth <= options.GaussMinLocalWidth
                                options.GaussMinLocalWidth = options.GaussMinLocalWidth - 1;
                            end
                        end
                        if isstruct(rslt) == 0
                            options.ADMaxLocalWidth = 6;
                            options.FeatureType = 'ADMax';
                            while isstruct(rslt) == 0 & options.ADMaxLocalWidth > 0
                                GM.ExtractFeatures(options);
                                GN.ExtractFeatures(options);
                                rslt = GM.ComputeContinuousProcrustes(GN,options);
                                options.ADMaxLocalWidth = options.ADMaxLocalWidth - 1;
                            end
                            if isstruct(rslt) == 0
                                disp('the changes dont work')
                            end
                        end
                    end
                end
            end
        end
        
        if (k1 == 1 & k2 == length(TAXApath)) | (k2 == 1 & k1 == length(TAXApath))
            lk2 = GN.V(:,GetLandmarks(GN.Aux.name,LandmarksPath,[MeshesPath GN.Aux.name MeshSuffix],options));
            lk1 = GN.V(:,rslt.cPmap(GetLandmarks(GM.Aux.name,LandmarksPath,[MeshesPath GM.Aux.name MeshSuffix],options)));
            rslt.lkMSE = mean(sqrt(sum((lk2-lk1).^2)));
        end
        
        cPrslt{k1,k2} = rslt;
    end
    progressbar(k1,length(TAXApath),length(TAXApath))
end

%%% Process rslts
for k1 = 1:length(TAXApath)
    for k2 = 1:length(TAXApath)
        cPDistMatrix(k1,k2) = cPrslt{k1,k2}.cPdist;
        cPMapsMatrix{k1,k2} = cPrslt{k1,k2}.cPmap;
        invcPMapsMatrix{k1,k2} = cPrslt{k1,k2}.invcPmap;
        if (k1 == 1 & k2 == length(TAXApath)) | (k2 == 1 & k1 == length(TAXApath))
            cPlmkMSEMatrix(k1,k2) = cPrslt{k1,k2}.lkMSE;
        end
    end
end

for j = 1:size(cPrslt,1)
    for k = 1:size(cPrslt,2)
        if cPDistMatrix(j,k)<cPDistMatrix(k,j)
            cPlmkMSEMatrix(k,j) = cPlmkMSEMatrix(j,k);
            cPMapsMatrix{k,j} = invcPMapsMatrix{j,k};
        else
            cPlmkMSEMatrix(j,k) = cPlmkMSEMatrix(k,j);
            cPMapsMatrix{j,k} = invcPMapsMatrix{k,j};
        end
    end
    progressbar(j,size(cPrslt,1),size(cPrslt,1))
end

lmkMSEResult(1) = cPlmkMSEMatrix(1,length(TAXApath));
disp('Original Branch lmkMSE calculated')

%% Calculate lmkMSE along the intermediate teeth path using the maps
G1 = [samples_path taxa_code{TAXApath(1)} '.mat'];
G2 = [samples_path taxa_code{TAXApath(end)} '.mat'];

GM = load(G1);
GM = GM.G;
GN = load(G2);
GN = GN.G;

ImprMap = ComposeMapsAlongPath(1:length(TAXApath),cPMapsMatrix);
lk2 = GN.V(:,GetLandmarks(GN.Aux.name,LandmarksPath,[MeshesPath GN.Aux.name MeshSuffix],options));
lk1 = GN.V(:,ImprMap(GetLandmarks(GM.Aux.name,LandmarksPath,[MeshesPath GM.Aux.name MeshSuffix],options)));
lmkMSEResult(2) = mean(sqrt(sum((lk2-lk1).^2)));
disp('Intermediate Branch lmkMSE calculated')

end



