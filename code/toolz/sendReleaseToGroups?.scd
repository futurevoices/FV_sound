s.plotTree;

fork { q.composChoices.do(_.load) };

MFdef(\hang).value;

Tdef( 'fv_grainbow').get(\mygroup);

Tdef( 'fv_grainbow').get(\mygroup).release;

q.bufpool[0].play;
q.bufpool[3].duration;

x = (dur: inf).play;
x.release(2);


////
// synthdef to play a buffer, and has releasable env
SynthDef(\simpsamp2, { |out, gate = 1, buf, amp=0.1, rate = 1, pan=0, start|
	var snd = PlayBuf.ar(1,
		buf, rate, 1,
		start * BufSampleRate.ir(buf),
		0, 2, doneAction: 2
	);
	var env = Env.cutoff.kr(2, gate);
	OffsetOut.ar(out, Pan2.ar(snd, pan, amp * env));
}).add;

// event releases after sound already ended:
/// -> produces a node not found error!
x = (instrument: \simpsamp2,
	buf: q.bufpool[3],
	sustain: q.bufpool[3].duration + 1,
	group: Tdef( 'fv_grainbow').get(\mygroup)
).play;


x = (instrument: \simpsamp2,
	buf: q.bufpool.maxItem(_.duration).bufnum,
	rate: { rrand(0.9, 1.1) }.dup(5),
	pan: { 1.0.rand2 }.dup(5),
	sustain: inf,
	group: Tdef( 'fv_grainbow').get(\mygroup)
).play;

q.sendRelease = { |q, group, releaseTime = 0|
	if (releaseTime <= 0) {
		releaseTime = -1;
	} {
		releaseTime = (releaseTime+1).neg;
	};
	s.sendBundle(nil,
		['/error', -1],
		*event.id.collect { |id|
			[ 15, id, \gate, releaseTime ]
		}
	);
};

s.sendBundle(nil,
	['/error', -1],
	[ 15, Tdef( 'fv_grainbow').get(\mygroup).nodeID, \gate, -1 ]
);
)

q.sendRelease(x, 0);

q.sendRelease(x, 1);


// make a release message for an event and all its synths:
q.sendEventRelease = { |q, event, releaseTime = 0|
	if (releaseTime <= 0) {
		releaseTime = -1;
	} {
		releaseTime = (releaseTime+1).neg;
	};
	s.sendBundle(nil,
		['/error', -1],
		*event.id.collect { |id|
			[ 15, id, \gate, releaseTime ]
		}
	);
};

s.sendBundle(nil,
	['/error', -1],
	[ 15, x.id.unbubble, \gate, -3 ],
);

Node.basicNew(s, x.id.unbubble).releaseMsg

Tdef( 'fv_grainbow').get(\mygroup).release(3);



x = (instrument: \simpsamp,
	buf: q.bufpool[6],
	amp: 0.25, pan: -1.0.rand2,
	sustain: inf,
	rate: { 5.bilinrand *2 }.dup(rrand(3, 7) ).midiratio,
	strum: rrand(0.03,0.3),
	group: Tdef( 'fv_grainbow').get(\mygroup)
).play;


(instrument: \singSamp, buf: q.bufpool[6] , amp: 0.8).play;
