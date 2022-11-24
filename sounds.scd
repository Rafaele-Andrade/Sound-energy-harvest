//Sounds - Sound energy harvest



	/* Drop SynthDefs here */

SynthDef(\audioIn, {
    | intCoeff = 0.99999|
    var in = SoundIn.ar([0, 1]);
    var inAbs = in.abs;
    var boost = inAbs * 5;
    var capacitor = Integrator.ar(boost, intCoeff);
    var rms = RMS.kr(in);
    Out.ar(~audioIn, in);
    SendReply.kr(Impulse.kr(10), '/audioFeatures', rms);
};).add;

SynthDef(\crystalsounds,{
    |pulse = 10, amp =0.05, freq = 4000, add = 1, attack = 0.2 ,sustain = 2,release = 2, noise = 1|
    var src = LFTri.ar(pulse * noise, mul: Formlet.ar(WhiteNoise.ar(0.01), [freq,freq + 1000,freq + 300] * (noise + 0.000001).sqrt, 0.1, 2, 0.005)) * 10;
    var mov = FSinOsc.kr(XLine.kr(2,0.1,4));
    var env =  EnvGen.kr(Env.linen(attack, sustain, release, 1, \sine), 1.0, doneAction:2);
    Out.ar(~audioOutBus, Pan2.ar(src.sum * env, mov)); // Using audioOutBus for sending all audio out signals to master output
}).add;

/* Using two synthdefs for every static synth in order to allow for individual control of synths (see Rafa and Adam ID) */
2.collect{ |i|

    SynthDef("\Capacitor_%".format(i),{ |gate = 1, intervalo = 0.4, amp = 0.05, speed = 0.1, add = 100|
        var env = EnvGen.kr(Env([0, 1, 0], [5, 10], releaseNode: 1), gate, doneAction: 2);
        var numSines = 20;
        var array = Array.fill(numSines, {arg i; (i+add) * intervalo});
        var src = SinOsc.ar(array) * (1 / numSines);
        var mov = LFNoise1.ar(LorenzL.ar(0.05).exprange(0.0001,0.1));
        var pos = SinOsc.ar(speed + mov);
        var int =Integrator.ar(Impulse.ar(1, mul: 0.1), 0.999999);
        Out.ar(~audioOutBus, Compander.ar(LPF.ar(Pan2.ar(Mix(src) * env,pos),300),0,0.001));
    }).add;

/*
    SynthDef("\resTuning_%".format(i), {
        |array = 138, harm = 1, coef = 0.01, add = 100, attack = 0.4, release = 5, detune = 1, freqMul = 1|
        var amp = (1 / coef).sqrt;
        /*var array = ~tuning[i];*/
        var src = Mix.new(Resonz.ar(WhiteNoise.ar(0.5), array * detune, coef,[[10, 10, 10, 10],[1, 1,1,1]] * amp));
        var env = EnvGen.kr(Env([0, 1, 0], [attack, release]), doneAction: Done.freeSelf);
        Out.ar(0, Splay.ar(src * 0.1) * env);
    }).add;
*/
	SynthDef("\resTuning_%".format(i), {
	|array = 138, harm = 1, coef = 0.001, add = 100, attack = 0.4, release = 5, beating = 1, freqMul = 1, amp = 1, iteration = 1, pan = 0.0005|
	var n = Array.fill(15, { arg i; i + iteration }); //create beating by applying a different list
	var amplitude = 1/n;  //divided to compensate the volume
	var frecs = n.collect({|i| (i)*array});
	var mov = SinOsc.ar(pan.rand);
	var oscs = frecs.collect{|i| Resonz.ar(WhiteNoise.ar(0.1),[ i+ beating, i],coef,10)};
	var env = EnvGen.kr(Env([0, 1, 0], [attack, release]), doneAction: Done.freeSelf);
	Out.ar(0, Splay.ar(Pan2.ar(oscs.sum*LFTri.ar(mov),SinOsc.ar(0.02 + mov))) * env);
}).add;

    SynthDef("\loFreqEnergy_%".format(i), { |gate = 1, detune = 1, maxSinFreq = 44|
        var env = EnvGen.kr(Env([0, 1, 0], [10, 15], releaseNode: 1), gate, doneAction: 2);
        var gNoise = OnePole.kr(~groundNoise[i].kr , 0.5);
        var harvester = ~harvesterVal[i].kr;
        var lfNoise = LFNoise1.ar(450 * (gNoise + 0.00001).sqrt, 0.01);
        var resonators = DynKlank.ar(`[[80, 107, 115, 472, 680] * detune, nil, [0.5, 5, 0.5, 1.5, 1.5]], lfNoise);
        var sine = SinOsc.ar(OnePole.kr(harvester, 0.4).linlin(0.0001, 1.0, 0.7, maxSinFreq), 0, 66, 40);
        var resHP = RHPF.ar(resonators, sine, harvester.linlin(0, 1, 0.2, 0.01), 0.05);
        var highPass = HPF.ar(resHP, OnePole.kr(harvester, 0.9).linlin(0, 1.0, 100.0, 400)) * env;
        Out.ar(~audioOutBus, Limiter.ar(highPass * 0.6) ! 2);
    }).add;

    SynthDef("\WhitenPeaks_%".format(i),{
        |intervalo =377, whichMov = 0, bwr = 0.5, speed = 0.1, add = 1, attack = 5 ,release = 4, startMov = 20, endMov = 0.1, movTime = 8|
        var numFreqs = 35;
        var amp = 1 / numFreqs;
        var array = Array.fill(numFreqs ,{arg i; (i+add) * intervalo}) * ~groundNoise[i].kr.clip(0, 0.5).linlin(0, 0.5, 0.8, 1.2);
        var filterAmp = (1 / bwr).sqrt;
        var src = Resonz.ar(WhiteNoise.ar(0.1),array, bwr, filterAmp) * amp;
        var mov_0 = LFTri.ar(XLine.kr(startMov,endMov, movTime));
        var mov = Select.kr(whichMov, [(Median.kr(3, OnePole.kr(~rocBus[i].kr.abs * 0.05, 0.9)) + 0.02), mov_0]);
        var movAmp = Select.kr(whichMov, [(1 / mov), DC.kr(1)]);
        var int = Integrator.ar(Impulse.ar(1, mul:0.1),  0.999999);
        var env = EnvGen.kr(Env.perc(attack,release), doneAction: Done.freeSelf);
        Out.ar(~audioOutBus, Pan2.ar(FreeVerb.ar(Limiter.ar(src.sum * mov, 0.6 * movAmp)), FSinOsc.kr(mov)).scope * env);
    }).add;
};

~audioOutBus = 0;
x = Synth("\resTuning_%".format(0));
x = Synth("\Capacitor_%".format(0));

SynthDef(\lorenz, {|startVal_0 = 20000, startVal_1 = 20000, envTime_0 = 10, envTime_1 = 10|
    var synth = LorenzL.ar(XLine.kr([startVal_1, startVal_1], 455, [envTime_0, envTime_1])) * 0.3;
    Out.ar(0, synth);
}).add;

SynthDef(\Capacitorempty,{
	|freq =50, amp =0.05, speed = 0.23, add = 3|

	var filter = LFTri.ar(speed,mul:amp);
	var src = SinOsc.ar( freq:[freq, freq+add],mul:filter);

	Out.ar([0,1], Mix.new(src));

}).add;

//x = Synth("Capacitorempty")


SynthDef(\Lowgliss,{
    |intervalo =0.4, amp =0.1, speed = 0.04, add = 100|

    var src = LorenzL.ar(XLine.kr([1100,800],[222,230],5))*amp;

    Out.ar([0,1], Compander.ar(Mix.ar(src),0,0.1));

}).add;

//x = Synth("Lowgliss")

//master
SynthDef(\audioOut, {
    var in = In.ar(~audioOutBus, 2).scope;
    var compressor = Compander.ar(in, in, 0.9, 1, 0.5, 0.01, 0.01);
    var limiter = Limiter.ar(compressor, 0.95);
    Out.ar(0, limiter)};
).add;

