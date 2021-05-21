% generate params
h = round(rcosdesign(0.25,20,4)*2048);
fvtool(h,'magnitude');
fvtool(h,'impulse');

% write to file
fileID = fopen('data.txt','w');
fprintf(fileID,'%d\t',h);
fclose(fileID);