# brainvisionloader
Loads raw brainvision data into Julia

The magic happens in

readBrainVision.jl

Check out script.jl to see how to read & plot the exemplary dataset

```julia
using Plots

using brainvisionloader

filename = "./data/example"
EEG = brainvisionloader.loadFile(filename)

## --------
toi     = EEG.Markers[2,2]-EE:G.SamplingRate:EEG.Markers[2,2]+EEG.SamplingRate;
y       = EEG.data[25,toi]
x       = [1:length(y)]-EEG.SamplingRate
xtick   = -EEG.SamplingRate:(EEG.SamplingRate/4):EEG.SamplingRate

plot(x, y,
    linewidth=2,
    alpha=0.6,
    title="EEG Trace",
    legend=:none,
    xlabel = "Time in ms",
    ylabel = "Amplitude in μV",
    size = (1024,480),
    xticks = xtick,
    );
gui()
savefig("./docs/example.png")
```

<img src = "./docs/example.png">
