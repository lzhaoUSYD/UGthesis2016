modelAddress   = fullfile('..','COMSOL models','Phil plus MP for COMSOL v5_0');
    fprintf(['Loading ' modelAddress '\n']);
    tic
    model = mphload(modelAddress);
    toc
    
    