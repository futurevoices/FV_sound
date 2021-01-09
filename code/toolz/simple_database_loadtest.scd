// simple database load test:

// make 10k database entries
// test queries that search in database

~caps = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
~langs = 30.collect { 2.collect { ~caps.choose }.join.asSymbol };
~keywords = 60.collect {
	rrand(4, 12).collect { ~caps.choose }.join.asSymbol
};

~descs = 10000.collect {
	(
		lang: ~langs.choose,
		keywords: rrand(2, 5).collect { ~keywords.choose },
		path: String.fill(rrand(20, 40), { "qwertyuiopasdfghjklzxcvbnm./".choose }),
		duration: exprand(3.0, 120)
	)
};

// test query for 3 properties in database:
// language, presence of 1 or 2 keywords, lower duration
// runs in 0.006 - faster than network latency!

bench {
	var lang = ~langs.choose.postln;
	var keywords = ~keywords.scramble.keep(1).postln;
	~descs.select { |desc|
		(desc[\lang] == lang) and: {
			(keywords sect: desc[\keywords]).size == 1
			and: { desc[\duration] < 18 }
		};
	}.size.postln;
};