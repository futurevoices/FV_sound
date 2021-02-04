// cleaned up version of jingle ver.1:
// algo. hang melody;
// incl. loading the samples.
// ToDo: add it to the daily routine;
// ToDo: sample loader into general loader script

MFdef('jinglers').add(\load, {
	q.jinglePath = (q.soundlibsPath +/+ "/_jinglers").standardizePath;

	// tell q where the jingle soundfiles are:
	// q.jinglePath = "~/Seafile/Future_Voices/soundlibs/_jinglers".standardizePath;

	//// to get the files, use name part + wildcard:
	// (q.jinglePath +/+ "jinglers*.wav").pathMatch.size;
	// (q.jinglePath +/+ "*musik*.wav").pathMatch.size;
	// (q.jinglePath +/+ "*zukunfts*.wav").pathMatch.size;

	if (q.jingfullBufs.isNil) {
		q.jingfullPaths = (q.jinglePath +/+ "jinglers*.wav").pathMatch;

		q.jingfullBufs = q.jingfullPaths.collect{|path|
			Buffer.read(s, path);
		};
	};

	if (q.jingBufsDuos.isNil) {
		q.jingBufsDuos = (q.jinglePath +/+ "*duo*.wav").pathMatch.collect{
			|path| 	Buffer.read(s, path);
		};
	};
});


// if (\DayTimer.asClass.notNil) {
// 	\DayTimer.asClass.start.putDate(\jingle, { |date|
// 		if ([15, 30, 45].includes(date.minute) and: (date.second == 0)) {
// 			date.stamp.postln;
// 			Tdef(\jingleDir.postln).play;
// 		};
// 	});
// };


(
// simpsamp with RLP filter:
SynthDef(\simpsampFlt, { |out, buf, amp=0.1, rate = 1, pan=0, ffreq=6000, rq=0.2, start|
	var snd = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf),
		0, 2, doneAction: 2
	);
	snd = RLPF.ar(snd, ffreq * LFNoise2.kr(1).exprange(0.5, 2), rq);
	OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
}).add;
);


(

// Tdef(\algomelPoly).clear;
Tdef(\algomelPoly).set(\seed, 210113);
Tdef(\algomelPoly).set(\seed, ("2101" ++ rrand(13, 31).asString).interpret.postc); // any day left in Jan
Tdef(\algomelPoly).set(\numVoices, 2);
Tdef(\algomelPoly).addSpec(\numVoices, [1,5,\exp,1]);
Tdef(\algomelPoly).addSpec(\seed, [210101, 211231, 0,1]);

// algorithmic melody, determined by random seed, playing with 2 hangs.
Tdef(\algomelPoly, { |ev|
	var data, numNotes, tempoScale, maxVoices=5, numVoices;// = exprand(1.6, maxVoices+0.5).round.asInteger;
	numVoices = ev.numVoices.asInteger;
	// score generation
	"*** algo jingle hang melo playing % voices on seed %\n".postf(numVoices, ev.seed);
	thisThread.randSeed = ev.seed;
	numNotes = rrand(12, 20);
	tempoScale = rrand(0.4, 0.66); // small value > faster
	data = maxVoices.collect{|i|
		var hangNr, melo, rhythm, density;
		hangNr = q.hang.size.rand ! numNotes;
		// melo = { 10.rand2 } ! numNotes;
		melo = { [0, 2, 4, 5, 7].choose  * [-1,1].choose + 2} ! numNotes;
		density = rrand(1, 3.5);
		rhythm = { [true, false].wchoose([1,density].normalizeSum) } ! numNotes;
		rhythm = { |i| [0.7, 0.3, 0.4, 0.2, 0.7, 0.1, 0.3, 0.6].wrapAt(i).coin }.dup(numNotes);
		[melo, rhythm, hangNr];
	}.wrapExtend(numVoices);
	data.shape.postln;

	// score pb
	numNotes.do{ |i|
		data.do{|voice, j|
			var mrh = voice.flop[i];
			if(mrh[1]){
				(instrument: \simpsampFlt,
					buf: q.hang @@ (mrh[2] + 3.bilinrand),
					rate: (mrh[0] + 0.1.rand2).midiratio,
					amp: 0.5 * exprand(0.5, 1) * (maxVoices-j/maxVoices).pow(1.5), // higher voices > sophter
					ffreq: j.linexp(0, maxVoices, 8000, 200).round,
					rq: 0.8,
					pan: [-0.5, 0.5, -1, 1, 0] @@ j * 0.4,
					lag: 0.025.linrand
				).play;
			};
		};
		(0.25 * tempoScale).wait;
	}
});

);


/// use simpsamp synthdef:
Tdef(\jing3, {
	q.jingfullBufs.scramble.keep(3).do { |buf|
		(instrument: \simpsamp, buf: buf,
			amp: 0.5, pan: 1.0.rand2
		).play;
		0.2.wait;
	};
	1.5.wait;
	// the chosen one: a chimaera from the 'duos' selection
	(instrument: \simpsamp,
		buf: (q.jingfullBufs ++ q.jingBufsDuos ++ q.jingBufsDuos).choose,
		amp: 1.5, pan: 0
	).play;
});


(
Tdef(\jingleDir, { |ev|
	var daySeed = Date.getDate.stamp.keep(6).asInteger;
	Tdef(\algomelPoly).set(\seed, daySeed);
	// first round:
	Tdef(\algomelPoly).set(\numVoices, [1,2,2,2,2].choose).play;
	// 2nd round:
	Tdef(\algomelPoly).embed;
	Tdef(\jing3).embed;
	1.5.wait;
	Tdef(\algomelPoly).set(\numVoices, [3,4,5,5,5,5].choose).play;
	Tdef(\algomel).embed;
});
);
/*
Tdef(\jingleDir).play;
*/
