pianoHigh = 4186.01;
pianoLow = 27.5;
numKeys = 88;
hearingHigh = 20e3;

r = 2^(1/12);
% hearingHigh = 27.5 * r^(n-1)
solve(hearingHigh == 27.5 * r^(n-1))
s = vpa(solve('20e3 = 27.5 *  2^(1/12)^(x-1)'),3);

logspace(log10(pianoLow),log10(20e3),115);