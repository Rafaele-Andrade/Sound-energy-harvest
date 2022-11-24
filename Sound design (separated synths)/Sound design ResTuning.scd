
~AdamTuning = [77.522, 55, 137.5, 192.5];  // G C# A Eb
~RafaTuning = [183.33, 138, 101.5 , 32.70]; // F# C# G1/2# C


//original
//Adam's tuning
{ Mix.new(Resonz.ar(WhiteNoise.ar(0.5), [77.522, 55, 137.5, 192.5,77.522*4, 55*4, 137.5*4, 192.5*4],0.01,5)) }.play

//Rafa's tuning
{ Mix.new(Resonz.ar(WhiteNoise.ar(0.5), [77.522, 55, 137.5, 192.5,77.522*4, 55*4, 137.5*4, 192.5*4],0.01,5)) }.play




//Synthdef
(
SynthDef(\AdamresTuning,{
	 |harm = 4, amp = 5, coef = 0.01, add = 100, attack = 0.4, release = 5|

var array = [77.522, 55, 137.5, 192.5];
	var src = Mix.new(Resonz.ar(WhiteNoise.ar(0.5),[array,array*harm],coef,amp));
var env = EnvGen.kr(Env.perc(attack,release), doneAction: Done.freeSelf);

Out.ar([0,1], Compander.ar(src*env,0,0.001));

}).add;

x = Synth("AdamresTuning")
)

(
SynthDef(\RafaresTuning,{
	 |harm = 4, amp = 5, coef = 0.01, add = 100, attack = 0.4, release = 5|

var array = [183.33, 138, 101.5 , 32.70];
var src = Mix.new(Resonz.ar(WhiteNoise.ar(0.5),[array,array*harm],coef,amp));
var env = EnvGen.kr(Env.perc(attack,release), doneAction: Done.freeSelf);

Out.ar([0,1], Compander.ar(src*env,0,0.001));

}).add;

x = Synth("RafaresTuning")
)