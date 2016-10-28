
function compareModes(vid1,vid2,vid3,outname)
%% Set up 

% Modify system path to allow ffmpeg. Haven't figured out how to do all of
% ffmpeg within Matlab.
% command = ['path1 = getenv(''PATH'') ',...
% 'path1 = [path1 '':/usr/local/bin''] ',...
% 'setenv(''PATH'', path1) ',...
% '!echo $PATH '];
% doCommand(command)

% doCommand('ls')

% Change directory.
vidDir = [pwd '/Outputs/vid/'];
command = ['cd ' vidDir ' '];
doCommand(command)

% doCommand('ls')

thisMac = [1440,900];

%% Preprocess filenames to avoid annoying characters.
% No need

% vid1 = escape(vid1);
% vid2 = escape(vid2);
% vid3 = escape(vid3);
% 
% outname = escape(outname);

%% 1x3 mosaic in .avi, outputs as .mkv
mosaicTemplate = ['ffmpeg -i vid1.avi -i vid2.avi -i vid3.avi ',...
    '-filter_complex "nullsrc=size=BIGWIDTHxBIGHEIGHT [base]; ',...
    '[0:v] setpts=PTS-STARTPTS, scale=WIDTHxHEIGHT [left]; ',...
    '[1:v] setpts=PTS-STARTPTS, scale=WIDTHxHEIGHT [centre]; ',...
    '[2:v] setpts=PTS-STARTPTS, scale=WIDTHxHEIGHT [right]; ',...
    '[base][left] overlay=shortest=1 [tmp1]; ',...
    '[tmp1][centre] overlay=shortest=1:x=X1OFFSET [tmp2]; ',...
    '[tmp2][right] overlay=shortest=1:x=X2OFFSET ',...
    '" ',...
    '-c:v libx264 output.mkv '];
% Resize
bigWid = thisMac(1);
bigHei = thisMac(2);
wid    = bigWid/3;
hei    = bigHei;
x1     = wid;
x2     = wid*2;
inputs = {bigWid,bigHei,wid,hei,x1,x2};
inputs = cellfun(@(x) num2str(x),inputs,'uniformoutput',0);

command = regexprep(mosaicTemplate,...
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
command = regexprep(command,...
    {'vid1\.avi','vid2\.avi','vid3\.avi','output'},...
    {vid1,vid2,vid3,outname});
doCommand(command)
%% Then .mkv to .gif
command = regexprep('./gifenc.sh video.mkv anim.gif ',...
        {'video','anim'},...
        {outname,outname});
    doCommand(command)

% avigifTemplate = 'ffmpeg -i video.avi -t 10 out.gif';
% command = regexprep(avigifTemplate,...
%     {'video.avi'},...
%     {outname});

    function safe = escape(input)
        tmp = input;
        riskyChars = '.+';
        for r = riskyChars
            tmp = strrep(tmp,r,['\',r]);
        end
        safe = tmp;
    end

    function doCommand(command)
        disp(command)
%         system(command)
    end
end