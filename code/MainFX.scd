/// Make a MainFX chain for the stereo outs:

ProxyChain.add3(\eq, \filter -> { |in, locutfreq = 80, midGain = 4, airGain = 6|

	var snd = RHPF.ar(in, locutfreq, 0.7);
	snd = MidEQ.ar(snd, 2500, 2, midGain);
	snd = MidEQ.ar(snd, 10000, 2, airGain);
},
0.1,
(
	locutfreq: [20, 200, \exp],
	midGain: [-12, 12],
	airGain: [-12, 12],
)
);

ProxyChain.add3(\reverb, \filterIn -> { |in, revTime = 2, animRate = 0.1, animDepth = 0.3|

	AdCVerb2.ar(in.sum * 0.2,
		revTime.lag(0.5),
		animRate.lag(0.5),
		animDepth.lag(0.5),
		hfDamping: 0.1,
		nOuts: 2,         // fixed number of decorrelated output channels
		predelay: 0.03.lag(0.5),
		numCombs:     8,     // fixed number - increase for more density
		numAllpasses: 4,     // fixed number - increase for more diffuseness
		inFilter: 0.6,
		leakCoeff: 0.99
	);
},
0.1,
(
\revTime: [0.01, 100, \exp],
	\animRate: [0.01, 10, \exp],
	\animDepth: [0, 1, \amp],
	\hfDamping: [0, 1],
	\predelay: [0.0, 0.2, \amp],
	\revTime: [0.01, 100, \exp],
	\inFilter: [-0.99, 0.99]
)
);

ProxyChain.add3(
	\ampFin, \filter -> { |in, drive=1, ampLimit=0.96|
		Limiter.ar(in * drive, ampLimit, 0.03).clip2(0.9999);
	},
	1,
	( drive: [0.1, 10, \exp], ampLimit: [0.5, 1] )
);

/*
MainFX(s).clear;
*/
MainFX(s, 2, [\eq, \reverb, \ampFin]);

MainFX(s).add(\eq, 1).add(\ampFin, 1).add(\reverb, 0.08);

// MainFXGui(MainFX(s));
