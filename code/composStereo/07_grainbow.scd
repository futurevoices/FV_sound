// compos: grainbow
// choose file by some logic, e.g. all really short ones
// start N grainplayers with an env for read position
// envs have different warps so some starts faster, others slower
// LFNoise for pan and amp
// repeat and overlap with next file


Tdef('fv_grainbow').set(\randSeed, nil);

Tdef('fv_grainbow').set(\chosenDur, 120);

Tdef('fv_grainbow').quant_(0).stop.play;

Tdef('fv_grainbow', { |ev|
	var mykey = 'fv_grainbow';
	var thisTdef = Tdef(mykey);
	var thisNdef = q.tdefPrepNdef(thisTdef);
	var time0 = Main.elapsedTime;

	0.1.wait;
	"\n*** % starts ***\n\n".postf(thisTdef);
	q.tdefSeed(thisTdef);
	0.1.wait;
	// really make sure the ndef plays ...
	thisNdef.play(fadeTime: 0.1);

	inf.do {
		var dicts = q.bufmem.filterDict(q.mainDict);

		dicts.values.scramble.do { |dict|
			var dur = dict.dur, buf;
			var numvoices = exprand(3, 8).round;
			var pitchvar = 0.1.linrand.round(0.001);

			// compTdef, startedTime, intendedDur, projected next dur
			MFdef(\adjustTime).value(thisTdef, time0, ev.chosenDur, dur);

			q.readBufToDict(dict);
			buf = dict.buf;


			MFdef(\sendInfo).value(dict.name, q.activeTdef.key);
			"- % n: % pvar: %\n".postf(dict.name, numvoices, pitchvar);

			thisNdef.fadeTime = 1;

			Ndef(mykey, {
				var timebends = { 3.0.rand2 }.dup(numvoices).sort / max(1, buf.duration / 10);
				var readenvs = timebends.collect { |warp| Env([0, 1], [ 1 ], warp) };
				var readposes = readenvs.collect(EnvGen.kr(_, timeScale: dur));
				var graindurscale = (1.62 ** LFDNoise3.kr(0.3));
				var grains = readposes.collect { |readpos, i|
					GrainBuf.ar(2, Impulse.ar(20, i / numvoices),
						0.1 * graindurscale, buf,
						LFNoise0.kr(100, pitchvar, 1),
						readpos, 2,
						i.linlin(0, numvoices - 1, -1, 1)
					)
					* (LFNoise2.kr(0.3, 0.5, 0.5) ** 1.5)
				};
				grains = grains.mean * 6;
				if (0.5.coin) { grains = grains.reverse };
				grains * Env([1, 1, 0 ], [buf.duration, 1]).kr(2);
			});
			(dur).wait;
		};
		1.wait;
	};
	"*** % looping ...\n".postf(thisNdef);
	1.wait;
});
