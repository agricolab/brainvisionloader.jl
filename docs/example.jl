
using Plots
using brainvisionloader

filename = "data/example"
EEG = brainvisionloader.loadFile(filename)

toi     = EEG.markers[2,2]-EEG.srate:EEG.markers[2,2]+EEG.srate;
y       = EEG.data[25,toi]
x       = [1:length(y)]-EEG.srate
xtick   = -EEG.srate:(EEG.srate/4):EEG.srate

plot(x, y,
    linewidth=2,
    alpha=0.6,
    title="EEG Trace",
    legend=:none,
    xlabel = "Time [ms]",
    ylabel = "Amplitude [μV]",
    size = (1024,480),
    xticks = xtick,
    );
gui()
savefig("./example.png")
