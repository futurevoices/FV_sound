"*** FUTURE VOICES / ZUKUNFTSMUSIK starting up. ***".postln;

/*
// maybe it is in a private repo?
"~/src/futurevoices/code/_FV_director.scd".loadPaths;
// if checked out as quark, it is here:

Quarks.at("futurevoices");

// still not working everywhere:
Quarks.at("futurevoices").update;

Quarks.at("futurevoices").localPath.openOS;
// -> delete by hand ... then reinstall:
Quarks.install("https://github.com/adcxyz/futurevoices");

*/

// startup from downloaded quark:
(Quarks.folder +/+ "futurevoices/code/_FV_director.scd").loadPaths;


// // open this file?
// thisProcess.nowExecutingPath.openOS;

///// if running as online stream generator,
///// enable this to send remote monitoring info:
// s.doWhenBooted {
// 	defer ({
// 		(Quarks.folder +/+ "futurevoices/code/fuvoMonitorSend.scd"
// 		).loadPaths;
// 	}, 5)
// };
