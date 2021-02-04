////// this is a copy of the hangOn composition,
/// commented as a full example of the schema for FV compositions.


// this function runs when compos starts;
// if needed, it prepares things that the compos needs:
// load buffers, load data,
// make Ndefs that play background sounds etc etc

MFdef('fv_example').add(\prep, {
	// PREP: make sure perc and brazil are there:
	// load brazil samples if not there
	MFdef(\brazil).value;
	// load hang samples if not there
	MFdef(\hang).value;
});

///// this is the Tdef that plays
(
// make sure tdef starts instantly:
Tdef('fv_example').quant = 0;
// and stop first in case it is running
Tdef('fv_example').stop.play;

Tdef( 'fv_example' , { |ev|

	///////////////// general preparation, same for all Tdefs:
	// set my name
	var mykey = 'fv_example';
	// set my tdef
	var thisTdef = Tdef(mykey);
	// make or find my ndef and bus to play events to
	var thisNdef = q.tdefPrepNdef(thisTdef);
	// know my starting time:
	var time0 = Main.elapsedTime;

	// run my prep func:
	MFdef(mykey).value;

	"\n*** % starts ***\n\n".postf(thisTdef);
	// wait a little ...
	0.1.wait;
	// so seed set from outside can be used when Tdef runs:
	q.tdefSeed(thisTdef);

	// wait some more, just to be safe ...
	0.1.wait;
	// play my listening sound
	thisNdef.play(fadeTime: 0.1);

	////////// this part is different for every composition:
	//////// how to choose which contributions?
	//////// which other sounds to go along?
	//////// loop to run forever (potentially)
	////////
	loop {
		// choose my selection of entries:
		// could be selected from full database,
		// by mood, topic/keyword/tag/language ...
		var myEntries = q.mainDict;
		// filter recent buffers from selection
		myEntries = q.bufmem.filterDict(myEntries);
		// post how many items we have:
		"myEntries size: %\n".postf(myEntries.size);

		// convert myEntries to array (values)
		// and scramble for random order;
		// then do the same for each one:
		myEntries.values.scramble.do {|entryDict, i|
			// choose a hang perc sound to use
			var hangbuf = q.hang.wrapAt(i);
			// choose a brazil perc sound to use
			var percbuf = q.brazil.wrapAt(i + (0.. 3.linrand));

			var buf;
			// compTdef, startedTime, plannedDur, projected next dur
			MFdef(\adjustTime).value(thisTdef, time0, ev.chosenDur, entryDict.dur);

			// load soundfile from entry into buffer:
			buf = q.readBufToDict(entryDict).buf;
			// tell buffer memory we used this file,
			// so we can avoid repeating it too soon:
			q.bufmem.addKey(entryDict.name);

			// send info to the stream website for visualising ...
			// or anyone else who is interested
			MFdef(\sendInfo).value(entryDict.name, q.activeTdef.key);

			if(buf.notNil){
				////// example for an extra
				// play a hang sample as a phrase:
				// time offsets and different pitches
				(instrument: \simpsamp,
					buf: hangbuf,
					amp: 0.25, pan: -1.0.rand2,
					sustain: hangbuf.duration,
					rate: { 5.bilinrand * 2 }.dup(rrand(3, 7) ).midiratio,
					strum: rrand(0.03, 0.3),
					out: ev.bus
				).play;

				// wait for hang samples to end
				(hangbuf.duration).wait;
				// and a bit more:
				(exprand(0.2, 1)).wait;

				// play the entry soundfile buffer,
				// as it is:
				(instrument: \simpsamp,
					buf: buf,
					amp: 0.5, pan: 0,
					sustain: buf.duration,
					out: ev.bus
				).play;
				(buf.duration).wait;
			};

			// play a single perc sample,
			//just once if no list for rates
			(instrument: \simpsamp,
				buf: percbuf,
				amp: 0.25, pan: 0.5.rand2,
				sustain: 2,
				//rate: { 5.bilinrand * 3}.dup( rrand(1,4) ).midiratio,
				strum: rrand(0.03,0.1),
				out: ev.bus
			).play;
			// wait for end of perc sound
		 	1.0.wait;

			/// and sometimes,
			//	make an extra mystery/misery pause!
			if (i.isPrime) {
				3.wait;
			}
		};

		///////// post that we reached the end of this round
		"*** % looping ... \n".postf(thisTdef);
		// and safety wait for the loop:
		// if myChoices is always empty,
		// loop waits to avoid lockup crash!
		1.wait;
	}
});
);