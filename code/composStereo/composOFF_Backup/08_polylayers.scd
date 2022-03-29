//////// START 2-5 layers at once!

{
	//////// all necessary prep/checks go here:
	// .....

	////// then start the tdef:
	Tdef('fv_POLY').play
}.defer(0.2);

Tdef('fv_POLY').set(\randSeed, nil);
Tdef('fv_POLY').set(\timeRange, [21, 55]);

Tdef('fv_POLY', { |ev|
	var mykey = 'fv_POLY';
	var thisTdef = Tdef(mykey);
	var thisNdef, numTdefs;
	var director = Tdef(\director_FV);
	var dur;

	0.1.wait;
	thisNdef = q.tdefPrepNdef(thisTdef);

	"\n*** % starts ***\n\n".postf(thisTdef);
	q.tdefSeed(thisTdef);

	numTdefs = rrand(2, 4);

	dur = (director.get(\remainTime) / numTdefs).round.postln;
	director.set(\remainTime, dur);

	q.composChoices.scramble.keep(numTdefs).do { |path|
		path.basename.postcs;
		path.load;
	};
});
