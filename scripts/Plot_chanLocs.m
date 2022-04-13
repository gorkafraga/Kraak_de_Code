DIROUTPUT = 'C:\Users\Gorka\Documents';
chanlocsfile = 'Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\channelsThetaPhi-64scalp.elp';
addpath('Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\scripts')
addpath ('Z:\fraga\EEG_ABMP\Kraak_analysis\Kraak EEG\scripts')
%Load channel locations
EEG = pop_chanedit(EEG,'load',chanlocsfile,'besa');
%%
figure; 
topoplot([],EEG.chanlocs,'headrad', 'rim','intsquare', 'on','style','blank',...
'electrodes','ptslabels','chaninfo',EEG.chaninfo);

set(gcf,'Color','w')
set(get(gca,'Title'),'Visible','off')
children = get(gca,'Children');
%%
for l = 1:length(children);
     if strcmp(get(children(l),'Type'),'text')==1 ;
     set(children(l),'Visible', 'on', 'FontName','Arial','fontsize',16);
     elseif strcmp(get(children(l),'Marker'),'.')==1
         %set(children(l),'MarkerSize',45,'Color',[1 102/255 102/255]);
         set(children(l),'MarkerSize', 75,'Color',[0.6 0.6 0.6])
    elseif strcmp(get(children(l),'Type'),'patch') ==1
        set(children(l),'EdgeColor',[0.5 0.5 0.5],'FaceColor',get(children(l),'EdgeColor'))
    elseif  strcmp(get(children(l),'Type'),'line') ==1
       set(children(l),'lineWidth',2)
     end
    
end
axis tight
set(gcf, 'Position', get(0,'Screensize'));
%%
cd (DIROUTPUT)
 %export_fig ('scalplocation', '-tiff', '-cmyk', '-r300')
   saveas (gcf,'ScalpLocations_justDots', 'tiff')
  %close gcf
