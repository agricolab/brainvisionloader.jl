module NI

type dataset
    data::Array{Float64}
    labels::Array{String}
    Markers
    SamplingRate::Int32
end

function loadFile(filename::String)
    DataInfo, ChanInfo  = readHDR(filename)
    trial               = readEEG(filename,DataInfo,ChanInfo)
    Markers             = readMRK(filename)
    EEG                 = dataset(trial,ChanInfo[1,:],Markers,get(DataInfo,"SamplingRate",NaN));
    return EEG
end

function readEEG(filename::String,DataInfo,ChanInfo)
    open(string(filename,".eeg")) do f
        FileSize    = position(seekend(f))
        FrameNumber = Int64(FileSize/( get(DataInfo,"ByteLength",2) * get(DataInfo,"ChannelNumber",32)))
        FileDim     = (get(DataInfo,"ChannelNumber",32),FrameNumber)
        seekstart(f)
        trial       = float(read(f, Int16, FileDim[1],FileDim[2]))
    end
    trial       = trial.*repmat(ChanInfo[2,:],1,size(trial,2))
    return trial
end

function readMRK(filename::String)
    doCollect   = false
    MarkerInfo  = hcat(Array{String}(0,1),Array{Int64}(0,1))
    open(string(filename,".vmrk")) do f
        while !eof(f)
            x = readline(f)
            # Read Channel-Specific Info
            if contains(x[1:2],"\r\n"); doCollect = false; end
            if doCollect
                MarkerInfo  = vcat(MarkerInfo,getMarkerSegment(x))
            end
            if contains(x,"; Commas in type or description text are coded")
                doCollect = true
            end
        end
    end
    return MarkerInfo
end

function getMarkerSegment(x)
    k1          = search(x,',')
    k2          = search(x,',',k1+1)
    k3          = search(x,',',k2+1)
    MarkerCode  = x[k1+1:k2-1]
    MarkerSeg   = parse(Int64,x[k2+1:k3-1])
    return Mrk  = hcat(MarkerCode,MarkerSeg)
end

function readHDR(filename::String)
    Fs            = NaN;
    dataFormat    = "";
    bitFormat     = NaN;
    dataOrient    = "";
    binaryFormat  = "";
    NumChan       = NaN;
    ChanInfo      = [];
    DataInfo      = [];
    doCollect     = false;
    open(string(filename,".vhdr")) do f
        while !eof(f)
            x = readline(f)

          # Read General Info
            if contains(x,"Sampling Rate [Hz]:");
                Fs = parse(Int32,getGeneralInfo(x));
            end
            if contains(x,"Number of channels:");
                NumChan = parse(Int32,getGeneralInfo(x));
            end
            if contains(x,"DataFormat")
                dataFormat = getDataInfo(x);
            end
            if contains(x,"DataOrientation")
                dataOrient = getDataInfo(x);
            end
            if contains(x,"BinaryFormat");
                binaryFormat,bitFormat = getEncoding(x)
            end

            # Read Channel-Specific Info
            if contains(x[1:2],"\r\n"); doCollect = false; end
            if doCollect; ChanInfo = hcat(ChanInfo,getChanInfo(x)); end
            if contains(x,"Ch1="); doCollect = true; ChanInfo = getChanInfo(x); end

        end
    end
    DataInfo = Dict("SamplingRate"=>Fs,"ChannelNumber"=>NumChan,"Encoding"=>binaryFormat,"ByteLength"=>bitFormat,"Format"=>dataFormat,"Orientation"=>dataOrient)
    return DataInfo, ChanInfo
end

function getChanInfo(x::String)
    h         = search(x,'h');
    s         = search(x,'=');
    e         = search(x,',');
    v         = search(x,'V');
    name      = x[s+1:e-1];
    id        = parse(Int64,x[h+1:s-1]);
    res       = parse(Float32,x[e+2:v-4]);
    info      = [name;res;id]
    return info
end

function getGeneralInfo(x::String)
    s  = search(x,':');
    return x[s+2:end-2];
end

function getDataInfo(x::String)
    s  = search(x,'=');
    return x[s+1:end-2];
end

function getEncoding(x::String)
    TypeEncode  = Dict("INT_16" => "Int16","UINT_16" => "UInt16","FLOAT_32" => "Float32");
    BitEncode    = Dict("INT_16" => 2,"UINT_16" => 2,"FLOAT_32" => 4);
    return TypeEncode[getDataInfo(x)], BitEncode[getDataInfo(x)];
end


end
