/// split mainDict by lang:

q.ourLangs = q.mainDict.collect {|sd|
	try { sd.language.language_short.asString.keep(2).toLower.asSymbol };
}.reject(_.isNil);

q.mainDict.size;
q.ourLangs.size; // complete

q.langCount = ();

q.mainDict.do { |dict|
	var langkey = dict.language.language_short.asString.keep(2).toLower.asSymbol;
	q.langCount[langkey] = q.langCount[langkey] ? 0 + 1;
};

// statistics:
q.langCount.asKeyValuePairs.clump(2).sort { |a, b| a[1] > b[1] }.printAll;

