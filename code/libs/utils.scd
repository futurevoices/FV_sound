// utilities for tdefs

///////////// lookup and stop
q.fvTdefs = { Tdef.all.select {|tdef| tdef.key.asString.beginsWith("fv_") } };
q.fvPdefs = { Pdef.all.select {|pdef| pdef.key.asString.beginsWith("fv_") } };
q.fvNdefs = { Ndef.dictFor(s).envir.values.select {|ndef|
	ndef.key.asString.beginsWith("fv_") and:
	ndef.monitor.isPlaying;
} };

// cleanup function as Tdef.
// So we can trigger it anywhere, anytime.
Tdef(\stopAll, {
	q.fvTdefs.do(_.stop);
	q.fvPdefs.do(_.stop);
	q.fvNdefs.do( _.end(5) );

}).quant_(0);

////// randseeding tdefs
q.tdefSeed = { |q, tdef|
	var defSeed;
	try { 0.1.wait };
	// get randSeed to repeat random choices exactly:
	defSeed = tdef.get(\randSeed);
	if (defSeed.notNil) {
		"// % randSeed is %\n".postf(tdef, defSeed.cs);
	};
	// if it is a number (and not e.g. a symbol), use the randSeed:
	if (defSeed.isNumber) { thisThread.randSeed = defSeed };
	defSeed
};

////// randseeding pdefs
q.pdefSeed = { |q, pdef|
	Plazy({
		// this reads the randSeed if the pdef has one set,
		// or else, because Pseed needs it, generates a new random randSeed
		var defSeed = pdef.get('randSeed') ?? { rand(20000000) };
		// could do logging here ...
		"// %: randSeed is %);\n".postf(pdef, defSeed.cs);
		defSeed
	})
};


///////////////////////////////////
/// make group and bus for each tdef:
q.tdefPrepNdef = { |q, tdef|
	// this is the bus the events play into:
	var evbus = tdef.get(\bus) ?? { Bus.audio(s, 2) };
	// make or get same-named Ndef that reads from that bus
	// so we have vol, can fadeout with .end, etc.
	// start ndef process, but don't play it yet
	var ndef = Ndef(tdef.key, { InFeedback.ar(evbus.index, 2) });
	// store back into event:
	tdef.set(\ndef, ndef);
	tdef.set(\bus, evbus);
	// and return ndef
	ndef;
};

////////////////////////////
//// sample blocks to prepload
MFdef('brazil').add(\prep, {
	if(q.brazil.isNil){
		forkIfNeeded {
			q.brazil = q.loadSamples(q.soundlibsPath +/+ "_BRAZILPERC");
			s.sync;
			"_BRAZILPERC loaded.".postln;
		}
	};
});

MFdef('hang').add(\prep, {
	if(q.hang.isNil){
		forkIfNeeded {
			q.hang = q.loadSamples(q.soundlibsPath +/+ "_Hang"); //
			s.sync;
			"_Hang loaded.".postln;
		}
	};
});


/////// send to website:
/*

// test sending  with local addr:

q.fvweb = NetAddr.localAddr;
MFdef(\setStatus).add(\post, { |kvlist| kvlist.postcs });

OSCdef(\fvweb, { |msg|
	"receiving \fvweb".postln;
	MFdef(\setStatus).value(msg.drop(1));
}, \fuvoStatus).permanent_(true);

q.fvweb.sendMsg(\fuvoStatus, \compos, \fv_bumpy, \entry, '2021-01-08-21-21-03_germany_de');
q.fvweb.sendMsg(\fuvoStatus, \compos, \fv_hangOn, \entry, '2021-01-08-21-21-03_germany_de');


////// TEST SENDING TO MEDIENHAUS:
q.fvweb.sendMsg(\fuvoStatus, \compos, \fv_bumpy, \entry, '2021-01-08-21-21-03_germany_de');
q.fvweb.sendMsg(\fuvoStatus, \compos, \fv_hangOn, \entry, '2021-01-08-21-21-03_germany_de');

MFdef(\sendInfo).value('2021-01-08-21-21-03_germany_de', \kont1);

MFdef(\sendInfo).value(
	q.mainDict.keys.choose.cs,
	q.fvTdefs.keys.cs
);
// q.fvTdefs:
Set[ 'fv_POLY', 'fv_bumpy', 'fv_lang_clusters', 'fv_kont_1', 'fv_stereoBattle', 'fv_listo', 'fv_hangOn', 'fv_grainbow' ]

*/

q.fvweb = NetAddr.localAddr;
(
q.home = "~".standardizePath.basename;
/// // turn it on for testing
q.home = "fuvo";

if ("fuvo" == q.home) {
	q.fvweb = NetAddr("gencomp.medienhaus.udk-berlin.de", 4242);

	MFdef(\sendInfo).add(\sendFVweb, { |entryKey, composKey|
		composKey = composKey ? try { q.activeTdef.key } ? 'silent?';
		try {
			// "sending to futurevoices website:".postln;
			// [\fuvoStatus, \compos, composKey, \entry, entryKey].postcs;
			q.fvweb.sendMsg(\fuvoStatus, \compos, composKey, \entry, entryKey);
		};
	});
};
);