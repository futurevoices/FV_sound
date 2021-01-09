////// sketch for how to remember recent bufyamp keys

q.recent = ();
q.recent.usedKeys = List[];
q.recent.maxSize = q.mainDict.size div: 2;
q.recent.addKey = { |rec, newkey|
	// remove if already there
	rec.usedKeys.remove(newkey);
	// addfirst, drop oldest one if maxsize reached
	rec.usedKeys.addFirst(newkey).keep(rec.maxSize);
};

q.recent.filter = { |recent, dict|
	dict.select { |value, key| q.recent.usedKeys.includes(key).not };
};

q.recent.addKey(\a);
q.recent.addKey(\b);
q.recent.addKey(\a);

q.recent.filter((a: 1, b: 2, c: 3));

