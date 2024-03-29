(
Tdef(\testAll).set(\episodeTime, 20);
Tdef(\testAll).set(\remainTime, 20);
Tdef(\testAll).set(\speedup, 1);

Tdef(\testAll).addSpec(\episodeTime, [8, 72, \exp, 0.1]);
Tdef(\testAll).addSpec(\remainTime, [20, 0, \lin, 1]);
Tdef(\testAll).addSpec(\speedup, [1, 30, \exp, 0.1]);

Tdef(\testAll, { |ev|

	Tdef(\stopAll).stop.play;
	Tdef(\jingleDir).embed;

	q.composChoices = q.fuvo.composPath.pathMatch;

	q.composChoices.do { |compos|
		var activeTdef;
		q.chosenFile = compos;

		Tdef(\stopAll).stop.play;

		1.wait;

		"\n\n*** starting composition %\n".postf(q.chosenFile.basename);

		"*** plays for % seconds \n\n".postf(ev.episodeTime.round(1));

		activeTdef = q.chosenFile.load; // load and play!
		activeTdef.postln.set(\randSeed, 10000.rand);
		q.activeTdef = activeTdef;

		Tdef(\testAll).addSpec(\remainTime, [ev.episodeTime, 0, \lin, 0.01]);
		ev.remainTime = ev.episodeTime;

		while { ev.remainTime >= 0 } {
			ev.remainTime = ev.remainTime - 1;
			(1/ev.speedup).wait;
		};

		"\n\n*** ending composition %\n\n".postf(q.chosenFile.basename)

		// then go back to top, and stopAll
	};

	Tdef(\stopAll).stop.play;
	"*** Tdef('testAll') DONE!".postln;
});
);