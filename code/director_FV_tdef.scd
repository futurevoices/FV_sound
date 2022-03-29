/*
Director is a Tdef that loads one composition after another
from individual files and takes care of cleanups when transitioning.
it also plays a fuure voices jingle after every quarter hour,
and an hourClock / BigBen like jingle after a new hour has begun.

The idea is that a single composition is always loaded by loading
one code file from the corresponding subdirectory, so it will
find new files every time it looks, and will always use the latest
versions of the files.
Each it composition is ended/cleaned up by the Tdef(\stopAll)

The conventions for the compos. files are:
- all compositions are usually Tdefs, which make their corresponding Ndefs
compos. Tdef, Ndef (and maybe Pdef) names always start with 'fv' !
- the Tdef('fv_something').play function is called in the composition file.
So it will also run if you JUST execute their file.
*/

/*
///// Test examples:
// speed up director for testing all compositions faster:
Tdef(\director_FV).set(\speedup, 10);
Tdef(\director_FV).set(\speedup, 1);
*/


/* MFdef(\dateSeed) is a global function to reseed the director tdef's thread:
get todays date, hours and minutes, and use these to create
a random seed number for the thread in which function is called.
this allows two things
- keeping log files of q.seed to reproduce random decisions in a task/thread,
- syncing multiple machines running the same program:
if the function is called within the same minute,
the random decision sequence between the machines will be the same.

// test:
MFdef(\dateSeed).value;
-> posts
"2203091221"
// reseeding q.seed: -2091876075
-> [ -2091876075 ]
*/

MFdef(\dateSeed).add(\doit, {
	var date = Date.getDate;
	q.seed = (date.dayStamp ++ date.secStamp.keep(4)).postcs.interpret;
	"// reseeding q.seed: %\n".postf(q.seed);
	// reseeding the thread it is is, e.g. director
	thisThread.randSeed_(q.seed);
	q.seed
});

/* MFdef(\adjustTime) lets compos-tdefs adjust the Director's remainTime:
The compos-tdef projects how long next timestep would take;
if projected next time is much longer that remainTime,
-> stop compos-tdef and tell director tdef is over
-> if it is a little longer, extend the director's remainTime
-> if shorter, do nothing, just keep going.

// Use example - copy these lines into a compos-tdef:
// before tdef
Tdef('fv_XXX').set(\chosenDur, 120);
// first thing within tdef
var time0 = Main.elapsedTime;

// before loading next buffer to play:
// args: compTdef, startedTime, plannedDur, projected duration
///   of next loop iteration (e.g. dur of soundfile)
MFdef(\adjustTime).value(thisTdef, time0, ev.chosenDur, entry.dur);
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

/*
Tdef(\hourClock) plays a Big Ben hourClock melody
with one randomly chosen hang and brazil sound each.
*/

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
///// Tdef director parameter setup
// set useful and safe ranges for the parameters as ControlSpec
Tdef(\director_FV).addSpec(\speedup, [1, 30, \exp]);
Tdef(\director_FV).addSpec(\cycleMins, [3, 180, \lin, 1]);
Tdef(\director_FV).addSpec(\closeSecs, [60, 300, \lin, 1]);

// set initial values
Tdef(\director_FV).set(\speedup, 1);
Tdef(\director_FV).set(\cycleMins, 60);   // full hour in minutes
Tdef(\director_FV).set(\closeSecs, 150);

///
Tdef(\director_FV, { |ev|

	var thisQuarter, lastQuarter = -1;

	q.composRecents = [];

	// this is for a specific audio interface, the playaudio12:
	// the Ndef(\zz_PASign) generates a signal that tells the playaudio12
	// that everything is OK; when this signal fails, the playaudio12 switches
	// to a fallback computer which runs replacement audio on the same channels.
	if (q.usePlayAudio12) {
		// play sine sig on ch 13 for playAudio 12 interface:
		Ndef(\zz_PASign, { SinOsc.ar }).play(12, vol: 0.1);
	};

	// the main director loop
	// starts a new composition every 2-5 minutes

	inf.do {
		// internal variables
		var cycleTimeSecs, cycleRemainSecs;
		var remainTime, activeTdef;
		var date, now, isClose, isAtZero;

		// first, check for new entries in database folder:
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

		// stop all previous tdefs & ndefs for the transition
		Tdef(\stopAll).stop.play(quant: 0);

		0.1.wait;

		// each quarter hour, play info jingle for listeners
		thisQuarter = Date.getDate.minute div: 15;
		[\quarter, thisQuarter, \prev, lastQuarter].postln;

		// if we are in a new quarter (after min 00, 15, 30, 45)
		if (thisQuarter != lastQuarter) {
			// if we are in a new hour now ...
			if (thisQuarter == 0) {
				2.wait;
				// play the hang/brazil bigBen melody here
				Tdef(\hourClock).embed;
			};
			// every quarter, play the FutureVoices/Zukunftsmusik jingle
			"jingling!".postln;
			Tdef(\jingleDir).embed;
		};
		lastQuarter = thisQuarter;
		[\quarter, thisQuarter, \prev, lastQuarter].postln;


		// choose & play one of the compos files:
		// new compositions get added automatically,
		// because we look everytime with pathMatch!
		q.composChoices = q.fuvo.composPath.pathMatch;
		"found % compositions - ".postf(q.composChoices.size);

		/**** FOR TAKEOVERS ****/
		// reduce composChoices by filtering
		// see filterMain.scd for details and examples
		q.filterCompos;

		// remove a few most recently played paths from available choices,
		// so we only repeat the same composition after a few others played.

		q.composChoices = q.composChoices.reject { |path|
			var numRecentsToAvoid = q.composChoices.size div: 2;
			numRecentsToAvoid = min(numRecentsToAvoid, q.composChoices.size - 2);
			q.composRecents.keep(numRecentsToAvoid).includesEqual(path)
		};
		q.composChoices.size;
		// choose one of the remaining ones
		q.chosenFile = q.composChoices.choose;

		q.composRecents = q.composRecents.addFirst(q.chosenFile)
		.keep(q.composChoices.size);
		"keeping % comp. choices to avoid repetition.\n".postf(q.composChoices.size);


		"\n\n*** starting composition %\n".postf(q.chosenFile.basename);
		q.chosenDur = (exprand(120, 300)).round.asInteger;
		"*** plays for % seconds \n\n".postf(q.chosenDur.round(1));

		activeTdef = q.chosenFile.load; // load and play tdef!
		// set its seed; this is based on randSeed of director now
		activeTdef.set(\randSeed, 10000.rand);
		// set how long the compos. should try to play
		activeTdef.set(\chosenDur, q.chosenDur);
		q.activeTdef = activeTdef;

		// set spec for remaining time remainTime,
		// so the GUI shows a countdown
		Tdef(\director_FV).addSpec(\remainTime, [0, q.chosenDur, \lin, 1]);
		ev.remainTime = q.chosenDur;


		//// now we just need to wait for when to transition to the next thing:
		// wait for remainTime in short increments so speedup changes work
		// show the remainTime in FutureVoices TdefGui
		// when the compos-tdef gets near its end, it does ajustTime;
		// do we still play a full composition, or do we stop
		// and play hourCLOCK or jingle?

		////// FIXME: better varable names that explain logic clearly
		////// is this still needed, or did we do everything in quarter check already?
		while {
			//
			cycleTimeSecs = ev.cycleMins * 60;
			date = Date.getDate;
			// what second are we at in the hour?
			now = date.rawSeconds.round % cycleTimeSecs; // full hour
			cycleRemainSecs = cycleTimeSecs - now;
			// are there less than 3 minutes to full hour?
			isClose = cycleRemainSecs < ev.cycleTimeSecs;
			isAtZero = cycleRemainSecs <= 1;         // at full hour

			(ev.remainTime > 0) or: isClose and: isAtZero.not
		} {
			// make sure active ndef runs and listens!
			q.activeNdef = q.activeTdef.get(\ndef);
			if (q.activeNdef.notNil) {
				if (q.activeNdef.monitor.isPlaying.not) { q.activeNdef.play };
				if (q.activeNdef.objects.size < 1) { q.activeNdef.send };
			};

			////// debug waiting: FIXME
			if (isClose) {
				"close - dt compos: % dt cycle: % \n"
				.postf(ev.remainTime.round, cycleRemainSecs);
			};

			// countdown in logical seconds
			ev.remainTime = ev.remainTime - 1;
			// real waiting may be speeded up
			(1/ev.speedup).wait;
		};

		"\n\n*** ending composition %\n\n".postf(q.chosenFile.basename);

		if (isAtZero) {
			"*** FULL HOUR ***".postln;
			1.wait; // jump over exact full hour, so we get
			MFdef(\dateSeed).value;
			thisThread.randSeed_(q.seed);
			"*** postseed check: %\n".postf(100.rand);

			// FIXME - ditch syncing across machines to simplify code?
			// clear composRecents so we can sync across machines!
			// also clear bufmem recents? ...
			q.composRecents = [];

		};

		// now go back to top, stopAll, check if quarter etc, or play next compos
	};
});
);