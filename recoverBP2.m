close all

toRecover = {'BP+2 4.fig'
'BP+2 5.fig'
'BP+2 6.fig'
'BP+2 7.fig'
'BP+2 8.fig'
'BP+2 9.fig'
'BP+2 10.fig'
'BP+2 11.fig'
'BP+2 12.fig'};

potDir = [pwd '/Outputs/Potentials/'];

temp = BP2result

for r = 1:length(toRecover)
   open([potDir toRecover{r}]) 
   hscatter = findobj(gca,'type','scatter');
   x = hscatter.XData(:);
   y = hscatter.YData(:);
   z = hscatter.ZData(:);
   V = hscatter.CData(:);
   temp{3+r,1} = [x,y,z,V]
end
