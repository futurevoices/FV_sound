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

	var timeRange, allshortz, myshorts, percs;

	loop {

		timeRange = exprand(2.0, 20) * [1, 1.5];

		allshortz = q.mainDict.selectAs ({ |dict|
			dict.dur.inclusivelyBetween(*timeRange) }, Array);
		myshorts;

		percs = 5.collect { [ q.hang.choose, q.brazil.choose ] }.flat;

		"fv_converse: % files in timeRange % secs.\n\n".postf(
			allshortz.size,
			timeRange.round(0.001)
		);

		allshortz.curdle(0.15).do { |myshorts, j|
			myshorts.size.postln;

			fork {
				10.do { |i|
					/// whistle
					(instrument: \glisson, sustain: exprand(0.02, 0.2),
						freq: exprand(400, 4000), freq2: exprand(400, 4000),
						pan: 0.8.rand2
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

			myshorts.do { |dict| q.readBufToDict(dict) };
			0.2.wait;

			rrand(1, 3).do { |i|
				myshorts.scramble.do { |dict, j|
					(instrument: \simpsamp, buf: dict.buf,
						amp: 0.3, pan: [-0.8, 0.8].wrapAt(j)
					).play;

					(dict.buf.duration / (q.mood.density ? 1.25)).wait;

					/// whistle
					(instrument: \glisson, sustain: exprand(0.02, 0.2),
						freq: exprand(400, 4000), freq2: exprand(400, 4000)
					).play;
					// perc
					(instrument: \simpsamp, buf: percs[j],
						lag: 0.3,
						amp: 0.3, pan: [-0.8, 0.8].wrapAt(j)
					).play;
				}
			};
		};
		// loop
		1.wait;
	}
}).play;

