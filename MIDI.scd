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
		~capacitor_0.set(\noiseVar, 0.5);
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