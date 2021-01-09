// ==========================================================
// ==========================================================
/*****

*****/

(
q=q?(); // just a space to stor variables



// audio server must be booted:
//	s.waitForBoot{ // assume booted!

// better test: if size of Dict would be the same... else, it's time for [freeing all old bufs and] update.

q.bufPath = q.bufPath ? "~/Seafile/JaMoP/upload/".standardizePath; // as in Buffers !
q.yamlPaths = (q.bufPath +/+ "*.yaml").pathMatch;

/*	q.patienceDict.size;
q.yamlPaths.size;
q.voiceBufs.size; // more*/



if( q.patienceDict.isNil or:
	{ q.patienceDict.size < q.findSamples("contributions", q.bufPath.dirname).size }
){ // load only if not loaded yet..

	// ==========================================================
	// ==========================================================
	// then, load all Buffers
	try{ q.voiceBufs.do(_.free) };   // empty, just in case they have been loaded already...
	s.sync;
	q.voiceBufs = q.loadSamples("contributions", q.bufPath.dirname); // load 'em
	s.sync;
	q.voiceBufs.do(_.normalize); // same gain for all
	// turn into dictionary for better availability. All keys are Symbols, lowercase;
	q.voiceDict = q.sampDict(q.voiceBufs);


	// ==========================================================
	// ==========================================================
	// now, load all metadata



	// ==========================================================
	// ==========================================================
	// harvest all yamls into Dict:
	q.patienceDict = ();
	// load a dict FOR EACH LOADED BUFFER !
	q.voiceBufs.do{|buf, i|
		var d = q.readYaml(buf.path);

		if (d.notNil) {
			q.patienceDict.put(d.name, d);
		} {
			"\n\n*** NO YAML found for soundfile %!\n\n\n".postf( buf.path);
		};
	};

	q.patienceDict.keys;
	"\n\n*** Success loading % voice buffers. \n\n".postf(q.voiceBufs.size);
	"*** Success loading % complete data sets into \n q.patienceDict;\n \n\n".postf(q.patienceDict.size);


}{
	"\n\n*** % complete data sets were already loaded into \n q.patienceDict;\n \n\n".postf(q.patienceDict.size);
}

);
