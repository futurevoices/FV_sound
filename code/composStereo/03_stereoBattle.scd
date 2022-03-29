////// this is the dynamic version of fv_stereoBattle:
/// it reads buffers newly on demand.

(
Tdef('fv_stereoBattle').quant_(0).stop.play;
Tdef('fv_stereoBattle').set(\chosenDur, 120);

Tdef( 'fv_stereoBattle' , { |ev|
	var mykey = 'fv_stereoBattle';
	var thisTdef = Tdef(mykey);
	var thisNdef = q.tdefPrepNdef(thisTdef);
	var time0 = Main.elapsedTime;

	0.1.wait;
	q.tdefSeed(thisTdef);
	0.1.wait;
	thisNdef.fadeTime_(0.1).send.play;

	"\n*** % starts ***\n\n".postf(thisTdef);


	inf.do { |i|
		var mydict = q.bufmem.filterDict(q.mainDict);
		mydict.asArray.scramble.do { |voiceDict|
			var stretch = exprand(1.5, 2.5);
			var pan = (i%2*2-1) * rrand(0.85, 0.95);

			var sample1;

			// compTdef, startedTime, intendedDur, projected next dur
			MFdef(\adjustTime).value(thisTdef, time0, ev.chosenDur, voiceDict.dur * stretch);

			q.readBufToDict(voiceDict);
			q.bufmem.addKey(voiceDict.name);

			sample1 = voiceDict.buf;

			MFdef(\sendInfo).value(voiceDict.name, q.activeTdef.key);

			voiceDict.name.cs.postln;

			if (sample1.notNil) {

				// one side: normal, 1 sec later
				(
					instrument: \simpsamp,
					buf: sample1,
					amp: 0.5, pan: pan, out: ev.bus,
					sustain: sample1.duration,
					lag: 1
				).play;

				// other side: glitching up, 1 sec later
				(instrument: \simpsampGlitch, buf: sample1,
					rate: exprand(9/8, 8/9),
					pan: pan.neg, amp: 0.3,
					out: ev.bus,
					start: 0,
					lag: 1).play;

				// middle: 2 bg layers, granulated
				(instrument: \sampGrain, buf: sample1,
					out: ev.bus,
					rate: exprand(1/2, 2), stretch: stretch * 2.5,
					pan: -0.2, ovlp: exprand(5, 50), trigrate: exprand(13, 100),
					jitter: 0.6.linrand, amp: 0.02 * rrand(1, 2.0)
				).play;

				(instrument: \sampGrain, buf: sample1,
					rate: exprand(1/2, 2), stretch: stretch * 2.5,
					pan: 0.2, ovlp: exprand(5, 50),
					amp: 0.02 * rrand(1, 2.0),
					out: ev.bus,
					trigrate: exprand(13, 100),
					jitter: 0.6.linrand,
				).play;
				"waiting for: ".post;
				( sample1.duration * stretch + 1).postln.wait;

			};
		};
		"*** % looping ...\n\n".postf(thisTdef);
		2.wait;
	}
});
);

