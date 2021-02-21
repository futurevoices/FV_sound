/*****
CONVERSATION:
short sentences alternate between left and right
short whistles, short perc sounds as punctuation
*/

MFdef('fv_converse').add(\mood, {
	MFdef('fv_converse').postcs;
	q.mood = q.mood ? (density: 1.1);
});

/*
////// try different densities from mood:
q.mood .density = 1;
q.mood .density = 1.26;
q.mood .density = 2.62;

(instrument: \glisson, sustain: 0.1, freq: 2000, freq2: 3000).play
*/
Tdef(\fv_converse).set(\chosenDur, 120);

Tdef(\fv_converse).quant = 0;
Tdef(\fv_converse).stop.play;

Tdef(\fv_converse, { |ev|
	var timeRange, allshortz, allshortz2, shortgroups, percs;
	var time0 = Main.elapsedTime;

	// same for all Tdefs (except name):
	var mykey = 'fv_converse';
	var thisTdef = Tdef(mykey);
	var thisNdef = q.tdefPrepNdef(thisTdef);
	"\n*** % starts ***\n\n".postf(thisTdef);
	MFdef(mykey).value;

	0.1.wait;
	// wait so that seed set from outside can be used when Tdef runs:
	q.tdefSeed(thisTdef);
	0.1.wait;
	thisNdef.play(fadeTime: 0.1);

	loop {

		timeRange = (exprand(2.0, 20) * [1, 1.5]).round(0.01);

		allshortz = q.mainDict.select ({ |dict|
			dict.dur.inclusivelyBetween(*timeRange) });

		("raw allshorts: " + allshortz.size).postln;
		allshortz = q.bufmem.filterDict(allshortz);
		("filtered shorts: " + allshortz.size).postln;

		percs = 5.collect { [ q.hang.choose, q.brazil.choose ] }.flat;

		"fv_converse: % files in timeRange % secs.\n\n".postf(
			allshortz.size,
			timeRange.round(0.001)
		);

		shortgroups = allshortz.asArray.scramble.curdle(0.15);
		"groupsizes: ".post;
		shortgroups.collect(_.size).postln;
		shortgroups.do { |myshorts, j|
			"\n --- shortz group % - % files\n".postf(j, myshorts.size);
			// myshorts.do { |entry| entry.literal_text.keep(80).postcs };

			fork {
				10.do { |i|
					/// whistle
					(instrument: \glisson, sustain: exprand(0.02, 0.2),
						freq: exprand(400, 4000), freq2: exprand(400, 4000),
						pan: 1.0.rand2,
						out: ev.bus
					).play;
					0.05.wait;
				};
				percs.scramble.do { |buf, i|
					(instrument: \simpsamp, buf: buf,
						amp: 0.3,
						pan: [-0.1, 0.1].wrapAt(i) * i,
						out: ev.bus
					).play;
					0.1.wait;
				}
			};

			rrand(1, 2).do { |i|
				// reverse repeats? - not working yet
				var rate = [1, -1][i];
				var waittime;
				("converse rep:" + i).postln;

				myshorts.scramble.do { |dict, j|
					var percpan;

					// only load the first time, not again
					// on reversed repeat
					if (i == 0) {
						q.readBufToDict(dict);
						q.bufmem.addKey(dict.name);
					} {
						"reversed: ".post;
						(dict.literal_text ?? dict.name.asString).keep(50).postcs;
					};

					// compTdef, startedTime, intendedDur, projected next dur
					MFdef(\adjustTime).value(thisTdef, time0, ev.chosenDur, dict.dur);

					(instrument: \simpsamp,
						buf: dict.buf,
						amp: 0.3, pan: [-0.9, 0.9].wrapAt(j),
						rate: rate,
						out: ev.bus
					).play;

					(dict.buf.duration / (q.mood.density ? 1.25)).wait;

					percpan = ((j + 1) / myshorts.size) * [-1, 1].wrapAt(j);

					/// whistle
					(instrument: \glisson,
						sustain: exprand(0.02, 0.2),
						freq: exprand(400, 4000), freq2: exprand(400, 4000),
						pan: percpan.neg,
						rate: rate,
						out: ev.bus
					).play;

					// perc
					(instrument: \simpsamp,
						buf: percs.wrapAt(j),
						rate: rate,
						amp: 0.26, pan: percpan,
						out: ev.bus
					).play;
				}
			};
		};
		// loop
		1.wait;
		"\n\n<<< converse LOOPING >>>\n\n".postln;
	}
});

