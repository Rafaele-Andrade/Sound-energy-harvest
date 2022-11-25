// Click here command + enter.
// Check that Interpreter is active. If not, click in Interpreter and boot it

//1. server config
s = Server.local;

/* Audio interface
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
*/

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
