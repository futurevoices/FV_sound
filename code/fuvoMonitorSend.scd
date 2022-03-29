/*** Future Voices Installation Monitor:

/*
// toggle sending:
MFdef(\senderFunc).disable(\sendOscar);
MFdef(\senderFunc).enable(\sendOscar);

MFdef(\senderPlot).value;
// toggle sender plotting
MFdef(\senderFunc).disable(\plot);
MFdef(\senderFunc).enable(\plot);
*/

SENDER SIDE:
--> to run on computer in radio DLF house, and on gencomp stream generator (at adc):
- watch that we have sound output
- send last n volume values to OSCRouter
- optionally plot locally for visual monitoring
- if vol too low for too long, try restarting

// TODO:
// lazarus shell scripts, esp. Paris - in SC
if sound output is silent, try restarting FV_director
if server dead, try rebooting it
in shell: if pgrep sclang is nil, kill SuperCollider and restart it

RECEIVER:
--> whoever is on duty to watch that the streams are running
- receive amps remotely
- check whether piece is alive
- if yes, do nothing
- if NO, SCREAM for help!
****/

(
///// SENDER ONLY:
// OSCRouter
q.fuvo = q.fuvo ? ();
q.fuvo.senderName = Platform.userHomeDir.basename.asSymbol;
q.fuvo.oscar = OSCRouterClient(q.fuvo.senderName, \fuvo, "gencomp.medienhaus.udk-berlin.de");
q.fuvo.oscar.join;

// load setup once server is booted and ready:
ServerTree.add(MFdef(\fuvoMonSend), s);

MFdef(\fuvoMonSend).add(\setup, {
	// control proxy that reads current main output
	Ndef(\fuvoMon, {
		var peax = PeakFollower.ar(InFeedback.ar(0, 2), 0.9999);
		A2K.kr(peax.reduce(\max));
	});

	q.fuvo.skipSend.stop;
	q.fuvo.skipSend = SkipJack(MFdef(\senderFunc), 1.0, name: \fuvo);

	// keep a minute of amp value values, init with ramp
	q.fuvo.recentAmps = Array.geom(60, 0.8, 0.95).round(0.001);
	q.fuvo.serverDownTime = 0;

	MFdef(\senderFunc).add(\serverAlive, {
		if (s.serverRunning) {
			q.fuvo.serverDownTime = 0;
		} {
			q.fuvo.serverDownTime = q.fuvo.serverDownTime + 1;
			if (q.fuvo.serverDownTime > 10) {
				"*** SERVER DOWN - REBOOTING!".postln;
				q.fuvo.serverDownTime = 0;
				forkIfNeeded {
					Server.killAll;
					2.wait;
					s.boot;
				};
			}
		}
	});

	MFdef(\senderFunc).add(\getAmps, {
		var newAmp;
		if (s.serverRunning) {
			try {
				newAmp = Ndef(\fuvoMon).bus.getSynchronous.round(0.001);
				q.fuvo.recentAmps =
				q.fuvo.recentAmps.rotate(-1).putLast(newAmp);
				newAmp;

				// if too silent, restart FV_director:
				if (q.fuvo.recentAmps.keep(-10).sum < 0.01) {
					"*** VOL TOO LOW - restarting director_FV".postln;
					q.fuvo.recentAmps.putLast(1);
					Tdef(\director_FV).stop.play;
				};
			};
		}
	});

	MFdef(\senderFunc).add(\sendOscar, {
		q.fuvo.oscar.sendMsg(\fuvoAlive,
			q.fuvo.senderName,
			*q.fuvo.recentAmps
		);
	});

	MFdef(\senderPlot).add(\makePlot, {
		// optional on sender side: plotting
		q.fuvo.plotta = q.fuvo.recentAmps.plot(\lastMinute, minval: 0, maxval: 1);
		q.fuvo.plotta.findSpecs = false;
		MFdef(\senderFunc).add(\plot, {
			defer { q.fuvo.plotta.value = q.fuvo.recentAmps };
		});
	});
});

if (s.serverRunning) {
	MFdef(\fuvoMonSend).value
};
)
