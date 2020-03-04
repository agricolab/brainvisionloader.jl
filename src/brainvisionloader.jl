module brainvisionloader

struct dataset
    data::Array{Float64}
    labels::Array{String}
    markers
    srate::Float64
end

function loadFile(filename::String)
    dataInfo, chanInfo  = readHDR(filename)
    trial               = readEEG(filename,dataInfo,chanInfo)
    markers             = readMRK(filename)
    EEG                 = dataset(trial,chanInfo[1,:],markers,get(dataInfo,"srate",NaN));
    return EEG
end

function readEEG(filename::String,dataInfo,chanInfo)
    open(string(filename,".eeg")) do f
        filesize    = position(seekend(f))
        framenumber = Int64(filesize/( get(dataInfo,"ByteLength",2) * get(dataInfo,"ChannelNumber",32)))
        filedim     = (get(dataInfo,"channelNumber",32),framenumber)
        seekstart(f)
        trial = reinterpret(Int16,read(f))
    end


    trial = collect(trial)

    trial = reshape(trial,size(chanInfo,2),:)
    trial = trial.*repeat(chanInfo[2,:],1,size(trial,2))

    return trial
end

function readMRK(filename::String)
    doCollect   = false

    markerInfo  = hcat(Array{String},Array{String},Array{Int64},Array{Int64})
    open(string(filename,".vmrk")) do f
        while !eof(f)
            x = readline(f)
            # Read Channel-Specific Info

            if contains(x[1:2],"\r\n"); doCollect = false; end
            if doCollect
                MarkerInfo  = vcat(MarkerInfo,getMarkerSegment(x))
            end
            if contains(x,"; Commas in type or description text are coded")

                if length(x)==0 || isnothing(x) || any(occursin("\r\n",x[1:2]))
                    doCollect = false;
                end
                if doCollect
                    markerInfo  = vcat(markerInfo,getMarkerSegment(x))
                end
                if occursin("; Commas in type or description text are coded",x)
                    # once we are here, start collecting the markers

                    doCollect = true
                end
            end
        end

        return MarkerInfo
    end

    return markerInfo
end

function getMarkerSegment(x)
    type,code,position,duration,chan = split(split(x,"=")[2],",")
    position   = parse(Int64,position)
    return Mrk  = hcat(type,code,position,duration)
end

function readHDR(filename::String)
    Fs            = NaN;
    dataformat    = "";
    bitformat     = NaN;
    dataOrient    = "";
    binaryformat  = "";
    NumChan       = NaN;
    chanInfo      = [];
    dataInfo      = [];

    println(filename)

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

function getchanInfo(x::String)

    id,other = split(x,"=")

    name,ref,res,unit  = split(other,",")

    res       = parse(Float64,res);
    info      = [name;res;id]

    return info
end

function getGeneralInfo(x::String)
    return split(x,':')[2];

end

function getdataInfo(x::String)
    return split(x,'=')[2];

end

function getencoding(x::String)
    TypeEncode  = Dict("INT_16" => "Int16","UINT_16" => "UInt16","FLOAT_32" => "Float32");
    BitEncode    = Dict("INT_16" => 2,"UINT_16" => 2,"FLOAT_32" => 4);
    return TypeEncode[getdataInfo(x)], BitEncode[getdataInfo(x)];

end

end
