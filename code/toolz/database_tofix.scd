// how many stereo files still in?
q.mainDict.select { |d| d[\numChannels] == 2 }.size;


~allKeysInEntry = Set[];
q.mainDict.do { |dict| dict.keysDo { |key| ~allKeysInEntry.add(key) } };
~allKeysInEntry.size;
~allKeysInEntry.asArray.sort.cs;

// [ 'approval_date', 'approved', 'approved_by', 'coordinates', 'country', 'country_code', 'dialect', 'dur', 'filePath', 'filename', 'keywords', 'langKey', 'language', 'language_short', 'lat', 'literal_text', 'literal_text_english', 'name', 'numChannels', 'soundfile', 'soundfilePath', 'speaker_native_language', 'tags', 'user_timestamp', 'user_timestamp_string', 'version', 'yamlFilename', 'yamlFilenamePath', 'yamlPath' ]

/////// check for missing keys in entries:

~missingKeys = ();
q.mainDict.do { |dict|
	~allKeysInEntry.difference(dict.keys).do { |key|
		~missingKeys.put(key, ~missingKeys.at(key) ? 0 + 1);
	}
};
~missingKeys;

////// buf is harmless, dialect and lat too,
////// but the others are not OK!

( 'lat': 46, 'buf': 195, 'dialect': 168, 'tags': 1,
  'literal_text_english': 4, 'speaker_native_language': 1, 'keywords': 1 )


q.mainDict.collect(_.size).asArray.sort.plot; //
q.mainDict.collect(_.size).count(_ == 1); //

q.mainDict.select(_.size < 2)

database consistency:
/// how many files have empty strings
q.mainDict.select { |d| d[\literal_text_english] == "" }.size; // 0
q.mainDict.select { |d| d[\literal_text_english] == nil }.size; // 4 nils?
q.mainDict.select { |d| d[\literal_text] == nil }.size; // 0
q.mainDict.select { |d| d[\literal_text] == "" }.size; // 0

q.mainDict.select { |d| d[\keywords].isArray.not }.size; // 1!
q.mainDict.select { |d| d[\tags].isArray.not }.size; // 1!

q.mainDict.select { |d| d[\lat].isNumber.not }.size; // 46
q.mainDict.select { |d| d[\coordinates].select(_.isNumber).size < 2 }.size; // 47
q.mainDict.select { |d| d[\long].isNumber.not }.size; // 236 - all

q.mainDict.select { |d| d[\town].isNil }.size; // we don't have time yet

