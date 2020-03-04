# brainvisionloader
Loads raw brainvision data into Julia

# Install

```
Pkg.add("https://github.com/agricolab/brainvisionloader.jl")
```

The magic happens in

`src/brainvisionloader.jl`

Check out `doc/example.jl` to see how to read & plot the exemplary dataset ( below)

```julia
using brainvisionloader

EEG = brainvisionloader.loadFile(filename)
# EEG.marker
# EEG.data
# EEG.srate
# EEG.labels
```

<img src = "./docs/example.png">
