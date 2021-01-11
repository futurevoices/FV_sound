////// DONE simpler in FV_director at the moment.
////// so this may staty unused.

// we have composChoices already:
q.composChoices.size;

q.compmem = ();
q.compmem.usedKeys = [];
q.compmem.maxMems = (max (4, q.composChoices.size div: 2));
q.compmem.addKey = { |mem, newkey|
	// remove if already there
	mem.usedKeys.remove(newkey);
	// addfirst, drop oldest one if maxsize reached
	mem.usedKeys = mem.usedKeys.addFirst(newkey).keep(mem.maxMems);
	mem.usedKeys.size.postln;
};

q.compmem.filter = { |mem, choices|
	choices.reject { |key| q.compmem.usedKeys.includesEqual(key) }
};

q.compmem.getNext = {
	var nextoptions = q.compmem.filter(q.composChoices);
	var nextkey = nextoptions.choose;
	"nextoptions:".postln;
	nextoptions.printAll;
	q.compmem.addKey(nextkey);
	nextkey
};

//// works - but is it convenient?
q.compmem.getNext;

