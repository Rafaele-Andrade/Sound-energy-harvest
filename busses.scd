
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
