s.meter;

s.plotTree;

MIDIIn.connectAll;

MIDIFunc.trace(true);
MIDIFunc.trace(false);

OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false);

( // Click here command + enter.
// Check that Interpreter is active. If not, click in Interpreter and boot it

//1. server config
s = Server.local;

/* Audio interface */
s.options.outDevice_(
	 //"Built-in Output"
   "Fireface UCX (23732049)"
	// "Scarlett 2i2 USB"
	//"Komplete Audio 6"
);

s.options.inDevice_(
	// "Fireface UCX (23732049)"
	"Scarlett 2i2 USB"
	//"Komplete Audio 6"
);

/* For loading external .scd files. Currently not in use*/
~myplace =  thisProcess.nowExecutingPath.dirname;

~osc = "SEH_OSC.scd";
~osc.loadRelative;

/* Define global variables */
~numInChannels = 2;
~numOutChannels = 2;
~inMic = 0;
~sampleRate = 48000;

/* OSC communication */
~rafaOSCPort = 3333;
~adamOSCPort = 3334;
// ~rafaBelaOSCPort = 3335;*/

// ~oscout = NetAddr("localhost", 6542);

thisProcess.openUDPPort(~rafaOSCPort); // Receiving from Rafaele
thisProcess.openUDPPort(~adamOSCPort); // Receiving from Adam
// thisProcess.openUDPPort(~rafaBelaOSCPort); // Receiving from Rafa's Bela

/* Each player can enable or disable the OSC functions receiving OSC data*/
~rafaUDPSend = true;
~adamUDPSend = true;

/* For identifying each player (useful in arrays) */
~rafaID = 1;
~adamID = 0;

/* Min and max of harvester values (for scaling in OSC Function)*/
~adamHMin = 1.9;
~adamHMax = 2048;

//What's Rafa's min and max values?
/*~rafaHMin = 1.9;
~rafaHMax = 2048;*/

~sceneIndex = 0; // Initialise scene index

MIDIIn.connectAll;

/* Automatically detect MIDI controllers */
if (MIDIClient.sources.detect { |e| e.device.containsi("SSCOM") } != nil)
{
	~softStep = MIDIClient.sources.detect { |e| e.device.containsi("SSCOM") }.uid;
} {
	~softStep = nil};

/*if (MIDIClient.sources.detect { |e| e.device.containsi("nanoKONTROL2") } != nil)
{
	~nanoKtl_source = MIDIClient.sources.detect { |e| e.device.containsi("nanoKONTROL2") }.uid;
} {
	~nanoKtl_source = nil};*/


/* Server options */
s.options.numInputBusChannels_(~numInChannels);
s.options.numOutputBusChannels_(~numOutChannels);
s.recChannels_(~numOutChannels);
s.options.sampleRate_(~sampleRate);
s.options.memSize_(2.pow(20));

s.newBusAllocators;

ServerBoot.removeAll;
ServerTree.removeAll;
ServerQuit.removeAll;
MIDIIn.connectAll;

~makeBusses = {
	~audioInBus = ~numInChannels.collect{ |i| Bus.audio(s)};
	~harvesterVal = 2.collect{Bus.control(s, 1).set(1)};
	~rocBus = 2.collect{Bus.control(s, 1).set(1)};
	~groundNoise = 2.collect{Bus.control(s, 1).set(0.5)};
	~schmittTrigger = 2.collect{Bus.control(s, 1).set(0)};
	~trigDiffMean = 2.collect{Bus.control(s, 1).set(0)};
	~trigDiffVariance = 2.collect{Bus.control(s, 1).set(0)};
	~groundMax = 2.collect{Bus.control(s, 1).set(0)}; // Max value of ground hum (dynammically decreasing to 1)
	~audioIn = Bus.audio(s, 2);
	~audioOutBus = Bus.audio(s, 2);
	~carrFreq = 2.collect{Bus.audio(s, 1)};
	~modFreq = 2.collect{Bus.control(s, 1).set(10)};
	~modOsc = 2.collect{Bus.control(s, 1)};
	~volCharge = 2.collect{Bus.control(s, 1)};
};

~makeArrays = {
	// ~tuning = [[32.70, 101.5, 138, 183.33 ], [77.522, 55, 137.5, 192.5]]; // Array for storing tuning
	~tuning = [[138, 193], [137.5, 192.5]]; // Array for storing tuningvalues
};

~makePresets = {
};

~makeControllers = {
	/* Button 1, neutral state */
	MIDIFunc.noteOn({~sceneIndex = 0;
		~synthGrp.set(\gate, 0);
}, 1, 0, ~softStep);

/* Scenes */

	MIDIFunc.noteOn({~sceneIndex = 1;
		~capacitor_0 = Synth(\Capacitor_0, target: ~synthGrp);
	}, 6, 0, ~softStep);
	MIDIFunc.noteOff({
	}, 6, 0, ~softStep);
	MIDIFunc.noteOn({~sceneIndex = 2;
	}, 7, 0, ~softStep);

	MIDIFunc.noteOff({
		~capacitor_0.set(\gate, 0);
	}, 7, 0, ~softStep);
	MIDIFunc.noteOn({~sceneIndex = 3;
	}, 8, 0, ~softStep);

	MIDIFunc.noteOn({
		var rafaCharge = ~volCharge[0].getSynchronous;
		var adamCharge = ~volCharge[1].getSynchronous;
		~sceneIndex = 4;
		"test_Lorenz".postln;
		~lorenzSweep = Synth(\lorenz, [\startVal_0, rafaCharge, \startVal_1, adamCharge, \envTime_0, 10, \envTime_1, 20]);
	}, 9, 0, ~softStep);
	MIDIFunc.noteOff({
		// ~lorenzSweep.gate(0);
	}, 9, 0, ~softStep);

		MIDIFunc.noteOn({
		if(~sceneIndex != 5){
			~loFreqEnergy = Synth("\loFreqEnergy_%".format(0), target: ~synthGrp);
		};
		~sceneIndex = 5;
	}, 10, 0, ~softStep);
	MIDIFunc.noteOff({
		~loFreqEnergy.free;
	}, 10, 0, ~softStep);
};

~makeBuffers = {
};

/* Custom envelopes. Currently not in use*/
~makeEnvelopes = {
	~env_qgauss = Env([0, 1, 1, 0], [0.25, 0.5, 0.25], \sin);
	~env_welch = Env([0, 1, 1, 0], [0.25, 0.5, 0.25], \welch);
	~psShiftEnv = Env([0, 1, 1, 0], [0.2, 0.7, 0.1], -4);
};

~makeOSC = {
	/* Receiving OSC from incoming audio (audio features) */
	OSCFunc({|msg|
		2.collect{|i|
			var vol = ~volCharge[i].getSynchronous; // RMS amplitude
			~volCharge[i].set(vol + msg[3 + i])};
	/*	msg.postln;*/
	}, '/audioFeatures');
};

~rafaOSC = {
	var groundMax = 1; // Maximum of ground noise
	var lastVal = 0; // Last (x(t-1)) value of harvester
	var schmittState = 0; // State of Schmitt trigger 1
	var schmittState_2 = 0; // State of Schmitt trigger 2
	var schmittUpperThresh = 1900; // Upper harvester threshold for schmitt T 1 (to do: scale to 0-1)
	var schmittLowerThresh = 1000; // Lower harvester threshold for schmitt T 1 (to do: scale to 0-1)
	var schmittUpperThresh_2 = 1900; // Upper harvester threshold for schmitt T 2 (to do: scale to 0-1)
	var schmittLowerThresh_2 = 1500; // Lower harvester threshold for schmitt T 2 (to do: scale to 0-1)
	var lastTS = 0; // Last (x(t-1)) time stamp
	var lastStrigTS = 0; // Time stamp of last Schmitt trigger
	var tBetweenTrig = 0; // Time between triggers
	var tStArraySize = 8;
	var tStArraySizeInv = 1.0 / tStArraySize; // Inverse of tStArraySize
	var tStArray = Array.fill(tStArraySize, {0}); // Array for holding time stamps
	var tBetweenTrigSum = 0; // Running sum of time between triggers (calculated over array of size tStArraySize)
	var tBetweenTrigMean = 0; // Mean val of tBetweenTrigSum
	/*var runningAvgT = 0; Not sure what this was, currently not needed */
	var tStArrayCount = 0; // For indexing into time stamp array
	var tStArrayCount_prev = 0; // Previous time stamp
	var tDiffVariance = 0;
	var tDiffVarMax = 1;
	var tDiffVarianceDynNorm = 0;
	var noiseAbsDynScale = 0.5;
	var harvestMax = 0;

~rafaOSCFunc = { |msg, time, addr, recvPort|
		var adamID = 1;
		if(recvPort == ~rafaOSCPort){ // If this is Rafa's's port

			if(~rafaUDPSend == true){ // If Adam is sending
				if(msg[0] != '/status.reply') {
					var valDiff = (lastVal - msg[1]); // Difference between current and last harvester val
					var timeDiff = time - lastTS; // Time difference between current and last message (around 0.025 Seconds)
					var timeDiffScaled = timeDiff * 50; // Time difference scaled to a value closed to one
					var roc = valDiff / timeDiffScaled; // Rate-of-change (ROC)
					var rocAbs = roc.abs; // Absolute value of ROC

					if (msg[1] > harvestMax){
						harvestMax = msg[1];
					};

					~harvesterVal[~rafaID].set(msg[1]); // Set harvester value
					~rocBus[~rafaID].set(roc); // Set ROC
					lastTS = time; // Set time stamp

					if(msg[2] > groundMax){ // Update maximum ground value (mV)
						groundMax = msg[2];
					};

					groundMax = groundMax - ((groundMax - 1) * (timeDiff / 10)); // Taper off max ground value (minimum = 1)
					~groundMax[~rafaID].set(groundMax); //Route to bus
					noiseAbsDynScale = msg[2].abs.linlin(0, groundMax, 0, 1.0); // Scale noise dynamically
					~groundNoise[~rafaID].set(noiseAbsDynScale);	// Set ground value (for noise sampling)

					/* Second Schmitt Trigger */
					if(msg[1] > schmittUpperThresh_2 && schmittState_2 == 0){
						tBetweenTrig = time - lastStrigTS; // Count time since last trigger

						if(tDiffVariance > tDiffVarMax){ // Set variance max
							tDiffVarMax = tDiffVariance};

						lastStrigTS = time;
						schmittState_2 = 1;

						/* Calculating harvester running sum, mean and variance */

						tStArrayCount_prev = tStArray[tStArrayCount]; // Get index of oldest value (current
						tStArray[tStArrayCount] = tBetweenTrig; // Add new time stamp to array (replace oldest value)
						tStArrayCount = (tStArrayCount + 1) % tStArraySize; // Increment counter
						tBetweenTrigSum = tBetweenTrigSum + tBetweenTrig; // Update running sum of time stamos
						tBetweenTrigSum = tBetweenTrigSum - tStArrayCount_prev; // Deduct oldest value
						tBetweenTrigMean = tBetweenTrigSum * tStArraySizeInv; // Calculate mean of time stamps
						tDiffVariance = tStArraySize.collect{|i| (tStArray[i] - tBetweenTrigMean).pow(2)}.sum * tStArraySizeInv; // Calculate variance
						tDiffVarianceDynNorm = tDiffVariance.linlin(0, tDiffVarMax, 0.0, 1); // Scale variance dynamically to 0-1
						~trigDiffMean[~rafaID].set(tBetweenTrigMean); // Set bus with mean value
						~trigDiffVariance[~rafaID].set(tDiffVariance); // set bus with variance value

						/* Commands for scenes (triggered by Schmitt Trigger 2)*/

						switch (~sceneIndex,
							0, {},
							1, {if(tDiffVarianceDynNorm > 0.7){
								~capacitor_0.set(\intervalo, noiseAbsDynScale.linlin(0.0, 1.0, 0.3, 0.8))} {
								~capacitor_0.set(\intervalo, noiseAbsDynScale.linlin(0.0, 1.0, 0.2, 0.5))}},
							2, {if(tDiffVarianceDynNorm > 0.5){
								~capacitor_0.set(\intervalo, noiseAbsDynScale.linlin(0.0, 1.0, 0.3, 0.8))} {
								~capacitor_0.set(\intervalo, noiseAbsDynScale.linlin(0.0, 1.0, 0.2, 0.5))}},
							3, {},
							5, {~loFreqEnergy.set(\detune, 1.0, \maxSinFreq, 40 + 35.0.rand);},
						);

			};
			if(msg[1] < schmittLowerThresh_2 && schmittState_2 == 1){
				schmittState_2 = 0;
			};

			tDiffVarMax = (tDiffVarMax - (tDiffVarMax * (timeDiff / 10))).clip(1, 400); // Taper off time difference maximum

			/* Schmitt Trigger 1 */
			if(msg[1] > schmittUpperThresh && schmittState == 0){

						/* Commands for scenes (triggered by Schmitt Trigger 1)*/

					switch (~sceneIndex,
							0, {},
							1, {~capacitor_0.set(\speed, tDiffVarianceDynNorm.sqrt * 100);},
							2, {~capacitor_0.set(\speed, tDiffVarianceDynNorm * 180);
								Synth("crystalsounds", ["attack", 0.01 + 1.0.rand, "release", 2 + 15.rand, "noise", noiseAbsDynScale, \pulse, tBetweenTrigMean.sqrt.clip(0.2, 50) * 50  * noiseAbsDynScale.linlin(0, 1, 0.5, 1.5) ], target: ~synthGrp);},
							3, {var rand = tBetweenTrig.clip(0.0001, 20).linlin(0.001, 20, 0, 0.1);
								var randSign = [-1, 1].choose;
								Synth("\resTuning_%".format(1), [\attack, 1 + (4.0).rand, \release, 1 + (15.0).rand, \coef, 0.001, \detune, 1  + (rand), \array, ~tuning[1].choose], target: ~synthGrp);},
						);


						~schmittTrigger[~rafaID].set(1);
						schmittState = 1;
						/*"State = 1".postln;*/
					};
					if(schmittState == 1){
					};
					if(msg[1] < schmittLowerThresh && schmittState == 1){
						schmittState = 0;
						~schmittTrigger[~rafaID].set(0);
						/*"State = 0".postln;*/
					};

				};
			};
		};
	};
thisProcess.addOSCRecvFunc(~rafaOSCFunc);
};

/*~rafaBelaOSCFunc = { |msg, time, addr, recvPort|

	if(recvPort == ~rafaBelaOSCPort){
		msg.postln;
	};

	thisProcess.addOSCRecvFunc(~rafaBelaOSCFunc);
	};*/

~adamOSC = { // For now, see Rafa OSC for explanation of
	var groundMax = 1;
	var lastVal = 0;
	var schmittState = 0;
	var schmittState_2 = 0;
	var schmittUpperThresh = 1900;
	var schmittLowerThresh = 1000;
	var schmittUpperThresh_2 = 1900;
	var schmittLowerThresh_2 = 1500;
	var lastTS = 0;
	var lastStrigTS = 0;
	var tBetweenTrig = 0;
	var tBetweenTrigSum = 0;
	var tBetweenTrigMean = 0;
	var runningAvgT = 0;
	var tStArraySize = 8;
	var tStArraySizeInv = 1.0 / tStArraySize;
	var tStArray = Array.fill(tStArraySize, {0});
	var tStArrayCount = 0;
	var tStArrayCount_prev = 0;
	var tDiffVariance = 0;
	var tDiffVarMax = 1;
	var tDiffVarianceDynNorm = 0;
	var noiseAbsDynScale = 0.5;
	var dynNormDecreaseFactor = 20;
	var volMax = 0;

~adamOSCFunc = { |msg, time, addr, recvPort|
		var adamID = 1;
		if(recvPort == ~adamOSCPort){ // If this is Adam's port
			if(~adamUDPSend == true){ // If Adam is sending
				if(msg[0] != '/status.reply') {
					var valDiff = (lastVal - msg[1]); // Difference between current and last harvester val
					var timeDiff = time - lastTS; // Time difference between current and last message (around 0.025 Seconds)
					var timeDiffScaled = timeDiff * 50; // Time difference scaled to a value closed to one
					var roc = valDiff / timeDiffScaled; // Rate-of-change (ROC)
					var rocAbs = roc.abs; // Absolute value of ROC
					~harvesterVal[~adamID].set(msg[1].linlin(~adamHMin, ~adamHMax, 0, 1.0)); // Set harvester value
					~rocBus[~adamID].set(roc); // Set ROC
					lastTS = time; // Set time stamp
					/*msg[1].postln;*/
					/*tBetweenTrig.postln;*/

					if (msg[1] > volMax){
						volMax = msg[1];
						volMax.postln;
					};

				/*	if(tDiffVarianceDynNorm > 0.5){
							"yes".postln;
						} {
						"no".postln;
					};*/

					if(msg[2] > groundMax){ // Update maximum ground value (mV)
						groundMax = msg[2];
					};

					groundMax = groundMax - ((groundMax - 1) * (timeDiff / dynNormDecreaseFactor)); // Taper off max ground value (minimum = 1)
					~groundMax[~adamID].set(groundMax); //Route to bus
					noiseAbsDynScale = msg[2].abs.linlin(0, groundMax, 0, 1.0); // Scale noise dynamically
					~groundNoise[~adamID].set(noiseAbsDynScale);	// Set ground value (for noise sampling)

					if(msg[1] > schmittUpperThresh_2 && schmittState_2 == 0){
						tBetweenTrig = time - lastStrigTS; // Count time since last trigger
						if(tDiffVariance > tDiffVarMax){ // Set variance max
							tDiffVarMax = tDiffVariance};
						lastStrigTS = time;
						schmittState_2 = 1;

						/* Calculating harvester running sum, mean and variance */

						tStArrayCount_prev = tStArray[tStArrayCount]; // Get index of oldest value (current
						tStArray[tStArrayCount] = tBetweenTrig; // Add new time stamp to array (replace oldest value)
						tStArrayCount = (tStArrayCount + 1) % tStArraySize; // Increment counter
						tBetweenTrigSum = tBetweenTrigSum + tBetweenTrig; // Update running sum of time stamos
						tBetweenTrigSum = tBetweenTrigSum - tStArrayCount_prev; // Deduct oldest value
						tBetweenTrigMean = tBetweenTrigSum * tStArraySizeInv; // Calculate mean of time stamps
						tDiffVariance = tStArraySize.collect{|i| (tStArray[i] - tBetweenTrigMean).pow(2)}.sum * tStArraySizeInv; // Calculate variance
						tDiffVarianceDynNorm = tDiffVariance.linlin(0, tDiffVarMax, 0.0, 1); // Scale variance dynamically to 0-1
						~trigDiffMean[~adamID].set(tBetweenTrigMean);
						~trigDiffVariance[~adamID].set(tDiffVariance);
						/*tBetweenTrigMean;*/

						switch (~sceneIndex,
							0, {},
							1, {},
							2, {},
							3, {},
						);

					};
					if(msg[1] < schmittLowerThresh_2 && schmittState_2 == 1){
						schmittState_2 = 0;
					};

					tDiffVarMax = (tDiffVarMax - (tDiffVarMax * (timeDiff / dynNormDecreaseFactor))).clip(1, 400);

					/* Schmitt Trigger*/
					if(msg[1] > schmittUpperThresh && schmittState == 0){

						switch (~sceneIndex,
							0, {},
							1, {Synth("WhitenPeaks_%".format(adamID), [\whichMov, 2.rand, \startMov, tBetweenTrigMean * 50, \endMov, tBetweenTrigMean.clip(0.1, 10), \movTime, 8, "intervalo", tBetweenTrig.clip(0, 30).linlin(0, 30, 600, 200), "attack", 0.1 + 1.0.rand,"release", tDiffVarianceDynNorm * 30, \bwr, tBetweenTrig.clip(0, 30).linlin(0, 30, 0.01, 0.5)], target: ~synthGrp);},
							2, {Synth("crystalsounds", ["attack", 0.01 + 1.0.rand, "release", 2 + 15.rand, "noise", noiseAbsDynScale, \pulse, tBetweenTrigMean.sqrt.clip(0.2, 50) * 50  * noiseAbsDynScale.linlin(0, 1, 0.5, 1.5) ], target: ~synthGrp);},

							/* Scene 3 */

							3, {var rand = tBetweenTrig.clip(0.0001, 20).linlin(0.001, 20, 0, 0.1).postln;
								var randSign = [-1, 1].choose;
								Synth("\resTuning_%".format(0), [\attack, rrand(4,10.0), \release, rrand(6,15.0), \coef, 0.001, \freqMul, 2, \detune, 1 + (rand), \array, ~tuning[0].choose * 2], target: ~synthGrp);},
							/* Scene 5 */

							5, {~loFreqEnergy.set(\detune, 0.8 + 0.4.rand, \maxSinFreq, 30 + 45.0.rand)};
						);



						// msg[1].postln;
						~schmittTrigger[~adamID].set(1);
						schmittState = 1;
						// "State = 1".postln;
					};
					if(schmittState == 1){
						/*~schmittTrigger.set(0);*/
					};
					if(msg[1] < schmittLowerThresh && schmittState == 1){
						schmittState = 0;
						~schmittTrigger[~adamID].set(0);
						// "State = 0".postln;
					};

				};
			};
		};
	};
thisProcess.addOSCRecvFunc(~adamOSCFunc);
};

~makeRoutines = {
};

~cleanup = {
	s.newBusAllocators;
	ServerBoot.removeAll;
	ServerTree.removeAll;
	ServerQuit.removeAll;
};

/* Synth hierarchy (for proper bus signal flow between synths) */
~makeNodes = {
	s.bind({
		~inGrp = Group.new;
		~synthGrp = Group.new(~inGrp, \addAfter);
		~listenGrp = Group.new(~synthGrp, \addAfter);
		~reverbGrp = Group.new(~listenGrp, \addAfter);
		~outGrp = Group.new(~reverbGrp, \addAfter);
		~audioInSynth = Synth(\audioIn, target: ~inGrp);
		~audioOutSynth = Synth(\audioOut, target: ~outGrp);
	});
};

ServerBoot.add(~makeArrays);
ServerBoot.add(~makeBusses);
ServerBoot.add(~makeBuffers);
ServerBoot.add(~makeEnvelopes);
ServerBoot.add(~adamOSC);
ServerBoot.add(~rafaOSC);
ServerBoot.add(~makeOSC);
/*ServerBoot.add(~rafaBelaOSCFunc);*/
ServerBoot.add(~makeControllers);
ServerQuit.add(~cleanup);

s.waitForBoot({
s.sync;

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


				SynthDef("\resTuning_%".format(i), {
			|array = 138, harm = 1, coef = 0.01, add = 100, attack = 0.4, release = 5, detune = 1, freqMul = 1|
			var amp = (1 / coef).sqrt;
			/*var array = ~tuning[i];*/
			var src = Mix.new(Resonz.ar(WhiteNoise.ar(0.5), array * detune, coef,[[10, 10, 10, 10],[1, 1,1,1]] * amp));
			var env = EnvGen.kr(Env([0, 1, 0], [attack, release]), doneAction: Done.freeSelf);
			Out.ar(~audioOutBus, Splay.ar(src * 0.1) * env);
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
		Out.ar(~audioOutBus, Limiter.ar(highPass * 0.6) ! 2);}).add;

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

	SynthDef(\lorenz, {|startVal_0 = 20000, startVal_1 = 20000, envTime_0 = 10, envTime_1 = 10|
		var synth = LorenzL.ar(XLine.kr([startVal_1, startVal_1], 455, [envTime_0, envTime_1])) * 0.3;
		Out.ar(0, synth);
	}).add;

	SynthDef(\audioOut, {
		var in = In.ar(~audioOutBus, 2).scope;
		var compressor = Compander.ar(in, in, 0.9, 1, 0.5, 0.01, 0.01);
		var limiter = Limiter.ar(compressor, 0.95);
		Out.ar(0, limiter)};
		).add;

s.sync;

	//6b. register remaining functions
		//ServerTree.add(~makeControllers);
	ServerTree.add(~makeNodes);
	ServerTree.add(~makeRoutines);
	ServerTree.add(~makePresets);

s.freeAll;
s.sync;
	"done".postln;
});
)
