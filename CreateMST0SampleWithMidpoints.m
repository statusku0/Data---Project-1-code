path(pathdef);
addpath(path,genpath([pwd '/utils/']));

test_taxa_table = load('C:/Users/Kevin/Documents/MATLAB/cPdist-master/PoissonMSTTeeth/teeth_taxa_table_with_artificial');
test_taxa_table = test_taxa_table.teeth_taxa_table_with_artificial;
for k1 = 117:228
    test_taxa_table{k1} = test_taxa_table{k1}(1:(end-3));
end
for k1 = 1:112
    test_taxa_table{2,k1} = strtok(test_taxa_table{1,(k1+116)},'_');
    test_taxa_table{3,k1} = test_taxa_table{1,(k1+116)}((length(test_taxa_table{2,k1})+2):end);
end

for k1 = 1:112
toothind1(k1) = find(strcmp(test_taxa_table(1,1:228),test_taxa_table{2,k1}) == 1);
toothind2(k1) = find(strcmp(test_taxa_table(1,1:228),test_taxa_table{3,k1}) == 1);
end

dist0 = load('C:/Users/Kevin/Documents/MATLAB/cPdist-master/DistRslts0SampleImproved/cPMSTDistMatrix');
dist0 = dist0.ImprDistMatrix;

for k1 = 1:112
dist0(toothind1(k1),(k1+116)) = 0.5*(dist0(toothind1(k1),toothind2(k1)));
dist0((k1+116),toothind1(k1)) = dist0(toothind1(k1),(k1+116));
dist0(toothind2(k1),(k1+116)) = 0.5*(dist0(toothind1(k1),toothind2(k1)));
dist0((k1+116),toothind2(k1)) = dist0(toothind2(k1),(k1+116));
end

for k1 = 1:228
    for k2 = 1:228
        if dist0(k1,k2) == 0
            dist0(k1,k2) = 100;
        end
    end
end

[STtest,PREDtest] = ConstructGraph(dist0,'MST');
view(biograph(STtest,test_taxa_table(1,1:228)))

