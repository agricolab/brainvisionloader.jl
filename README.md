# brainvisionloader
Loads raw brainvision data into Julia

The magic happens in

readBrainVision.jl

Check out script.jl to see how to read & plot the exemplary dataset

```julia
include("readBrainVision.jl")

filename = "./data/example"
EEG = NI.loadFile(filename)

y = EEG.data[25,1:10*EEG.SamplingRate]
x = 1:length(y)
```

<img src = "./data/example.png">
