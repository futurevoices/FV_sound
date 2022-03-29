"*** FutureVoices default startupfile : ***
// * play 2 channels for 24/7 webstream
// * Seafile sounds / database folders
// * exclusive mode: always kill all servers and reboot?
\n\n".postln;

// make a global container
q = q ? ();
// and inside it, one for everything futurevoices
q.fuvo = q.fuvo ? ();

// minimum settings for the server:
q.fuvo.server = (
	numInputBusChannels: 0,
	numOutputBusChannels: 2,
	// minimum realtime memory for delay lines etc:
	memSize: 8192 * 16,
	///// set audio hardware to use?
	// device: "playaudio 12"
);
/***
// compare with current server options:
s.options.dump;
***/


// Global things to know about the computer platform
// - can override these here for testing,
// defaults woill be added in loadMe files

// Do we have GUI classes present?
// when headless platform (webserver, raspi lite ...),
// dont load any gui code
q.hasGui = \View.asClass.notNil;

// Do we have a local Seafile dir for the default file locations?
q.seafileDir = "~/Seafile/";

//// global settings for FuVo ////
// should FuVo run exclusively on this machine?
// // if true, always kill all servers, then reboot my server:
// q.fuvo.doReboot = true;
// // for loading into an existing setup, dont:
q.fuvo.doReboot = false;

// // make my own MainFX? yes on free-standing ones,
// q.fuvo.makeMainFX = true;
// // probably no when loading into existing setup
q.fuvo.makeMainFX = false;


////// set the paths of soundfiles, database, compositions
"*** Future Voices paths - found? ***".postln;
// use Seafile Future_Voices dir:
q.fuvo.dir = q.seafileDir +/+ "Future_Voices";
// // to use the fuvo quark directory, do this:
// q.fuvo.dir = Quarks.folder +/+ "FV_sound";

q.fuvo.codeDir = q.fuvo.dir +/+ "code";
q.fuvo.loadMePath = q.fuvo.codeDir +/+ "_00_loadMe_FV.scd";

// // uncomment the compositions folder to load:
q.fuvo.composPath = q.fuvo.codeDir +/+ "composStereo/*_fv_*.scd";
// q.fuvo.composPath = q.fuvo.codeDir +/+ "composDearJ";
// q.fuvo.composPath = q.fuvo.codeDir +/+ "composMulti10";

// the soundfile database and sounds dirs:
q.fuvo.soundsDir = q.seafileDir +/+ "future_soundz";
q.fuvo.dbDir = q.seafileDir +/+ "future_mirror";

// post the paths used for clarity
q.seafileDir.pathMatch.post.notEmpty.postln;
q.fuvo.dir.pathMatch.post.notEmpty.postln;
q.fuvo.codeDir.pathMatch.post.notEmpty.postln;
q.fuvo.loadMePath.pathMatch.post.notEmpty.postln;
q.fuvo.soundsDir.pathMatch.post.notEmpty.postln;
q.fuvo.dbDir.pathMatch.post.notEmpty.postln;
q.fuvo.composPath.dirname.post.notEmpty.postln;

q.fuvo.loadMePath.loadPaths;

