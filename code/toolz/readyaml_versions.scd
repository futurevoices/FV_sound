[\Hana, \Zihern, \HH, \adc, \oez, \kk, \andre, \marcel ] .size


q.readYaml_adc("/Users/adc/Seafile/Future_Voices/upload/contributions/*KEN.yaml".pathMatch.first);

q.readYamlOrig("/Users/adc/Seafile/Future_Voices/upload/contributions/2020_12_08_FV_adel.yaml");
q.readYaml_adc("/Users/adc/Seafile/Future_Voices/upload/contributions/2020_12_08_FV_shahin.yaml");


q.readYamlOrig = {|ev, path|

	var filename = PathName(path).fileNameWithoutExtension;
	var defaultPath = q.bufPath +/+ "_template.yaml";
	var individualPath = q.bufPath +/+ filename ++ ".yaml";
	var defaulz, myPath = if(individualPath.postcln.pathMatch.notEmpty)
	{defaulz=false; individualPath}
	{defaulz=true; defaultPath};

	var id = myPath.standardizePath.parseYAMLFile;
	d = q.dictToEvent(id, () );
	d.put(\name, filename.toLower.asSymbol);
	d.put(\filename, filename.toLower.asSymbol);
	d = q.emptyStringsToNils(d);
	d = q.numerifyVals(d);
	d = q.addBuffer(d);      // find Buffer previously loaded
	d
};

q.readYaml_adc = {|ev, path|
	var d = ();
	var filename = PathName(path).fileNameWithoutExtension;
	var defaultPath = q.bufPath +/+ "_template.yaml";
	var individualPath = q.bufPath +/+ filename ++ ".yaml";
	var defaulz, myPath = if(individualPath.postcln.pathMatch.notEmpty)
	{defaulz=false; individualPath}
	{defaulz=true; defaultPath};

	var id = try { myPath.standardizePath.parseYAMLFile } {
		"\n\n\n*** YAML FILE FAILS: \n%\n\n\n\n".postf(path.cs ++ ".openOS;");
		// path.openOS;
		id = nil;
	};

	// if (id.notNil) {
	// 	d = q.dictToEvent(id, () );
	// 	d.put(\name, filename.toLower.asSymbol);
	// 	d.put(\filename, filename.toLower.asSymbol);
	// 	d = q.emptyStringsToNils(d);
	// 	d = q.numerifyVals(d);
	// 	///// find Buffer previously loaded
	// 	///// FIXME - better not to load all buffers on startup!
	// 	d = q.addBuffer(d);
	// 	d;
	// };
};

