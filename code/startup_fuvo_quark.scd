"*** FUTURE VOICES / ZUKUNFTSMUSIK FV_Sound starting up - quark. ***".postln;


/**** Example startup file for Future Voices when installed as quark. ***/

/*
NOTE: This quark needs two soundfile repositories to be in place:
future_mirror/ // the current soundfile database
future_soundz/  // the basic percussion and jingle soundfiles used.

The should both be in the default Seafile folder:
"~/Seafile/future_mirror".pathMatch
"~/Seafile/future_soundz".pathMatch

// test Quark healthyness:
Quarks.at("FV_sound"); // quark should be found and post
// -> Quark: FV_sound[...<long ID number>]
*/

// if OK, enable this line by uncommenting:
// (Quarks.folder +/+ "FV_sound/code/_00_loadMe_FV.scd").loadPaths;

//// If you use the StartupFile quark, put this file here:
/*
StartupFile.openDir
// and run this line to select it as startup:
StartupFile.dialog

// If not, copy the file to
Platform.userAppSupportDir;
// and rename the file there to:
startup.scd

// recompile ... and FV should start!
*/

///// if running as online stream generator,
///// enable this to send remote monitoring info:
// s.doWhenBooted {
// 	defer ({
// 		(Quarks.folder +/+ "futurevoices/code/fuvoMonitorSend.scd"
// 		).loadPaths;
// 	}, 5)
// };
