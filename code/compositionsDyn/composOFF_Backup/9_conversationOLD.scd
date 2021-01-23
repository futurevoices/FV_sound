/*****
CONVERSATION:
short sentences alternate between left and right
short whistles, short perc sounds as punctuation
*/

q.mood = q.mood ? (density: 1.62);

/*
////// try different densities from mood:
q.mood .density = 1;
q.mood .density = 1.62;
q.mood .density = 2.62;

(instrument: \glisson, sustain: 0.1, freq: 2000, freq2: 3000).play
*/

Tdef(\fv_converse, {

	var allshortz = q.mainDict.selectAs ({ |dict| dict.dur.inclusivelyBetween(4, 6) }, Array);
	var myshorts;

	var percs = 5.collect { [ q.hang.choose, q.brazil.choose ] }.flat;

	allshortz.size.postln;

	loop {
		fork {
			10.do {
				/// whistle
				(instrument: \glisson, sustain: exprand(0.02, 0.2),
					freq: exprand(400, 4000), freq2: exprand(400, 4000)
				).play;
				0.05.wait;
			};
			percs.scramble.do { |buf, i|
				(instrument: \simpsamp, buf: buf,
					amp: 0.3, pan: [-1, 1].wrapAt(i)
				).play;
				0.1.wait;
			}
		};

		myshorts = allshortz.scramble.keep(10);
		myshorts.do { |dict| q.readBufToDict(dict) };

		rrand(2, 5).do { |i|
			myshorts.scramble.do { |dict, j|
				(instrument: \simpsamp, buf: dict.buf,
					amp: 0.3, pan: [-1, 1].wrapAt(j)
				).play;

				(dict.buf.duration / (q.mood.density ? 1.25)).wait;

				/// whistle
				(instrument: \glisson, sustain: exprand(0.02, 0.2),
					freq: exprand(400, 4000), freq2: exprand(400, 4000)
				).play;
				// perc
				(instrument: \simpsamp, buf: percs[j],
					lag: 0.3,
					amp: 0.3, pan: [-1, 1].wrapAt(j)
				).play;
			};
		};
		1.wait;
	};
}).play;