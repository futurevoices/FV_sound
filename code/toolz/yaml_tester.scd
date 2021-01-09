// "~/Seafile/Future_Voices/upload/contributions/-*.yaml".pathMatch.first.parseYAMLFile

"~/Seafile/Future_Voices/upload/contributions/".openOS;
(
// see if any yaml files in main folder fail:
"~/Seafile/Future_Voices/upload/contributions/*.yaml".pathMatch
.collect { |path|
	var str = File.readAllString(path);
	try { str.parseYAML } {
		"*** FAILS: \n%\n".postf(path.cs ++ ".openOS;");
	};
}
);

var path = "~/Seafile/Future_Voices/upload/contributions/fv-ilijadjordjevic-hbs.yaml";
path.pathMatch;
x = path.pathMatch.first.parseYAMLFile;
x["literal_text_EN"];


