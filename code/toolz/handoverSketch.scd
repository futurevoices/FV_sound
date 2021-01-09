// stream handover sketch:
// 3 tdefs alternate, no repetition
// each one gets a fixed dur,
// when done, calls MFdef('nexT')
// to hand over to next one
/***** START WITH:
MFdef(\nexT).value;
****/
q = q ? ();

Tdef(\a).set(\myname, \a);
Tdef(\b).set(\myname, \b);
Tdef(\c).set(\myname, \c);

q.tdefs = [Tdef(\a), Tdef(\b), Tdef(\c) ];

(
Tdef(\a, { |ev|
	var myname = ev[\myname];
	var mytdef = Tdef(myname);
	var dura =  ev[\dura] ?? { exprand(10, 30) };
	var t0 = Main.elapsedTime;

	var sust;
	(degree: { rrand(0,16) }.dup(5), sustain: 0.1).play;

	while {
		Main.elapsedTime - t0 < dura
	} {
		var sust = rrand(2, 5);
		// these could be buffer players of different lengths
		(degree: rrand(0,16), sustain: sust).postln.play;
		sust.wait;
	};
	MFdef(\nexT).value(mytdef);
});

Tdef(\b, Tdef(\a).source);
Tdef(\c, Tdef(\a).source);
)

MFdef(\nexT).add(\next, { |lasttdef|
	var choices = q.tdefs.select(_ != lasttdef);
	var choice = choices.choose;
	var dura = exprand(10, 30).round;
	choice.set('dura', dura);
	"\n\n***   choices: %\n*** next: % plays for % sec.\n".postf(choices, choice, dura);
	choice.stop.play;
});

