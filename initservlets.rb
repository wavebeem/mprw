class InitServlets
    EOL = "\r\n"

    def initialize server, mpd
        @server = server
        @mpd    = mpd

        # Percentage by which to increment volume
        @d_volume = 5

        # Maps "directories" on the server to methods in this class
        @mapping = {
            "prev"          => :prev,
            "next"          => :next,
            "stop"          => :stop,
            "pause"         => :pause,
            "play"          => :play,
            "playpause"     => :play_pause,
            "debug"         => :debug,
            "volup"         => :vol_up,
            "voldown"       => :vol_down,
            "nowplaying"    => :now_playing,
        }

        # Prefix to the "directories" above
        @prefix = "/message"
    end

    def load
        @mapping.each do |k, v|
            dir = @prefix + "/" + k
            fun = method v

            @server.mount_proc dir, fun
        end
    end

    def prev req, resp
        @mpd.previous
        resp.body = "Previous"
    end

    def next req, resp
        @mpd.next
        resp.body = "Next"
    end

    def stop req, resp
        @mpd.stop
        resp.body = "Stop"
    end

    def pause req, resp
        @mpd.pause = true
        resp.body = "Pause"
    end

    def play req, resp
        @mpd.play
        resp.body = "Play"
    end

    def play_pause req, resp
        @mpd.pause = !  @mpd.paused?
        resp.body  = if @mpd.paused?
            then "Pause"
            else "Play"
        end
    end

    def vol_up req, resp
        @mpd.volume += @d_volume
        resp.body = "Volume #{@mpd.volume}"
    end

    def vol_down req, resp
        @mpd.volume -= @d_volume
        resp.body = "Volume #{@mpd.volume}"
    end

    def now_playing req, resp
        song = @mpd.current_song

        stats = %w[title album artist time]
        stats.each do |stat|
            resp.body << stat << " " << song.send(stat) << EOL
        end
    end

    def debug req, resp
        stats = @mpd.stats
        stats.each do |k, v|
            resp.body << "#{k}: #{v}" << "\n"
        end
    end
end
