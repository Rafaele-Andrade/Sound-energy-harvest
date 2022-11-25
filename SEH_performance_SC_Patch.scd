s.meter;

s.plotTree;

MIDIFunc.trace(true);
MIDIFunc.trace(false);

OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false);

( // Click here command + enter.
// Check that Interpreter is active. If not, click in Interpreter and boot it

/*"tuning.scd".loadRelative;
"envelopes.scd".loadRelative;*/


/* Define global variables */
~numInChannels = 2;
~numOutChannels = 2;
~inMic = 0;
~sampleRate = 48000;

/* OSC communication */
~rafaOSCPort = 3334;
~adamOSCPort = 3333;
// ~rafaBelaOSCPort = 3335;*/

// ~oscout = NetAddr("localhost", 6542);

/* Each player can enable or disable the OSC functions receiving OSC data*/
~rafaUDPSend = true;
~adamUDPSend = true;

/* For identifying each player (useful in arrays) */
~rafaID = 1;
~adamID = 0;

/* Min and max of harvester values (for scaling in OSC Function) */

/* Adam without lights */
~adamHMin = 1.0;
~adamHMax = 2048;

/* Adam with 9 leds
~adamHMin = -0.43652352690697;
~adamHMax = 935.96893310547; */

~rafaHMin = 1.0;
~rafaHMax = 1900;

~sceneIndex = 0; // Initialise scene index

~capacitorGain = 1; // For scaling the value of incoming amplitude (RMS)

"serverconfig.scd".loadRelative.postln;

ServerBoot.removeAll;
ServerTree.removeAll;
ServerQuit.removeAll;
MIDIIn.connectAll;

"busses.scd".loadRelative;

"MIDI.scd".loadRelative;

~makeArrays = {
	// ~tuning = [[32.70, 101.5, 138, 183.33 ], [77.522, 55, 137.5, 192.5]]; // Array for storing tuning
	~tuning = [[138, 193], [137.5, 192.5]]; // Array for storing tuningvalues
};

~makeOSC = {
	/* Receiving OSC from incoming audio (audio features) */
	var lastPitch = 440;

	OSCFunc({|msg|
	2.collect{|i|
			var vol = ~volCharge[i].getSynchronous; // RMS amplitude
			~volCharge[i].set(vol + msg[3 + i])}; // Charge the fictional capacitor
		// msg.postln;
	}, '/audioFeatures');
};

"RafaOSC.scd".loadRelative;

"AdamOSC.scd".loadRelative;

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
ServerBoot.add(~adamOSC);
ServerBoot.add(~rafaOSC);
ServerBoot.add(~makeOSC);
/*ServerBoot.add(~rafaBelaOSCFunc);*/
ServerBoot.add(~makeControllers);
ServerQuit.add(~cleanup);

s.waitForBoot({
s.sync;

	"SynthDefs.scd".loadRelative;

s.sync;

	//6b. register remaining functions
		//ServerTree.add(~makeControllers);
	ServerTree.add(~makeNodes);
	ServerTree.add(~makeRoutines);

s.freeAll;
s.sync;
	"done".postln;
});
)
