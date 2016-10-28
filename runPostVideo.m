% BP1    = 'AFBipolar1.avi';
% BP2    = 'AFBipolar2.avi';
% BP     = 'AFBipolar.avi';
% MP     = 'AFMonopolar.avi';
% pTP2   = 'AFpTripolarSig2.avi';
% pTP033 = 'AFpTripolarSig033.avi';
% TP     = 'AFTripolar.avi';
% 
% stimModes = {MP,BP,BP1,BP2,TP,pTP2,pTP033};

% outname = 'MPvsBPvsTP';
% outname = 'BPvsBP1vsBP2';
% outname = 'pTPsig033vsTPvspTPsig067';
% outname = 

% vid1 = eval(vids{1});
% vid2 = eval(vids{2});
% vid3 = eval(vids{3});

fnames = {...
    'MP';
    'BP';
    'BP1';
    'BP2';
    'TP';
    'pTPsig067';
    'pTPsig033';
    };

vidNames = cellfun(@(x) [x '.avi'],fnames,'uniformoutput',0);

% Indices of modes to be compared.
% MPvsBPvsTP
compTriplet = [1 2 5];
% % BPvsBP1vsBP2
compTriplet = [2 3 4];
% % pTPsig033vsTPvspTPsig067
compTriplet = [5 6 7];

% Process (one triplet at a time).
% vids = strsplit(outname,'vs');
compVids = vidNames(compTriplet);
vid1 = compVids{1};
vid2 = compVids{2};
vid3 = compVids{3};
% Separate names with 'vs' and fiddly string manipulation.
outname = cellfun(@(x) [x 'vs'],fnames(compTriplet),'uniformoutput',0);
outname = strcat(outname{:});
outname = outname(1:end-2);
compareModes(vid1,vid2,vid3,outname)

%% .avi to .gif
vidNames = {'BP1\_5.avi','BP\+1\_5.avi'};
for s = 1:length(vidNames)
%     name = [s{:} '.avi'];
    name = vidNames{s};
    name = name(1:end-4);
    avigifTemplate = 'ffmpeg -i video.avi -t 10 out.gif ';
    command = regexprep(avigifTemplate,...
        {'video','out'},...
        {name,name});
    disp(command)
end


% Now copy and paste the commands into Terminal.