

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