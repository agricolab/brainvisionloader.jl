#
workspace()
using Plots
plotlyjs()
# unicodeplots()
include("readBrainVision.jl")

filename = "./data/example"
EEG = NI.loadFile(filename)

## --------
y = EEG.data[25,1:10*EEG.SamplingRate]
x = 1:length(y)

plot(x, y,
    linewidth=2,
    alpha=0.6,
    title="EEG Trace",
    legend=:none,
    xlabel = "Time in ms",
    ylabel = "Amplitude in μV",
    size = (1024,480),
    );

savefig("./data/example.png")
