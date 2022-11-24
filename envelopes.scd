/* Custom envelopes. Currently not in use*/
~makeEnvelopes = {
	~env_qgauss = Env([0, 1, 1, 0], [0.25, 0.5, 0.25], \sin);
	~env_welch = Env([0, 1, 1, 0], [0.25, 0.5, 0.25], \welch);
	~psShiftEnv = Env([0, 1, 1, 0], [0.2, 0.7, 0.1], -4);
};