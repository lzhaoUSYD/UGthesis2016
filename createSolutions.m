model.sol().create('sol2')
model.sol('sol2').feature().create('s2','Stationary')
model.sol('sol2').feature('s2').create('i2','Iterative')
model.sol('sol2').feature('s2').feature('i2').feature('mg2').set('prefun','amg')

% amgauto	3
% coarsening	brutal
% coarseningactive	off
% enrich	0
% enrichactive	off
% geomuse	geom1
% gmglevels	1
% hybridcomp	[empty stringarray]
% hybridization	single
%>> change hybridvar to 'mod1_V, mod1_ec_term1_V0_ode'
%>> couldn't change 'Unknown feature.'
% hybridvar	[empty stringarray] change 
% hybridvarspec	all
% interpolation	standard
% interpolationactive	off
% iter	2
% iterm	iter
% jacinterp	off
% jacinterpactive	off
% massem	on
% maxcoarsedof	5000
% mcaseassem	[empty stringarray]
% mcasegen	any
% mcaseuse	[empty stringarray]
% mgcycle	v
% mglevels	5
% mkeep	off
% negcoupl	0.25
% negcouplactive	off
% poscoupl	1
% poscouplactive	off
%>> change prefun to 'amg'
% prefun	gmg 
% rhob	1
% rmethod	longest
% scale	2
% truncinterp	0.2
% truncinterpactive	off