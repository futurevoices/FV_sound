// ==========================================================
// ==========================================================
// Director is a Tdef that loads one composition after another
// from individual files and takes care of cleanups

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


/////// THESE ARE THE ONES for the stream installation:
//// contributions folder in its own seafile
q.yamlSearchPath = "~/Seafile/future_mirror/*.yaml".standardizePath;
//// soundlibz folder in its own seafile
q.soundlibsPath = "~/Seafile/future_soundz/soundlibs/";

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
"jinglers.scd".loadRelative;

// load director and testAll Tdefs:
"director_FV_tdef.scd".loadRelative;
"testAll_tdef.scd".loadRelative;

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

		////// preload sample banks
		MFdef('brazil').value;
		MFdef('hang').value;
		MFdef('jinglers').value;

		0.2.wait;

		"*** FUVO - PREP DONE!".postln;

		if (q.usePlayAudio12) {
			// play sine sig on ch 13 for playAUdio:
			Ndef(\zz_PASign, { SinOsc.ar }).play(12, vol: 0.1);
		};

		Tdef(\director_FV).play;
	}
}.play(AppClock);

