% Initialization
clear all

path(pathdef);
path(path, genpath('./utils'));

% load data
load('./DistRslts/cPDistMatrix.mat');
load('./DistRslts/cPlmkMSEMatrix.mat');
load('./DistRslts/cPMapsMatrix.mat');
load('./PNAS/teeth_taxa_table.mat')

% Construct MST graph
[ST,PRED] = ConstructGraph(cPDistMatrix,'MST');

% finding shortest paths
for k = 1:116
    for j = k:116
        P{k,j} = FindGraphShortestPath(ST,k,j,taxa_code,'off');
    end
end

% adjusting cPMapsMatrix so that all maps are the same length (filling empty spots w/ zeroes) (sketchy?)
for k = 1:116
    for j = 1:116
        L(k,j) = size(cPMapsMatrix{k,j},1);
    end
end

maxlength = max(L(:));

for k = 1:116
    for j = 1:116
        R = cPMapsMatrix{k,j};
        if length(R) < maxlength
            R(length(R):maxlength) = 0;
        end
        cPMapsMatrix{k,j} = R;
    end
    progressbar(k,116,10)
end

disp('cPMapsMatrix adjusted')

%%% finding maps for shortest paths
for k = 1:116
    for j = k:116
        p = P{k,j};
        if k ~= j
            for n = 1:(length(p)-1)
                m{n} = cPMapsMatrix{p(n), p(n+1)};
            end
            Map{k,j} = m{1};
            for q = 2:length(m)
                N = m{q};
                for t = 1: length(Map{k,j})
                    T = Map{k,j};
                    if T(t) ~= 0
                        T(t) = N(T(t));
                    else
                        T(t) = 0;
                    end
                    Map{k,j} = T;
                end
            end
        else
            Map{k,j} = cPMapsMatrix{k,j};
        end
%         progressbar(j,116,10)
    end
    progressbar(k,116,116)
end

disp('Upper trig. Map matrix done')

% finding maps for reverse paths
for k = 1:116
    for j = 1:k
        N = Map{j,k};
        Map{k,j} = N(N);
    end
    progressbar(k,116,10)
end

disp('Map matrix done')


        
   


