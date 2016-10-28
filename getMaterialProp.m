modelAddress   = fullfile('..','COMSOL models','Phil plus MP for COMSOL v5_0');
    fprintf(['Loading ' modelAddress '\n']);
    tic
    model = mphload(modelAddress);
    toc

% Assumes loaded.

clc
materialsHEATHER = cell(21,3);
for m = 1:21
tag = ['mat' num2str(m)];

material = model.material(tag).name
mat1 = model.material(tag);
mm = mat1.propertyGroup('def');

params = mm.param;
% param(1)

mSigma = mm.getString('electricconductivity')
epsilonr = mm.getString('relpermittivity');
materialsHEATHER{m,1} = char(material);
materialsHEATHER{m,2} = eval(char(mSigma));
materialsHEATHER{m,3} = eval(char(epsilonr));
end
materialsHEATHER
save('./codeGenerators/HEATHER.mat','materialsHEATHER')



