
////// make pool of buffers to use
MFdef('makeBufPool').add('make', {
	q.bufpool = q.bufpool ?? { Buffer.allocConsecutive(100, s, 1) };
	q.bufpoolIndex = -1;
	q.bufpoolGet = {
		q.bufpoolIndex = q.bufpoolIndex + 1;
		q.bufpool.wrapAt(q.bufpoolIndex);
	};
	q.bufLast = { q.bufpool.wrapAt(q.bufpoolIndex) };
});

if (s.serverRunning) {
	MFdef('makeBufPool').value
} {
	s.doWhenBooted { MFdef('makeBufPool').value };
};

///// get next buffer, read soundfile given in dict,
///// and add it to the dict:
q.readBufToDict = { |q, entrydict, postTextSize = 40|
	var sf = entrydict.soundfile;
	// always get next free buffer in pool
	var buf = q.bufpoolGet;
	buf.allocReadChannel(sf.path, channels: sf.numChannels.rand);
	s.sync;
	buf.normalize;
	buf.updateInfo;
	s.sync;
	"% - dur: %\n'%'\n".postf(
		buf.path.basename,
		buf.duration.round(0.01),
		entrydict.literal_text.keep(postTextSize);
	);
	entrydict.buf = buf;
	entrydict;
};

