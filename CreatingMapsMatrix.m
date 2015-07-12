%%% preparation
clear all;
close all;
path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%%% setup paths
base_path = [pwd '/'];
data_path = [base_path 'PoissonMSTTeeth/'];
result_path = [base_path 'DistRsltsNew0Sample/']; 
rslts_path = [base_path 'Rslts/rslts9/'];
cPDistMatrix_path = [base_path 'DistRsltsNew0Sample/cPDistMatrix'];


%%% load taxa codes
% taxa_file = [data_path 'teeth_taxa_table_with_artificial_1_4_6_9.mat'];
taxa_file = [base_path 'PNAS/teeth_taxa_table.mat'];
taxa_code = load(taxa_file);
% taxa_code = taxa_code.teeth_taxa_table_with_artificial;
taxa_code = taxa_code.taxa_code;
GroupSize = length(taxa_code);
% chunk_size = 55; %% PNAS
% chunk_size = 50; %% Clement
chunk_size = 116;

%%% Find only those maps that lie in the MST

cPDistMatrix = load(cPDistMatrix_path);
cPDistMatrix = cPDistMatrix.cPDistMatrix;

[ST,~] = ConstructGraph(cPDistMatrix,'MST');
STdouble = full(ST);
STdoublesym = STdouble';

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
        if STdouble(k1,k2) ~= 0 | STdoublesym(k1,k2) ~= 0 | k1 == k2
            cPMapsMatrix{k1,k2} = cPrslt{k1,k2}.cPmap;
            invcPMapsMatrix{k1,k2} = cPrslt{k1,k2}.invcPmap;
        end
%         cPlmkMSEMatrix(k1,k2) = cPrslt{k1,k2}.lkMSE;
        
%         tmpTextureCoords1Matrix{k1,k2} = cPrslt{k1,k2}.TextureCoords1;
%         tmpTextureCoords2Matrix{k1,k2} = cPrslt{k1,k2}.TextureCoords2;
        
        cnt = cnt+1;
    end
end

%%% symmetrize
cnt = 0;
job_id = 0;
for j=1:GroupSize
    progressbar(j,GroupSize,20);
    for k=1:GroupSize
%         if mod(cnt,chunk_size)==0
%             if cnt>0
%                 save([TextureCoords1Matrix_path 'TextureCoords1_mat_' num2str(job_id) '.mat'],'TextureCoords1Matrix');
%                 save([TextureCoords2Matrix_path 'TextureCoords2_mat_' num2str(job_id) '.mat'],'TextureCoords2Matrix');
%                 clear TextureCoords1Matrix TextureCoords2Matrix
%             end
%             job_id = job_id+1;
%             TextureCoords1Matrix = cell(GroupSize,GroupSize);
%             TextureCoords2Matrix = cell(GroupSize,GroupSize);
%         end
        if cPDistMatrix(j,k)<cPDistMatrix(k,j)
%             cPlmkMSEMatrix(k,j) = cPlmkMSEMatrix(j,k);
            cPMapsMatrix{k,j} = invcPMapsMatrix{j,k};
%             TextureCoords1Matrix{j,k} = tmpTextureCoords1Matrix{j,k};
%             TextureCoords2Matrix{j,k} = tmpTextureCoords2Matrix{j,k};
        else
%             cPlmkMSEMatrix(j,k) = cPlmkMSEMatrix(k,j);
            cPMapsMatrix{j,k} = invcPMapsMatrix{k,j};
%             TextureCoords1Matrix{j,k} = tmpTextureCoords2Matrix{k,j};
%             TextureCoords2Matrix{j,k} = tmpTextureCoords1Matrix{k,j};
        end
        cnt = cnt+1;
    end
end

save([result_path 'cPMapsMatrix.mat'],'cPMapsMatrix');