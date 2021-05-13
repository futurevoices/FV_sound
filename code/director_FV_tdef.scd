// Director is a Tdef that loads one composition after another
// from individual files and takes care of cleanups

/*
// idea:
a single composition is loaded by loading one code file from the corresponding subdir.;
it is ended/cleaned up by the Tdef(\stopAll)

conventions:
- all compositions have Tdef and Ndef / Pdef names starting with 'fv' !
- .play function is supplied inside the composition. So it will also run if u JUST execute their file.

*/

/*
Tdef(\director_FV).set(\speedup, 10);
Tdef(\director_FV).set(\speedup, 1);
*/

// reseed director thread when called for:
MFdef(\dateSeed).add(\doit, {
	var date = Date.getDate;
	q.seed = (date.dayStamp ++ date.secStamp.keep(4)).postcs.interpret;
	"// reseeding q.seed: %\n".postf(q.seed);
	// reseeding the thread it is is, e.g. director
	thisThread.randSeed_(q.seed);
	q.seed
});

// let composTdefs adjust directors remainTime:
// tdef projects how long next timestep would take;
// if projected next time much longer that remainTime,
// -> stop tdef and tell director tdef is over
// -> if a little longer, extend director remainTime
// -> if shorter, just keep going.

/* // copy these into tdefs:
// before tdef
Tdef('fv_XXX').set(\chosenDur, 120);
// first thing within tdef
var time0 = Main.elapsedTime;

// before loading next buffer to play:
// compTdef, startedTime, plannedDur, projected next dur
MFdef(\adjustTime).value(thisTdef, time0, ev.chosenDur, dict.dur);
*/

MFdef(\adjustTime).add(\stopOrExtend, { |compTdef, time0, plannedDur = 120, projectedDur|
	// if remainder of chosenDur > thistime
	var timeSoFar = Main.elapsedTime - time0;
	var myRemainTime = plannedDur - timeSoFar;
	case { myRemainTime < (projectedDur * 0.5) } {
		"next event much longer than plannedDur,\n"
		"so end and hand back early".postln;
		Tdef(\director_FV).set(\remainTime, 0);
		compTdef.postcs.stop;
		0.01.wait;
		// "what? not stopping yet???".postln;
	} { myRemainTime < projectedDur } {
		"next event a little over plannedDur,\n"
		"extend director remainTime to: ".post;
		Tdef(\director_FV).set(\remainTime, projectedDur.round(0.01).postln);
	};
});

Tdef(\hourClock, {
	var bufs =  [q.hang, q.brazil].collect(_.choose);
	var dur = bufs.collect(_.duration).product ** (1/bufs.size);
	var pitches = [4, 0, 2, -5, -5, 2, 4, 0];
	var durs = [1, 1, 1, 3, 1, 1, 1, 3] * (dur * 0.5).clip(0.38, 1.62);

	"\n*** hourClock:".postln;
	bufs.do { |buf|
		(buf.path.basename + buf.duration.round(0.01)).postln;
	};
	"dur: %\n".postf(dur);

	pitches.do { |pitch, i|
		bufs.do { |buf|
			(
				instrument: \simpsamp,
				buf: bufs,
				rate: pitch.midiratio * [0.99, 1.01].scramble,
				amp: 0.5,
				pan: [-1, 1]
			).play;
		};
		durs[i].wait;
	};
}).quant_(0);

(
Tdef(\director_FV).addSpec(\speedup, [1, 30, \exp]);
Tdef(\director_FV).addSpec(\cycleMins, [3, 180, \lin, 1]);
Tdef(\director_FV).addSpec(\closeSecs, [60, 300, \lin, 1]);

Tdef(\director_FV).set(\speedup, 1);
Tdef(\director_FV).set(\cycleMins, 60);   // full hour in minutes
Tdef(\director_FV).set(\closeSecs, 150);


Tdef(\director_FV, { |ev|

	var thisQuarter, lastQuarter = -1;

	q.composRecents = [];

	if (q.usePlayAudio12) {
		// play sine sig on ch 13 for playAudio 12 interface:
		Ndef(\zz_PASign, { SinOsc.ar }).play(12, vol: 0.1);
	};

	inf.do {
		// internals
		var cycleTimeSecs, cycleRemainSecs;
		var remainTime, activeTdef;
		var date, now, isClose, isAtZero;

		// check for new entries in folder:
		defer {
			var t0 = Main.elapsedTime;
			q.updateEntries;
			/**** FOR TAKEOVERS ****/
			// filter mainDict to focus on smaller thematic subset of mainDict
			q.filterMain;
			"*** q.mainDict filtered to % entries.\n".postf(q.mainDict.size);
			q.lang.check;
			"updated entries & langs in % secs.\n"
			.postf((Main.elapsedTime - t0).round(0.001));
		};

		// stop all previous tdefs & ndefs:
		Tdef(\stopAll).stop.play(quant: 0);

		0.1.wait;

		thisQuarter = Date.getDate.minute div: 15;
		[\quarter, thisQuarter, \prev, lastQuarter].postln;
		if (thisQuarter != lastQuarter) {
			if (thisQuarter == 0) {
				2.wait;
				// play a little hang/brazil bigBen flourish here?;
				Tdef(\hourClock).embed;
			};

			"jingling!".postln;
			Tdef(\jingleDir).embed;
		};
		lastQuarter = thisQuarter;
		[\quarter, thisQuarter, \prev, lastQuarter].postln;

		// choose & play one of the compos files:
		// new compositions get added automatically!
		q.composChoices = q.composPath.pathMatch;

		/**** FOR TAKEOVERS ****/
		// reduce composChoices by  filtering:
		q.filterCompos;

		// // remove last played path - no immediate repeat
		// // could keep several recent ones to avoid repeating them soon
		// q.composChoices = q.composChoices.removeAllSuchThat { |path| path != q.chosenFile };

		///// remove last 4 played paths from choices:
		q.composChoices = q.composChoices.reject { |path|
			var numRecents = q.composChoices.size div: 2;
			q.composRecents.keep(numRecents).includesEqual(path)
		};
		// choose one of them
		q.chosenFile = q.composChoices.choose;

		// and add new one to recents, max 4
		q.composRecents = q.composRecents.addFirst(q.chosenFile).keep(4);



		"\n\n*** starting composition %\n".postf(q.chosenFile.basename);
		q.chosenDur = (exprand(120, 300)).round.asInteger;
		"*** plays for % seconds \n\n".postf(q.chosenDur.round(1));

		activeTdef = q.chosenFile.load; // load and play!
		activeTdef.set(\randSeed, 10000.rand);
		activeTdef.set(\chosenDur, q.chosenDur);
		q.activeTdef = activeTdef;

		// spec for remaining time remainTime
		Tdef(\director_FV).addSpec(\remainTime, [0, q.chosenDur, \lin, 1]);
		ev.remainTime = q.chosenDur;

		// wait for remainTime in short increments so speedup changes work
		// see remainTime showing in TdefGui
		while {
			cycleTimeSecs = ev.cycleMins * 60;
			date = Date.getDate;
			now = date.rawSeconds.round % cycleTimeSecs; // full hour
			cycleRemainSecs = cycleTimeSecs - now;
			isClose = cycleRemainSecs < ev.cycleTimeSecs;   // if less than 3 minutes to full hour
			isAtZero = cycleRemainSecs <= 1;         // at full hour

			(ev.remainTime > 0) or: isClose and: isAtZero.not
		} {
			// make sure active ndef runs and listens!
			q.activeNdef = q.activeTdef.get(\ndef);
			if (q.activeNdef.notNil and: { q.activeNdef.monitor.isPlaying.not }) {
				q.activeNdef.play;
			};
			if (q.activeNdef.notNil and: { q.activeNdef.objects.size < 1 }) {
				q.activeNdef.send;
			};

			////// debug waiting:
			if (isClose) {
				"close - dt compos: % dt cycle: % \n"
				.postf(ev.remainTime.round, cycleRemainSecs);
			};


			ev.remainTime = ev.remainTime - 1;
			(1/ev.speedup).wait;
		};

		"\n\n*** ending composition %\n\n".postf(q.chosenFile.basename);

		if (isAtZero) {
			"*** FULL HOUR ***".postln;
			1.wait; // jump over exact full hour, so we get
			MFdef(\dateSeed).value;
			thisThread.randSeed_(q.seed);
			"*** postseed check: %\n".postf(100.rand);

			// clear composRecents so we can sync across machines!
			// also clear bufmem recents? ...
			q.composRecents = [];

			///// play jingle at full hour! plays higher up anyway:
			// Tdef(\jingleDir).embed;
		};

		// then go back to top, and stopAll
	};
});
);