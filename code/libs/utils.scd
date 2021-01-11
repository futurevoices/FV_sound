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
	var ndef = Ndef(tdef.key);
	var evbus = tdef.get(\bus);
	ndef.ar(2);
	tdef.set(\ndef, ndef);
	// make a separate bus to play events to ...
	evbus = evbus ?? { Bus.audio(s, 2) };
	tdef.set(\bus, evbus);
	// in the Ndef, read from evbus, so fadeout with .end works:
	Ndef(tdef.key).prime({ InFeedback.ar(evbus.index, 2) });
	ndef;
};

////////////////////////////
//// sample blocks to prepload
MFdef('brazil').add(\prep, {
	if(q.brazil.isNil){
		forkIfNeeded {
			q.brazil = q.loadSamples(q.soundlibsPath +/+ "_BRAZILPERC");
		}
	};

});
MFdef('hang').add(\prep, {
	if(q.hang.isNil){
		forkIfNeeded {
			q.hang = q.loadSamples(q.soundlibsPath +/+ "_Hang"); //
		}
	};
});


/////// send to website:

q.home = "~".standardizePath.basename;
/// // turn it on for testing
// q.home = "fuvo";
/*
// test sending:
q.fvweb = NetAddr("gencomp.medienhaus.udk-berlin.de", 2222);
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

if ("fuvo" == q.home) {
	q.fvweb = NetAddr("gencomp.medienhaus.udk-berlin.de", 4242);

	MFdef(\sendInfo).add(\sendFVweb, { |entryKey, compos|
		// "sending to futurevoices website:".postln;
		compos = compos ? try { q.activeTdef.key } ? 'silent?';
		try {
			[\fuvoStatus, \compos, compos, \entry, entryKey].postcs;
			q.fvweb.sendMsg(\fuvoStatus, \compos, compos, \entry, entryKey);
		};
	});
};
