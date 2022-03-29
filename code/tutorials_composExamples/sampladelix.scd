// rhythmic organization of sample segments


(
r{
	e = q.mainDict.choose;
	b = q.readBufToDict(e);
}.play
)

b;
b.buf;

(instrument: \sampEnv, buf: 50).play
// synthdef to play a section from a buffer. start/end in seconds
// SynthDef(\sampEnv, { |out, buf, amp=0.1, rate = 1, pan, start, sustain=0.8, fade=0.01|
(instrument: \sampEnv, buf: b.buf, start: b.buf.numFrames.rand, sustain: 0.1, amp: 1).play;

(
Tdef(\b, {
	var dt= 1/8, pos;
	var posOffs = (b.buf.duration * 0.2).rand; // start in the first 50 %
	var seq = [1,2,3,4,  1,1,2,4]/5;
	100.do{|i|
		// pos = pos + pi % b.buf.duration;
		pos = seq@@i + posOffs + 0.02.rand2 %  b.buf.duration;
		(instrument: \sampEnv, buf: b.buf, start: b.buf.numFrames.rand, sustain: dt*0.5, amp: 2).play;
		dt.wait;
	}
}).play
);


(
// sequence positions and durs
Tdef(\a, {

	var e = q.mainDict.choose;
	var b = q.readBufToDict(e);

	var dt = 1/8;
	var pos, pan = rrand(0.1, 0.9);
	var posOffs = (b.buf.duration * 0.1).rand + 0.1; // start in the first 10-20 %
	var posSeq = [0,1,2,3,  1,1,0,3]/5;              // til 80%
	var durSeq = [1.5] ++ {rrand(0.2, 0.7)}.dup(7);  // accent on the 1, random afterwds.

	32.do{|i|
		posSeq.do{|val, j|
			var sus = durSeq @@ j * dt;
			var pos = val + posOffs + 0.05.rand2 * b.buf.duration %  b.buf.duration;
			(instrument: \sampEnv, buf: b.buf, start: pos, sustain: sus, amp: 0.75, pan: pan).play;
			dt.wait;
		};
		if((1/16).coin){posSeq=posSeq.scramble.postcln};
	}
}).play
);


(
// sequence positions and durs
// 3 voices in a single loop !
Tdef(\c3, {

	var b3 = 3.collect{
		var e = q.mainDict.choose;
		var b = q.readBufToDict(e);
		b;
	};

	var dt = 1/8;
	var pos, pan = rrand(0.1, 0.9);
	var posOffs = (b.buf.duration * 0.1).rand + 0.1; // start in the first 10-20 %
	var posSeq = [0,1,2,3,  1,1,0,3]/5;              // til 80%
	var durSeq = [1.5] ++ {rrand(0.2, 0.7)}.dup(7);  // accent on the 1, random afterwds.

	32.do{|i|
		posSeq.do{|val, j|
			b3.collect{|b, k|
				var sus = durSeq @@ (k*2+j) * dt;
				var pos = val + posOffs + 0.5.rand2 * b.buf.duration %  b.buf.duration;
				var offsT = 0.25.rand;
				(instrument: \sampEnv, buf: b.buf, start: pos, sustain: sus, amp: 0.75, pan: pan, timingOffset: offsT).play;
			};
			dt.wait;
		};
		if((1/16).coin){posSeq=posSeq.scramble.postcln};
	}
}).play
)