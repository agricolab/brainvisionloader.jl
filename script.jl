# workspace()
include("readBrainVision.jl")
filename = "./data/example"
# DataInfo, ChanInfo = readHDR(filename)
EEG, DataInfo, ChanInfo = readEEG(filename)

## --------
using Gadfly
y = EEG[21,1:10*get(DataInfo,"SamplingRate",1000)];
x = 1:length(y);
xticks = [0:get(DataInfo,"SamplingRate",1000):length(y);]
plot(x=x,y=y,
    Geom.line,
    Guide.xlabel("Time (in ms)"),
    Guide.ylabel("Amplitude (in \muV )"),
    Guide.xticks(ticks=xticks)
    )
