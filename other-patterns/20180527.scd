SuperDirt.start


(
SynthDef(\mbell, { |out, pan=1|
	var note;

	note = {SinOsc.ar(Rand(400, 800), 0, 0.2) * Line.kr(1, 0, 1, doneAction: Done.freeSelf)};

	OffsetOut.ar(out, DirtPan.ar(note, ~dirt.numChannels, pan, 1))
}).add;
)


(
SynthDef(\inPt, { |in, out, amp = 0.1, freqs = #[300, 400, 500, 600], gate = 1|
    var env, sines;
    env = Linen.kr(gate, 0.1, 1, 1, 2) * amp;
	// sines = In.ar SinOsc.ar(freqs +.t [0,0.5]).cubed.sum;
    Out.ar(out,  In.ar * env);
}, [0, 0.1, 0]).add;
)

~bus = Bus.audio(s, numChannels:2); // assuming stereo, expand if needed

~dirt.orbits[1].outBus = ~bus; // play into that bus.


/*
Now, playing patterns in d1 in tidal should be silent.
*/

// listen directly
(
Ndef(\x, {
	var dirt = InBus.ar(~bus, 1);
	dirt
}).play;

)

// resonant low pass filter controlled by cursor
(
Ndef(\x, {
	var dirt = InBus.ar(~bus, 2);
	RLPF.ar(dirt, MouseY.kr(30, 20000, 1), MouseX.kr(0.01, 1, 1))
}).play;
)

(
SynthDef(\gabberkick, {
    var snd, freq, high, lfo;
    freq = \freq.kr(440) * (Env.perc(0.001, 0.08, curve: -1).ar * 48 * \bend.kr(1)).midiratio;
    snd = Saw.ar(freq);
    snd = (snd * 100).tanh + ((snd.sign - snd) * -8.dbamp);
    high = HPF.ar(snd, 300);
    lfo = SinOsc.ar(8, [0, 0.5pi]).range(0, 0.01);
    high = high.dup(2) + (DelayC.ar(high, 0.01, lfo) * -2.dbamp);
    snd = LPF.ar(snd, 100).dup(2) + high;
    snd = RLPF.ar(snd, 7000, 2);
    snd = BPeakEQ.ar(snd, \ffreq.kr(3000) * XLine.kr(1, 0.8, 0.3), 0.5, 15);
    snd = snd * Env.asr(0.001, 1, 0.05).ar(2, \gate.kr(1));
    Out.ar(\out.kr(0), snd * \amp.kr(0.1));
}).add;
)
(
SynthDef(\hoover, {
    var snd, freq, bw, delay, decay = 300;
    freq = \freq.kr(440);
    freq = freq * Env([-5, 6, 0], [0.1, 1.7], [\lin, -4]).kr.midiratio;
    bw = 1.035;
    snd = { DelayN.ar(Saw.ar(freq * ExpRand(bw, 1 / bw)) + Saw.ar(freq * 0.5 * ExpRand(bw, 1 / bw)), 0.01, Rand(0, 0.01)) }.dup(20);
    snd = (Splay.ar(snd) * 3).atan;
    snd = snd * Env.asr(0.01, 1.0, 1.0).kr(0, \gate.kr(1));
    snd = FreeVerb2.ar(snd[0], snd[1], 0.3, 0.9);
    snd = snd * Env.asr(0, 1.0, 4, 6).kr(2, \gate.kr(1));
    Out.ar(\out.kr(0), snd * \amp.kr(0.1));
}).add;
)