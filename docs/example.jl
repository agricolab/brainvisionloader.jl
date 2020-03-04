# workspace()
using Plots
plotlyjs()
include("readBrainVision.jl")

filename = "./data/example"
EEG = NI.loadFile(filename)

## --------
toi     = EEG.Markers[2,2]-EEG.SamplingRate:EEG.Markers[2,2]+EEG.SamplingRate;
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
savefig("./data/example.png")
