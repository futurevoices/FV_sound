// analysis:
q.mainDict.size;


// duration studies:
~durs = q.mainDict.collect(_.dur);

// total playing time
~durs.sum;
~durs.sum.asTimeString;

~durs.mean; // average
~durs.values.sort.asArray.plot; // distribution
~durs.values.sort[q.mainDict.size div: 2]; // median dur

/// langs:

~langdicts = q.mainDict.collect(_.language);
~langdicts.size;

~langshorts = ~langdicts.collect(_.language_short);
~langshorts.size;

~langdicts.keys.removeAll(~langshorts.keys); // Set[ Audio 1_05 ] has no language_short
q.mainDict.choose.language;


~langshorts.values.collect(_.toLower).asSet.asArray.sort;

