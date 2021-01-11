q.lang = ();

q.lang.check = {
	q.lang.numEntries = ();
	q.mainDict.do {|sd|
		var langKey;
		try {
			langKey = sd.language_short.asString.keep(2).toLower.asSymbol;
			// write langKey back into entryDict:
			sd.put(\langKey, langKey);
			// count them:
			q.lang.numEntries[langKey] = q.lang.numEntries[langKey] ? 0 + 1;
		};
	}.reject(_.isNil);

	q.lang.byCount = q.lang.numEntries.asKeyValuePairs.clump(2)
	.sort { |a, b| a[1] > b[1] };
	q.lang.names = q.lang.byCount.collect(_.first);
	q.lang.numEntries;
};

// this is the interface:
q.lang.check;
q.lang.names;
q.lang.numEntries;
q.lang.byCount;
