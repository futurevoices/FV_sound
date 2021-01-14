// some new synthDefs that re-synthesize the Buffer. May/June 2020
(
// synthdef: resynth a buffer player with sines
SynthDef(\singSamp, { |out, buf, amp=0.1, rate = 1, pan=0, start, xpose1=0.625, xpose2=3|
	var in, ampTr, freq, hasFreq, sound;
	in = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf),
		0, 2, doneAction:2
	);
	ampTr = Amplitude.kr(in, 0.05, 0.05);
	# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);

	sound = SinOsc.ar((freq.lag(1/25).round(50) * [xpose1, xpose2]), 0, hasFreq * ampTr).sum;
	OffsetOut.ar(out, Pan2.ar(sound, pan, amp));
}).add;
/*
(instrument: \singSamp, buf: q.patienceDict.values[11].buf , amp: 0.8).play;
*/
SynthDef(\singSampRing, { |out, buf, amp=0.1, rate = 1, pan=0, start, xpose1=0.625, xpose2=2|
	var in, ampTr, freq, hasFreq, sound;
	in = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf),
		0, 2, doneAction:2
	);
	ampTr = Amplitude.kr(in, 0.05, 0.05);
	# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);

	sound = SinOsc.ar((freq.lag(1/25).round(30) * [xpose1, xpose2]), 0, hasFreq * ampTr).sum;
	OffsetOut.ar(out, Pan2.ar(sound*in, pan, amp));
}).add;
/*
(instrument: \singSampRing, buf: q.patienceDict.values[11].buf , amp: 0.8).play;
*/


// synthdef: resynth a buffer player with a tuned comb
SynthDef(\singSampComb, { |out, buf, amp=0.1, rate = 1, pan=0, start, xpose1=0.625, xpose2=3, dcy=5|
	var in, ampTr, freq, hasFreq, sound, pls, env;
	in = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf),
		0, 2
	);
	ampTr = Amplitude.kr(in, 0.05, 0.05);
	# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);

	pls = LPF.ar(Blip.ar((freq/16), 260, 1.25), 2000, hasFreq * ampTr / 2);
	sound = CombL.ar(pls, 0.2, [xpose1, xpose2] / freq.lag(1/25).round(25), dcy, 0.5).sum;
	env = EnvGen.kr(Env([1,1,0], [BufDur.ir(buf) / rate, 0.5]), 1, doneAction: 2);

	OffsetOut.ar(out, Pan2.ar(sound, pan, amp * env));
}).add;
/*
(instrument: \singSampComb, buf: q.patienceDict.values[11].buf , amp: 0.8).play;

(instrument: \singSampComb, buf: q.patienceDict.values[11].buf, rate:0.25, dcy: 10, xpose1: 4, amp: 0.8).play;
*/


// synthdef: resynth a buffer player with Impulse/Ringz
SynthDef(\singSampRinger, { |out, buf, amp=0.1, rate = 1, pan=0, start, xpose1=0.625, xpose2=2|
	var in, ampTr, freq, hasFreq, sound, pls, env, trig;
	in = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf),
		0, 2
	);
	ampTr = Amplitude.kr(in, 0.05, 0.05);
	# freq, hasFreq = Pitch.kr(in,  median: 7);
	freq = freq.fold(100, 1000).round(33); // higher ones hurt..
	sound = Limiter.ar(Ringz.ar(hasFreq * Impulse.ar(freq/4, 0, 0.2).lag(0.0002), freq.lag([0, 1, 0.1]) * [xpose1,1,xpose2], 1.5).mean);

	env = EnvGen.kr(Env([1,1,0], [BufDur.ir(buf) / rate, 0.5]), 1, doneAction: 2);

	OffsetOut.ar(out, Pan2.ar(sound, pan, amp * env));
}).add;
/*
(instrument: \singSampRinger, buf: q.patienceDict.values[11].buf, amp: 0.8).play;
(instrument: \singSampRinger, buf: q.patienceDict.values[11].buf, rate: 0.25, amp: 0.8).play;
*/


// synthdef: resynth a buffer player with Blip
SynthDef(\singSampBlip, { |out, buf, amp=0.1, rate = 1, pan=0, start|
	var in, ampTr, freq, hasFreq, sound, pls, env, trig;
	in = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf),
		0, 2
	);
	ampTr = Amplitude.kr(in, 0.05, 0.05);
	# freq, hasFreq = Pitch.kr(in,  median: 7);
	freq = freq.fold(60, 1500).round(25); // higher ones hurt..
	// sound = LPF.ar(Blip.ar((freq/4), 160, 5), freq*4, hasFreq).sin;
	sound = LPF.ar(Blip.ar((freq/3), 20000/freq, 10), freq*4, hasFreq).sin * ampTr * 2;

	env = EnvGen.kr(Env([1,1,0], [BufDur.ir(buf) / rate, 0.5]), 1, doneAction: 2);

	OffsetOut.ar(out, Pan2.ar(sound, pan, amp * env));
}).add;
/*
(instrument: \singSampBlip, buf: q.patienceDict.values[11].buf , amp: 0.8).play;
*/





// synthdef: ringing filter on signal peaks
SynthDef(\singSampRingerSinger, { |out, buf, amp=0.1, rate = 1, start, xpose1=2, xpose2=1.25, dcy= 2, wet = 0.50|
	var in, ampTr, ampTrSlow, trig, freq, hasFreq, sound, pls, env;
	in = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf)
	);
	# freq, hasFreq = Pitch.kr(in,  median: 7);
	ampTr     = Amplitude.kr(in, 0.05, 0.05);
	ampTrSlow = Amplitude.kr(in, 0.25, 0.75);
	trig = ampTr > ampTrSlow;
	// trig.poll;
	freq = Latch.kr(freq, trig);
	freq = freq.fold(100, 2000); // higher ones hurt..
	sound = Limiter.ar(
		Splay.ar(
			Ringz.ar(trig*in.squared,
				freq * [xpose1,1,xpose2],
				dcy
			)
		)
	);

	env = EnvGen.kr(Env([1,1,0], [BufDur.ir(buf) / rate + dcy, 0.5]), 1, doneAction: 2);
	sound = Balance2.ar(in, sound, wet);

	OffsetOut.ar(out, sound * (amp * env));
}).add;




///////////////////////////////////////////////////////
// cavarero variants
///////////////////////////////////////////////////////

/*
(instrument: \singSampRingerSinger, buf: q.patienceDict.values[11.rand].buf, amp: 0.8).play;
(instrument: \singSampRingerSinger, buf: q.patienceDict.values[11].buf, rate: 0.25, amp: 0.8).play;
*/
SynthDef(\singSampCavaChord, { |out, buf, amp=0.1, rate = 1, start,  wet = 0.50,
	locut=1000, pole=0.6, strDecay=1, strSlope=0.8, delayfan=1|
	var str, filtSrc, notes, freqs, ampComps;
	var in, ampTr, ampTrSlow, trig, freq, hasFreq, sound, pls, env;
	in = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf)
	);
	freqs = Control.names(["notes"]).kr([48, 55, 62, 63, 70, 77]).midicps;
	filtSrc = HPF.ar(OnePole.ar(in * (strDecay ** -0.5), pole), locut);
	ampComps = freqs.collect({|fr| AmpComp.ir(fr) });


	str = SplayAz.ar(2,
		CombL.ar(
			filtSrc,
			0.1,
			freqs.reciprocal
			* LFDNoise3.kr(0.3, 0.005, 1),
			strDecay * (strSlope ** (0..5)),
			ampComps
		)
	);
	env = EnvGen.kr(Env([1,1,0], [BufDur.ir(buf) / rate + strDecay.sqrt, 0.5]), 1, doneAction: 2);
	sound = Balance2.ar(in, str, wet);
	OffsetOut.ar(out, sound * (amp * env));
}).add;

/*
(instrument: \singSampCavaChord, buf: q.patienceDict.values[21.rand].buf, amp: 0.8).play;

(instrument: \singSampCavaChord, rate: 1/4, buf: q.patienceDict.values[21.rand].buf, amp: 0.8, wet: 0.9, strDecay: 15, strSlope:0.9, notes: [{rrand(50, 90)}.dup(6)] ).play;
*/

SynthDef(\singSampCavaChord2, { |out, buf, amp=0.1, rate = 1, start,  wet = 0.50,
	locut=1000, pole=0.6, strDecay=1, strSlope=0.9, delayfan=1|
	var str, filtSrc, freqs, ampComps;
	var in, ampTr, ampTrSlow, trig, freq, hasFreq, sound, pls, env;
	in = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf)
	);
	// ampTr     = Amplitude.kr(in, 0.05, 0.05);
	// ampTrSlow = Amplitude.kr(in, 0.25, 0.75);
	// trig = ampTr > ampTrSlow;
	// trig =

	// notes = Control.names(["notes"]).kr([48, 55, 62, 63, 70, 77]);
	freqs = { LFNoise0.kr(Rand(1/2, 1/7)).range(50, 90).trunc }.dup(6).midicps;
	ampComps = freqs.collect({|fr| AmpComp.ir(fr) });

	filtSrc = HPF.ar(OnePole.ar(in * (strDecay ** -0.5), pole), locut);


	str = SplayAz.ar(2,
		CombL.ar(
			filtSrc,
			0.1,
			freqs.reciprocal
			* LFDNoise3.kr(0.3, 0.005, 1),
			strDecay * (strSlope ** (0..5)),
			ampComps
		)
	);
	str = OnePole.ar(str, 0.8);

	env = EnvGen.kr(Env([1,1,0], [BufDur.ir(buf) / rate + strDecay.sqrt, 0.5]), 1, doneAction: 2);
	sound = Balance2.ar(in, str, wet);
	OffsetOut.ar(out, sound * (amp * env));
}).add;

/*
(instrument: \singSampCavaChord2, buf: q.patienceDict.values[21.rand].buf, amp: 0.8).play;

(instrument: \singSampCavaChord2, buf: q.patienceDict.values[21.rand].buf, amp: 2.98, wet: 0.8, strDecay: 15, strSlope:0.9 ).play;

(instrument: \singSampCavaChord2, buf: q.patienceDict.values[21.rand].buf, amp: 2.98, wet: 0.8, strDecay: 150, rate: 0.5 ).play; // lower pitch

*/

// chord built internally; triggered by peaks in audio sig.
SynthDef(\singSampCavaChord3, { |out, buf, amp=0.1, rate = 1, start,  wet = 0.50, thresh=0.2,
	locut=1000, pole=0.6, strDecay=1, strSlope=0.9, delayfan=1, pan= 0|
	var str, filtSrc, freqs, ampComps;
	var in, ampTr, ampTrSlow, trig, freq, hasFreq, sound, pls, env;
	in = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf)
	);
	ampTr     = Amplitude.kr(in, 0.05, 0.05);
	ampTrSlow = Amplitude.kr(in, 0.25, 0.75);
	trig = ampTr-thresh > ampTrSlow;
	// PulseCount.kr(trig).poll;
	trig = Trig.kr(PanAz.kr(6, trig, LFNoise1.kr(1/6, 2)));

	// notes = Control.names(["notes"]).kr([48, 55, 62, 63, 70, 77]);
	freqs = {|i| TIRand.kr(50, 90, trig[i]) }.dup(6).round(2).midicps;
	// Out.kr(20, freqs/2000);
	ampComps = freqs.collect({|fr| AmpComp.ir(fr) });

	filtSrc = HPF.ar(OnePole.ar(in * (strDecay ** -0.5), pole), locut);


	str = SplayAz.ar(2,
		CombL.ar(
			filtSrc,
			0.1,
			freqs.reciprocal
			* LFDNoise3.kr(0.3, 0.005, 1),
			strDecay * (strSlope ** (0..5)),
			ampComps
		)
	);
	str = OnePole.ar(str, 0.86);

	env = EnvGen.kr(Env([1,1,0], [BufDur.ir(buf) / rate + strDecay.sqrt, 1], \sin), 1, doneAction: 2);
	sound = Pan2.ar(in, pan, 1-wet) + (wet * str);
	OffsetOut.ar(out, sound * (amp * env));
}).add;

/*
(instrument: \singSampCavaChord3, buf: q.patienceDict.values[21.rand].buf, amp: 0.8).play;

(instrument: \singSampCavaChord3, buf: q.patienceDict.values[21.rand].buf, amp: 2.98, wet: 0.8, strDecay: 3, strSlope:0.9, rate: 1/9, thresh: 0.125 ).play;

*/


// chord built internally; triggered by peaks in audio sig.
SynthDef(\singSampCavaForm, { |out, buf, amp=0.1, rate = 1, start,  wet = 0.50, thresh=0.2, formDecay=10, pole=0.6,  strSlope=0.9, delayfan=1, pan= 0, lag=1|

	var str, filtSrc, freqs, ampComps;
	var in, ampTr, ampTrSlow, trig, freq, hasFreq, sound, pls, env;
	var harms = Control.names(["harms"]).kr([1, 2, 3, 5, 8]).lag3(lag);

	in = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf)
	);
	ampTr     = Amplitude.kr(in, 0.05, 0.05);
	ampTrSlow = Amplitude.kr(in, 0.25, 0.75);
	trig = ampTr-thresh > ampTrSlow;
	trig = Trig.kr(PanAz.kr(6, trig, LFNoise1.kr(1/6, 2)));

	freqs = {|i| TIRand.kr(50, 90, trig[i]) }.dup(6).round(2).midicps;
	// Out.kr(20, freqs/2000);
	ampComps = freqs.collect({|fr| AmpComp.ir(fr) });

	filtSrc = HPF.ar(OnePole.ar(in * (formDecay ** -0.5), pole), 100);


	str = SplayAz.ar(2,

		Formlet.ar(
			Line.kr(0, 1, 0.1) * 0.01 * in,
			(freqs *.t harms).flat,
			0.0,
			formDecay * { ExpRand(0.5, 2.0) }.dup(30)
		).scramble  * { ExpRand(0.5, 1.0) }.dup(30)

	);
	str = OnePole.ar(str, 0.86);

	env = EnvGen.kr(Env([1,1,0], [BufDur.ir(buf) / rate + formDecay.sqrt, 1], \sin), 1, doneAction: 2);
	sound = Pan2.ar(in, pan, 1-wet) + (wet * str);
	OffsetOut.ar(out, sound * (amp * env));
}).add;

/*
(instrument: \singSampCavaForm, buf: q.patienceDict.values[21.rand].buf, amp: 0.8).play;

(instrument: \singSampCavaForm, buf: q.patienceDict.values[21.rand].buf, amp: 2.98, wet: 0.5, strDecay: 3, strSlope:0.9, rate: 1, thresh: 0.25 ).play;

*/


////// should these SynthDefs go to libs?

// SynthDef for playing sample with variable rate.
SynthDef(\rampy, { |out=0, amp=0.5, pan=0, buf=0, rate=1, rateEnd=2|
	var bufdur = BufDur.ir(buf);
	var rateLine = Line.kr(rate, rateEnd, bufdur);
	var snd = PlayBuf.ar(1, buf, rateLine, doneAction: 2);
	Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;
/*
(instrument: \rampy).play;
(instrument: \rampy, rateEnd: 1).play;
(instrument: \rampy, rateEnd: 16).play;
(instrument: \rampy, rateEnd: 0.5).play;
*/

// random pitch drift
SynthDef(\bumpy, { |out=0, amp=0.5, pan=0, buf=0, rate=1, modDepth= 12, modRate=2|
	var bufdur = BufDur.ir(buf);
	var rateMod = LFNoise2.kr(modRate, modDepth).midiratio * rate;
	var snd = PlayBuf.ar(1, buf, rateMod, doneAction: 2);
	Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

// latched pitch drift - triggers new rate only in breaks of speech
SynthDef(\bumpyLatch, { |out=0, amp=0.5, pan=0, buf=0, rate=1, modDepth= 12, modRate=2, thresh=0.1|
	var bufdur = BufDur.ir(buf);

	var in = LocalIn.ar(1);
	var trig = Trig.kr(Amplitude.kr(in, 0.01, 0.25) < thresh, 0.15);
	var rateMod = TRand.kr(modDepth.neg, modDepth, trig).midiratio * rate;
	var snd = PlayBuf.ar(1, buf, rateMod, doneAction: 2);
	// Out.kr(22, trig); // debug
	LocalOut.ar(snd);
	Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

);