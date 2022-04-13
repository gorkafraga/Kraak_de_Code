%% Rename files for NBT
dirinput = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\resting-state EEG\output_pre\EditChannels_NBT';
cd(dirinput);
list = dir('*Segment*.txt');
file = {list.name} ;
%%
for s = 1:length(file);
    nameinput = file{s}; 
    nameoutput = strrep(nameinput,'_4secSegment_','.YYYYMMDD.seg');
    nameoutput(1)= 'S';
    nameoutput = ['Rest.',nameoutput];
    %rename
    movefile(nameinput,nameoutput);
end
 