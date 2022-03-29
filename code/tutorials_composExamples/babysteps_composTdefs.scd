q.mainDict.size

~myentry = q.mainDict.choose;

~myentry2 = q.mainDict.at('2021-04-29-16-05-15_germany_en');

~myentry2.sortedKeysValuesDo { |key, obj|
	[ key, obj ].postcs;
};

[ 'approval_date', "2021-05-09T00:22:01.712Z" ]
[ 'approved', "true" ]
[ 'approved_by', "awe" ]
[ 'buf', Buffer.new ]
[ 'coordinates', (  ) ]
[ 'country', "Germany" ]
[ 'country_code', "DE" ]
[ 'dialect', "?" ]
[ 'dur', 8.5333333333333 ]
[ 'filePath', "uploads/2021-04-29-16-05-15_germany_en.wav" ]
[ 'filename', "2021-04-29-16-05-15_germany_en.wav" ]
[ 'keywords', [ "oracle" ] ]
[ 'langKey', 'en' ]
[ 'language', "English" ]
[ 'language_short', "EN" ]
[ 'literal_text', "\"When day comes we step out of the shade, Aflamed and unafraid.\" (Amanda Gorman, The Hill We Climb, p.48, chosen by the I Ching)" ]
[ 'literal_text_english', "\"When day comes we step out of the shade, Aflamedp and unafraid.\" (Amanda Gorman, The Hill We Climb, p.48, chosen by the I Ching)" ]
[ 'name', '2021-04-29-16-05-15_germany_en' ]
[ 'numChannels', 2 ]
[ 'soundfile', SoundFile.new ]
[ 'soundfilePath', "/Users/adc/Seafile/future_mirror/2021-04-29-16-05-15_germany_en.wav" ]
[ 'speaker_native_language', "DE" ]
[ 'tags', [ "oracle", "voice:awe" ] ]
[ 'user_timestamp', "2021-04-29T18:06:15.625Z" ]
[ 'user_timestamp_string', "2021-04-29T16:06:15.000Z" ]
[ 'version', 0.1 ]
[ 'yamlFilename', "2021-04-29-16-05-15_germany_en.yaml" ]
[ 'yamlFilenamePath', "uploads/2021-04-29-16-05-15_germany_en.yaml" ]
[ 'yamlPath', "/Users/adc/Seafile/future_mirror/2021-04-29-16-05-15_germany_en.yaml" ]

fork {
	q.readBufToDict(~myentry2);
	~myentry2.buf.postln.play;
};


// play an empty tdef
Tdef(\test, {
	inf.do {
		"hello world".scramble.postln;
		1.wait;
	}
}).play;

Tdef(\test2, {
	inf.do { |cnt|
		cnt.postln;
		// "hello world".reverse.postln;
		2.wait;
	}
}).play;


// modify it:
Tdef(\test3, {
	inf.do {
		var entry = q.mainDict.choose;
		entry.postln;
		5.wait;
	}
}).play;

a = q.mainDict.choose;
a.keys;
a.dur;
a.filename;
a.country
a.langKey
a.country_code
a.coordinates
a.language
a.soundfilePath;
a.dur;

Tdef(\play1buf, {
	// choose an entry
	var entry = q.mainDict.choose;
	// load its soundfile to a buffer
	q.readBufToDict(entry);
	// when loaded, play that buffer
	entry.buf.dump;
	entry.buf.play;
});



// modify it:
Tdef(\test3, {
	inf.do {
		var entry = q.mainDict.choose;
		entry.postln;
		q.readBufToDict(entry);
		entry.buf.play;
		5.wait;
	}
}).play;


Tdef(\test3, {
	inf.do {
		var entry = q.mainDict.choose;
		q.readBufToDict(entry);
		entry.buf.play;
		entry.dur.postln.wait;
	}
}).play;

MainFX(s).set(\wet20, 1.0.rand);


Tdef(\test3, {
	inf.do {
		var entry = q.mainDict.choose;
		q.readBufToDict(entry);
		entry.buf.play;
		// wait for dur - 1 sec
		(entry.dur - 1).postln.wait;
		// set reverb tail high
		MainFX(s).set(\wet20, 0.7);
		// wait 1 sec til end of sound
		// wait another 2 secs
		3.wait;
		// end of loop: set rev small
		MainFX(s).set(\wet20, 0.1);
	}
}).play;



// play thru a SynthDef rather than buf.play!
 // (instrument: \simpsamp, buf: x.buf, rate: -1).play;

Tdef(\test3, {
	inf.do {
		var entry = q.mainDict.choose;
		q.readBufToDict(entry);

		(   instrument: \simpsamp,
			buf: entry.buf,
			rate: -1,
			amp: 0.9,
			pan: 1.0.rand
		).play;

		// wait for dur - 1 sec
		(entry.dur - 1).postln.wait;
		// set reverb tail high
		MainFX(s).set(\wet20, 0.7);
		// wait 1 sec til end of sound
		// wait another 2 secs
		3.wait;
		// end of loop: set rev small
		MainFX(s).set(\wet20, 0.1);
	}
}).play;

// play back and forth at the same time, panned to L/R !
Tdef(\test3, {
	inf.do {
		var entry = q.mainDict.choose;
		q.readBufToDict(entry);

		(   instrument: \simpsampGlitch, // \simpsamp,
			buf: entry.buf,
			rate: [-1, 1],
			amp: 0.9,
			pan: [-1, 1]
		).play;

		// wait for dur - 1 sec
		(entry.dur - 1).postln.wait;
		// set reverb tail high
		MainFX(s).set(\wet20, 0.7);
		// wait 1 sec til end of sound
		// wait another 2 secs
		3.wait;
		// end of loop: set rev small
		MainFX(s).set(\wet20, 0.1);
	}
}).play;









