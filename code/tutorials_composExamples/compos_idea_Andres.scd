/// Andres grain drone ...
(
SynthDef.new(\grain, {
	arg grainfreq=20, graindur=0.1, durRand=1, buf=0, ratebuf=1, pos=0, speedpos=1, disorder=0, grainEnv=(-1), pan=0, panHz=0.1, panRand=0, atk=1, sus=2, rel=1, c0=1, c1=(-1), amp=1, out=0, randPulse = 0;
	var sig, env, densCtrl, durCtrl, posCtrl, panCtrl;

	env = EnvGen.ar(Env.new([0,1,1,0],[atk,sus,rel],[c0,0,c1]),doneAction: 2);

	densCtrl = Impulse.kr(grainfreq + LFNoise1.kr(grainfreq).bipolar(grainfreq * randPulse));

	durCtrl = graindur * LFNoise1.kr(100).exprange(1/durRand, durRand);

	posCtrl = Phasor.ar(0, speedpos * BufRateScale.ir(buf), 0, BufSamples.ir(buf)-1);
	posCtrl = posCtrl + LFNoise1.kr(100).bipolar(disorder*SampleRate.ir);
	posCtrl = posCtrl / BufSamples.ir(buf);
	posCtrl = posCtrl + pos;

	panCtrl = pan +LFNoise1.kr(panHz).bipolar(panRand);

	sig = GrainBuf.ar(
		2,
		densCtrl,
		durCtrl,
		buf,
		ratebuf,
		posCtrl,
		2,
		panCtrl,
		grainEnv
	);

	sig = sig * env * amp;

	Out.ar(out, sig);
}).add;
);


//// choose only soundfiles between 7 and 10 seconds?

// select from a collection:
[ 1, 2, 3, 4 ].select { |num| num < 3 }

// select from a dict/event
(a: 1, b: 2, c: 3, d: 4).select { |num| num < 3 };

// select from a dict of dicts:
(
a: (dur: 1, filename: \oezcan),
b: (dur: 2, filename: \adc),
c: (dur: 3, filename: \andres),
d: (dur: 5, filename: \hannes)
).select { |dict| dict.dur < 3 };

// this is our big dict of dicts:
q.mainDict.choose.keys;

// select from a dictionary/event:
q.mainDict.select { |entry, key|
	(entry.dur < 10)
	and:
	(entry.dur > 5)
	and:
	(entry.langKey == \it)
}.size;



(

// play back and forth at the same time, panned to L/R !
Tdef(\fv_graindrone, {
	1.do {
		var wait_time;
		// var entry = q.mainDict.choose;
		var entry = q.mainDict.select { |entry|
			(entry.dur < 10)
			and: (entry.dur > 5)
			// and: (entry.langKey == \it)
		}.choose;

		[ entry.filename, entry.dur, entry.langKey ].postln;
		q.readBufToDict(entry);

		"// first buf:".postln;
		(   instrument: \simpsamp, // \simpsamp,
			buf: entry.buf,
			rate: 1, // [-1, 1],
			amp: 0.5,
			pan: 0 // [-1, 1]
		).play;

		(entry.buf.duration * 0.5).wait;
		// fork {
		// 	entry.buf.duration.wait;
		// 	Pdef(\fv_graindrone).stop;
		// };
		Pdef(
			\fv_graindroneH,
			Pbind(
				\type, \note,
				\instrument, \grain,
				\buf, entry.buf,
				\dur, 0.5,
				\ratebuf, 1,
				\speedpos, 0,
				\pos, Pseries(0, 0.05, inf),
				\randPulse, 1,
				\grainfreq, Pwhite(5, 20, inf),
				\graindur, 0.1,
				\disorder, 0.01,
				\atk, 0.5,
				\sus, 1,
				\rel, 0.5,
				\amp, 0.1,
				\pan, Pwhite(-1.0, 1.0),
				\panRand, 1,
				\panHz, 1,
				\out, 0
			)
		).postln.play;

		Pdef(
			\fv_graindroneL,
			Pbind(
				\type, \note,
				\instrument, \grain,
				\buf, entry.buf,
				\dur, 0.5,
				\ratebuf, 2,
				\speedpos, 0,
				\pos, Pseries(0, 0.05, inf),
				\randPulse, 1,
				\grainfreq, Pwhite(5, 20, inf),
				\graindur, 0.1,
				\disorder, 0.01,
				\atk, 0.5,
				\sus, 1,
				\rel, 0.2,
				\amp, 0.1,
				\pan, Pwhite(-1.0, 1.0),
				\panRand, 1,
				\panHz, 1,
				\out, 0
			)
		).postln.play;

		// to wait depending on the duration of the audio
		(
			if (entry.buf.duration < 4){
				wait_time = 4;
			};
			if (entry.buf.duration >= 4 && entry.buf.duration < 10){
				wait_time = entry.buf.duration * 1.5
			};
			if (entry.buf.duration >= 10){
				wait_time = entry.buf.duration
			}
		);
		(wait_time).wait;
		Pdef(\fv_graindroneL).stop;
		Pdef(\fv_graindroneH).stop;

		"// the second buf".postln;
		(   instrument: \simpsamp, // \simpsamp,
			buf: entry.buf,
			rate: 0.75, // [-1, 1],
			amp: 0.5,
			pan: 0 // [-1, 1]
		).postln.play;
		(entry.buf.duration * 0.5).wait;

		// second grains


		Pdef(
			\fv_graindroneH,
			Pbind(
				\type, \note,
				\instrument, \grain,
				\buf, entry.buf,
				\dur, 0.5,
				\ratebuf,  Prand([12.midiratio, 16.midiratio, 19.midiratio], inf),
				\speedpos, 0,
				\pos, Pseries(0, 0.05, inf),
				\randPulse, 0.5,
				\grainfreq, Pwhite(20, 40, inf),
				\graindur, 0.05,
				\disorder, 0.01,
				\atk, 0.5,
				\sus, 1,
				\rel, 1.0,
				\amp, 0.1,
				\pan, Pwhite(-1.0, 1.0),
				\panRand, 1,
				\panHz, 1,
				\out, 0
			)
		).postln.play;



		Pdef(
			\fv_graindroneL,
			Pbind(
				\type, \note,
				\instrument, \grain,
				\buf, entry.buf,
				\dur, 0.5,
				\ratebuf, Pseq([0.midiratio, 4.midiratio, 7.midiratio], inf),
				\speedpos, 0,
				\pos, Pseries(0, 0.05, inf),
				\randPulse, 0.5,
				/*Pseq([
				Pseries(2, -0.1, 10),
				Pseq([0], inf)

				], inf),*/
				\grainfreq, Pwhite(20, 40, inf),
				\graindur, 0.05,
				\disorder, 0.01,
				\atk, 0.5,
				\sus, 5,
				\rel, 0.5,
				\amp, 0.1,
				\pan, Pwhite(-1.0, 1.0),
				\panRand, 1,
				\panHz, 1,
				\out, 0
			)
		).postln.play;


		(wait_time).wait;
		Pdef(\fv_graindroneL).stop;
		Pdef(\fv_graindroneH).stop;

		"// the third buf".postln;

		(   instrument: \simpsamp, // \simpsamp,
			buf: entry.buf,
			rate: 0.5, // [-1, 1],
			amp: 0.5,
			pan: 0 // [-1, 1]
		).postln.play;

		(entry.buf.duration * 0.5).wait;


		// third grains


		(
			Pdef(
				\fv_graindroneH,
				Pbind(
					\type, \note,
					\instrument, \grain,
					\buf, entry.buf,
					\dur, 0.5,
					\ratebuf,  Prand([12.midiratio, 16.midiratio, 19.midiratio], inf),
					\speedpos, 0,
					\pos, Pseries(0, 0.05, inf),
					\randPulse, 0,
					\grainfreq, Pwhite(40, 80, inf),
					\graindur, 0.05,
					\disorder, 0.01,
					\atk, 2,
					\sus, 5,
					\rel, 1.0,
					\amp, 0.05,
					\pan, Pwhite(-1.0, 1.0),
					\panRand, 1,
					\panHz, 1,
					\out, 0
				)
			).postln.play;



			Pdef(
				\fv_graindroneL,
				Pbind(
					\type, \note,
					\instrument, \grain,
					\buf, entry.buf,
					\dur, 0.5,
					\ratebuf, Pseq([0.midiratio, 4.midiratio, 7.midiratio], inf),
					\speedpos, 0,
					\pos, Pseries(0, 0.05, inf),
					\randPulse, 0,
					/*Pseq([
					Pseries(2, -0.1, 10),
					Pseq([0], inf)

					], inf),*/
					\grainfreq, Pwhite(40, 80, inf),
					\graindur, 0.05,
					\disorder, 0.01,
					\atk, 2,
					\sus, 5,
					\rel, 0.5,
					\amp, 0.05,
					\pan, Pwhite(-1.0, 1.0),
					\panRand, 1,
					\panHz, 1,
					\out, 0
				)
			).postln.play;

		);
		(wait_time).wait;

		// the third buf
		(   instrument: \simpsamp, // \simpsamp,
			buf: entry.buf,
			rate: 0.25, // [-1, 1],
			amp: 0.5,
			pan: 0 // [-1, 1]
		).play;

		// small detail for high freq

		(
			Pdef(
				\fv_graindrone_Hoch,
				Pbind(
					\type, \note,
					\instrument, \grain,
					\buf, entry.buf,
					\dur, Pwhite(0.01, 0.05, inf),
					\ratebuf,  Prand([24.midiratio, 36.midiratio, 48.midiratio], inf),
					\speedpos, 0,
					\pos, Pseries(0, 0.05, inf),
					\randPulse, 0,
					\grainfreq, Pwhite(5, 15, inf),
					\graindur, 0.1,
					\disorder, 0.01,
					\atk, 1,
					\sus, 0,
					\rel, 0,
					\amp, 0.005,
					\pan, Pwhite(-1.0, 1.0),
					\panRand, 1,
					\panHz, 1,
					\out, 0
				)
			).postln.play;
		);

		(entry.buf.duration * 2).wait;
		Pdef(\fv_graindrone_Hoch).stop;
		(entry.buf.duration * 2).wait;

		Pdef(\fv_graindroneL).stop;
		Pdef(\fv_graindroneH).stop;


	}
}).stop.play;
);

// take  6 short soundfiles,
// play them in sequence,
// play the same soundfiles time-stretched as background
/// sometimes choppy, sometimes droney



// segundo stage

(
Pdef(
	\fv_graindroneH,
	Pbind(
		\type, \note,
		\instrument, \grain,
		\buf, ~voz.bufnum,
		\dur, 0.5,
		\ratebuf,  Prand([12.midiratio, 16.midiratio, 19.midiratio], inf),
		\speedpos, 0,
		\pos, Pseries(0, 0.05, inf),
		\randPulse, 1,
		\grainfreq, Pwhite(10, 30, inf),
		\graindur, 0.05,
		\disorder, 0.01,
		\atk, 0.5,
		\sus, 1,
		\rel, 1.0,
		\amp, 0.5,
		\pan, Pwhite(-1.0, 1.0),
		\panRand, 1,
		\panHz, 1,
		\out, 0
	)
).postln.play;
)
(

Pdef(
	\fv_graindroneL,
	Pbind(
		\type, \note,
		\instrument, \grain,
		\buf, ~voz.bufnum,
		\dur, 0.5,
		\ratebuf, Pseq([0.midiratio, 4.midiratio, 7.midiratio], inf),
		\speedpos, 0,
		\pos, Pseries(0, 0.05, inf),
		\randPulse, 1,
		/*Pseq([
		Pseries(2, -0.1, 10),
		Pseq([0], inf)

		], inf),*/
		\grainfreq, Pwhite(10, 30, inf),
		\graindur, 0.05,
		\disorder, 0.01,
		\atk, 0.5,
		\sus, 5,
		\rel, 0.5,
		\amp, 0.5,
		\pan, Pwhite(-1.0, 1.0),
		\panRand, 1,
		\panHz, 1,
		\out, 0
	)
).postln.play;

);




// tercer stage

(
Pdef(
	\fv_graindroneH,
	Pbind(
		\type, \note,
		\instrument, \grain,
		\buf, ~voz.bufnum,
		\dur, 0.5,
		\ratebuf,  Prand([12.midiratio, 16.midiratio, 19.midiratio], inf),
		\speedpos, 0,
		\pos, Pseries(0, 0.05, inf),
		\randPulse, 0,
		\grainfreq, Pwhite(40, 80, inf),
		\graindur, 0.05,
		\disorder, 0.01,
		\atk, 0.5,
		\sus, 5,
		\rel, 1.0,
		\amp, 0.5,
		\pan, Pwhite(-1.0, 1.0),
		\panRand, 1,
		\panHz, 1,
		\out, 0
	)
).postln.play;



Pdef(
	\fv_graindroneL,
	Pbind(
		\type, \note,
		\instrument, \grain,
		\buf, ~voz.bufnum,
		\dur, 0.5,
		\ratebuf, Pseq([0.midiratio, 4.midiratio, 7.midiratio], inf),
		\speedpos, 0,
		\pos, Pseries(0, 0.05, inf),
		\randPulse, 0,
		/*Pseq([
		Pseries(2, -0.1, 10),
		Pseq([0], inf)

		], inf),*/
		\grainfreq, Pwhite(40, 80, inf),
		\graindur, 0.05,
		\disorder, 0.01,
		\atk, 0.5,
		\sus, 5,
		\rel, 0.5,
		\amp, 0.5,
		\pan, Pwhite(-1.0, 1.0),
		\panRand, 1,
		\panHz, 1,
		\out, 0
	)
).postln.play;

);


(
Pdef(
	\fv_graindrone_Hoch,
	Pbind(
		\type, \note,
		\instrument, \grain,
		\buf, ~voz.bufnum,
		\dur, Pwhite(0.01, 0.05, inf),
		\ratebuf,  Prand([24.midiratio, 36.midiratio, 48.midiratio], inf),
		\speedpos, 0,
		\pos, Pseries(0, 0.05, inf),
		\randPulse, 0,
		\grainfreq, Pwhite(5, 15, inf),
		\graindur, 0.1,
		\disorder, 0.01,
		\atk, 1,
		\sus, 0,
		\rel, 0,
		\amp, 0.1,
		\pan, Pwhite(-1.0, 1.0),
		\panRand, 1,
		\panHz, 1,
		\out, 0
	)
).postln.play;
);