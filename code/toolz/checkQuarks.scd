////// FutureVoices:
// check quarks for installation version of

[ "JITLibExtensions", "adclib", "SafetyNet", "Bjorklund", "Utopia", "Vowel", "say", "HyperDisCo", "StartupFile", "DayTimer"].do { |name|
	if (Quarks.installed.any { |q| q.name == name }.not) {
		Quarks.install(name);
	};
};

if (Quarks.installed.any { |q| q.name == "postlog" }.not) {
	Quarks.install("https://github.com/adcxyz/postlog");
};


