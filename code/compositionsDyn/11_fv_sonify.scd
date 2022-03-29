/*****
// sonify entry text along with voice soundfile.
could take one of q.tonalDefs, but many do not have
pan, amp, sustain, and only indirect use of freq param
-> find a good subset.
-> or fix all of them.

// should go thru full synthlibs,
// and annotate which ones have good freq inputs!


q.tonalDefs.postcs;

// these have freq, amp, pan, sustain params:
q.fullDefs.keys(Array).sort.cs;
[ 'amacherFlimmern', 'basedrum', 'basedrum_holz', 'dessous', 'fbBass', 'flop', 'gliss2', 'gliss2p', 'gliss2s', 'glisson', 'grain', 'grainLine', 'grainSine', 'grainXLRev', 'grainXLine', 'pfeifchen', 'rain', 'wirk' ]

(instrument: \flop).play;

// these are new and fully working - load them below:
(instrument: 'gliss2', freq: 600, freq2: 100, sustain: 0.8, pan: [-1, 1].choose, amp: 0.25).play;
(instrument: 'mridangam2', freq: 400, freq2: 4000, sustain: 1, pan: [-1, 1].choose, amp: 0.25).play;
(instrument: 'gliss2p', freq: 600, freq2: 100, sustain: 0.8, pan: [-1, 1].choose, amp: 0.25).play;
(instrument: 'gliss2s', freq: 600, freq2: 100, sustain: 0.8, pan: [-1, 1].choose, amp: 0.25).play;

// these seem quite ok
(instrument: 'pfeifchen', freq: 300, freq2: 400, sustain: 0.1, pan: [-1, 1].choose, amp: 0.5).play;
(instrument: 'glisson', freq: 300, freq2: 400, sustain: 0.1, pan: [-1, 1].choose, amp: 0.5).play;
(instrument: 'grainXLine', freq: 600, freq2: 400, sustain: 0.1, pan: [-1, 1].choose, amp: 0.5).play;
(instrument: 'honky', freq: 600, freq2: 400, sustain: 0.1, pan: [-1, 1].choose, amp: 0.5).play;

q.paramNames[\honky]

// no panning
(instrument: 'saw', freq: 300, freq2: 400, sustain: 0.1, pan: [-1, 1].choose, amp: 0.5).play;
(instrument: 'press2', freq: 300, freq2: 400, sustain: 0.1, pan: [-1, 1].choose, amp: 0.5).play;
(instrument: 'music2', freq: 300, freq2: 400, sustain: 0.1, pan: [-1, 1].choose, amp: 0.5).play;

(instrument: \gliss2p, pan: -1).play;
(instrument: \mridangam2, pan: -1).play;

*/


// fixing two of the freq synthdefs for consistency;
// and adding two slight variants.

(
SynthDef( \mridangam2, { arg out, freq = 85, amp =0.4, pan, decay = 0.1;
	var sig = Resonz.ar(
		WhiteNoise.ar([100,100])
		* Decay2.ar( Impulse.ar(0) * amp, 0.002, 0.1 ),
		freq,
		0.1,
		4
	).distort;

	DetectSilence.ar( sig,  doneAction: 2 );
	OffsetOut.ar( out, Balance2.ar(sig[0], sig[1], pan));
}).add;

SynthDef('gliss2',
	{ arg out = 0, freq=800, freq2=1200, sustain=0.01, amp=0.1, pan = 0.0;
		var window, freqEnv;
		window = Env.linen(0.1, 0.8, 0.1, amp);
		freqEnv = Env([ freq, freq2 ], [ sustain ], \sin);
		Out.ar(out,
			Pan2.ar(
				SinOsc.ar(EnvGen.ar(freqEnv)),
				pan
			)
			* EnvGen.ar(window, timeScale: sustain, doneAction:2)
		)
}).add;

// and two variants with different oscillator/waveforms:
SynthDef('gliss2p',
	{ arg out = 0, freq=800, freq2=1200, sustain=0.01, amp=0.1, pan = 0.0;
		var window, freqEnv;
		window = Env.linen(0.1, 0.8, 0.1, amp);
		freqEnv = Env([ freq, freq2 ], [ sustain ], \sin);
		Out.ar(out,
			Pan2.ar(
				Pulse.ar(EnvGen.ar(freqEnv)) * 0.5,
				pan
			)
			* EnvGen.ar(window, timeScale: sustain, doneAction:2)
		)
}).add;

SynthDef('gliss2s',
	{ arg out = 0, freq=800, freq2=1200, sustain=0.01, amp=0.1, pan = 0.0;
		var window, freqEnv;
		window = Env.linen(0.1, 0.8, 0.1, amp);
		freqEnv = Env([ freq, freq2 ], [ sustain ], \sin);
		Out.ar(out,
			Pan2.ar(
				Saw.ar(EnvGen.ar(freqEnv)) * 0.5,
				pan
			)
			* EnvGen.ar(window, timeScale: sustain, doneAction:2)
		)
}).add;


Tdef('fv_sonifya').set(\chosenDur, 120);

Tdef('fv_sonifya').quant = 0;
Tdef('fv_sonifya').stop.play;



Tdef('fv_sonifya', { |ev|
	var time0 = Main.elapsedTime;

	// same for all Tdefs (except name):
	var mykey = 'fv_sonifya';
	var thisTdef = Tdef(mykey);
	var thisNdef = q.tdefPrepNdef(thisTdef);
	"\n*** % starts ***\n\n".postf(thisTdef);
	MFdef(mykey).value;

	0.1.wait;
	// wait so that seed set from outside can be used when Tdef runs:
	q.tdefSeed(thisTdef);
	0.1.wait;
	thisNdef.play(fadeTime: 0.1);

	q.interpunkt = "!,.;:?-";
	q.interpunkDict = ();
	q.interpunkt.do { |char| q.interpunkDict.put(char, q.brazil.choose) };

	inf.do {

		var entry = q.mainDict.choose;
		var text = entry.literal_text_english;
		var textLength = text.size;
		var entryDuration = entry.dur;
		var durPerChar =  entryDuration / (textLength + 2) * 0.7;
		var transpose = 12.rand2;
		var syndef, syndefVowel, syndefCons;

		text.postcs;

		// compTdef, startedTime, intendedDur, projected next dur
		MFdef(\adjustTime).value(thisTdef, time0, ev.chosenDur, entry.dur);

		q.interpunkt.do { |char| q.interpunkDict.put(char, q.brazil.choose) };

		q.interpunkDict.do { |buf|
			(instrument: \simpsamp, buf: buf, amp: 0.5, pan: 1.0.rand2).play;
			0.1.wait;
		};

		q.readBufToDict(entry);
		// waits until buffer is ready ...
		// then play the soundfile as is, pan a bit to the left
		(instrument: \simpsamp, buf: entry.buf, amp: 0.5, pan: -0.5).play;

		//////// sonification starts here //////
		// and over the whole duration it plays,
		// play the text as ascii sonification:
		// make it two freqs for glissandi.
		// syndef = q.fullDefs.keys.choose;

		////// these syndefs have a glissando to freq2:
		///// [ 'gliss2', 'gliss2p', 'gliss2s' ]
		////// these syndefs just have freq input:
		// [ 'mridangam2', 'pfeifchen', 'grainXLine', 'honky', 'saw' ].choose.postcs;

		syndefVowel = [ 'gliss2', 'gliss2p', 'gliss2s' ].choose;
		syndefCons = [ \mridangam2,  'grainXLine' ].choose;

		text.do { |char|
			var charNum = char.toUpper.ascii; // range is 65 - 90
			// if char is a letter, make a sound
			///// if it is a vowel, make a longer, pitched sound
			///// if consonant, make a shorter, drummy sound
			// if it is a space, silent. OK
			// if dot, comma, etc, play a perc sample OK

			if (char.isAlpha) {
				if (char.isVowel) {
					(instrument: syndefVowel,
						char: char,
						freq: (charNum + transpose).midicps,
						// small glissando away from initial pitch
						freq2: (charNum + transpose).midicps * rrand(0.9, 1.1),
						// double length
						dur: durPerChar * 2,
						pan: -0.5,
						amp: 0.1
					).play;
					durPerChar.wait;
				} {
					(instrument: syndefCons,
						char: char,
						midinote: charNum,
						dur: durPerChar,
						pan: -0.5,
						amp: 0.04
					).play;

				}
			} {
				// non-letters: if
				if ("!,.;:?-".includes(char)) {
					// "PUNKtion".postln;
					// q.interpunkDict[char].play;
					(instrument: \simpsamp,
						char: char,
						buf: q.interpunkDict[char],
						amp: 0.2
					).play;
					durPerChar.wait;
				};
			};

			durPerChar.wait;
		};

		"% looping...\n".postf(thisTdef);
		1.wait;
	}
});
)