function readEEG(filename)
    DataInfo, ChanInfo = readHDR(filename)
    f           = open(string(filename,".eeg"))
    FileSize    = position(seekend(f))
    FrameNumber = Int64(FileSize/( get(DataInfo,"ByteLength",2) * get(DataInfo,"ChannelNumber",32)))
    FileDim     = (get(DataInfo,"ChannelNumber",32),FrameNumber)
    seekstart(f)
    EEG         = float(read(f, Int16, FileDim[1],FileDim[2]))
    close(f)
    EEG         = EEG.*repmat(ChanInfo[2,:],1,size(EEG,2))

    return EEG, DataInfo, ChanInfo
end

function readHDR(filename)
    filename      = string(filename,".vhdr")
    Fs            = NaN;
    dataFormat    = "";
    bitFormat     = NaN;
    dataOrient    = "";
    binaryFormat  = "";
    NumChan       = NaN;
    ChanInfo      = [];
    DataInfo      = [];
    doCollect     = false;
    open(filename) do f
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

function getChanInfo(x)
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

function getGeneralInfo(x)
    s  = search(x,':');
    return x[s+2:end-2];
end

function getDataInfo(x)
    s  = search(x,'=');
    return x[s+1:end-2];
end

function getEncoding(x)
    TypeEncode  = Dict("INT_16" => "Int16","UINT_16" => "UInt16","FLOAT_32" => "Float32");
    BitEncode    = Dict("INT_16" => 2,"UINT_16" => 2,"FLOAT_32" => 4);
    return TypeEncode[getDataInfo(x)], BitEncode[getDataInfo(x)];
end
