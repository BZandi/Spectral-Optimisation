# Spectral optimisation pipeline for multi-primary LED luminaries 
In this repository, the Matlab code for spectrally optimising a 15-channel LED luminaire, using a multi-objective optimisation method is provided. The current version of this code can optimise a spectrum with the objectives luminance and the CIExy-1931 chromaticity coordinates.

**Correspondence:** [zandi@lichttechnik.tu-darmstadt.de](mailto:zandi@lichttechnik.tu-darmstadt.de)<br>
**Google Scholar Profile:** [Babak Zandi](https://scholar.google.de/citations?user=LSA7SdAAAAAJ&hl=de)<br>
**Twitter:** [@BkZandi](https://twitter.com/bkzandi)

## Usage

In the `Matlab/Main.m file`, the target luminance and the target chromaticity coordinates can be adjusted through the value `qp`. For example, if you want to optimise a spectrum that yields a luminance of 200 cd/m2 with a CIExy-1931 chromaticity coordinate of (0.333, 0.333), type `qp = [200, 0.333, 0.333]`. In addition, you need to set the tolerance criteria. The tolerances need to be set in the `Matlab/Main.m` file and the `Matlab/A01_Methods/runOptim_GA.m` (see the Method `myOutputFunction(options, state, flag)`).

To run the optimisation procedure you can simply call 

```matlab
qp = [500, 0.333, 0.333];
tolerance = [0.1, 0.0001, 0.0001];
num_channels = 15; % We use a 15-channel LED luminiare
population_size = 5000; % Size of the initial population
max_iter = 100000; % Count of iterations (Generations) of the optimisation
max_time = 1200; % Maximum optimisation time in seconds
last_pop = [];
scores = [];

% Run the optimisation
% Note that you need to adjust the tolerances in the myOutputFunction() inside
% the runOptim_GA() function. Currently the thresholds are set to "tolerance = [0.1, 0.0001, 0.0001]"
[x, fval, exitflag, output, last_population, scores] = runOptim_GA(qp,...
    num_channels, population_size, max_iter, max_time, last_pop, scores);
```

## Miscellaneous

If you are interested in spectral optimisation of multi-channel LED luminaires, take a look at this publication:

Babak Zandi, Adrian Eissfeldt, Alexander Herzog & Tran Quoc Khanh. Melanopic Limits of Metamer Spectral Optimisation in Multi-Channel Smart Lighting Systems. *Energies*.**14**, 572 (2021). MDPI. DOI: https://doi.org/10.3390/en14030527.

## License

This code is licensed under [CC BY 4.0](https://github.com/BZandi/Spectral-Optimisation/blob/main/LICENSE).

