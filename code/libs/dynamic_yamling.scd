//
/* dynamic yaml / soundfile tracking:
- get all yaml filepaths
- on the new yaml filepaths,
-- try to read the yaml file
-- if OK,
--- try to find matching soundfile
--- if both OK,
---- add full dict to mainDict
*/

q = q ? ();

// this has all entries as dicts
q.mainDict = q.mainDict ? ();
(
q.mainDict = ();
q.updateEntries = {
	var initNumEntries = q.mainDict.size;
	var numNewEntries;
	q.yamlSearchPath.pathMatch.do { |path, i|
		var nameKey = path.basename.drop(-5).asSymbol;
		var soundfile;
		var dict, yamldict;
		if (q.mainDict[nameKey].isNil) {
			///// // we have a new one,
			// [i, path.basename ].postcs;
			try {
				yamldict = path.parseYAMLFile;

				// only look at approved ones for now
				// does not yet remove newly disapproved ones

				if (yamldict["approved"] == "true") {
					soundfile = SoundFile((path.splitext[0] ++ ".wav")).info;
					if (soundfile.notNil) {
						dict = (
							name: nameKey,
							filename: nameKey, // why twice?
							yamlPath: path,
							//// soundfile info:
							soundfilePath: soundfile.path,
							soundfile: soundfile,
							dur: soundfile.duration,
							numChannels: soundfile.numChannels
						);

						// "transfer more yaml info...".postln;
						q.dictToEvent(yamldict, dict );
						// really keep empty strings for e.g. literal_text?
						// can fail in compositions that need full data
						q.emptyStringsToNils(dict);
						q.numerifyVals(dict);

						// fix expected missing entries:
						[ 'literal_text', 'literal_text_english',
							'dialect', 'speaker_native_language' ].do { |key|
							dict[key] ?? { dict[key] = "?" };
						};
						[ \keywords, \tags].do { |key|
							dict[key] ?? { dict[key] = [] };
						};

						// dict.keys.postcs;
						// only load approved dicts!
						// this will load newly approved yamls when approved
						q.mainDict.put(nameKey, dict);
					} {
						"*** no soundfile for % !!\n".postf(nameKey.cs);
					};
					// "q.mainDict has % entries.\n".postf(q.mainDict.size);
				} {
						// "not approved: %.\n".postf(nameKey.cs);
				};
			} { |error|
				// error.dump;
				"*** yaml or soundfile read failed for % !!\n".postf(nameKey.cs);
			}
		}
	};
	numNewEntries = q.mainDict.size - initNumEntries;
	if (numNewEntries > 0) {
		"\n***\n*** q.mainDict has % entries now - % new ones. ***\n***\n\n".postf(
			q.mainDict.size,
			numNewEntries
		);
	};
	q.mainDict;
};

/*
q.mainDict.clear;
q.updateEntries; "";
*/
);

////// make pool of buffers to use
MFdef('makeBufPool').add('make', {
	q.bufpool = q.bufpool ?? { Buffer.allocConsecutive(100, s, 1) };
	q.bufpoolIndex = -1;
	q.bufpoolGet = {
		q.bufpoolIndex = q.bufpoolIndex + 1;
		q.bufpool.wrapAt(q.bufpoolIndex);
	};
	q.bufLast = { q.bufpool.wrapAt(q.bufpoolIndex) };
});

if (s.serverRunning) {
	MFdef('makeBufPool').value
} {
	s.doWhenBooted { MFdef('makeBufPool').value };
};

///// get next buffer, read soundfile given in dict,
///// and add it to the dict:
q.readBufToDict = { |q, entrydict|
	var sf = entrydict.soundfile;
	// always get next free buffer in pool
	var buf = q.bufpoolGet;
	buf.allocReadChannel(sf.path, channels: sf.numChannels.rand);
	s.sync;
	buf.normalize;
	buf.updateInfo;
	s.sync;
	"% - dur: %\n   ".postf(
		buf.path.basename,
		buf.duration.round(0.01)
	);
	entrydict.buf = buf;
	entrydict;
};



// test buffer reading, benchmark its timing
/*
fork {
var edict = q.mainDict.choose;
bench { q.readBufToDict(edict); };
edict.buf.postln.play;
};
*/

////////////////////// some  tests
/*
bench {
"~/Seafile/Future_Voices/upload/contributions/""*.yaml".pathMatch.do { |path|
var key = path.basename.drop(-5).asSymbol;
if (q.mainDict[key].isNil) {
q.mainDict.put(key, ());
}
}
};
*/


/*
"~/*/*".pathMatch.size.postln; // */*/
// ->  2247 files, 0.2 first time, 0.02 second time - caching

"~/*/*/*" .pathMatch.size.postln; // */*/*/

/// 15114 files, 1.5sec first time, then 0.1 - caching!
bench {
"~/*/*/*".pathMatch.size.postln; /// */*/*/
};
*/
