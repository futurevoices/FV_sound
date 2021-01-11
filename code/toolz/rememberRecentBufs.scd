////// sketch for how to remember recent buf/yaml keys

q.bufmem = ();
q.bufmem.usedKeys = List[];
q.bufmem.maxMems = q.mainDict.size div: 2;
q.bufmem.addKey = { |mem, newkey|
	// remove if already there
	mem.usedKeys.remove(newkey);
	// addfirst, drop oldest one if maxsize reached
	mem.usedKeys = mem.usedKeys.addFirst(newkey);
	if (mem.usedKeys.size > mem.maxMems) {
		"pop".postln;
		mem.usedKeys.pop;
	};
	mem.usedKeys;
};

// remove all recent buffers from a dict of dicts
q.bufmem.filterDict = { |bufmem, dict|
	dict.select { |value, key| q.bufmem.usedKeys.includes(key).not };
};


/// use case 1: filter recents from full dict, then choose
q.newdict = q.bufmem.filterDict(q.mainDict).choose;
q.bufmem.addKey(q.newdict.name);
q.readBufToDict(q.newdict);
q.newdict.buf.play;

q.bufmem.usedKeys.size;

/// use case 2: make a subset of full dict, and filter that:
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
().play


q.bufmem.addKey(\otto);
q.bufmem.addKey(\ada);
