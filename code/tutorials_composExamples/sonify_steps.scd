// known good synthdefs:
q.fullDefs.keys


~entry = q.mainDict.choose;
fork { q.readBufToDict(~entry) };

~text = ~entry.literal_text_english;

~text.as(Array).collect { |char| char.toUpper.ascii };

fork { q.readBufToDict(~entry) };

~entry.buf.play;

Tdef(\sonitest, {
	var entry = ~entry;
	var text = entry.literal_text_english.postln;
	var entryDuration = entry.dur.postln;
	var textLength = text.size.postln;
	var durPerChar =  entryDuration / (textLength + 2);

	// play the buffer
	(instrument: \simpsamp, buf: entry.buf, amp: 0.5).play;

	text.do { |char|
		var charNum = char.toUpper.ascii;
		(midinote: charNum, dur: durPerChar).postln.play;
		durPerChar.wait;
	};
}).play;


(
Tdef(\sonitest, {
	var entry = ~entry;
	var text = entry.literal_text_english.postln;
	var entryDuration = entry.dur.postln;
	var textLength = text.size.postln;
	var durPerChar =  entryDuration / (textLength + 2);
	var syndef;

	// play the buffer
	(instrument: \simpsamp, buf: entry.buf, amp: 0.5).play;

	syndef = q.fullDefs.keys.choose;
	text.do { |char|
		var charNum = char.toUpper.ascii;
		(instrument: syndef,
			midinote: charNum,
			dur: durPerChar,
			pan: [-1, 1].choose;
		).postln.play;

		durPerChar.wait;
	};
}).play;
)


///////// sonic alphabet!
/// make vowels, consonants, interpunction sound different
/// their timing could be different
///

"I support - the changes."

// letters, upper/lower case, space, dot.

~text.as(Array).collect { |char| char.ascii };

[ 73, 32, 115, 117, 112, 112, 111, 114, 116, 32, 116, 104, 101, 32, 99, 104, 97, 110, 103, 101, 115, 46 ]

// keep letters only:
"I support the changes.".select(_.isAlpha);
"I support the changes.".select { |char| char.isAlpha.not }.postcs;
"I support the changes.".select { |char| char.isVowel }.postcs;
"I support the changes.".select { |char| char.isVowel.not }.postcs;


~entry = q.mainDict.choose;
fork { q.readBuf2Dict(~entry) };

q.interpunkt = "!,.;:?-";

q.interpunkDict = ();
q.interpunkt.do { |char| q.interpunkDict.put(char, q.brazil.choose) };

q.interpunkDict[$!].play
q.interpunkDict[$,].play
q.interpunkDict[$.].play
q.interpunkDict[$;].play


~entry = q.mainDict.choose;
fork { q.readBufToDict(~entry) };
~entry.literal_text_english;

$A.ascii.postln.midicps // midi 65, ca. 350 Hz
$Z.ascii.postln.midicps // midi 90, ca 1500 Hz
$a.ascii.postln.midicps // 97 ca. 2200
$z.ascii.postln.midicps // 122, 9400 Hz


(midinote: $A.ascii - 24).play
(midinote: $Z.ascii - 24).play
(midinote: $a.ascii - 24).play
(midinote: $z.ascii, ).play /



(
Tdef(\sonitest, {
	var entry = ~entry;
	var text = entry.literal_text_english.postln;
	var entryDuration = entry.dur.postln;
	var textLength = text.size.postln;
	var durPerChar =  entryDuration / (textLength + 2) * 0.7;
	var syndef, syndefVowel, syndefCons;

	// play the buffer
	(instrument: \simpsamp, buf: entry.buf, amp: 0.5, pan: 0.5).play;

	// syndef = q.fullDefs.keys.choose;
	syndefVowel = \gliss2;
	syndefCons = \mridangam2;

	text.do { |char|
		var charNum = char.toUpper.ascii; // range is 65 - 90
		// if char, make a sound
		///// if vowel, make a longer, pitched sound OK
		///// if consonant, make a shorter, drummy sound
		// if space, silent. OK
		// if dot, comma, etc, play a perc sample OK

		if (char.isAlpha) {
			if (char.isVowel) {
				(instrument: syndefVowel,
					char: char,
					freq: charNum.midicps,
					freq2: charNum.midicps * rrand(0.9, 1.1),
					dur: durPerChar * 2,
					pan: -0.5,
					amp: 0.2
				).postln.play;
				durPerChar.wait;
			} {
				(instrument: syndefCons,
					char: char,
					midinote: charNum,
					dur: durPerChar,
					pan: -0.5,
					amp: 0.02
				).postln.play;

			}
		} {
			// non-letters: if
			if ("!,.;:?-".includes(char)) {
				"PUNKtion".postln;
				// q.interpunkDict[char].play;
				(instrument: \simpsamp,
					char: char,
					buf: q.interpunkDict[char],
					amp: 0.2
				).postln.play;
				durPerChar.wait;
			};
		};

		durPerChar.wait;
	};
}).play;
)

/////// delay & chorus experiments:
(instrument: \simpsamp, buf: ~entry.buf, amp: 0.5, start: 3).play

// 12 sec
(instrument: \simpsamp, buf: ~entry.buf, pan: [-0.5, 0.5], amp: 0.5, lag: [0, 12]).play

// 1 sec
(instrument: \simpsamp, buf: ~entry.buf, pan: [-0.5, 0.5], amp: 0.5, start: [4, 3.0]).play


// 200 msec - slapback - Elvis 1950s rockabilly!
(instrument: \simpsamp, buf: ~entry.buf, amp: [0.5, 0.2], start: [3.2, 3.0]).play

// 100 msec - stadium PA echo
(instrument: \simpsamp, buf: ~entry.buf, amp: 0.5, start: [3, 3.1]).play



// 50 msec - 2 voices "voice doubling"
(instrument: \simpsamp, buf: ~entry.buf, pan: [-0.5, 0.5], amp: 0.5, start: 3, lag: [0, 0.05]).play

// 30 msec - 2 voices still "voice doubling"
(instrument: \simpsamp, buf: ~entry.buf, pan: [-0.5, 0.5], amp: 0.5, start: 3, lag: [0, 0.03]).play

// 20 msec - 1 voice, but in a strange room
(instrument: \simpsamp, buf: ~entry.buf, pan: [-0.5, 0.5], amp: 0.5, start: 3, lag: [0, 0.02]).play

// 14 msec - 1 voice, but in a strange room
(instrument: \simpsamp, buf: ~entry.buf, pan: [-0.5, 0.5], amp: 0.5, start: 3, lag: [0, 0.014]).play

// 10 msec - 1 voice, but in a strange room - metallic coloring
(instrument: \simpsamp, buf: ~entry.buf, pan: [-0.2, 0.2], amp: 0.5, start: 3, lag: [0, 0.010]).play

// 5 msec - 1 voice, but in a strange room - metallic
(instrument: \simpsamp, buf: ~entry.buf, pan: [-0.2, 0.2], amp: 0.5, start: 3, lag: [0, 0.005]).play

// 3 msec - 1 voice, but in a resonant box -
(instrument: \simpsamp, buf: ~entry.buf, pan: [-0.2, 0.2], amp: 0.5, start: 3, lag: [0, 0.003]).play

// 2 msec - 1 voice, but in a resonant box -
(instrument: \simpsamp, buf: ~entry.buf, pan: [-0.2, 0.2], amp: 0.5, start: 3, lag: [0, 0.002]).play

// 1 msec - 1 voice, but in a resonant box -
(instrument: \simpsamp, buf: ~entry.buf, pan: [-0.2, 0.2], amp: 0.5, start: 3, lag: 0.001 * (0..10)).play

FreqScope.new


/////// plans:
// effects patch that does
// 1. chorusing
// 2. pitch shifting
// pitch shift can be set from sonif/text-melody

// 3. autotuna - measure pitch of incoming sound,
// calculate ratio to desired pitch

/*
ProxyChain(\fx).clear
*/
// make a ProxyChain with buffer and FX
ProxyChain(\fx, [ \bufplay, \micdead, \shifta, \chorus, \delay ]);
ProxyChain(\fx).gui

// the buffer player
ProxyChain.add3(
	\bufplay,
	\mix -> { |buf, rate=1, pan, loop=1|
		Pan2.ar(PlayBuf.ar(1, buf, rate, loop: loop), pan);
	},
	1,
	(
		buf: [0, 100, \lin, 1],
		rate: [0.25, 4, \exp],
		loop: [0, 1, \lin, 1]
	)
);


// the delay
ProxyChain.add3(
	\delay,
	\filter -> { |in, delaytime = 0.1, decaytime = 1, drift = 0|
		var timedrift = LFDNoise3.kr(0.2 ! in.size).range( (1-drift).max(0.0001), 1);
		CombL.ar(in, 1,
			delaytime.lag(0.2) * timedrift,
			decaytime.lag(0.2)
		);
	},
	1,
	(
		delaytime: [0.0001, 1, \exp],
		decaytime: [0.01, 100, \exp],
		drift: [0, 1],
	)
);

// the chorus
ProxyChain.add3(
	\chorus,
	\filter -> { |in, modRate = 0.4, modDepth = 0|
		var numVoices = 6;

		var delaytimes = { LFDNoise3.kr(modRate ! numVoices, modDepth).exprange( 0.003, 0.03) };
		var delays = DelayL.ar(in.sum, 0.2, delaytimes);
		Splay.ar(delays);
	},
	1,
	(
		modRate: [0.01, 10, \exp],
		modDepth: [0, 1],
	)
);

// the shifta
ProxyChain.add3(
	\shifta,
	\filter -> { |in, interval = 0|
		PitchShift.ar(in, 0.12, interval.midiratio, 0.01, 0.01);
	},
	1,
	(
		interval: [-24, 24, \lin],
	)
);

~entry = q.mainDict.choose;
fork { q.readBufToDict(~entry) };

(
Tdef(\sonitest, {
	var entry = ~entry;
	var text = entry.literal_text_english.postln;
	var entryDuration = entry.dur.postln;
	var textLength = text.size.postln;
	var durPerChar =  entryDuration / (textLength + 2);

	/// play the buffer into
	(instrument: \simpsamp, buf: entry.buf,
		amp: 0.5,
		out: ProxyChain(\fx).proxy.index
	).play;

	ProxyChain(\fx).play;

	text.do { |char|
		var charNum = char.toUpper.ascii;
		var interval = charNum - [65, 90].mean;
		if (char.isAlpha) {
			ProxyChain(\fx).set(\interval, interval.postln);
		};

		//
		(instrument: \gliss2,
			char: char,
			freq: charNum.midicps,
			freq2: charNum.midicps * rrand(0.9, 1.1),
			dur: durPerChar,
			pan: -0.5,
			amp: 0.03
		).play;

		durPerChar.wait;
	};
}).play;
)


// zihern question - text to speech on macOS:
Quarks.install("say");
SayBuf.help;


////// HOMEWORK:
//// micdead :-)

// the autotuna
ProxyChain.add3(
	\autotuna,
	\filter -> { |in, desiredPitch = 0|
		// get pitch from signal on bus,
		// set pitchshift ratio to difference between
		// measured pitch and desired pitch
		PitchShift.ar(in, 0.12, interval.midiratio, 0.01, 0.01);
	},
	1,
	(
		interval: [-24, 24, \lin],
	)
);
