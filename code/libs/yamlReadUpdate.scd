

/****
Updating SC database after new rsync from website database
needs to fulfill criteria:

updated yaml files should update entries in mainDict:
- if now approved, convert yamldict and make an entry from it
- if now disapproved, remove entry!
- in both cases, redo analyses

LOGIC sketch:
- shell - select all yaml files newer than lastCheckDate
- SC: newYamls = newPaths parsed;
- if approved false, remove by key from mainDict
- if approved true, find or make dict for it in mainDict;
-- fill new dict with data from yaml:
--- keys as symbols
--- values depending on keys:
--- leave as strings,
or convert to symbols, numbers, booleans etc

x = (q.yamlSearchPath.dirname +/+ "2021-01-11-13-03-37_germany_en.yaml").parseYAMLFile;
x["dialect"].cs
x.keys(Array).sort.cs;

x = (q.yamlSearchPath.dirname +/+ "2021-01-10-19-56-21_germany_en.yaml").parseYAMLFile;
x["literal_text_english"].postcs;

x = (q.yamlSearchPath.dirname +/+ "2021-01-05-22-48-12_germany_de.yaml").parseYAMLFile;
x["coordinates"];
x["keywords"].cs;
x["tags"].cs;

****/

(
/// read and update a single yaml dict
q.readUpdateYaml = { |q, path|
	var stringKeys = [ "approval_date", "approved_by" ];
	var symbolKeys = [ "country_code", "approved_by" ];
	var numberKeys = [ "approval_date", "approved_by" ];
	var stringArrayKeys = [ "approval_date", "approved_by" ];

	var yamdict = path.parseYAMLFile;
	var yamKey = path.basename.splitext[0].asSymbol;
	var sfpath, soundfile;
	var entryDict;
	var coordDict, coordDict2, keywordsArray, tagsArray;
	var longNum, latNum;

	if (yamdict["approved"] != "true") {
		// "remove me".postln;
		q.mainDict.removeAt(yamKey);
	} {
		sfpath =path.splitext[0] ++ ".wav";
		soundfile = SoundFile(sfpath).info;
		if (soundfile.isNil) {
			"no soundfile fpr %!\n".postf(path);
		} {
			// "add or update me".postln;

			entryDict = q.mainDict[yamKey] ?? { () };

			entryDict.put(\soundfile, soundfile);
			entryDict.put(\soundfilePath, soundfile.path);
			entryDict.put(\dur, soundfile.duration);
			entryDict.put(\numChannels, soundfile.numChannels);

			entryDict.put(\name, yamKey);

			entryDict.put(\approved, true);
			entryDict.put(\approved_by, yamdict["approved_by"]);
			entryDict.put('approval_date', yamdict["approval_date"]);

			entryDict.put('town', yamdict["town"]);
			entryDict.put('country', yamdict["country"]);
			entryDict.put('country_code', yamdict["country_code"].asSymbol);

			entryDict.put('language', yamdict["xxx"]);
			entryDict.put('dialect', yamdict["dialect"]);
			entryDict.put('language_short', yamdict["language_short"]);
			entryDict.put('speaker_native_language', yamdict["speaker_native_language"]);
			entryDict.put('langKey', yamdict["language_short"].asSymbol);

			entryDict.put('literal_text', yamdict["literal_text"]);
			entryDict.put('literal_text_english', yamdict["literal_text_english"]);

			entryDict.put('user_timestamp', yamdict["user_timestamp"]);
			entryDict.put('user_timestamp_string', yamdict["user_timestamp_string"]);
			entryDict.put('version', yamdict["version"]);
			entryDict.put('yamlFilename', yamdict["yamlFilename"]);
			entryDict.put('yamlFilePath', path);

			// check for integrity? should be arrays of string
			entryDict.put('keywords', yamdict["keywords"]);
			entryDict.put('tags', yamdict["tags"]);

			coordDict = yamdict["coordinates"];
			// these need more conversion:
			if (coordDict.isKindOf(Dictionary)) {
				var dict = ();
				try {
					coordDict.keysValuesDo { |k, v|
						var key = k.asSymbol;
						var num =  v !? { v.interpret };
						dict.put(key, num);
						entryDict.put(key, num);
					}
				} {
					"coords failed for %:\n".postf(yamKey);
					"% : coords: %\n".postf(entryDict[\town], coordDict.cs);
				};
				if (dict.size < 2) {
					"coords incomplete for %:\n".postf(yamKey.cs);
					coordDict.postcs;
				};
				entryDict.put('coordinates', dict);
			};
		};
	};
};

// bench {
// 	// should remove me:
// 	q.readUpdateYaml(q.yamlSearchPath.dirname +/+ "2021-01-05-22-48-12_germany_de.yaml");
// 	// should update me:
// 	q.readUpdateYaml(q.yamlSearchPath.dirname +/+ "2021-01-05-17-44-59_poland_pl.yaml");
// };

bench {
	q.yamlSearchPath.pathMatch.do(q.readUpdateYaml(_));
}
)


// get file dates:
stat -f "%Sm" -t "%Y-%m-%d %H:%M" [filename]
If I want to run it on a range of files, I can do something like this:

// #!/usr/bin/env bash
// for i in /var/log/*.out; do
// stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$i"
// done

/// how fast is shell cmd to get files newer-than-testfile files?

bench {
	unixCmdGetStdOut("find /Users/adc/Seafile/future_mirrTEST/ -newer /Users/adc/Seafile/future_mirrTEST/_datefiledummy.yaml").cs;
};

/// futuremirror
bench {
	unixCmdGetStdOut("find /Users/adc/Seafile/future_mirror/ -newer /Users/adc/Seafile/future_mirrTEST/_datefiledummy.yaml").cs;
};



// 0.14 sec for 250 yamls
bench {
	var yamlpaths, yamlDicts;
	yamlpaths = q.yamlSearchPath.pathMatch;
	"found % yamls\n".postf(yamlpaths.size);
	yamlDicts = yamlpaths.collect { |path|
		var yamdict = path.parseYAMLFile;
		if (yamdict["approved"] != "true") {
			// remove these
			path.basename.postcs;
		} {
			// add if not present;
			// update if anything changed;
		};
		yamdict
	};
	yamlDicts[0].sortedKeysValuesDo { |key, val|
		(key.cs + val.cs).postln;
	};
}