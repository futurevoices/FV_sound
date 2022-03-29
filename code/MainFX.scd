/// Make a MainFX chain for the stereo outs:

/*
MainFX(s).clear;

MainFX(s, 2, [\eq, \reverb, \dualMax, \ampFin]);

MainFX(s).set(\drive, 0.7);

MainFX(s).add(\eq, 1).add(\ampFin, 1).add(\reverb, 0.08);

MainFXGui(MainFX(s));
*/

ProxyChain.add3(\eq, \filter -> { |in, locutfreq = 30, midGain = 0, airGain = 6|

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
	\ampFin, \filter -> { |in, drive=0.5, ampLimit=0.96|
		Limiter.ar(in * drive, ampLimit, 0.03).clip2(0.9999);
	},
	1,
	( drive: [0.1, 10, \exp], ampLimit: [0.5, 1] )
);

///// dual band compressor
///// - try whether this sounds better than ampFin limiter
//////////// NOT WORKING YET!

(
ProxyChain.add3('dualMax', \filter -> { |in,
	limit = 1.0, gain = 1,
	eqTilt = 0.0, limTilt = -0.5, xfreq = 300|

	var loGain, hiGain, loSig, hiSig;
	var loLim, hiLim;
	var loMax = 0, hiMax = 0;
	var loCtl, hiCtl, loOut, hiOut, sumOut;

	limit = limit.lag(0.1);
	gain = gain.lag(0.1);
	xfreq = xfreq.lag(0.1);

	loGain = eqTilt.lag(0.1).linlin(-1, 1, 1.8, 0.2);
	hiGain = 2 - loGain;
	loLim = limTilt.lag(0.1).linlin(-1, 1, 0.9, 0.1);
	hiLim = (1 - loLim);
	// adjust for equal power, and scale to limit:
	loLim = (loLim.sqrt * limit);
	hiLim = (hiLim.sqrt * limit);

	loSig = RLPF.ar(in, xfreq.lag(0.1), 0.7);
	hiSig = (in - loSig);
	loSig = loSig * (loGain * gain); //.postln.poll(2, "logain");
	hiSig = hiSig * (hiGain * gain); // .poll(2, "higain");

	// get level control signals from channels
	loCtl = PeakFollower.ar(loSig, 0.999).postln; // .poll(2, "loCtl"); // estimate pretty fast response, adjust!
	hiCtl = PeakFollower.ar(hiSig, 0.999);

	// // link channels: take peaks of loudest chan as control signals:
	// loCtl.do { |ch| loMax = max(loMax, loCtl) };
	// hiCtl.do { |ch| hiMax = max(hiMax, hiCtl) };
	// loCtl = loMax;
	// hiCtl = hiMax;

	// tweak these: slopeAbove is 0.0, i.e. hard limit
	// clampTime is as fast as possible with 0.002,
	// relaxtime is normal with 0.1.
	loOut = Compander.ar(loSig, loSig, loLim, 1, 0.0, 0.0, 0.1);
	hiOut = Compander.ar(hiSig, hiSig, hiLim, 1, 0.0, 0.0, 0.1);

	sumOut = loOut + hiOut;
	// hard clip for peaks that escape equal-power-bandsplit
	SendReply.ar(sumOut.abs > 1.0, "/clipped", (0..sumOut.lastIndex));
	sumOut.clip2(limit);

}, 1, (
	limit: [0.1, 1, \exp],
	gain: [0.25, 8, \exp],
	eqTilt: \pan,
	limTilt: \pan,
	xfreq: [100, 900, \exp],
));
);

MainFX(s).clear;

MainFX(s, 2, [\eq, \reverb, \dualMax, \ampFin]);

MainFX(s).set(\drive, 0.7);

MainFX(s).add(\eq, 1).add(\ampFin, 1).add(\reverb, 0.08);

