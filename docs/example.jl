
using Plots
plotly()
using brainvisionloader

filename = "../data/example"
EEG = brainvisionloader.loadFile(filename)

toi     = range(EEG.markers[2,3]-EEG.srate,stop=EEG.markers[2,3]+EEG.srate);
y       = EEG.data[25,Int64.(toi)]
x       = collect(1:length(y)) .-EEG.srate
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
