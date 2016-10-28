clear

doMosaic = 1;
doGIF = 0;

%% Generates ffmpeg commands to use in Terminal.
% Borrows from this:
% web('https://trac.ffmpeg.org/wiki/Create%20a%20mosaic%20out%20of%20several%20input%20videos','-browser')

vidDir = [pwd '/Outputs/vid/'];

% Change directory.
commandcd = ['cd ' vidDir];
disp(commandcd)

thisMac = [1440,900];
%%
if doMosaic
    %% 1x3 mosaic of videos
    mosaicTemplate = ['ffmpeg -i 1.avi -i 2.avi -i 3.avi ',...
        '-filter_complex "nullsrc=size=BIGWIDTHxBIGHEIGHT [base]; ',...
        '[0:v] setpts=PTS-STARTPTS, scale=WIDTHxHEIGHT [left]; ',...
        '[1:v] setpts=PTS-STARTPTS, scale=WIDTHxHEIGHT [centre]; ',...
        '[2:v] setpts=PTS-STARTPTS, scale=WIDTHxHEIGHT [right]; ',...
        '[base][left] overlay=shortest=1 [tmp1]; ',...
        '[tmp1][centre] overlay=shortest=1:x=X1OFFSET [tmp2]; ',...
        '[tmp2][right] overlay=shortest=1:x=X2OFFSET ',...
        '" ',...
        '-c:v libx264 output.mkv'];
    % Resize
    bigWid = thisMac(1);
    bigHei = thisMac(2);
    wid    = bigWid/3;
    hei    = bigHei;
    x1     = wid;
    x2     = wid*2;
    inputs = {bigWid,bigHei,wid,hei,x1,x2};
    inputs = cellfun(@(x) num2str(x),inputs,'uniformoutput',0);
    
    commandMosaic1x3 = regexprep(mosaicTemplate,...
        {'BIGWIDTH','BIGHEIGHT','WIDTH','HEIGHT','X1OFFSET','X2OFFSET'},...
        inputs);
    % % MP vs BP vs TP
    % command2 = regexprep(command2,...
    %     {'1\.avi','2\.avi','3\.avi'},...
    %     {'Rattay1999Eqn4subplots3by1MP\.avi',...
    %     'Rattay1999Eqn4subplots3by1BP\.avi',...
    %     'Rattay1999Eqn4subplots3by1TP\.avi'})
    
    % % All vs all in a canon-like loop
    % command2 = regexprep(command2,...
    %     {'1\.avi','2\.avi','3\.avi'},...
    %     {'Rattay1999Eqn4subplots3by1AllModes4to21\.avi',...
    %     'Rattay1999Eqn4subplots3by1NoMP4to21\.avi',...
    %     'Rattay1999Eqn4subplots3by1NoMPBP4to21\.avi'})
    
    % BPs
    commandMosaic1x3 = regexprep(commandMosaic1x3,...
        {'1\.avi','2\.avi','3\.avi'},...
        {'Rattay1999Eqn4subplots3by1BP\.avi',...
        'Rattay1999Eqn4subplots3by1BP\+1\.avi',...
        'Rattay1999Eqn4subplots3by1BP\+2\.avi'});
end

if doGIF
    %% .mkv to .gif
    % http://superuser.com/questions/556029/how-do-i-convert-a-video-to-gif-using-ffmpeg-with-reasonable-quality
    % http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
    
    gifTemplate = ['ffmpeg -y -ss 30 -t 3 -i input.flv \',...
        '-vf fps=10,scale=320:-1:flags=lanczos,palettegen palette.png ',...
        'ffmpeg -ss 30 -t 3 -i input.flv -i palette.png -filter_complex \ ',...
        '"fps=10,scale=320:-1:flags=lanczos[x];[x][1:v]paletteuse" output.gif'];
    
    commandmkv2gif = regexprep(gifTemplate,...
        {'input.flv'},...
        {'Rattay1999Eqn4subplots3by1MPBPTP.mkv'});
    
    % chmod 777 ./gifenc.sh
    fname = 'Rattay1999Eqn4subplots3by1MPBPTP';
    fname = 'Rattay1999Eqn4subplots3by1BPs';
    fname = 'Rattay1999Eqn4subplots3by1Cascade';
    commandmkv2gif = regexprep('./gifenc.sh video.mkv anim.gif',...
        {'video.mkv','anim.gif'},...
        {[fname '.mkv'],[fname '.gif']});
end

%% .avi to .gif
avigifTemplate = 'ffmpeg -i video.avi -t 10 out.gif';
commandavi2gif = regexprep(avigifTemplate,...
        {'video.avi'},...
        {'main.avi'});

%% .png to .gif
% Weird colour
pnggifTemplate = 'ffmpeg -i %03d.png output.gif';
% fname = '160823_008_noise_fine_steps';
% commandpng2gif = regexprep(pnggifTemplate,...
%         {'%03d','output'},...
%         {['%06d'],fname});
fname = 'fibresxElectrodeXZ';
commandpng2gif = regexprep(pnggifTemplate,...
    {'%03d','output'},...
    {[fname '_%05d'],fname});
disp(commandpng2gif)
%     command = regexprep(pnggifTemplate,...
%         {'%03d','output'},...
%         {[fname '%05d'],fname});
    
%% Output the shell command
% 
% if exist('command','var')
%     disp(command)
%     clipboard('copy',command)
% end

%% Directly command from Matlab
% Change to the right directory.
system(commandcd)

% After making avi from runMakeVideo.
system(commandMosaic1x3)
system(commandavi2gif)

% Directly from serial .png files to .gif.
system(commandpng2gif)

% TODO see if mosaic works just as well for .gif to .gif
