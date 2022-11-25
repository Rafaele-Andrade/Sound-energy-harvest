
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
	}, 6, 0, ~softStep)
	;
	MIDIFunc.noteOff({
	}, 6, 0, ~softStep);


	MIDIFunc.noteOn({~sceneIndex = 2;
	}, 7, 0, ~softStep);
	MIDIFunc.noteOff({
		~capacitor_0.set(\gate, 0);
	}, 7, 0, ~softStep);


	MIDIFunc.noteOn({~sceneIndex = 3;
		fork{
			~attack = 20;
			~release = 30;
			~array = 133;
			~iter = rrand(1,1.2) ;
			30.wait;
			~array = ~tuning[1].choose;
			30.wait;
			~array = ~tuning[0].choose;
			~iter = rrand(1.2,1.4);
			30.wait;
			~array = ~tuning[2].choose;
			~pan = 0.001;
			30.wait;
			~pan = rrand(0.01,0.1);
			10.wait;
			~pan = rrand(4,19);
		};
	}, 8, 0, ~softStep);



	MIDIFunc.noteOn({ ~sceneIndex = 4;
		var rafaCharge = ~volCharge[0].getSynchronous;
		var adamCharge = ~volCharge[1].getSynchronous;

		//~lorenzSweep = Synth(\lorenz, [\startVal_0, rafaCharge, \startVal_1, adamCharge, \envTime_0, 10, \envTime_1, 20]);
		fork{
		~capacitorempty = Synth("Capacitorempty");
		~lowgliss = Synth("Lowgliss", ["amp",1, "release",20]);

		30.wait;

		~capacitorempty.set("speed",0.15, "add",2.rand);

		30.wait;
		~capacitorempty.set("speed",0.1, "add",1.rand);
		}

	}, 9, 0, ~softStep);

	MIDIFunc.noteOff({
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



)





/*  dont really understand :P

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


~makeRoutines = {
};


~cleanup = {
	s.newBusAllocators;
	ServerBoot.removeAll;
	ServerTree.removeAll;
	ServerQuit.removeAll;
};

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

*/
