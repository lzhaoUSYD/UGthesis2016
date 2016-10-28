

cln = model.result.dataset.create('cln', 'CutLine3D');
      cln.setIndex('genpoints','1e-2',1,0);
      cln.setIndex('genpoints','1e-2',0,2);
      cln.setIndex('genpoints','5e-2',1,0);
      T = mphinterp(model,'T','dataset','cln')

data = mphinterp(model, <expr>, 'dataset', <dsettag>);