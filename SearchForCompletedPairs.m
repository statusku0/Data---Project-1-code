%% preparation
clear all;
close all;
path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%% paths
base_path = '/home/class/mthdata-01/data-24/Work/cPdist/';
rslts_path = [base_path 'rslts/'];

%% check rslts
%%% list teeth pairs
taxa_code = load([base_path 'PoissonMSTTeeth/TaxaCodes/teeth_taxa_table_with_artificial_5']);
taxa_code = taxa_code.teeth_taxa_table_with_artificial;
TeethPairList = {};
for k1 = 1:116
    for k2 = 1:116
        Tooth1 = taxa_code{k1};
        Tooth2 = taxa_code{k2};
        if sum(strcmp(taxa_code,[Tooth1 '_' Tooth2 '_05'])) == 1
            TeethPairList{size(TeethPairList,1)+1,1} = Tooth1;
            TeethPairList{size(TeethPairList,1),2} = Tooth2;
        end
    end
end 

%%% find completed pairs
for k1 = 1:size(TeethPairList,1)
    if exist([rslts_path 'rslts_' TeethPairList{k1,1} '_' TeethPairList{k1,2} '/rslt_mat_' num2str(k2) '.mat'],'file') == 2
        for k2 = 1:10
            load([rslts_path 'rslts_' TeethPairList{k1,1} '_' TeethPairList{k1,2} '/rslt_mat_' num2str(k2) '.mat'])
            if isempty(LMSErslt{k2})
                break
            end
            if k2 == 10
                disp([TeethPairList{k1,1} '_' TeethPairList{k1,2}])
            end
        end
    end
end
