// ==========================================================
// ==========================================================
// Director is a Tdef that loads one composition after another from individual files and takes care of cleanups

/*
// idea:
a single composition is loaded by loading one code file from the corresponding subdir.;
it is ended/cleaned up by the Tdef(\stopAll)

conventions:
- all compositions have Tdef and Ndef / Pdef names starting with 'fv' !
- .play function is supplied inside the composition. So it will also run if u JUST execute their file.

// ToDo:
- Ndefs end slowly in 5 secs; if SAME composition is chosen again, it will not restart in time!! (not all compos use Ndefs)
- make sure that starting any Tdef(\jmp...) plays everything relating to that composition.
*/

// set relative filepaths once at compile time
q=q?();

////// orig: preloaded buffers
// q.composPath = "compositions/*.scd".resolveRelative;
////// read the ones with dynamic buffer loading:
q.codeDir = thisProcess.nowExecutingPath.dirname;
q.futureDir = thisProcess.nowExecutingPath.dirname.dirname;
q.composPath = "compositionsDyn/*.scd".resolveRelative;
q.readDictPath = "libs/a_readDict.scd".resolveRelative;

//// adjust this for BRAZILPERC and hang soundlibs!
q.soundlibsPath = q.futureDir +/+ "soundlibs/";
q.soundlibsPath = "~/Seafile/Future_Voices/soundlibs/";
q.soundlibsPath = "~/Seafile/future_soundz/soundlibs/";

//***** edit this to taste ***********//

// define path for database folder with soundfiles and yaml files:
/////// this is the Future_Voices course folder version - OBSOLETE
/////// q.yamlSearchPath = "~/Seafile/Future_Voices/upload/contributions/*.yaml".standardizePath;

/////// THIS IS THE ONE for the one-year stream installation:
q.yamlSearchPath = "~/Seafile/future_mirror/*.yaml".standardizePath;

/* // get PostLog:
Quarks.install("https://github.com/adcxyz/postlog");
*/
if (\PostLog.asClass.notNil) {
	\PostLog.asClass.start;
};


// ==========================================================
// ==========================================================
// first, load SynthDef and sample loading libraries



"libs/a_functions.scd".loadRelative; // load all functions
"libs/_SampleLib.scd".loadRelative;
"libs/_reSampleLib.scd".loadRelative;
"libs/_SynthLib.scd".loadRelative;
"libs/dynamic_yamling.scd".loadRelative;
"libs/utils.scd".loadRelative;
"libs/langAnalysis.scd".loadRelative;

/// q.updateEntries;

Tdef(\director_FV).addSpec(\speedup, [1, 30, \exp]);
/*
Tdef(\director_FV).set(\speedup, 10);
*/
Tdef(\director_FV).set(\speedup, 1);

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
Tdef(\director_FV).addSpec(\cycleMins, [3, 180, \lin, 1]);
Tdef(\director_FV).addSpec(\closeSecs, [60, 300, \lin, 1]);

Tdef(\director_FV).set(\cycleMins, 60);   // full hour in minutes
Tdef(\director_FV).set(\closeSecs, 150);


Tdef(\director_FV, { |ev|

	q.composRecents = [];

	loop {
		var cycleTimeSecs, cycleRemainSecs;
		var remainTime, activeTdef;
		var date, now, isClose, isAtZero;

		// check for new entries in folder:
		q.updateEntries;

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
		};

		// then go back to top, and stopAll
	};
});
);

(
Tdef(\testAll, { |ev|

	// make sure main dict is loaded / reloaded as needed
	q.readDictPath.load;
	s.sync;

	q.composChoices = q.composPath.pathMatch;

	q.composChoices.do { |compos|
		var activeTdef;
		q.chosenFile = compos;

		Tdef(\stopAll).stop.play;

		2.wait;

		"\n\n*** starting composition %\n".postf(q.chosenFile.basename);
		q.chosenDur = 15;
		"*** plays for % seconds \n\n".postf(q.chosenDur.round(1));

		activeTdef = q.chosenFile.load; // load and play!
		activeTdef.postln.set(\randSeed, 10000.rand);

		Tdef(\testAll).addSpec(\remainTime, [0, q.chosenDur]);
		ev.remainTime = q.chosenDur;

		while { ev.remainTime >= 0 } {
			ev.remainTime = ev.remainTime - 1;
			(1/ev.speedup).wait;
		};

		"\n\n*** ending composition %\n\n".postf(q.chosenFile.basename)

		// then go back to top, and stopAll
	};

	Tdef(\stopAll).stop.play;
	"*** Tdef('testAll') DONE!".postln;
});
);

// for proxychain and MasterFX
1000.do { |i| Spec.add(("wet"++i).asSymbol, \unipolar) };

///////////// STARTUP:
Task {
	////// make sure we always get a fresh server!
	Server.killAll;

	///////// do server setup here, before booting:
	// s.options.device = "the special 2 computer device ...";
	// give server lots of realtime Memory: 2 ** 21 is 2 GB, 2 ** 19 is 500MB
	s.options.memSize = (2 ** 19).asInteger; // 500MB
	s.options.numAudioBusChannels = 4096;
	s.options.sampleRate = 44100;
	s.options.numBuffers = 2048; // default is 1024

	// no inputs
	s.options.numInputBusChannels = 0;
	s.options.numOutputBusChannels = 4;

	q.usePlayAudio12 = ServerOptions.devices.any (_=="PlayAUDIO12");

	// use PlayAUDIO12 if there, then with
	if (q.usePlayAudio12) {
		s.options.device = "PlayAUDIO12";
		s.options.numOutputBusChannels = 14;
	};

	2.wait;
	// boot server, then start director:
	s.waitForBoot {

		0.5.wait;
		// MainFX(s).clear;
		"MainFX.scd".loadRelative;

		// remove for headless deploy
		if (\View.asClass.notNil) {
			defer ({ (q.codeDir +/+ "Guis.scd").load }, 0.2);
		};

		////// preload two perc sample banks
		MFdef('brazil').value;
		MFdef('hang').value;

		0.2.wait;

		"*** FUVO - PREP DONE!".postln;

		if (q.usePlayAudio12) {
			// play sine sig on ch 13 for playAUdio:
			Ndef(\zz_PASign, { SinOsc.ar }).play(12, vol: 0.1);
		};

		Tdef(\director_FV).play;
	}
}.play(AppClock);

