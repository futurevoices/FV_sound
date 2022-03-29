/*
/// UPDATE / Refactor JUNE 17:
- read all yaml files, or later, all json files
- matching soundfile found
-> convert to full entry in q.allEntries
- then filter from q.allEntries to q.mainDict:
approved only?
only certain keywords?
any other criteria?

// strange, 3 different sizes?
q.yamlSearchPath.pathMatch.size;
q.yamlSearchPath.replace("yaml", "json").pathMatch.size;
q.yamlSearchPath.replace("yaml", "wav").pathMatch.size;
q.yamlSearchPath.dirname.openOS;

how to check only files changed since last check time?
raw filedate newer than lasttime?

hm, the jsons are not very human-readable.
*/


///// Date.getDate.rawSeconds
/*
// get all files at path from last 7 days:
bench { unixCmdGetStdOut("find ~/Seafile/future_mirror/*.json -mtime -7d").split($\n).size.postln }; // */

// maybe -mtime flag is macOS only?
// get all files from last 7 days:
bench { ~yamls = unixCmdGetStdOut("find ~/Seafile/future_mirror/*.yaml -mtime -7d").split($\n); ~yamls.size.postln }; // 0.03 adc */
bench { ~jsons = unixCmdGetStdOut("find ~/Seafile/future_mirror/*.json -mtime -7d").split($\n); ~jsons.size.postln }; // 0.025 adc */
bench { ~wavs  = unixCmdGetStdOut("find ~/Seafile/future_mirror/*.wav  -mtime -7d").split($\n); ~wavs .size.postln }; // 0.03 adc */

// which ones convert faster? no difference
bench { ~yamls.collect(_.parseYAMLFile) }; // 0.03
bench { ~jsons.collect(_.parseJSONFile) }; // 0.03

bench { q.db.datafileSearchPath.pathMatch; }; // patchMatch is really fast!

so, keep allEntries around;
add newly incoming ones, thus replacing older dict versions;
and remake mainDict on every update by filtering allEntries.
*/


q.db = q.db ? ();
q.db.allEntries = q.db.allEntries ? ();
// replace later?
q.db.datafileSearchPath = q.yamlSearchPath;

q.db.getAllPaths = { |db|
	db.allPaths = q.db.datafileSearchPath.pathMatch;
	db.allPaths
};
// how far back should this go?
// 2hours seems more than enough
q.db.getNewerPaths = { |db|
	db.newerPaths = unixCmdGetStdOut("find ~/Seafile/future_mirror/*.yaml -mtime -2h").split($\n);
	db.newerPaths.reject(_ == "");
};

q.db.getAllPaths .size;
q.db.getNewerPaths .size;

q.db.makeEntry = { |db, path|
	var nameKey = path.basename.splitext[0].asSymbol;
	var soundfile, yamldict, entryDict;
	try {
		yamldict = path.parseYAMLFile;

		soundfile = SoundFile((path.splitext[0] ++ ".wav")).info;

		if (soundfile.notNil) {
			entryDict = (
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
			q.dictToEvent(yamldict, entryDict );
			// really keep empty strings for e.g. literal_text?
			// can fail in compositions that need full data
			q.emptyStringsToNils(entryDict);
			q.numerifyVals(entryDict);

			// fix expected missing entries:
			[ 'literal_text', 'literal_text_english',
				'dialect', 'speaker_native_language' ].do { |key|
				entryDict[key] ?? { entryDict[key] = "?" };
			};
			[ \keywords, \tags].do { |key|
				entryDict[key] ?? { entryDict[key] = [] };
			};
			// convert "true" "false" to boolean
			entryDict[\approved] = entryDict[\approved] == "true";

			// dict.keys.postcs;
			// only load approved dicts!
			// this will load newly approved yamls when approved
			q.db.allEntries.put(nameKey, entryDict);
		} {
			"*** no soundfile for % !!\n".postf(path.cs);
		}
	} { |error|
		// error.dump;
		"*** yaml read failed for % !!\n".postf(nameKey.cs);
	};
	entryDict
};


q.updateEntries = {
	/// this only changes something when new data files come in:
	q.db.getNewerPaths.do { |path| q.db.makeEntry(path) };
	// filtering the full allEntries dict happens with every new composition:
	"*** q.db.allEntries: % \n".postf(q.db.allEntries.size);
	q.filterMain ?? { q.filterMain_default };
	"*** q.mainDict: % \n".postf(q.mainDict.size);
};

////// filterMain: by default, only use aprroved entries.
////// easy to livecode different versions later!

q.filterMain = nil;

q.filterMain_default = {
	" ... filterMain_default:".postln;
	q.mainDict = q.db.allEntries.select {|entry| entry.approved };
};

// initialize with allPaths only once:
q.db.allPaths.do { |path| q.db.makeEntry(path) };

q.updateEntries;

