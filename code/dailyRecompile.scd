// recompile daily, at 3.45 am:
if (\DayTimer.asClass.notNil) {
	\DayTimer.asClass.start.putDate(\reboot, [03, 45, 00], {
		Tdef('stopAll').stop.play;
		1.wait;
		defer { Window.closeAll };
		2.wait;
		s.quit;
		0.5.wait;
		thisProcess.recompile;
	});
};