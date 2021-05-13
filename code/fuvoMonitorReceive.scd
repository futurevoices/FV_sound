/*** Future Voices Installation Monitor:

SENDER SIDE:
--> to run at DLF house and on gencomp stream source:
- watch that we have sound output
- send last n vol values to OSCRouter
- optionally plot locally for visual monitoring
- if vol too low too long, try restarting

RECEIVER:
--> whoever is on duty to watch that the streams are running
- receive amps remotely
- check whether piece is alive
- if yes, do nothing
- if NO, SCREAM for help!
****/


/////////// receiver side:
(
// OSCRouter
q = q ? ();
q.fuvo = q.fuvo ? ();
q.fuvo.senders = q.fuvo.senders ? ();

q.fuvo.recvName = (unixCmdGetStdOut("whoami").select(_.isAlphaNum) ++ "_listen").asSymbol;
q.fuvo.oscar = OSCRouterClient(q.fuvo.recvName, \fuvo, "gencomp.medienhaus.udk-berlin.de");
q.fuvo.oscar.join;

q.fuvo.oscar.peers.postln;

q.fuvo.win = Window("fuvo_remotes").front;
q.fuvo.win.addFlowLayout;
q.fuvo.plot1Name = StaticText(q.fuvo.win, 400@20).string_("gencomp");
q.fuvo.plot1 = Plotter("gencomp", (400@180).asRect, q.fuvo.win);
q.fuvo.plot1.value_((0.0, 0.1 ..1.0));

/*
OSCdef(\fuvoMonitor).disable;
q.fuvo.senders.choose.recvAmps.fill(0);
*/

OSCdef(\fuvoMonitor, { |msg|
	var senderName = msg[1];
	var mydict = q.fuvo.senders[senderName] ?? {()};
	q.fuvo.senders[senderName] = mydict;

	mydict.prevRecvTime = mydict.lastRecvTime;
	mydict.lastRecvTime = Main.elapsedTime.round(0.001);
	mydict.prevAmps = mydict.recvAmps;
	mydict.recvAmps = msg.drop(2).round(0.001);
	if (mydict.plotta.isNil) {
		defer { q.fuvo.addPlotta(senderName) };
	};
}, \fuvoAlive).permanent_(true);

MFdef(\fuvoAliveCheck).value;

// // dict for my test sending machine:
// q.fuvo[\adc].keys;

q.fuvo.skipCheck.stop;
q.fuvo.skipCheck = SkipJack(MFdef(\fuvoAliveCheck), 1.0, name: \fuvoAlive);

/*
OSCdef(\fuvoMonitor).disable;
OSCdef(\fuvoMonitor).enable;

q.fuvo.keys
*/

// optional : plotting
q.fuvo.addPlotta = { |fuvo, sendaName|
	var senDict = q.fuvo.senders[sendaName];
	var plotta = senDict.recvAmps.plot(
		sendaName ++ "_fuvo_last60sec",
		minval: 0, maxval: 1);
	plotta.findSpecs = false;
	senDict.put(\plotta, plotta);
};

/*
q.fuvo.addPlotta(q.fuvo.senders.keys.choose);
*/

MFdef(\fuvoAliveCheck).add(\updatePlot, {
	defer {
		q.fuvo.senders.do { |senderDict|
			var plotta = senderDict.plotta;
			plotta !? { plotta.value = senderDict.recvAmps };
		};
	}
});


MFdef(\fuvoAliveCheck).add(\alarm, {
	q.fuvo.senders.do { |senderDict, senderName|
		// if no new data for too long -> ALARM
		if (Main.elapsedTime - senderDict.lastRecvTime > 5) {
			MFdef(\fuvoWarn).value(
				"Future Voices:\n%\nNO DATA FOR > 5 sec!".format(senderName)
			)
		} {
			// if too silent for too long
			if (senderDict.recvAmps.keep(-10).sum < 0.01) {
				MFdef(\fuvoWarn).value(
					"Future Voices:\n%\nVOL TOO LOW for 10 sec!".format(senderName)
				)
			}
		}
	}
});

MFdef(\fuvoWarn).add('win', { |warnText|
	defer {
		var win = Window.find("fuvoWarn") ?? {
			Window("fuvoWarn").front;
		};
		win.front;
		win.drawFunc = {
			Pen.stringCenteredIn(
				warnText.postln ++ "\n" ++ Date.getDate,
				win.view.bounds,
				Font(Font.defaultMonoFace, 24)
			)
		};
		win.refresh;
	}
});
);