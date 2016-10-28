
close all

doSave = 0; % Save as figs
doFlush = 0; % Clear the model (java)

if doFlush
    % Remove the model object in java.
    clear java
    % Unfortunately kills everything else, so restart them.
    mphstart;
    import com.comsol.model.*;
    import com.comsol.model.util.*;
end

%% S U M M A R Y O F C O M M A N D S | 185

% colortable
% mphdoc
% mpheval
% mphevalglobalmatrix
% mphevalpoint
% mphgeom
% mphgetadj
% mphgetcoords
% mphgetexpressions
% mphgetproperties
% mphgetselection
% mphgetu
% mphglobal
% mphimage2geom
% mphint2
% mphinterp
% mphload
% mphmatrix
% mphmax
% mphmean
% mphmesh
% mphmeshstats
% mphmin
% mphmodel
% mphmodellibrary
% mphnavigator
% mphplot
% mphsave
% mphsearch
% mphselectbox
% mphselectcoords
% mphshowerrors
% mphsolinfo
% mphstart
% mphstate
% mphversion
% mphviewselection
% mphxmeshinfo

%% Port the model
% Avoid unnecessary loading/waiting. Takes about 2 minutes.
if ~exist('model','var')
    modelAddress = '../COMSOL models/Model_Head - Phil''s model original';
    modelAddress = '../COMSOL models/Model_Head - Phil''s model';
    %     modelAddress   = '../COMSOL models/Model_Head - Phil''s model MP';
    modelAddress   = '../COMSOL models/Phil plus MP for COMSOL v5_0';
    modelAddress   = fullfile('..','COMSOL models','Phil plus MP for COMSOL v5_0');
    fprintf(['Loading ' modelAddress '\n']);
    tic
    model = mphload(modelAddress);
    toc
end
viewTop = [-146.5,-10];
viewSide = [-155.5,-80];

%% Landmarks

% Relevant domains
dom.ScVest  = 5;  % Extends to nerve trunk
dom.Electrodes   = 15;
dom.CNVII   = 25; % Facial nerve identified by geniculate ganglion.
dom.CNVIII  = 31;
dom.BonyLab = 33; % Goes up to nerve trunk. Spline this

dom.ScTymp  = 34; % Includes electrode array
dom.ScMedia = 35; % COCHLEAR PARTITION Spline this
dom.SpGang  = 37; % Spline this
dom.NTrunk  = 47;
dom.notSure = 48;

dom.Elec    = [40:46 49:56 58:64]; % 22 electrodes appearing in increasing order of x-coord
domNames = fieldnames(dom);
domNames = {domNames{:}};
numDoms = length(domNames);

% Relevant points
pointRange = 7000:17765;
nTrunkPoints = 14321:17784;
numPoints = length(nTrunkPoints);

% c = zeros(numPoints,3);
% for p = nTrunkPoints
%     c(p - min(nTrunkPoints) + 1,:) = mphgetcoords(model, 'geom1', 'point', p)';
% end
%
% Relevant boundaries
boundRange = 4544:5903;
numBounds = length(boundRange);
bound.Array = 4983;

% Electrode entities manually ordered along cochlear spiral
domBaseToApex      = [40,44,50,55,58,60,62,64,63,61,59,56,52,46,43,41,42,45,49,53,54,51];
boundBasetoApexRange = [6054;
    6359;
    6656;
    6907;
    7126;
    7322;
    7478;
    7591;
    7567;
    7426;
    7233;
    6986;
    6723;
    6425;
    6180;
    6077;
    6159;
    6361;
    6600;
    6824;
    6901;
    6710];
% [6078,7126,7322,7478,7591,7567,7426,7233,6986];
% Titanium (electrodes)
model.material('mat19');

%>> DEPRECATED (single) Electrode selection. Don't need boundaries any more
% after manually creating 22 terminals in COMSOL.
% elecSelect = 1:22;
% elecSelect = 11; % Default (7233)
% Get electrode boundary index/indices and store in bd_idx. Each row
% contains the boundaries adjacent to a domain. 2 boundary numbers:
% one for the front (tissue-contacting) surface,
% one for the other 5 surfaces of the electrode.
% Don't know how Cochlear made those or how to differentiate
% programmatically, if needed. The boundary with 5 surfaces has been used
% as the default.
%
% Boundaries of electrodes with front surface as the 2nd index of bd_idx.
% 7322 7478 7591 7567 7426 7233 6985 ... 6159 ... 6600 6824 6901 6710
% x-coordinate of top right > bottom left from x-y view?
% bd_idx = [];
% for domElec = 1:length(elecSelect)
%     bd_idx = [bd_idx;
%         mphgetadj(model,'geom1','boundary','domain',domBaseToApex(domElec))];
% end



% Default stimulation setting: 59 (11th) (7233)


%
% c = [];
% for b = boundRange
%     c = [c;mphgetcoords(model, 'geom1', 'boundary', b)'];
% end


domains = cell(numDoms,2);
%% Iterate through domains
for d = 1 : numDoms
    domName = domNames{d};
    domNum = dom.(domName);
    % Something about memory between java and functions didn't work out so
    % calling these as scripts to modularise.
    % Uses model, domNum; returns c, x, y, z, V
    %% Get cut points & evaluate
    c = mphgetcoords(model, 'geom1', 'domain', domNum)';
    domains{d,1} = c;
    domains{d,2} = domName;
end



% data = mphinterp(model, <expr>, 'dataset', <dsettag>)


% cln.getDoubleArray('pointx');
