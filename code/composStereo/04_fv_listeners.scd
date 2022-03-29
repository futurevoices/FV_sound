/*
See:
Miller Puckette, The Theory and Technique of Electronic Music, p. 126
http://crca.ucsd.edu/~msp/techniques/latest/book.pdf
"http://crca.ucsd.edu/~msp/techniques/latest/book-html/node77.html#sect5.ringmod".openOS;
*/

(
MFdef('fv_listeners').add(\prep, {
	// filter Ndef for all voices:
	/////// was fv_catchAll
	forkIfNeeded {

		MFdef(\brazil).value;

		Ndef('fv_listeners').ar(numChannels: 2);
		Ndef('fv_listeners').play;
		try { s.sync };

		Ndef('fv_listeners')[5] = \filter -> {|in| HPF.ar(DelayN.ar(in, 0.2,  LFNoise0.ar(1/2).exprange(0.2, 1/200).lag(0.2, 0.5), 1, in), 40)  };

		Ndef('fv_listeners')[10] = \filter -> {|in| HPF.ar(CombL.ar(in, 0.1, LFNoise0.ar(1).exprange(1/100, 1/4000).lag(0.2, 0.5), 2, 0.2), 40)  };

		Ndef('fv_listeners')[20] = \filter -> {|in| HPF.ar(AdCVerb.ar(in, 4, 0.6), 40, 0.1)  };

		Ndef('fv_listeners').set(\wet5, 0.75);
		Ndef('fv_listeners').set(\wet10, 0.05);
		Ndef('fv_listeners').set(\wet20, 0.075);

		try { s.sync };

		Ndef(\fv_companion, {
			var in, ampTr, ampFollower, freq, hasFreq, sound, blipFr, mod, modFormant, modBW;
			in = Ndef('fv_listeners').ar(2);
			ampTr = Amplitude.kr(in.mean, 0.05, 5);
			ampFollower = 1 - (ampTr.madd(20).clip(0, 0.95).sqrt).lag2(0.02, 6);
			# freq, hasFreq = Pitch.kr(in.mean);

			modFormant = LFTri.kr([0.12, 0.09]).exprange(100, 1000);
			modBW = modFormant * LFPar.kr(0.23).range(0.1, 0.8);
			mod = LFNoise1.kr([2, 1, 1, 0.2, 0.11]);
			blipFr = freq/[4/3, 3/4.2, 0.51, 16.02, 6.043, 41/20, 3, 5, 1/3, 1/4] * mod[0].range([0.95, 1], 1);

			// sound = LPF.ar(Blip.ar(blipFr, 10000/freq, 10), freq*4, ampFollower * mod[1].range(0.3, 1));

			sound = Splay.ar(
				Formant.ar(
					blipFr,
					modFormant,
					modBW,
					ampFollower * mod.range(0.25, 1)
				)
			);
			sound * 0.4
		}).play(vol: 0.2);
	};
});

(
Tdef('fv_listeners').quant_(0).stop.play;
Tdef('fv_listeners').set(\chosenDur, 120);
Tdef('fv_listeners' , { |ev|
	var mykey = 'fv_listeners';
	var thisTdef = Tdef(mykey);
	var thisNdef = q.tdefPrepNdef(thisTdef);
	var time0 = Main.elapsedTime;

	var numPerc, percbuf, pans = #[-1,1]*0.9;

	"\n*** % starts ***\n\n".postf(thisTdef);
	// wait a little ...
	0.1.wait;
	// so seed set from outside can be used when Tdef runs:
	q.tdefSeed(thisTdef);

	MFdef('fv_listeners').value;

	0.1.wait;

	thisNdef.send.play(fadeTime: 0.1);

	Ndef('fv_listeners').play;
	Ndef(\fv_companion).play(vol: 0.2);

	inf.do {
		var mydict = q.bufmem.filterDict(q.mainDict);
		mydict.asArray.scramble.do { |dict, i|
			var buf;

			// compTdef, startedTime, intendedDur, projected next dur
			MFdef(\adjustTime).value(thisTdef, time0, ev.chosenDur, dict.dur);
			MFdef(\sendInfo).value(dict.name, q.activeTdef.key);

			q.readBufToDict(dict);
			buf = dict.buf;

			if (buf.notNil) {

				// plain playback on 1 ear
				(instrument: \simpsamp, buf: buf , amp: 0.6, pan: pans@@i,
					out: Ndef('fv_listeners').bus.index
				).play;
				// F X on other channel
				(instrument: [\singSamp, \singSampRing, \singSampComb, \singSampRinger, \singSampBlip].choose,
					buf: buf, amp: 0.5,
					pan: pans @@ (1+i),
					xpose1: [3, 3/2, 2, 5/4, 4/5, 0.75].choose,
					rate: exprand(7/8,8/7),
					amp: 0.2,
					out: Ndef('fv_listeners').bus.index
				).play;

				(buf.duration).wait;

				1.6.rand.wait;
				percbuf = q.brazil.wrapAt(i + (0.. 4.linrand));
				numPerc = exprand(1,8);
				(instrument: [\simpsampGlitch, \simpsamp].choose,
					buf: percbuf,
					amp: 0.2,
					pan: {0.5.rand2} ! numPerc,
					sustain: 2,
					rate: { 5.bilinrand * 4.5}.dup( numPerc ).midiratio,
					strum: rrand(0.03,0.1),
				).play;
				(2.0).wait;
				(2.0.rand).wait;

				/// add mystery pause!
				if (i.isPrime) {
					3.wait;
				};
			};
			1.wait;
		}
	}
});
);
);
