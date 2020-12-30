export Microphone

struct Microphone end

function show(io::IO, ::MIME"text/html", microphone::Microphone)
    mic_id = randstring('a':'z')
    mic_btn_id = randstring('a':'z')
    microphone
    withtag(() -> (), io, :audio, :id => mic_id)
    print(io, """<input type="button" id="$mic_btn_id" class="mic-button" value="Stop">""")
    withtag(io, :script) do 
        print(io, """
            const player = document.getElementById('$mic_id');
            const stop = document.getElementById('$mic_btn_id');
        
            const handleSuccess = function(stream) {
            const context = new AudioContext({ sampleRate: 44100 });
            const analyser = context.createAnalyser();
            const source = context.createMediaStreamSource(stream);
        
            source.connect(analyser);
            
            const bufferLength = analyser.frequencyBinCount;
            
            let dataArray = new Float32Array(bufferLength);
            let animFrame;
            
            const streamAudio = () => {
                animFrame = requestAnimationFrame(streamAudio);
                analyser.getFloatTimeDomainData(dataArray);
                player.value = dataArray;
                player.dispatchEvent(new CustomEvent("input"));
            }
        
            streamAudio();
        
            stop.onclick = e => {
                source.disconnect(analyser);
                cancelAnimationFrame(animFrame);
            }
            }
        
            navigator.mediaDevices.getUserMedia({ audio: true, video: false })
            .then(handleSuccess)
        """
        )
    end
    withtag(io, :style) do 
        print(io, """
            .mic-button {
                background-color: darkred;
                border: none;
                border-radius: 6px;
                color: white;
                padding: 15px 32px;
                text-align: center;
                text-decoration: none;
                display: inline-block;
                font-size: 16px;
                font-family: "Alegreya Sans", sans-serif;
                margin: 4px 2px;
                cursor: pointer;
            }
        """
        )
    end
end

get(microphone::Microphone) = microphone