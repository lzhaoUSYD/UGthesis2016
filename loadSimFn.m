% Function for loading .mph files with simulation results, checking electrode
% configurations.
function [simC_mA,simV] = loadSimFn(modelAddress)

% close all
% 
% doSave = 0; % Save as figs
% doFlush = 0; % Clear the model (java)
% 
% if doFlush
%     % Remove the model object in java.
%     clear java
%     % Unfortunately kills everything else, so restart them.
%     mphstart;
%     import com.comsol.model.*;
%     import com.comsol.model.util.*;
% end
% 
% simDir = fullfile(pwd,'Outputs','simulations');
% fname = 'Monopolar_6';
% modelAddress = fullfile(simDir,fname);

%% Dummy configuration for testing saving
% currents = 1:22;
% currents(1:3:22) = pi;
% milliAmps = '[mA]';
% 
% for e = 1 : 22
%     tag = ['term' num2str(e)];
%     current = currents(e); % Dummy current equivalent to electrode number for testing.
%     currentStr = [num2str(current) milliAmps];
%     
%     % Set
%     fprintf(['Setting ' tag ' to %.4f mA.\n'],current);
%     model.physics('ec').feature(tag).set('I0',currentStr);
%     
%     % model.physics('ec').feature('term1').set('V0',1);
%     % model.physics('ec').feature('term1').set('I0',0.1065e-3);
%     % model.physics('ec').feature('term1').set('Zref',50);
%     %
%     % model.physics('ec').feature('term1').set('Vinit',0);
%     % model.physics('ec').feature('term1').set('Iinit',1);
%     
%     % Query (check)
%     %     mphgetproperties(model.physics('ec').feature(tag))
% end

%% Save configuration
% fprintf(['Saving ' modelAddress '\n']);
% tic
% mphsave(model,modelAddress);
% toc
%% 

%% Load blank results 
% % ~90 s on Level 8, 120 s on my laptop.
% 
% 
% %     modelAddress = '../COMSOL models/Model_Head - Phil''s model original';
% %     modelAddress = '../COMSOL models/Model_Head - Phil''s model';
% %     modelAddress   = '../COMSOL models/Model_Head - Phil''s model MP';
% % phil   = '../COMSOL models/Phil plus MP for COMSOL v5_0';
% modelAddress = fullfile('..','COMSOL models','Phil plus MP for COMSOL v5_0');
% % 
% fprintf(['Loading ' modelAddress '\n']);
% tic
% model = mphload(modelAddress);
% toc
% % 
% % Check the electrode configurations
% milliAmps = '[mA]';
% currentsGet_mA = nan(1,22);
% 
% for e = 1 : 22
%     % Element name for accessing in Comsol.
%     tag = ['term' num2str(e)];
%     term = mphgetproperties(model.physics('ec').feature(tag));    
%     tI0 = term.I0; % mA, as string
%     
%     % Process string to get only the numerical value back.
%     current = sscanf(tI0,'%f');    
%     currentsGet_mA(e) = current;
% end
% currentsGet_mA

%% Load simulation results 
% ~90 s on Level 8, 120 s on my laptop.
% modelAddress = [simDir fname]
% modelAddress = fullfile(simDir,fname);


%     modelAddress = '../COMSOL models/Model_Head - Phil''s model original';
%     modelAddress = '../COMSOL models/Model_Head - Phil''s model';
%     modelAddress   = '../COMSOL models/Model_Head - Phil''s model MP';
% modelAddress   = '../COMSOL models/Phil plus MP for COMSOL v5_0';

fprintf(['Loading ' strrep(modelAddress,'\','\\') '; time started = ' datestr(now,'HH:MM') '\n']);
tic
model = mphload(modelAddress);
toc

% Check the electrode configurations
milliAmps = '[mA]';
currentsGet_mA = nan(1,22);

for e = 1 : 22
    % Element name for accessing in Comsol.
    tag = ['term' num2str(e)];
    term = mphgetproperties(model.physics('ec').feature(tag));    
    tI0 = term.I0; % mA, as string
    
    % Process string to get only the numerical value back.
    current = sscanf(tI0,'%f');    
    currentsGet_mA(e) = current;
end
currentsGet_mA

V = mphinterp(model,'V','dataset','cpt')';

simC_mA = currentsGet_mA;
simV = V;
%% Landmarks
% 
% % Relevant domains
% dom.ScVest  = 5;  % Extends to nerve trunk
% dom.Electrodes   = 15;
% dom.CNVII   = 25; % Facial nerve identified by geniculate ganglion.
% dom.CNVIII  = 31;
% dom.BonyLab = 33; % Goes up to nerve trunk. Spline this
% 
% dom.ScTymp  = 34; % Includes electrode array
% dom.ScMedia = 35; % COCHLEAR PARTITION Spline this
% dom.SpGang  = 37; % Spline this
% dom.NTrunk  = 47;
% dom.notSure = 48;
% 
% dom.Elec    = [40:46 49:56 58:64]; % 22 electrodes appearing in increasing order of x-coord
% domNames = fieldnames(dom);
% domNames = {domNames{:}};
% numDoms = length(domNames);
% 
% % Relevant points
% pointRange = 7000:17765;
% nTrunkPoints = 14321:17784;
% numPoints = length(nTrunkPoints);
% 
% % c = zeros(numPoints,3);
% % for p = nTrunkPoints
% %     c(p - min(nTrunkPoints) + 1,:) = mphgetcoords(model, 'geom1', 'point', p)';
% % end
% %
% % Relevant boundaries
% boundRange = 4544:5903;
% numBounds = length(boundRange);
% bound.Array = 4983;
% 
% % Electrode entities manually ordered along cochlear spiral
% domBaseToApex      = [40,44,50,55,58,60,62,64,63,61,59,56,52,46,43,41,42,45,49,53,54,51];
% boundBasetoApexRange = [6054;
%     6359;
%     6656;
%     6907;
%     7126;
%     7322;
%     7478;
%     7591;
%     7567;
%     7426;
%     7233;
%     6986;
%     6723;
%     6425;
%     6180;
%     6077;
%     6159;
%     6361;
%     6600;
%     6824;
%     6901;
%     6710];
% % [6078,7126,7322,7478,7591,7567,7426,7233,6986];
% % Titanium (electrodes)
% model.material('mat19');
% 
% domains = cell(numDoms,2);
% % Iterate through domains
% for d = 1 : numDoms
%     domName = domNames{d};
%     domNum = dom.(domName);
%     % Something about memory between java and functions didn't work out so
%     % calling these as scripts to modularise.
%     % Uses model, domNum; returns c, x, y, z, V
%     %% Get cut points & evaluate
%     c = mphgetcoords(model, 'geom1', 'domain', domNum)';
%     domains{d,1} = c;
%     domains{d,2} = domName;
% end
