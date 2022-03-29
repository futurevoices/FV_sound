/*
**** Requires current adclib!!!! ****

Butz(\fuvo).clear;
*/
Butz.style.font_(Butz.style.font.size_(14));
Butz.style.winLoc = 10 @ 50;


Butz.addMiniMax;
Butz.add(\StartupDial, { StartupFile.dialog });
Butz.add(\MainVol, { WinBounds.showOrMake(\Volume) });
Butz.add(\TdefAll, { WinBounds.showOrMake(\TdefAll) });
Butz.add(\mixer,   { WinBounds.showOrMake(\mixer) });
Butz.add(\MainFX,  { WinBounds.showOrMake(\MainFX) });
Butz.add(\scope,   { WinBounds.showOrMake(\scope) });
Butz.add(\meter,   { WinBounds.showOrMake(\meter) });

// specific to fuvo:
Butz(\fuvo).addMiniMax;
Butz(\fuvo).add(\StartupDial);
Butz(\fuvo).add(\MainVol);
Butz(\fuvo).add(\scope);
Butz(\fuvo).add(\meter);

Butz(\fuvo).add(\FutureVoices, { WinBounds.showOrMake(\FutureVoices) });

Butz(\fuvo).add(\SHOWALL, {
	[ 'TdefAll', 'mixer', 'MainFX', \MainVol,
		'scope', 'meter' ].do { |name|
		Butz.run(name)
	};
	Butz(\fuvo).run('FutureVoices');
});

Butz(\fuvo).add(\TdefAll);
Butz(\fuvo).add(\mixer);
Butz(\fuvo).add(\MainFX);

WinBounds.addMake(\TdefAll, { TdefAllGui.new(16).parent.name_(\TdefAll) });
WinBounds.addMake(\scope, { s.scope.window.name_(\scope) });
WinBounds.addMake(\meter, { s.meter.window.name_(\meter) });

WinBounds.addMake(\Volume, {
	VolumeGui(s.volume, nil, Rect(150.0, 600.0, 80.0, 330.0)).window;
});


WinBounds.addMake(\MainFX, {
	var paramgui;
	q.mfgui = MainFXGui(MainFX(s));
	q.mfgui.parent.name_(\MainFX);
	// update bloody param specs by hand:
	paramgui = q.mfgui.editGui.paramGui;
	MainFX(s).proxyChain.slotNames.do { |key|
		ProxyChain.atSrcDict(key).specs.keysValuesDo { |key, spec|
			paramgui.specs.put(key, spec);
		}
	};
	// paramgui.specs.postln;
	q.mfgui.parent;
});

Butz.add(\closeAll, {
	Window.closeAll;
	defer({
		Butz.show;
		Butz.w.layout.margins = [2, 2, 2, 2];
		Butz.w.layout.spacing_(4);
		Butz.showButs;
	}, 0.1);
});
Butz(\fuvo).add(\closeAll);


Butz(\fuvo).add(\openDir, { q.fuvo.dir.openOS });

// open fuvo Butz
Task {
	0.1.wait;
	Butz.run(\closeAll);
	0.1.wait;
	Butz.curr = \fuvo;
	Butz.run(\meter);
	Butz.run(\scope);
}.play(AppClock);

WinBounds.addMake(\mixer, {
	q.mix = NdefMixer.new(s);
	ProxyMeter.addMixer(q.mix);
	q.mix.name_(\mixer);
	// q.mix.moveTo(20, Window.availableBounds.height - 700);
	q.mix.parent;
});

WinBounds.addMake(\FutureVoices, {

	q.tdefwin = Window(\FutureVoices).front.moveTo(300, Window.availableBounds.height - 100);
	q.tdefwin.addFlowLayout;
	q.statusView = StaticText(q.tdefwin, 400@40)
	.string_(" ... ").align_(\center)
	.font_(Font.default.copy.size_(16));

	q.dirGui = TdefGui(Tdef(\director_FV), 5, q.tdefwin, 380@120);
	q.dirGui.nameBut.states_([[ "DIRECTOR", Color.white, Color.blue ]]);
	q.dirGui.nameBut.font_(Font.default.copy.size_(16));


	q.autobut = Button(q.tdefwin, 90@30).states_([["Auto"], ["Manual"]]);

	q.tdpop = EZPopUpMenu(q.tdefwin, 280@30, \tdef2show, [\none, \yet], { |pop|
		q.tdefgui.object = Tdef(pop.item).postln;
	});

	q.tdefgui = TdefGui(nil, 10, q.tdefwin, 380@200);
	q.tdefgui.nameBut.font_(Font.default.copy.size_(16));

	q.tdefguiskip.stop;
	q.tdefguiskip = SkipJack({
		q.statusView.string = "% contributions in % languages"
		.format(q.mainDict.size, q.lang.names.size)
		++ "\nTotal duration: %".format(q.mainDict.sum(_.dur).asTimeString);
		q.fvkeys = try { q.fvTdefs.keys(Array).sort } ? [];
		q.tdpopitems = q.tdpop.items.collect(_.key);
		if (q.fvkeys != q.tdpopitems) {
			// "setting tdpop".postln;
			q.tdpop.items = q.fvkeys;
		};
		if (q.autobut.value == 0) {
			if (q.activeTdef != q.tdefgui.object) {
				q.tdpop.value = q.fvkeys.indexOf(q.activeTdef.key);
				q.tdefgui.object = q.activeTdef;
			};
		}
	}, 1, { q.tdefwin.isClosed });


	TdefGui(Tdef(\testAll), 4, q.tdefwin, 380@50);

	q.tdefwin;
});

/*
Window.getAll.printcsAll;
WinBounds.saveString;
*/

WinBounds.stored.putAll( (
	'Butz': Window.flipY(Rect(10, 10, 117.0, 460.0)),
	'MainFX': Rect(694.0, 38.0, 524.0, 350.0),
	'FutureVoices': Rect(450.0, 406.0, 400.0, 520),
	'NdefMixer_mixer': Rect(150, 100, 684.0, 345.0),

	'meter': Rect(10, 10, 134.0, 230.0),
	'scope': Rect(150, 10, 263.0, 230.0),
	'TdefAll': Rect(230, 400, 300, 350)
) );


