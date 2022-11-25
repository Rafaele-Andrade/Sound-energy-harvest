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
							3, {
								var rand = tBetweenTrig.clip(0.0001, 20).linlin(0.001, 20, 0, 0.1);
								var randSign = [-1, 1].choose;
								Synth("\resTuning_%".format(1),
									[
										\attack, ~attack, //1 + (4.0).rand,
										\release, ~release, //1 + (15.0).rand,
										\beating, 7,
										\coef,  0.001,
										\array, ~array,
										\pan, ~pan,
										\iteration,~iter
									]
									, target: ~synthGrp);},
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