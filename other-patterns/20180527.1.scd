SuperDirt.start

(

s = Server.local;

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

)

(
SynthDef("help_PlayBuf", { arg out=0,bufnum=0;
	Out.ar(out,
		PlayBuf.ar(0, bufnum, BufRateScale.kr(bufnum)),
		PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum))
	)
}).play(s, [\out, [0,1], \bufnum, b.bufnum]);
)

b.free