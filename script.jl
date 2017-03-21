# workspace()
using Plots
plotlyjs()
# unicodeplots()
include("readBrainVision.jl")

filename = "./data/example"
# DataInfo, ChanInfo = readHDR(filename)
EEG, DataInfo, ChanInfo = readEEG(filename)


## --------
y = EEG[25,1:10*get(DataInfo,"SamplingRate",1000)];
x = 1:length(y);

gui()
plt = plot(x, y,
    linewidth=2,
    alpha=0.6,
    title="EEG Trace",
    legend=:none,
    xlabel = "Time in ms",
    ylabel = "Amplitude in μV",
    size = (1024,480),
    );
savefig("./data/example.png")
