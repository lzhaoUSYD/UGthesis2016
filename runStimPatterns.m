% DEPRECATED. runStimPatternsV2 has if-end blocks that make more sense.

% Configurations as discussed in:
% - 2016 Kalkman et al
% - 2015 Wong

I0default = 0.1065; % mA

doRun = [1 0 0 0 0 0 0];
% 1. MP
% 2. BP
% 3. BP+1
% 4. BP+2
% 5. TP
% 6. pTP
% 7. PA

% Records on running time
% 1 electrode
% 204 s
%
% 3 electrodes
% c = oneShotStimPattern(model,[1 22 5],[5 9 18]);
% 177 s
%
% 5 electrodes
% c = oneShotStimPattern(model,[1 5 9 13 17],[1 5 1 5 1]);
% 235 s
% Doesn't look like the solution was updated.

tic
for e = 22%1:22
    %% Monopolar
    if doRun(1)
        I0mA = I0default;
        
        activeElectrodes = e;
        inputCurrents    = I0mA;
        
        MPresult{e} = oneShotStimPattern(model,activeElectrodes,inputCurrents);
    end
    
    
    %% Bipolar
    if doRun(2)
        e1 = e;
        % Either side
        e2 = e1 + 1; % e1 must be within [1,21]
        e2 = e1 - 1; % e1 must be within [2,22]
        I0mA = I0default;
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
        
        BPresult{e} = oneShotStimPattern(model,activeElectrodes,inputCurrents);
    end
    if doRun(3)
        e1 = e;
        %% BP+1
        e2 = e1 + 2; % e1 must be within [1,20]
        e2 = e1 - 2; % e1 must be within [3,22]
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
        
        BP1result{e} = oneShotStimPattern(model,activeElectrodes,inputCurrents);
    end
    if doRun(4)
        e1 = e;
        %% BP+2
        e2 = e1 + 3; % e1 must be within [1,19]
        e2 = e1 - 3; % e1 must be within [4,22]
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
        
        BP2result{e} = oneShotStimPattern(model,activeElectrodes,inputCurrents);
    end
    %% Tripolar
    if doRun(5)
        % 1994 Busby et al Pitch perception for different modes of stimulation using the cochlear multiple-electrode prosthesis
        
        % Centered around e2: e2 must be within [2,21].
        e2 = e;
        e1 = e2 - 1;
        e3 = e2 + 1;
        
        I0mA = I0default;
        activeElectrodes = [e1,e2,e3];
        inputCurrents    = [I0mA,-I0mA/2,-I0mA/2];
        
        TPresult{e} = oneShotStimPattern(model,activeElectrodes,inputCurrents);
    end
    if doRun(6)
        %% Partial Tripolar
        for sigma = [0.1 0.5 0.9]
            % Centered around e2: e2 must be within [2,21].
            e2 = e;
            e1 = e2 - 1;
            e3 = e2 + 1;
            
            I0mA = I0default;
            sigma = 0.5;
            activeElectrodes = [e1,e2,e3];
            inputCurrents    = [I0mA,-I0mA/(2*sigma),-I0mA/(2*sigma)];
            
            pTPresult{e,sigma} = oneShotStimPattern(model,activeElectrodes,inputCurrents);
        end
    end
    %% Phased array
    if doRun(7)
        % Lit review
        % 2011 Frijns et al Neural excitation patterns induced by phased-array stimulation in the implanted human cochlea
        % 2014 George et al Evaluation of focused multipolar stimulation for cochlear implants in acutely deafened cats
    end
end
toc

playHallelujah
