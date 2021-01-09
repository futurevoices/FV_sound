///// get next buffer, read soundfile given in dict,
///// and add it to the dict:
q.readBufToDict = { |q, entrydict|
	var sf = entrydict.soundfile;
	// always get next free buffer in pool
	var buf = q.bufpoolGet;
	buf.allocReadChannel(sf.path, channels: sf.numChannels.rand, completionMessage: { |buf|
		buf.normalize;
		buf.updateInfo;
		"%:\n   normalized and got info\n".postf(buf.path.basename);
	});
	try {
		s.sync;
		"   readBufToDict - synced".postln;
	};
	entrydict.buf = buf;
};

q.bufpoolGet;
q.lastBuf = { q.bufpool.wrapAt(q.bufpoolIndex) };


s.plotTree;
s.scope(32);

q.activeTdef;
q.activeTdef.get(\bus);
q.activeTdef.get(\ndef);
(note: 24, dur: 0.1, bus: q.activeTdef.get(\bus).index).play;

(instrument: \simpsamp, buf: q.bufpool[3], amp: 0.2, bus: q.activeTdef.get(\bus)).play;


Tdef('fv_kont_1')
sof_unsettled-sea_gr.wav is silent

Tdef(\bumpyrampy)
fv_bumpy is silent, catchall gets things

langclusters is silent

cmdPeriod

s.plotTree

s.defaultGroup.dumpTree

q.activeTdef;
q.activeTdef.get(\bus);
q.activeTdef.get(\ndef).play;
(note: 24, dur: 5, amp: 0.5, bus: q.activeTdef.get(\bus).index).play;

(instrument: \simpsamp, buf: q.hang[45], amp: 0.2, bus: q.activeTdef.get(\bus)).play;

Ndef(\fv_catchAll).bus

q.bufpoolIndex