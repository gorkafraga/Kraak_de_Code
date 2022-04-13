clear all
close all
%% Rename files for NBT
dirinput = 'Z:\fraga\EEG_Yang\R analysis\masked_files';
cd(dirinput);
list = dir('*csd4*.txt');
file = {list.name} ;
% generate random numeric labels for each file
randLabel = randperm(length(file));
% keep the correspondences between original file names and random labels
filename2label =[file;num2cell(randLabel)]';
%% save the correspondences !!! IMPORTANT! otherwise you won't know file original names! 
outputfilename = 'Mask_code_book.txt'; 
if exist(outputfilename,'file') == 0;
  writetable(cell2table(filename2label),outputfilename)
else disp('THE FILE ALREADY EXIST DO NOT RENAME THE FILES AGAIN' ); 
    return
end
    %% rename the files
    for s = 1:length(file);
        nameinput = file{s}; 
        nameoutput = strrep(nameinput,nameinput(1:end-4),['mask_',num2str(randLabel(s))]); % replace everything in the filename(except the file extension) by a mask
        %rename
        movefile(nameinput,nameoutput);
    end

