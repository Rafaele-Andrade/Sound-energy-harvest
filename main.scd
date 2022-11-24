
//Sound energy harvest 2022

//Rafaele Andrade
//Adam Pultz Meyble


(
s.meter;
s.plotTree;
// ~myplace +/+ "connection-test.scd".openOS;              //for testing

"serverconfig.scd".loadRelative;
"busses.scd".loadRelative;
"tuning.scd".loadRelative;
"envelopes.scd".loadRelative;
"sounds.scd".loadRelative;
"RafaOSC.scd".loadRelative;
"AdamOSC.scd".loadRelative;

)

(

/* neutral state */
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

~makeOSC = {
	/* Receiving OSC from incoming audio (audio features) */
	OSCFunc({|msg|
		2.collect{|i|
			var vol = ~volCharge[i].getSynchronous; // RMS amplitude
			~volCharge[i].set(vol + msg[3 + i])};
	/*	msg.postln;*/
	}, '/audioFeatures');
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
