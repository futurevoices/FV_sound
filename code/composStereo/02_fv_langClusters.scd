////// this is the dynamic version of langClusters:
/// it reads buffers newly on demand.

// play clustered by language, with a BG sound.
// @ class, 17.06.2020



MFdef(\fv_langClusters).add(\preload, {
	/// make all interesting numbers parameters:
	Ndef(\fv_forml).addSpec(\pitch, [15, 73]);
	Ndef(\fv_forml).addSpec(\chaos, [1.0, 2.0]);
	Ndef(\fv_forml).addSpec(\attack, [0.001, 0.3, \exp]);
	Ndef(\fv_forml).addSpec(\decay, [0.03, 5, \exp]);

	Ndef(\fv_forml).fadeTime = 1;

	Ndef(\fv_forml, { |chaos = 2.0, pitch = 42, attack = 0.05, decay = 0.10|
		var exciter = Crackle.ar(chaos ! 2, 0.1);
		var freq = pitch.midicps;
		var ampcomp = AmpComp.kr(freq);
		var filter = Formlet.ar(
			exciter * ampcomp,
			pitch.midicps,
			attack,
			decay * ampcomp
		);
		filter;
	}).play;

	MFdef(\hang).value;
});

(
Tdef(\fv_langClusters).quant_(0).stop.play;
Tdef('fv_langClusters').set(\chosenDur, 120);

Tdef(\fv_langClusters, { |ev|

	var mykey = 'fv_langClusters';
	var thisTdef = Tdef(mykey);
	var thisNdef = q.tdefPrepNdef(thisTdef);
	var time0 = Main.elapsedTime;

	"\n*** % starts ***\n\n".postf(thisTdef);
	// wait a little ...
	0.1.wait;
	// so seed set from outside can be used when Tdef runs:
	q.tdefSeed(thisTdef);

	MFdef(\fv_langClusters).value;

	0.1.wait;
	thisNdef.play(fadeTime: 0.1);
	Ndef(\fv_forml).play(vol: 0.1);

	// ////////// COURSE FOLDER VERSION:
	// // filter out missing lang entries
	// q.ourLangs = q.mainDict.values.collect {|sd|
	// 	try { sd.language.language_short.asString.keep(2).toLower }
	// }.reject(_.isNil);

	////////// DATABASE FOLDER VERSION:
	// filter out missing lang entries

	// declared in langAnalysis.scd:
	q.lang.check;  // this updates
	q.lang.numEntries; // how many each?
	q.lang.byCount;    // sorted by numEntries
	q.lang.names;      // just names sorted by numEntries

	inf.do {
		var mydict = q.bufmem.filterDict(q.mainDict);
		var langKeys = q.lang.names.scramble;
		var dictsPerLang;

		"*** lang keys: ***".postln;
		langKeys.postcs;

		dictsPerLang = langKeys.collect { |lang|
			mydict.values.select { |sd|
				sd.langKey == lang
				// and: { sd.soundfile.duration < 40 }
			}.scramble.keep(rrand(8, 13));
		}.select { |langdict| langdict.size > 0 };

		dictsPerLang.collect(_.size);

		dictsPerLang.do { |langdict|
			var lang = langdict.choose.langKey;
			var hangbuf = { q.hang.choose } ! 2;


			var sfdurs = langdict.collect { |sd|
				sd.soundfile.duration.round(0.01)
			};

			var pauses = sfdurs.collect { exprand(0.5, 3).round(0.01); };
			var cumulPauses = [0] ++ pauses.integrate;
			var endTimes = sfdurs + cumulPauses;
			var lastEndTime = endTimes.maxItem;
			var waitForEnds = lastEndTime - cumulPauses.last;

			"currently speaking % in % voices\n".postf(lang, sfdurs.size);
			"total dur: % wait for end: %\n".postf(lastEndTime, waitForEnds);

			// "durs: %\n".postf(sfdurs);
			// "pauses: %\n".postf(pauses);
			// "cumulativePauses: %\n".postf(cumulPauses);
			// "endTimes: %\n".postf(endTimes);
			// "waitForEnds: %\n".postf(waitForEnds);

			// compTdef, startedTime, intendedDur, projected next dur
			MFdef(\adjustTime).value(thisTdef, time0, ev.chosenDur, lastEndTime);

			// new lang: change background sound
			Ndef(\fv_forml).fadeTime = rrand(0, 2.0);
			Ndef(\fv_forml).xset(\pitch, exprand(40, 75));

			rrand(1, 4.0).wait;

			langdict.do {|entry, j|
				var buf;

				MFdef(\sendInfo).value(entry.name, q.activeTdef.key);

				buf = q.readBufToDict(entry).buf;
				q.bufmem.addKey(entry.name);


				(instrument: \simpsamp,
					buf: buf,
					amp: 0.5, pan: 0.9.rand2,
					sustain: 10,
					out: ev.bus
				).play;

				pauses[j].wait;

			};

			// "wait lost last soundfile to end...".postln;
			waitForEnds.wait;

			///////// maybe overlap single-file languages?
			// if (entriesPerLang.size > 1) {
			// 	waitForEnds.wait;
			// } {
			// 	// single languages:
			// 	// overlap 2 on average
			// 	(waitForEnds * 0.5).wait;
			// };

			// pause  secs between clusters
			1.wait; // before hang

			(instrument: \simpsamp,
				buf: hangbuf.choose,
				amp: 0.25, pan: -1.0.rand2,
				sustain: hangbuf.collect(_.duration).maxItem,
				rate: { 5.bilinrand *2 }.dup(rrand(3, 7) ).midiratio,
				strum: rrand(0.03,0.3),
				out: ev.bus
			).play;

			1.wait; // before hang

		};
		// wait in loop for safety
		1.wait;
	};
})
);

