// q.kontimuumSnds.do(_.free); q.kontimuumSnds=nil;
{
	// if(q.kontimuumSnds.isNil){
	// 	q.kontimuumSnds = q.loadSamples("upload_kont", "~/Seafile/JaMoP/");
	// };

	Tdef(\fv_kont_1).stop.play;

}.defer(0.2);

(
Tdef('fv_kont_1', { |ev|
	var mykey = 'fv_kont_1';
	var thisTdef = Tdef(mykey);
	var thisNdef = q.tdefPrepNdef(thisTdef);
	var rout;

	"\n*** % starts ***\n\n".postf(thisTdef);
	q.tdefSeed(thisTdef);

	0.2.wait;
	thisNdef.send.play(fadeTime: 0.1);

	rout = Pxrand(q.mainDict.values, inf).asStream;

	inf.do { |i|
		var dict = rout.next;
		var rate = exprand(0.94, 1.05);
		var rateFast = rrand(10, 20);
		var buf;
		q.readBufToDict(dict);
		buf = dict.buf;

		"*** playing: %\n".postf(buf.path.basename);
		// much longer, softer, longer ringing, higher trigger thresh
		(instrument: \singSampCavaChord3, buf: buf.bufnum,
			amp: 0.25, wet: 0.9, out: ev.bus.index,
			strDecay: 5.exprand(10), strSlope: 0.8,
			rate: rate/3, thresh: 0.2).play;

		1.wait;

		// FX; same sample & rate as plain voice
		(instrument: \singSampCavaChord3, buf: buf.bufnum,
			amp: 0.5, wet: 1, out: ev.bus,
			strDecay: 3.exprand(10), strSlope:0.9,
			rate: rate, thresh: 0.125, pan: #[-1,1]@@i ).play;

		// plain voice
		(instrument: \simpsamp, buf: buf.bufnum,
			amp: 0.7, out: ev.bus,
			rate: rate, pan: #[-1,1]@@i * rrand(0.66, 1) ).play;

		(buf.duration / rate).wait;

		(exprand(2, 10)).wait;

		// FFW delimiter sound
		(instrument: \simpsamp, buf: buf.bufnum, amp: 0.1,
			out: ev.bus, rate: rateFast, pan: #[-1,1]@@i ).play;
		(instrument: \simpsamp, buf: buf.bufnum, amp: 0.1,
			out: ev.bus, rate: rateFast*0.8, pan: #[1,-1]@@i  ).play;

	}
});
);

