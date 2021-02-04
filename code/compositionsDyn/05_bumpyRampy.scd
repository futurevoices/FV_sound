// added bg sound Ndef

////// SynthDefs \rampy, \bumpy, \bumpyLatch, moved to _reSampleLib!

// function that generates a sound for the BG Ndef
// q[\blipfunc] = {|freq=150, numharm= 5|
// Blip.ar(freq * LFNoise1.kr(0.07, 0.05, 1), numharm, 0.1)!2 };

q[\blipfunc] = {|freq=150, numharm= 5, pan=0|
	{ |amp=0.05|
		var snd = //Line.kr(0, 1, 5) *
		Blip.ar(freq * LFNoise1.kr(0.07, 0.05, 1), numharm, amp);
		Pan2.ar(snd, pan, LFNoise2.kr(0.1).range(0.5,1) );
	}
};

// Ndef(\fv_blip).edit;
// Ndef(\fv_blip).objects.do( _.clear)

(
Tdef('fv_bumpy').quant_(0).stop.play;
Tdef('fv_bumpy').set(\chosenDur, 120);

Tdef('fv_bumpy', { |ev|
	var mykey = 'fv_bumpy';
	var thisTdef = Tdef(mykey);
	var thisNdef = q.tdefPrepNdef(thisTdef);
	var time0 = Main.elapsedTime;

	"\n*** % starts ***\n\n".postf(thisTdef);
	0.1.wait;
	q.tdefSeed(thisTdef);

	0.1.wait;
	thisNdef.play(fadeTime: 0.1);

	loop {
		var mydict = q.bufmem.filterDict(q.mainDict);
		mydict.do { |dict|

			var numMax = exprand(1, 8).asInteger;
			var nums = Array.geom(numMax, 1, rrand(1.3, 2));
			var maxFreq = exprand(1000, 2000);
			var buf;

			// compTdef, startedTime, intendedDur, projected next dur
			MFdef(\adjustTime).value(thisTdef, time0, ev.chosenDur, dict.dur + 7);

			q.readBufToDict(dict);
			q.bufmem.addKey(dict.name);
			buf = dict.buf;
			MFdef(\sendInfo).value(dict.name, q.activeTdef.key);

			Ndef(\fv_blip).fadeTime = 3;

			nums.ceil.asInteger.do{|num, i|

				var freq = 50 * exprand(2, 8).asInteger;

				Ndef(\fv_blip).play;
				// add a layer of bg snd
				Ndef(\fv_blip)[7.rand] = \mix -> q[\blipfunc].value(pan: 1.0.rand2, freq: freq, numharm: (maxFreq div: freq).asInteger);

				3.wait;

				// growing number of sounds in parallel
				(instrument: [\bumpy, \bumpyLatch].choose,
					modRate: 1, modDepth: i.pow(0.33) * 4,
					buf: buf, rate: 1.0, pan: {1.0.rand2}!num,
					amp: num.reciprocal.sqrt * 0.8,
					out: ev.bus
				).play;

				(buf.duration).wait;
			};

			(instrument: \singSampCavaChord3, buf: buf,
				amp: 0.4, wet: 1, strDecay: 3.rrand(11),
				strSlope: 0.9, rate: 1/rrand(1,8),
				thresh: 0.2,
				out: ev.bus
			).play;
			1.wait;

			// FFW sound
			(instrument: \bumpy, modRate: 1, modDepth: 8, buf: buf,
				rate: exprand(6,16), pan: [-1,0,1], amp: 0.5,
				out: ev.bus
			).play;

			// end all BG sound.
			Ndef(\fv_blip).end(3);
			3.1.wait;
			Ndef(\fv_blip).clear;
		};
		1.wait;
	}
});
)
