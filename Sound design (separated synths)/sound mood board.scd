//Sound energy harvest

{ RHPF.ar(DynKlank.ar(`[[80, 107, 115, 472,680], nil, [0.5, 0.5, 0.5, 1.5,1.5]], LFNoise1.ar(300, 0.005)),SinOsc.ar(XLine.kr(0.7, 30, 4), 0, 66, 40), 0.2,0.05)!2 }.play;


//piezo peaks : high resonance
//



{ RHPF.ar(DynKlank.ar(`[[80, 107, 115, 472,680], nil, [0.5, 0.5, 0.5, 1.5,1.5]], LFNoise1.ar(300, 0.005)),SinOsc.ar(XLine.kr(0.7, 30, 4), 0, 66, 40), 0.2,0.05)!2 }.play;

{
	var n = 0;
	var intervalo =  0.4;
	var amplitude = 1/n;
	var frecs = n.collect{|i| (i+10)*intervalo};
	var oscs = frecs.collect{|i| SinOsc.ar(i.poll(1))*amplitude};
	LPF.ar(Pan2.ar(oscs.sum,SinOsc.ar(0.10 + SinOsc.ar(LorenzL.ar(0.05).exprange(0.001,0.05)))),600);
}.scope




//

{ Pan2.ar(LFTri.ar(1,mul:Formlet.ar(WhiteNoise.ar(0.01),[4000,5000,4300],0.1,2,0.005)), FSinOsc.kr(XLine.kr(2,0.1,4))) }.play


{ Pan2.ar(LFTri.ar(XLine.kr(17,0.1,4), mul:PinkNoise.ar(0.4)), FSinOsc.kr(XLine.kr(17,0.1,4)), 0.3) }.play;


//
(
{Formlet.ar(WhiteNoise.ar(0.01),[4000,5000,4300],0.1,2,0.005)}.play;
{Formlet.ar(Dust.ar(30),[4000,5000,4300],0.001,0.4,0.01)}.play
)


{ RHPF.ar(SinOsc.ar(200,0.1), FSinOsc.kr(XLine.kr(0.7,300,20), 0, 3600, 4000), 0.2) }.play;

{ RLPF.ar(SinOsc.ar([200,300], 0.1,0.1), SinOsc.ar(XLine.kr(0.7, 30, 8), 0, 360, 400), 0.2) }.play;


{ LFNoise1.ar(100, 0.25) }.play;


{ RLPF.ar(LFNoise1.ar(100, 0.25), SinOsc.ar(XLine.kr(0.7, 30, 8), 0, 360, 400), 0.2) }.play;


{ RLPF.ar(LFNoise1.ar(100, 0.25), SinOsc.ar(XLine.kr(0.7, 30, 8), 0, 360, 400), 0.2) }.play;



{ Resonz.ar(WhiteNoise.ar(0.5), LFNoise1.ar(500, 0.5), 1) }.play

{ DynKlank.ar(`[[800, 1071, 1153, 1723], nil, [0.5, 0.5, 0.5, 0.5]], LFNoise1.ar(50, 0.005)) }.play;

{ DynKlank.ar(`[[800, 1071, 1153, 1723], nil, [0.5, 0.5, 0.5, 0.5]], LFNoise2.ar(50, 0.005)) }.play;

{ RHPF.ar(DynKlank.ar(`[[80, 107, 115, 472], nil, [0.5, 0.5, 0.5, 1.5]], LFNoise1.ar(30, 0.005)),SinOsc.ar(XLine.kr(0.7, 30, 0.3), 0, 36, 40), 0.2,0.1)!2 }.play;

{ RHPF.ar(DynKlank.ar(`[[80, 107, 115, 472,680], nil, [0.5, 0.5, 0.5, 1.5,1.5]], LFNoise1.ar(30, 0.005)),SinOsc.ar(XLine.kr(0.7, 30, 0.3), 0, 36, 40), 0.2,0.1)!2 }.play;


{ RHPF.ar(DynKlank.ar(`[[80, 107, 115, 472,680], nil, [0.5, 0.5, 0.5, 1.5,1.5]], LFNoise1.ar(300, 0.005)),SinOsc.ar(XLine.kr(0.7, 30, 0.3), 0, 36, 40), 0.2,0.05)!2 }.play;


Gendy1


{ Pan2.ar(Gendy1.ar(1, 1, 1.0, 1.0, 30, 100, 0.3, 0.05, 5)) }.play


{ Pan2.ar(Gendy1.ar(initCPs:2)) }.play
{ Pan2.ar(Gendy1.ar(MouseX.kr(0, 7), MouseY.kr(0, 7), mul:0.2), 0.0) }.play


    (
        {
            Mix.fill(10, {
                var freq = rrand(130,160.3);
                Pan2.ar(SinOsc.ar(Gendy1.ar(6.rand, 6.rand, SinOsc.kr(0.1, 0, 0.49, 0.51),
                    SinOsc.kr(0.13, 0, 0.49, 0.51), freq, freq, SinOsc.kr(0.17, 0, 0.49, 0.51),
                    SinOsc.kr(0.19, 0, 0.49, 0.51), 12, 12, 200, 400), 0, 0.1), 1.0.rand2)
            })
        }.play
    )
