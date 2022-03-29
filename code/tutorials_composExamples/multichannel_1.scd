// Classroom Multichannel Experiments. 10 chans

// set Server options

// Souncraft UI24R
s.options.numInputBusChannels = 32;
s.options.numOutputBusChannels = 32;

// useful for MC FV:
s.options.numInputBusChannels = 0;
s.options.numOutputBusChannels = 10;

s.reboot; //
s.meter;


(
x.free; x = {
	PanAz.ar(
		numChans: 10,
		in: ClipNoise.ar(1/2),
		pos: LFSaw.ar(MouseX.kr(0.2, 100, 'exponential')),
		level: 0.5,
		width: 0.6,
		orientation: 0.5
	);
}.scope
)

{ LFSaw.ar(500) }.plot
{ Sweep.ar(1) }.plot
q.bufpool;


(instrument: 'simpsamp', buf: q.bufpool.[6]).play;
(instrument: 'simpsamp', buf: q.bufpool.[1], pan: -1).play;
(instrument: 'simpsamp', buf: q.bufpool.[1], pan: -1, out: 1).play;
(instrument: 'simpsamp', buf: q.bufpool.[1], pan: -1, out: 8.rand).play;

(instrument: 'simpsamp', buf: q.bufpool.[1], pan: -1, out: 8.rand).play;

// monoblock:
(instrument: 'simpsamp', buf: q.bufpool.[1], pan: -1, out: [2,3,4,5]).play;

(instrument: 'simpsamp', buf: q.bufpool.[1], pan: -1, out: (0..9)).play;

// circle
(
Tdef(\circle, {
	var buf = q.bufpool.[1];
	10.do{|i|
		(instrument: 'simpsamp', buf: buf, pan: -1, out: i).play;
		// 1.0.wait;
		(buf.duration*0.7).wait;

	}
}).play
)

// monoshift:
(instrument: 'simpsamp', buf: q.bufpool.[1], pan: -1, out: (0..9), lag: (0..9)).play; // too long lag

(instrument: 'simpsamp', buf: q.bufpool.[1], pan: -1, out: (0..9), lag: (0..9)*0.001).play; // too short to hear much


(
Tdef(\phases, {
	var buf = q.bufpool.[6];
	11.do{|i|
		(
			instrument: 'simpsamp', buf: buf,
			pan: -1, out: (0..9),
			lag: ((0..9) * 0.01 * i ).postln // 0.01 is great! spatial Echo, illusion of movement
		).play;
		(buf.duration * 1.0).wait;

	}
}).play
)


(
Tdef(\phases, {
	var buf = q.bufpool.[6];
	11.do{|i|
		(
			instrument: 'simpsamp', buf: buf,
			amp: 0.075, rate: 1,
			pan: -1, out: (0..9),
			lag: ((0..9).scramble + 5 * 0.01 * i ).postln // 0.01 is great! spatial Echo, illusion of movement
		).play;
		(buf.duration * 1.0).wait;

	}
}).play
);

// circle star:
(0..9);
[0, 9, 2, 4, 6, 8, 1, 3, 5, 7];
(
Tdef(\stars, {
	var buf = q.bufpool.[6];
	11.do{|i|
		(
			instrument: 'simpsamp', buf: buf,
			amp: 0.075, rate: [1, -1]@@i,
			pan: -1, out: (0..9),
			lag: ([0, 9, 2, 4, 6, 8, 1, 3, 5, 7] + 6 * 0.02 * i ).postln // 0.01 is great! spatial Echo, illusion of movement
		).play;
		(buf.duration * 1.0).wait;

	}
}).play
);

(
Tdef(\opposites, {
	var buf = q.bufpool.[6];
	10.do{|i|
		var call = 10.rand;
		var resp = call + 5 % 10;
		var dt = i + 1 * 0.04;
		6.do{|j|
			(
				instrument: 'simpsamp', buf: buf,
				amp: 0.075, rate: [1, -1]@@i,
				pan: -1, out: ([call, resp]@@j).postc
			).play;
			(dt).wait;
		};
		" // nu dice".postln;
		2.wait;
		buf.duration.wait;
	}
}).play
);


(
Tdef(\opposites, {
	var buf = q.bufpool.[6];
	10.do{|i|
		var call = 10.rand;
		var resp = call + 5 % 10;
		var dt = i + 1 * 0.04;
		6.do{|j|
			(
				instrument: 'simpsamp', buf: buf,
				amp: 0.075, rate: [1, -1]@@i,
				pan: -1, out: ([call, resp]@@j).postc
			).play;
			(dt).wait;
		};
		" // nu dice".postln;
		2.wait;
		buf.duration.wait;
	}
}).play
);

(
// tuned to "wo bleibt der Schnee":
// "~/Seafile/future_mirror/2021-02-06-20-23-16_germany_de.wav)
// 			(buf.duration * 0.40).wait;

Tdef(\opposites2, {
	var buf = q.bufpool.[8];
	10.do{|i|
		var call = 10.rand;
		var resp = call + 5 % 10;
		var dt = i + 1 * 0.04;
		2.do{|j|
			(
				instrument: 'simpsamp', buf: buf,
				amp: 0.075, rate: [1, -1]@@j,
				pan: -1, out: ([call, resp]@@j).postc
			).play;
			(buf.duration * 0.51).wait;
		};
		" // nu -- ".postln;
		buf.duration.wait;
	}
}).play
);

[10, 20].at(1) //
[10, 20] @ 1   // same as .at
[10, 20].wrapAt(1) //
[10, 20].at(2)     // quasi error
[10, 20].wrapAt(2) // no errors
[10, 20].wrapAt(3) //
[10, 20] @@ (3)    // same wrapAt.

.clipAt // |@|
.foldAt // @|@

//

(
Tdef(\opposites, {
	var buf = q.bufpool.[6];
	10.do{|i|
		var call = 10.rand;
		var resp = call + 5 % 10;
		var dt = i + 4 * 0.04;
		var amp = 0.1;
		rrand(12, 16).do{|j|
			(
				instrument: 'simpsamp', buf: buf,
				amp: amp = amp*0.9, rate: [1, -1]@@i,
				pan: -1, out: ([call, resp]@@j).postc
			).play;
			(dt = dt * 0.9).wait;
			// (dt = dt * [0.9, 1.1].wrapAt(i)).wait;
		};
		" // nu dice".postln;
		2.wait;
		buf.duration.wait;
	}
}).play
);

//// phases by diff. rate
{rrand(0.9, 1.1)}.dup(10);

(instrument: 'simpsamp', buf: q.bufpool.[6], pan: -1, out: (0..9), rate: {rrand(0.95, 1.05)}.dup(10) ).play; // too short to hear much


(instrument: 'simpsamp', buf: q.bufpool.[2], pan: -1, out: (0..9), rate: {rrand(0.9, 1.1) ** 0.3}.dup(10) ).play;

q.bufpool.[0].play;

c = q.db.allEntries.select {|entry| entry.dur > 25};
c.size;
d = c.choose;
fork{q.readBufToDict(d)};
d.buf.play;
d.buf
d.dur;

// calc lag vs. rate:
// lowest one starts immediately; fastest last..
(
var buf = d.buf;
var rates = {rrand(0.9, 1.1) ** 0.7}.dup(10);
var playtimes = buf.duration / rates;
var maxtime = playtimes.maxItem, mintime = playtimes.minItem;
var delta = maxtime - mintime;
var lags = playtimes.linlin(mintime, maxtime, delta/ 2, 0);

(instrument: 'simpsamp', buf: buf, pan: -1, out: (0..9), lag: lags, rate: rates ).play;

)

[0, 0.5, 1].linlin(0, 1, 0, 100);

(out: 2).play
//////

(
// calc lag vs. rate:
// lowest one starts immediately; fastest last..
// numVoices can be set,
//spread is spread of rates
// peak sets the time when they sync: 0 is beginning, 1 end
q.bufSwarm = { |q, buf, numVoices = 10, spread = 0.3, peak = 0.5|

	var rates = { exprand(0.9, 1/0.9) ** spread }.dup(numVoices);
	var playtimes = buf.duration / rates;
	var maxtime = playtimes.maxItem;
	var mintime = playtimes.minItem;
	var delta = maxtime - mintime;
	var lags = playtimes.linlin(mintime, maxtime, delta * peak, 0);

(instrument: 'simpsamp', buf: buf, pan: -1, out: (0..9), lag: lags, rate: rates ).play;
};

)
q.bufSwarm(d.buf, 10);
q.bufSwarm(d.buf, 10, 0.3);
q.bufSwarm(d.buf, 10, 0);
q.bufSwarm(d.buf, 10, 1); // 10% spread

// move the sync point: 0 is at start, 1 is sync at end
q.bufSwarm(d.buf, 20, 0.3, 0.2);
q.bufSwarm(d.buf, 10, 0.3, 0.5);
q.bufSwarm(d.buf, 30, 0.3, 0.8);

s.reboot;




q.hang.do { |buf| buf.allocRead(buf.path) };
q.brazil.do { |buf| buf.allocRead(buf.path) };

q.hang.choose.play;

/// every note one speaker
(
Tdef(\hourClock8, {
	var bufs =  [q.hang, q.brazil].collect(_.choose);
	var dur = bufs.collect(_.duration).product ** (1/bufs.size);
	var pitches = [4, 0, 2, -5, -5, 2, 4, 0];
	var durs = [1, 1, 1, 3, 1, 1, 1, 3] * (dur * 0.5).clip(0.38, 1.62);

	"\n*** hourClock:".postln;
	bufs.do { |buf|
		(buf.path.basename + buf.duration.round(0.01)).postln;
	};
	"dur: %\n".postf(dur);

	pitches.do { |pitch, i|
		bufs.do { |buf|
			(
				instrument: \simpsamp,
				buf: bufs,
				rate: pitch.midiratio * [0.99, 1.01].scramble,
				amp: 0.5,
				pan: [-1, 1],
				out: i
			).play;
		};
		durs[i].wait;
	};
}).quant_(0).play;
)

/// one pitch has the same location
(
Tdef(\hourClock8, {
	var bufs =  [q.hang, q.brazil].collect(_.choose);
	var dur = bufs.collect(_.duration).product ** (1/bufs.size);
	var pitches = [4, 0, 2, -5, -5, 2, 4, 0];
	var durs = [1, 1, 1, 3, 1, 1, 1, 3] * (dur * 0.5).clip(0.38, 1.62);


	"\n*** hourClock:".postln;
	bufs.do { |buf|
		(buf.path.basename + buf.duration.round(0.01)).postln;
	};
	"dur: %\n".postf(dur);

	pitches.do { |pitch, i|
		bufs.do { |buf|
			(
				instrument: \simpsamp,
				buf: bufs,
				rate: pitch.midiratio * [0.99, 1.01].scramble,
				amp: 0.5,
				pan: [-1, 1],
				out: pitch.wrap(0, 9)
			).play;
		};
		durs[i].wait;
	};
}).quant_(0).play;
)

