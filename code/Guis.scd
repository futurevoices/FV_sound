Butz.style.font_(Butz.style.font.size_(16));

Butz.add(\mini, { Butz.showButs(2); });
Butz.add(\maxi, { Butz.showButs });
Butz.add(\SHOWALL, {
	[ 'TdefAll', 'FutureVoices', 'mixer', 'MainFX', 'scope', 'meter' ].do { |name|
		Butz.run(name)
	}
});

Butz.add(\TdefAll, { WinBounds.showOrMake(\TdefAll) });
Butz.add(\FutureVoices, { WinBounds.showOrMake(\FutureVoices) });
Butz.add(\mixer,   { WinBounds.showOrMake(\mixer) });
Butz.add(\MainFX,  { WinBounds.showOrMake(\MainFX) });
Butz.add(\scope,   { WinBounds.showOrMake(\scope) });
Butz.add(\meter,   { WinBounds.showOrMake(\meter) });

WinBounds.addMake(\TdefAll, { TdefAllGui.new(16).parent.name_(\TdefAll) });
WinBounds.addMake(\scope, { s.scope.window.name_(\scope) });
WinBounds.addMake(\meter, { s.meter.window.name_(\meter) });

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
	paramgui.specs.postln;
	q.mfgui.parent;
});

Butz.add(\closeAll, {
	Window.closeAll;
	Butz.actions.size;
	defer({
		Butz.show.updateButtons;
		Butz.w.layout.margins = [2, 2, 2, 2];
		Butz.w.layout.spacing_(4);
	}, 0.1);
});

Butz.add(\updateCode, {
	defer { Quarks.at("futurevoices").update }
});

Butz.add(\updateQuarks, {
	defer { Quarks.installed.do(_.update) }
});

Butz.add(\openCodeDir, { q.codeDir.openOS });

Butz.add(\chooseStartup, { StartupFile.dialog });


Butz.add(\RESTART, {
	fork ({
		Window.closeAll;
		0.2.wait;
		s.quit;
		0.5.wait;
		thisProcess.recompile;
	}, AppClock);
});


Task {
	0.1.wait;
	Butz.run(\closeAll);
	0.1.wait;
	Butz.run(\meter);
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
	q.statusView = StaticText(q.tdefwin, 400@30)
	.string_(" ... ").align_(\center)
	.font_(Font.default.copy.size_(20));
	TdefGui(Tdef(\director_FV), 5, q.tdefwin, 380@120);
	TdefGui(Tdef(\testAll), 2, q.tdefwin, 380@50);
	q.autobut = Button(q.tdefwin, 90@30).states_([["Auto"], ["Manual"]]);

	q.tdpop = EZPopUpMenu(q.tdefwin, 280@30, \tdef2show, [\none, \yet], { |pop|
		q.tdefgui.object = Tdef(pop.item).postln;
	});

	q.tdefgui = TdefGui(nil, 10, q.tdefwin, 380@200);

	q.tdefguiskip.stop;
	q.tdefguiskip = SkipJack({
		q.statusView.string = "% contributions in % languages"
		.format(q.mainDict.size, q.lang.names.size);
		q.fvkeys = try { q.fvTdefs.keys(Array).sort } ? [];
		q.tdpopitems = q.tdpop.items.collect(_.key);
		if (q.fvkeys != q.tdpopitems) {
			"setting tdpop".postln;
			q.tdpop.items = q.fvkeys;
		};
		if (q.autobut.value == 0) {
			if (q.activeTdef != q.tdefgui.object) {
				q.tdpop.value = q.fvkeys.indexOf(q.activeTdef.key);
				q.tdefgui.object = q.activeTdef;
			};
		}
	}, 1, { q.tdefwin.isClosed });

	q.tdefwin;
});

/*
WinBounds.saveString
*/

WinBounds.stored.putAll( (
	'MainFX': Rect(694.0, 38.0, 524.0, 350.0),
	'FutureVoices': Rect(403.0, 406.0, 400.0, 400.0),
	'NdefMixer_mixer': Rect(100, 37.0, 684.0, 345.0),
	'scope': Rect(5.0, 100, 263.0, 250.0),

	'Butz': Rect(5.0, 545.0, 117.0, 460.0),
	'meter': Rect(5.0, 300, 134.0, 230.0),
	'TdefAll': Rect(126.0, 408.0, 274.0, 354.0)
) );


