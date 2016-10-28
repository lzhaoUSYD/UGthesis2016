% Takes images as frames and make a video out of them.
% Filenames of images begin with vidTitle and are numbered sequentially
% after an underscore. 
% e.g. filename_1.png, filename_2.png
% 67 s for 720 frames

function frames2video(vidTitle,varargin)
if nargin > 1
    secsPerImage = varargin{1}; % 1/fps
else
    secsPerImage = 1/20; % 20 fps
end

%>> Compile video.
% Select image sequence to compile.
%     vidTitle = 'greenwood';
vidDir = [pwd '/Outputs/vid/'];

allFiles = dir(vidDir);

% % Match all files starting with vidTitle, e.g. MP
% Pre-processing to escape regexp characters
vidTitle = strrep(vidTitle,'+','\+');

% Match all files starting with vidTitle and numbered
% title num_num.png, e.g. MP 22_58.
% imfiles = regexpi({allFiles.name},[vidTitle '.*\d+_\d+.*'],'match');

% Match video title with any strings before numbering.
% imfiles = regexpi({allFiles.name},[vidTitle '.*_\d+.*'],'match');
% Exact match of video title.
imfiles = regexpi({allFiles.name},[vidTitle '_\d+.*'],'match');

imfiles = [imfiles{:}]

% %% Figure out processing time.
% numImages = length(imfiles);
% 
% timePerImage = 0.21/10/60; % Minutes.
% estTimeMinutes = numImages * timePerImage;
% if estTimeMinutes > 1
%     numHours = floor(estTimeMinutes/60);
%     numMinutes = mod(estTimeMinutes,60);
%     checkBack = datestr(now + datenum(0,0,0,numHours,numMinutes,0),'HH:MM:SS dd/mmm/yyyy');
%     
%     checkTime = sprintf(['Estimated time for frames2video: %d hours %.2f minutes (come back around ' checkBack '). Continue?'],...
%         numHours,numMinutes);
%     confirmRun = questdlg(checkTime);
%     switch confirmRun
%         case 'Yes'
%             fprintf(['Come back around ' checkBack '\n']);
%         otherwise
%             disp('Cancelled.')
%             return
%     end
%     
%     timeStamp =  datestr(now,'dd-mmm-yyyy HH-MM-SS');
% end

%% Business end

if isempty(imfiles)
    fprintf('No .png files found beginning with ''%s''!\n',vidTitle);
    return
end

%>> Load images.
images    = cell(1,length(imfiles));
for im = imfiles
    fname = im{:};
    imSeqNumIndex = regexpi(fname,'\d*.png');
    imSeqNum = str2num(fname(imSeqNumIndex:end-4));
    images{imSeqNum} = imread([vidDir fname]);
end

%>> Set up video.
%     vidTitle = 'blah.avi';
%     vidDir = [pwd '/Outputs/vid/'];

% Remove regexp escapes.
vidTitle = strrep(vidTitle,'\','');

vidObj = VideoWriter([vidDir vidTitle]);
vidObj.FrameRate = 1/secsPerImage;
secsPerImage = 1/vidObj.FrameRate;
framesPerImage = vidObj.FrameRate * secsPerImage;

% open the video writer
open(vidObj);

images = images(cellfun(@(x) ~isempty(x),images));
% write the frames to the video
for u=1:length(images)
    % convert the image to a frame
    frame = im2frame(images{u});
    
    for v=1:framesPerImage
        writeVideo(vidObj, frame);
    end
end

% close the writer object
close(vidObj);

end