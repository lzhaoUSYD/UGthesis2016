% Probably works. Test run on PC after pTP done.

% Call reEvaluateSolution.m accessing the .mph files after solving, in case
% of resplining.
fullConfigs = {...
%     1:22;
%     2:22;
    3:22;
%     4:22;
%     2:21;
%     2:21;
%     2:21;
    };

simModes = {...
%     'Monopolar';
%     'Bipolar';
%     'BP+1';
    'BP+2';
    'Tripolar';
    'Partial_Tripolar_0pt33';
    'Partial_Tripolar_0pt67';
    };

% ONE-OFF for the BP+1 case with 5x I0.
simModes = {'BP+1x5'};

numSimModes = length(simModes);

simDir = fullfile(pwd,'Outputs','simulations');

I0default = 0.1065; % mA

timeStamp = datestr(now,'ddmmHHMM');

simTime = 140; % seconds

tstart = tic;
for sim = 1:numSimModes
    simModeStr = simModes{sim};
    configs = fullConfigs{sim};
    
    result = cell(22,3);
        
    for e = configs%(1:2)
        % Get the address.
        simStr = [simModeStr '_' num2str(e)];
        simAdd = fullfile(simDir,simStr);
        disp(simAdd)
        
        % Re-evaluate.
        disp('Loading...')
        tic;model = mphload(simAdd);toc
        disp('Re-evaluating...')
        tic;c = reEvaluateSolution(model);toc;
        result{e,1} = c;
        
        % Figure out electrodes and currents again because of lack of
        % foresight in code structure.
        switch simModeStr
            case 'Monopolar'
                I0mA = I0default;
                
                activeElectrodes = e;
                inputCurrents    = I0default;
                
                resultVarName = 'MPresult';
            case 'Bipolar'                
                e1 = e;
                % Went for latter direction in simulations (could be either
                % side).
                e2 = e1 + 1; % e1 must be within [1,21]
                e2 = e1 - 1; % e1 must be within [2,22]
                I0mA = I0default;
                
                activeElectrodes = [e1,e2];
                inputCurrents    = [I0mA,-I0mA];
                
                resultVarName = 'BPresult';
            case 'BP+1'
                e1 = e;
                e2 = e1 + 2; % e1 must be within [1,20]
                e2 = e1 - 2; % e1 must be within [3,22]
                I0mA = I0default;
                
                activeElectrodes = [e1,e2];
                inputCurrents    = [I0mA,-I0mA];
                
                resultVarName = 'BP1result';
            case 'BP+1x5'
                e1 = e;
                e2 = e1 + 2; % e1 must be within [1,20]
                e2 = e1 - 2; % e1 must be within [3,22]
                I0mA = I0default;
                
                activeElectrodes = [e1,e2];
                inputCurrents    = 5*[I0mA,-I0mA];
                
                resultVarName = 'BP1x5result';
            case 'BP+2'
                e1 = e;
                e2 = e1 + 3; % e1 must be within [1,19]
                e2 = e1 - 3; % e1 must be within [4,22]
                I0mA = I0default;
                
                activeElectrodes = [e1,e2];
                inputCurrents    = [I0mA,-I0mA];
                
                resultVarName = 'BP2result';
            case 'Tripolar'
                e2 = e;
                e1 = e2 - 1;
                e3 = e2 + 1;
                
                I0mA = I0default;
                activeElectrodes = [e1,e2,e3];
                inputCurrents    = [-I0mA/2,I0mA,-I0mA/2];
                
                resultVarName = 'TPresult';
            case 'Partial_Tripolar_0pt33'
                e2 = e;
                e1 = e2 - 1;
                e3 = e2 + 1;
                
                I0mA = I0default;
                sigma = 1/3;
                activeElectrodes = [e1,e2,e3];
                inputCurrents    = [-I0mA/2*sigma,I0mA,-I0mA/2*sigma];
                
                resultVarName = 'pTPsig033result';
            case 'Partial_Tripolar_0pt67'
                e2 = e;
                e1 = e2 - 1;
                e3 = e2 + 1;
                
                I0mA = I0default;
                sigma = 2/3;
                activeElectrodes = [e1,e2,e3];
                inputCurrents    = [-I0mA/2*sigma,I0mA,-I0mA/2*sigma];
                
                resultVarName = 'pTPsig067result';
        end
        
        result{e,2} = activeElectrodes;
        result{e,3} = inputCurrents;        
        %         result = e;
    end
    % Accomodating to runProcessingV2.m structure.
    assignin('base',resultVarName,result)
    %     % Just checking
    %     eval(resultVarName)
    % Throw a time stamp in there to be safe and not overwrite anything
    % good.
    save([simModeStr timeStamp '.mat'],resultVarName);
end
toc(tstart)
playHallelujah
