////// sketch for how to remember recent buf/yaml keys

(
q.bufmem = ();
q.bufmem.usedKeys = List[];
q.bufmem.maxMems = 50;
q.bufmem.addKey = { |mem, newkey|
	// remove if already there
	mem.usedKeys.remove(newkey);
	// addfirst, drop oldest one if maxsize reached
	mem.usedKeys = mem.usedKeys.addFirst(newkey);
	if (mem.usedKeys.size > mem.maxMems) {
		mem.usedKeys.pop;
	};
	mem.usedKeys;
};


////// safe new method - always keep some choices!
// remove all recent buffers from a dict of dicts
// when dict is small, only remove latest 75%
q.bufmem.filterDict = { |bufmem, dict|
	var maxmems = (dict.size * 0.75).asInteger min: (dict.size - 2);
	var usedKeysShort = q.bufmem.usedKeys.keep(maxmems);
	dict.select { |value, key| usedKeysShort.includes(key).not };
};

// // remove all recent 40 or so buffers from a dict of dicts
// q.bufmem.filterDict = { |bufmem, dict|
// 	dict.select { |value, key| q.bufmem.usedKeys.includes(key).not };
// };
// all collections
q.bufmem.filter = { |bufmem, coll|
	coll.select { |elem, key| q.bufmem.usedKeys.includes(elem.name) };
};
q.bufmem.filterNames = { |bufmem, list|
	list.removeAll(q.bufmem.usedKeys)
};
)

/*
q.mainDict.size;
q.bufmem.filterDict(q.mainDict).size;

////// use case 1: filter recents from full dict, then choose
(
fork {
	10.do {
		var syn;
		q.newdict = q.bufmem.filterDict(q.mainDict).choose;
		q.bufmem.addKey(q.newdict.name);

		q.readBufToDict(q.newdict);
		syn = q.newdict.buf.play;
		defer ({ syn.free }, 1);
		0.5.wait;
	};
};
)
q.bufmem.usedKeys.size;

/// use case 2: make a subset of full dict, filter that:

(
fork {
	var shortz = q.mainDict.select { |dict| dict.dur < 7.5 };

	var allowedShortz = q.bufmem.filterDict(shortz);

	shortz.size.postln;
	allowedShortz.size.postln;

	allowedShortz.asArray.scramble.do { |dict|
		dict.name.postln;
		q.bufmem.usedKeys.size.postln;
		q.bufmem.addKey(dict.name);
		q.readBufToDict(dict);
		dict.buf.play;
		1.wait;
	}
}
)

q.bufmem.usedKeys.size;
*/