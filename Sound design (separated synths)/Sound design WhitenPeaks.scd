//peaks

{
	var n = 15;
	var intervalo =  377;
	var amplitude = 1/n;  //divided to compensate the volume
	var frecs = n.collect{|i| (i+1)*intervalo};
    var mov = SinOsc.ar(LorenzL.ar(0.01).exprange(0.0001,0.001));
    var oscs = frecs.collect{|i| Resonz.ar(WhiteNoise.ar(0.1),i.poll(1),0.05,3)*amplitude};

    Pan2.ar(oscs.sum,SinOsc.ar(0.05 + mov));
}.scope


(
~a = 35;

SynthDef(\WhitenPeaks,{
	 |intervalo =377, amp =0.05, speed = 0.1, add = 1, attack = 5 ,release = 4 |

var array = Array.fill(~a,{arg i; (i+add)*intervalo});
var src = Resonz.ar(WhiteNoise.ar(0.1),array,0.05,3)*amp;
var mov = LFTri.ar(XLine.kr(17,0.1,4));
var int = Integrator.ar(Impulse.ar(1,mul:0.1),  0.999999);
var env = EnvGen.kr(Env.perc(attack,release), doneAction: Done.freeSelf);

	Out.ar([0,1], Pan2.ar(FreeVerb.ar(src.sum*mov,0.6),FSinOsc.kr(mov))*env);

}).add;

y = Synth("WhitenPeaks", ["attack",0.4,"release",50])
)


//variables
z = Synth("WhitenPeaks", ["intervalo", 277,"attack",0.4,"release",30])
z = Synth("WhitenPeaks", ["intervalo", 477,"attack",0.4,"release",30])
a = Synth("WhitenPeaks", ["intervalo", 577,"attack",0.4,"release",60])


