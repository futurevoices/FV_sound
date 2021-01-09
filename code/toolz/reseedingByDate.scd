
/// reseeding by date:
(
MFdef(\dateSeed).add(\doit, {
	var date = Date.getDate;
	q.seed = (date.dayStamp ++ date.secStamp.keep(4)).postcs.interpret;
	"// reseeding q.seed: %\n".postf(q.seed);
	// reseeding the thread it is is, e.g. director
	thisThread.randSeed_(q.seed);
	q.seed
});

Tdef(\dir, {
	loop {
		var date, now, isClose, isAtZero;
		var remain = rrand(20, 50);
		"NEW TASK - running for % secs\n".postf(remain);

		while {
			date = Date.getDate;
			now = date.rawSeconds.round % 120;
			isClose = 120 - now < 30;
			isAtZero = now == 0;
			(remain > 0)
			or: isClose
			and: { isAtZero.not }
		} {
			if (isClose) {
				"close to the edge, waiting ...".postln;
			};
			if (isAtZero) { MFdef(\dateSeed).value };

			remain = remain - 1;
			"t: %\n".postf(remain);

			1.wait
		};
		1.wait;
	};
}).play;
)