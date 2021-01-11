q.langCodes = TabFileReader.read("langCodes.csv".resolveRelative);
q.langCodes = q.langCodes.drop(1);
q.langCodeTitles = q.langCodes[0];
q.langCodes = q.langCodes.drop(1);

q.langCodes3 = q.langCodes.collect { |line| line[0].keep(3).asSymbol };
q.langCodes2 = q.langCodes.collect { |line| (line[1] ? "").select(_ != $ ).asSymbol };
q.langCodes2Set = q.langCodes2.asSet.asArray.sort;

/*
q.langCodeTitles.cs;
q.langCodes.size;
q.langCodes.last.cs;

q.langCodes3.size;
q.langCodes2.cs;
q.langCodes2Set.size;

q.langCodes3;
*/

// test mainDict language_short keys: must be in q.langCodes2Set !!

(
q.mainDict.do { |dict|
	var langshort = (dict.language_short ? "xxx").toLower.asSymbol;
	if (q.langCodes2Set.includes(langshort).not) {
		"*** % has unknown langshort %! ***\n".postf(dict.name, langshort);
	}
}; "";
)
