function testingtestingbranches(Tooth1,Tooth2,k1,rslts_path)
disp([Tooth1 Tooth2 ' ' k1 ' ' rslts_path])
k1 = str2double(k1);
load(rslts_path)
LMSErslt{k1} = 'yay';
save(rslts_path,'LMSErslt')
end