
(
Tdef('fv_kontinuum').set(\chosenDur, 60);

Tdef('fv_kontinuum').quant_(0).stop.play;

Tdef('fv_kontinuum', { |ev|
	var mykey = 'fv_kontinuum';
	var thisTdef = Tdef(mykey);
	var thisNdef = q.tdefPrepNdef(thisTdef);
	var time0 = Main.elapsedTime;

	"\n*** % starts ***\n\n".postf(thisTdef);
	0.1.wait;
	q.tdefSeed(thisTdef);
	0.1.wait;

	thisNdef.play(fadeTime: 0.1);

	inf.do { |i|
		var mydict = q.bufmem.filterDict(q.mainDict);

		mydict.values.scramble.do { |dict|
			var rate = exprand(0.94, 1.05);
			var rateFast = rrand(10, 20);
			var buf;
			q.readBufToDict(dict);
			buf = dict.buf;

			// compTdef, startedTime, intendedDur, projected next dur
			MFdef(\adjustTime).value(thisTdef, time0, ev.chosenDur, dict.dur + 4);

			MFdef(\sendInfo).value(dict.name, q.activeTdef.key);


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
		};
		1.wait;
	}
});
);

