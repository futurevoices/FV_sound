/* sync text via network */
// who's in?
// sani in
// fang in:)
// hh in
// hjk in
// fang again?????????this is fang ~~~~~~~~~~~
//
/*

~router.peers;

s.volume.gui


////  examples

[[1, 2, 3], [10, 11, 12]].flop.flat.clump(2);

a = (a:0);
b = (b:10);
a.putAll(b);
a.sect(b);

a = (a:0, z: 100, m: 50);
a.class;
a.dump;
a.keys;
a.values;

//// end examples

var i = 0;
var j = 0;
[-1, 1].wrapAt(j + i)

(j + i):
[0, 1]
[1, 2]
[2, 3]

*/


MFdef('fv_fangTest').add(\prep, {
	// PREP: make sure perc and brazil are there:
	// load brazil samples if not there
	MFdef(\brazil).value;
	// load hang samples if not there
	MFdef(\hang).value;
});

///// this is the Tdef that plays
(
// make sure tdef starts instantly:
Tdef('fv_fangTest').quant = 0;
// and stop first in case it is running
Tdef('fv_fangTest').stop.play;

Tdef( 'fv_fangTest' , { |ev|

	///////////////// general preparation, same for all Tdefs:
	// set my name
	var mykey = 'fv_fangTest';
	// set my tdef
	var thisTdef = Tdef(mykey);
	// make or find my ndef and bus to play events to
	var thisNdef = q.tdefPrepNdef(thisTdef);
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

		// q.mainDict.select keyword in maindict that has the word "hope"

		/*
		var filter = q.mainDict.select({|entryDict|
		entryDict.keywords.includesEqual("hope");
		});
		*/

		var filterKo = q.mainDict.select({|entryDict|
			[\ko].includes(entryDict.langKey);
		});

		var filterJa = q.mainDict.select({|entryDict|
			[\ja].includes(entryDict.langKey);
		});

		var filterZh = q.mainDict.select({|entryDict|
			[\zh].includes(entryDict.langKey);
		});

		var pairsAsia = [filterKo.values, filterZh.values].flop.flat.clump(2);


		myEntries = ().putAll(filterKo).putAll(filterJa).putAll(filterZh);


		//see how many files are picked
		pairsAsia.size;

		//assign these Entries to be played
		myEntries = q.bufmem.filterDict(myEntries);
		// filter recent buffers from selection
		// myEntries = q.bufmem.filterDict(myEntries);
		// post how many items we have:
		"myEntries size: %\n".postf(myEntries.size);

		// convert myEntries to array (values)
		// and scramble for random order;
		// then do the same for each one:
		pairsAsia.do {|entryDictPair, i|
			// choose a hang perc sound to use
			var hangbuf = q.hang.wrapAt(i);
			// choose a brazil perc sound to use
			var percbuf = q.brazil.wrapAt(i + (0.. 3.linrand));

			// load soundfile from entry into buffer:
			var bufs = entryDictPair.collect{ |entryDict, j|
				var buf = q.readBufToDict(entryDict).buf;
				// tell buffer memory we used this file,
				// so we can avoid repeating it too soon:
				q.bufmem.addKey(entryDict.name);

				// send info to the stream website for visualising ...
				// or anyone else who is interested
				MFdef(\sendInfo).value(entryDict.name, q.activeTdef.key);

				if(buf.notNil){
					// play the entry soundfile buffer,
					// as it is:
					(instrument: \simpsamp,
						buf: buf,
						amp: 0.5,
						pan: [-1, 1].wrapAt(j + i), // alternating panning!-) this is cool and easy!
						sustain: buf.duration,
						out: ev.bus
					).play;
					([0, buf.duration][j]).wait; // if left one is longer, we will get overlap
				};
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
		///////////(finishing) post that we reached the end of this round
		"*** % looping ... \n".postf(thisTdef);
		// and safety wait for the loop:
		// if myChoices is always empty,
		// loop waits to avoid lockup crash!
		1.wait;
	}
});
);
