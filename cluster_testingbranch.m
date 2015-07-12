%%% preparation
clear all;
close all;
path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%%% setup paths
base_path = '/home/class/mthdata-01/data-24/Work/cPdist/';
rslts_path = [base_path 'rslts2/'];
cluster_path = [base_path 'cluster2/'];
scripts_path = [cluster_path 'scripts/'];
errors_path = [cluster_path 'errors/'];
outputs_path = [cluster_path 'outputs/'];

%%% build folders if they don't exist
touch(scripts_path);
touch(errors_path);
touch(outputs_path);
touch(rslts_path);

%%% clean up paths
command_text = ['!rm -f ' scripts_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' errors_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' outputs_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' rslts_path '*']; eval(command_text); disp(command_text);

%%% define settings
chunk_size = 1;

%%% taxa table stuff
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
if size(TeethPairList,1) ~= 112
    error('Not the correct amount of teeth pairs for PoissonMSTTeeth')
end
for k1 = 1:size(TeethPairList,1)
    touch([rslts_path 'rslts' TeethPairList{k1,1} TeethPairList{k1,2} '/'])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('++++++++++++++++++++++++++++++++++++++++++++++++++');
disp('Submitting jobs...');

cnt = 0;
job_id = 0;
for k2 = 1:6 %% adjust accordingly to test a specific set of teeth pairs
    for k1=1:10
        if mod(cnt,chunk_size)==0
            if job_id>0 %%% not the first time
                %%% close the script file (except the last one, see below)
                fprintf(fid, '%s ', 'exit; "\n');
                fclose(fid);
                
                %%% qsub
                jobname = ['TCjob_' num2str(job_id)];
                serr = [errors_path 'e_job_' num2str(job_id)];
                sout = [outputs_path 'o_job_' num2str(job_id)];
                tosub = ['!qsub -N ' jobname ' -o ' sout ' -e ' serr ' ' ...
                         script_name ];
                eval(tosub);
            end
            
            job_id = job_id+1;
            script_name = [scripts_path 'script_' num2str(job_id)];
            
            %%% open the next (first?) script file
            fid = fopen(script_name,'w');
            fprintf(fid, '#!/bin/bash\n');
            fprintf(fid, '#$ -S /bin/bash\n');
            script_text = ['matlab -nodesktop -nodisplay -nojvm -nosplash -r '...
                '" cd ' base_path '; ' ...
                'path(genpath(''' base_path 'utils/''), path);'];
            fprintf(fid, '%s ',script_text);
            
            %%% create new matrix
            if ~exist([rslts_path 'rslts' TeethPairList{k2,1} TeethPairList{k2,2} '/rslt_mat_' num2str(k1) '.mat'],'file')
                LMSErslt = cell(1,10);
                save([rslts_path 'rslts' TeethPairList{k2,1} TeethPairList{k2,2} '/rslt_mat_' num2str(k1) '.mat'], 'LMSErslt');
            end
        end
        
        script_text = [' testingtestingbranches ' ...
            TeethPairList{k2,1} ' ' ...
            TeethPairList{k2,2} ' ' ...
            num2str(k1) ' ' ...
            [rslts_path 'rslts' TeethPairList{k2,1} TeethPairList{k2,2} '/rslt_mat_' num2str(k1)] '; '];
        fprintf(fid, '%s ',script_text);
        
        cnt = cnt+1;
    end 
end

% if mod(cnt,chunk_size)~=0
%%% close the last script file
fprintf(fid, '%s ', 'exit; "\n');
fclose(fid);
%%% qsub last script file
jobname = ['TCjob_' num2str(job_id)];
serr = [errors_path 'e_job_' num2str(job_id)];
sout = [outputs_path 'o_job_' num2str(job_id)];
tosub = ['!qsub -N ' jobname ' -o ' sout ' -e ' serr ' ' script_name ];
eval(tosub);
% end