// ==========================================================
// ==========================================================
// function definitions for yaml parsing

// ==========================================================
// ==========================================================
// sorter function
(
// assumes patienceDict existing.
q.sorterRecursive = {|ev, sortKey, sortFunc|

	var recursiveRetrieve = {|d, k|
		var levels = k.asString.split($.);
		var numLevels = levels.size;
		if(numLevels > 1){
			d = recursiveRetrieve.(d[levels.first.asSymbol], levels.drop(1).join($.) );
		}{
			d[k.asSymbol]
		};
	};

	var order = q.patienceDict.values.collect({|d|
		var val = recursiveRetrieve.(d, sortKey);
		[val, d.name];
	})
	.reject({|l| l[0].isNil}) // empty cells need to be rejected = thrown out!
	.sort(sortFunc ? {|a,b| a[0] < b[0]});

	var return = order.collect{|pair| q.patienceDict[pair[1]] };
	return      //a list of the single dicts in the sorted order
});
/*
q.sorterRecursive( 'literal_text' ); // 1 level
q.sorterRecursive( 'speaker.age' );  // 2 level
q.sorterRecursive( 'location.coordinates.lat' );  // 3 levels
q.sorterRecursive( 'location.coordinates.long' ).collect(_.buf); // all the buffers in this order
*/

(
q.dictToEvent = {|q, dict, event|
	if(event.isKindOf(Event).not){ "please provide an Event as input arg".warn}{
		dict.keysValuesDo{|k,v|
			if(v.isKindOf(Dictionary)){
				event.put(k.asSymbol, q.dictToEvent(v, () ) );
			}{
				event.put(k.asSymbol, v);
			}
		};
		event;
	}
};
// turn any empty strings into nils
q.emptyStringsToNils = {|q, event|
	if(event.isKindOf(Event).not){ "please provide an Event as input arg".warn}{
		event.keysValuesDo{|k,v|
			if(v.isKindOf(String) and: {v.isEmpty}){ v = event.put(k, nil) };
			if(v.isKindOf(Event)){ v = q.emptyStringsToNils(v) };
		};
		event
	}
};

// turn any numerical values into numbers (int or float)
q.numerifyVals = {|q, event|
	if(event.isKindOf(Event).not){ "please provide an Event as input arg".warn}{
		event.keysValuesDo{|k, v|

			// special case for new age ranges!
			if( k == \age and: {v.asString.contains(" - ")})
			{
				var val = v.split($-).first.interpret + 9.rand; // some random spread
				event.put(k, val)
			};

			if(v.isKindOf(String) and:
				{v.every({|char| char.isDecDigit or: {".-".contains(char)} })}){ v = event.put(k, v.interpret) }; // neg vals and floats do pass!!

			if(v.isKindOf(Event)){ v = q.numerifyVals(v) }; // recurs.
		};
		event
	}
};

// requires q.voiceDict  to be loaded
q.addBuffer = {|q, event|
	if(q.voiceDict.isNil){"voiceDict not loaded!!".warn;}{
		if(event.isKindOf(Event).not){ "please provide an Event as input arg".warn; }{
			// var key =    d.filename.split($.).first.toLower.asSymbol;
			var bufKey = event.name; // PathName(d.filename).fileNameWithoutExtension.toLower.asSymbol;
			var buf = q.voiceDict.at(bufKey);
			if(buf.notNil and: { buf.sampleRate.notNil } ){
				event.put(\buf, buf);
				event.put(\dur, buf.duration);
			};
			event
		}
	}
};

/////////// ORIG:
////// func to harvest 1 yaml
// q.readYaml = {|ev, path|
//
// 	var filename = PathName(path).fileNameWithoutExtension;
// 	var defaultPath = q.bufPath +/+ "_template.yaml";
// 	var individualPath = q.bufPath +/+ filename ++ ".yaml";
// 	var defaulz, myPath = if(individualPath.postcln.pathMatch.notEmpty)
// 	{defaulz=false; individualPath}
// 	{defaulz=true; defaultPath};
//
// 	var id = myPath.standardizePath.parseYAMLFile;
// 	d = q.dictToEvent(id, () );
// 	d.put(\name, filename.toLower.asSymbol);
// 	d.put(\filename, filename.toLower.asSymbol);
// 	d = q.emptyStringsToNils(d);
// 	d = q.numerifyVals(d);
// 	d = q.addBuffer(d);      // find Buffer previously loaded
// 	d
// };

//////// TRY FIX: FAILED YAML complains, but continues
//////// return either a valid dict, or nil
/////// - filter nils where q.readYaml is used!
q.readYaml = {|ev, path|

	var d = ();
	var filename = PathName(path).fileNameWithoutExtension;
	var defaultPath = q.bufPath +/+ "_template.yaml";
	var individualPath = q.bufPath +/+ filename ++ ".yaml";
	var defaulz, myPath = if(individualPath.pathMatch.notEmpty)
	{defaulz=false; individualPath}
	{defaulz=true; defaultPath};

	var id = try { myPath.standardizePath.parseYAMLFile } {
		"\n\n\n*** YAML FILE FAILS: \n%\n\n\n\n".postf(path.cs ++ ".openOS;");
		// path.openOS;
		id = nil;
	};

	if (id.notNil) {
		d = q.dictToEvent(id, () );
		d.put(\name, filename.toLower.asSymbol);
		d.put(\filename, filename.toLower.asSymbol);
		d = q.emptyStringsToNils(d);
		d = q.numerifyVals(d);
		///// find Buffer previously loaded
		///// FIXME - better not to load all buffers on startup!
		d = q.addBuffer(d);
		d;
	} {
		// return nil if failed
		nil
	};
};



// ==========================================================
// ==========================================================
// e.o.functions;
);
