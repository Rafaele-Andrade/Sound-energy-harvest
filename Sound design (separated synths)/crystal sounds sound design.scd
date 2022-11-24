//  Sound design crystal sounds

//original

{ var env = EnvGen.kr(Env.linen(0.5, 2, 0.8, 1, \sine ), 1.0, doneAction:2);
					var noise = msg[2].abs.linlin(0, groundMax, 0, 1.0);
					Pan2.ar(LFTri.ar(10 * ~groundNoise.kr , mul:Formlet.ar(WhiteNoise.ar(0.01),[4000,5000,4300] * (~groundNoise.kr + 0.00001).sqrt,0.1,2,0.005)), FSinOsc.kr(XLine.kr(2,0.1,4))) * 5 * env}.play;

//simplified version
{ Pan2.ar(LFTri.ar(1,mul:Formlet.ar(WhiteNoise.ar(0.01),[4000,5000,4300],0.1,2,0.005)), FSinOsc.kr(XLine.kr(2,0.1,4))) }.play



//synthdef
SynthDef(\crystalsounds,{
	 |pulse = 10, amp =0.05, freq = 4000, add = 1, attack = 0.2 ,sustain = 2,release = 2 |

var src = LFTri.ar(pulse,mul:Formlet.ar(WhiteNoise.ar(0.01),[freq,freq+1000,freq+300],0.1,2,0.005));
var mov = FSinOsc.kr(XLine.kr(2,0.1,4));
var env =  EnvGen.kr(Env.linen(attack, sustain, release, 1, \sine ), 1.0, doneAction:2);

	Out.ar([0,1], Pan2.ar(src,mov));

}).add;

b = Synth("crystalsounds", ["attack",5000,"release",10])
c = Synth("crystalsounds", ["freq",1000,"release",10])
