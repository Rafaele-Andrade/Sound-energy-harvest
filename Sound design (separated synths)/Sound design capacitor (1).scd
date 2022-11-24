//capacitor sound design


//original idea
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



//Synthdef
(
~n = 20;

SynthDef(\Capacitor,{
	 |intervalo =0.4, amp =0.05, speed = 0.1, add = 100|

var array = Array.fill(~n,{arg i; (i+add)*intervalo});
var src = SinOsc.ar( array)*amp;
var mov = LFNoise1.ar(LorenzL.ar(0.05).exprange(0.0001,0.005));
var pos = SinOsc.ar(speed+ mov);
var int =Integrator.ar(Impulse.ar(1,mul:0.1),  0.999999);

Out.ar([0,1], Compander.ar(Mix.ar(LPF.ar(Pan2.ar(src,pos),300)),0,0.001));

}).add;

x = Synth("Capacitor")
)


//variables to change

//pulse
x.set(\speed, 0.5);
x.set(\speed, 9);  //2 6 9
x.set(\speed, 60);
x.set(\speed, 130);
x.set(\speed, 200);

//a nice sequence
x.set(\intervalo, 0.4)
x.set(\intervalo, 0.44)
x.set(\intervalo, 0.45)
x.set(\intervalo, 0.50)
x.set(\intervalo, 0.55)
x.set(\intervalo, 0.3)

//section B
x.set(\intervalo, 0.1)

//sECTION c
x.set(\speed, 60);
x.set(\add, 0.4);

x.set(\add, 100);

x.set(\intervalo, 0.1);
x.set(\speed, 60);


x.free


//changes with add

x.set(\add, 50 + 0.4)
x.set(\intervalo, 0.55)


//contrast ideas
x.set(\intervalo, 10)


x.set(\add, 10)
x.set(\intervalo, 1)