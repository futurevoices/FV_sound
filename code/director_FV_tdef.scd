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

(
Tdef(\director_FV).addSpec(\speedup, [1, 30, \exp]);
Tdef(\director_FV).addSpec(\cycleMins, [3, 180, \lin, 1]);
Tdef(\director_FV).addSpec(\closeSecs, [60, 300, \lin, 1]);

Tdef(\director_FV).set(\speedup, 1);
Tdef(\director_FV).set(\cycleMins, 60);   // full hour in minutes
Tdef(\director_FV).set(\closeSecs, 150);


Tdef(\director_FV, { |ev|

	q.composRecents = [];

	Tdef(\jingleDir).embed;

	loop {
		var cycleTimeSecs, cycleRemainSecs;
		var remainTime, activeTdef;
		var date, now, isClose, isAtZero;

		// check for new entries in folder:
		defer {
			q.updateEntries;
			q.lang.check;
		};

		// stop all previous tdefs & ndefs:
		Tdef(\stopAll).stop.play(quant: 0);

		2.wait;

		// choose & play one of the compos files:
		// new compositions get added automatically!
		q.composChoices = q.composPath.pathMatch;

		// // remove last played path - no immediate repeat
		// // could keep several recent ones to avoid repeating them soon
		// q.composChoices = q.composChoices.removeAllSuchThat { |path| path != q.chosenFile };

		///// remove last 4 played paths from choices:
		q.composChoices = q.composChoices.reject { |path| q.composRecents.includesEqual(path) };
		// choose one of them
		q.chosenFile = q.composChoices.choose;

		// and add new one to recents, max 4
		q.composRecents = q.composRecents.addFirst(q.chosenFile).keep(4);



		"\n\n*** starting composition %\n".postf(q.chosenFile.basename);
		q.chosenDur = (exprand(120, 300)).round.asInteger;
		"*** plays for % seconds \n\n".postf(q.chosenDur.round(1));

		activeTdef = q.chosenFile.load; // load and play!
		activeTdef.set(\randSeed, 10000.rand);
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
			MFdef(\dateSeed).value;
			thisThread.randSeed_(q.seed);
			"*** postseed check: %\n".postf(100.rand);
			// clear chosenfile so it wont be removed from choices
			// this is to allow syncing across machines!
			// "play a little hang/brazil flourish here?";

			q.chosenFile = "nonono";

			// play jingle at full hour!
			Tdef(\jingleDir).embed;
		};

		// then go back to top, and stopAll
	};
});
);