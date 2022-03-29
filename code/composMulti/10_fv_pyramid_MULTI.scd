/* pyramid of many voices piling up:
choose lots of entries, sort by duration,
play longest first, shortest last, overlapping, so longest ends last.
stagger times so that last voice begins at peakTime (0-1) of longest time:
is the time at which all soundfiles play;
0.0 means all voices start at beginning, slow ramp down,
0.5 means densest point in the middle,
1.0 means ramp up until the end.
timeWarp: 0 means ramp is linear,
-1 means ramp begins slow and speeds up
1 means ramp starts fast and then adds up slower

*/

MFdef('fv_pyramid').add(\prep, {
	// nothing needed
});

///// this is the Tdef that plays
(

// make sure tdef starts instantly:
Tdef('fv_pyramid').quant = 0;
// and stop first in case it is running
Tdef('fv_pyramid').stop.play;
Tdef('fv_pyramid').set(\chosenDur, 120);
Tdef('fv_pyramid').set(\randSeed, nil);

Tdef('fv_pyramid').addSpec(\numEntries, [10, q.mainDict.size, \lin, 1]);
Tdef('fv_pyramid').addSpec(\peakTime, [0, 1]);
Tdef('fv_pyramid').addSpec(\timeWarp, [-2, 2]); // start slow, end fast


Tdef('fv_pyramid').set(\numEntries, 100);
Tdef('fv_pyramid').set(\peakTime, 0.8);
Tdef('fv_pyramid').set(\timeWarp, -1); // start slow, end fast

Tdef( 'fv_pyramid' , { |ev|

	// general preparation: set my name
	var mykey = 'fv_pyramid';
	var thisTdef = Tdef(mykey);
	var thisNdef = q.tdefPrepNdef(thisTdef);
	var time0 = Main.elapsedTime;
	var timeSoFar, myRemainTime;
	MFdef(mykey).value;

	"\n*** % starts ***\n\n".postf(thisTdef);
	0.1.wait;
	q.tdefSeed(thisTdef);
	0.1.wait;
	thisNdef.play(fadeTime: 0.1);


	/////// BODY OF this composition:
	inf.do {
		/////// fixed here:
		var numEntries = ev.numEntries min: q.mainDict.size;
		var myChoices = q.mainDict.values.scramble.keep(numEntries)
		.sort { |a,b| a.dur > b.dur };
		var timecurve = (0 .. numEntries - 1).normalize ** (2 ** ev.timeWarp);
		var times = (timecurve * myChoices[0].dur * ev.peakTime).round(0.01);
		var waittimes = times.differentiate;
		var endtimes = times.collect { |time, i|
			time + myChoices[i].dur };
		var lastendtime = endtimes.maxItem;

		var introbuf = q.brazil.choose;

		//
		(instrument: \simpsamp, amp: 0.4,
			buf: introbuf,
			rate: [-1, 1],
			pan: [-1, 1].scramble,
			out: ev.bus.index
		).play;
		introbuf.duration.wait;

		// compTdef, startedTime, intendedDur, projected next dur
		MFdef(\adjustTime).value(thisTdef, time0, ev.chosenDur, lastendtime);

		// defer { waittimes.plot };
		// waittimes.postln;

		times.differentiate.do { |time, i|
			var entry = myChoices[i];
			// readbuf takes time, so this slows the ramps down
			// maybe get next buffer first, givedefer it,
			fork { q.readBufToDict(entry) };
			fork ({
				0.5.wait;
				(instrument: \simpsamp, buf: entry.buf,
					amp: 0.3, pan: 1.0.rand2,
					// out: ev.bus.index
					out: 10.rand
				).play;
			});
			time.wait;
		};
		// how to wait until longest has ended?
		(lastendtime - times.last).postln.wait;

		// general end of loop, with safety wait for empty choices:
		"*** % looping ... \n".postf(thisTdef);
		1.wait;
		};

});
)