////// this is the dynamic version of hangOn:
/// it reads buffers newly on demand.

MFdef('fv_hangOn').add(\loadbufs, {
	// PREP: make sure perc and brazil are there:
	// load brazil samples if not there
	MFdef(\brazil).value;
	// load hang samples if not there
	MFdef(\hang).value;
});

///// this is the Tdef that plays
(
Tdef('fv_hangOn').quant = 0;
Tdef('fv_hangOn').stop.play;

Tdef( 'fv_hangOn' , { |ev|
	var mykey = 'fv_hangOn';
	//
	var thisTdef = Tdef(mykey);
	var thisNdef = q.tdefPrepNdef(thisTdef);
	MFdef(mykey).value;

	"\n*** % starts ***\n\n".postf(thisTdef);
	// wait a little ...
	0.1.wait;
	// so seed set from outside can be used when Tdef runs:
	q.tdefSeed(thisTdef);

	0.1.wait;

	thisNdef.play(fadeTime: 0.1);

	loop {
		// could filter by mood? topic?
		var mydict = q.mainDict;
		// filter recents;
		mydict = q.bufmem.filterDict(mydict);

		"mydict size: %\n".postf(mydict.size);

		mydict.values.scramble.do {|dict, i|
			var hangbuf = q.hang.wrapAt(i);
			var percbuf = q.brazil.wrapAt(i + (0.. 3.linrand));

			var buf;
			q.readBufToDict(dict);
			q.bufmem.addKey(dict.name);
			buf = dict.buf;
			buf.path.basename.postcs;

			MFdef(\sendInfo).value(dict.name, q.activeTdef.key);

			if(buf.notNil){

				(instrument: \simpsamp,
					buf: hangbuf,
					amp: 0.25, pan: -1.0.rand2,
					sustain: hangbuf.duration,
					rate: { 5.bilinrand * 2 }.dup(rrand(3, 7) ).midiratio,
					strum: rrand(0.03, 0.3),
					out: ev.bus
				).play;

				(hangbuf.duration).wait;
				(exprand(0.2, 1)).wait;

				(instrument: \simpsamp,
					buf: buf,
					amp: 0.5, pan: 0,
					sustain: buf.duration,
					out: ev.bus
				).play;
				(buf.duration).wait;
			};

			(instrument: \simpsamp,
				buf: percbuf,
				amp: 0.25, pan: 0.5.rand2,
				sustain: 2,
				//rate: { 5.bilinrand * 3}.dup( rrand(1,4) ).midiratio,
				strum: rrand(0.03,0.1),
				out: ev.bus
			).play;
			1.0.wait;

			/// add mystery/misery pause!
			if (i.isPrime) {
				3.wait;
			}
		};
		"*** % looping ... \n".postf(thisTdef);
		2.wait;
	}
});
);