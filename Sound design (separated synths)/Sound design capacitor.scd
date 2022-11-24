//capacitor sound design


{
	var n = 20;
	var intervalo =  0.4;
	var amplitude = 1/n;
	var frecs = n.collect{|i| (i+100)*intervalo};
    var mov = LFNoise1.ar(LorenzL.ar(0.05).exprange(0.0001,0.005));
	var oscs = frecs.collect{|i| SinOsc.ar(i.postln)*amplitude};
    var scr = LPF.ar(Pan2.ar(oscs.sum,SinOsc.ar(0.10 + mov)),300);
    Compander.ar(scr,0, 0.1);
}.scope


~n = 20;

SynthDef(\Capacitor,{
	 |intervalo =0.4, amp =0.1, speed = 0.04, add = 100|

var src = SinOsc.ar( freq: Array.fill(~n,{arg i; (i+add)*intervalo}))*amp;
var mov = LFNoise1.ar(LorenzL.ar(0.05).exprange(0.0001,0.05));
var pos = SinOsc.ar(0.10 + mov);

	Out.ar([0,1], Compander.ar(Mix.ar(LPF.ar(Pan2.ar(src,pos),300)),0,0.1));

}).add;

x = Synth("Capacitor")


//sequence
x.set(\intervalo, 0.44)
x.set(\intervalo, 0.4)
x.set(\intervalo, 0.45)
x.set(\intervalo, 0.50)
x.set(\intervalo, 0.6)

//changes with add

x.set(\add, 50)
x.set(\intervalo, 0.4)

//contrast

x.set(\intervalo, 10)


x.set(\add, 10)
x.set(\intervalo, 6)