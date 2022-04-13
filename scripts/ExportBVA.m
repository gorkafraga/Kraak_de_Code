dirinput = 
diroutput 
'Z:\fraga\EEG_Gorka\Analysis_EEGlab\Pretest_Analyzer_final_steps\';

for N = [31:34, 38,39]; 

    if N <10   
    [FILENAME] =['s00',num2str(N),'vwr-ICA-pruned'];
    elseif N >=10 && N<100   
    [FILENAME] =['s0',num2str(N),'vwr-ICA-pruned'];
    elseif N >99
    [FILENAME] =['s',num2str(N),'vwr-ICA-pruned'];
    end
    
    FILENAME1 = [FILENAME '.set'];
    EEG = pop_loadset(FILENAME1, DIRNAME);

    if ~isempty(dir(FILENAME1))

       EEG = pop_writebva(EEG, FILENAME1); 

    end
end
clear all 
 