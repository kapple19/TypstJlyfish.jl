function watch(
    typst_file;
    typst_args = "",
    evaluation_file = default_output_file(typst_file),
    watch_path = typst_file,
)
    @assert isfile(typst_file) "`$typst_file` does not exist."
    @assert ispath(watch_path) "`$watch_path` does not exist."

    Pkg.activate(mktempdir(prefix = "jlyfish-eval"))

    jlyfish_state = JlyfishState(;
        evaluation_file,
        typst_file,
        typst_args = split(typst_args),
    )

    while true
        @info Dates.format(Dates.now(), "HH:MM:SS")

        try
            execute!(jlyfish_state)
        catch e
            if e isa StopRunning
                break
            elseif e isa WaitForChange
            else
                throw(e)
            end
        end

        @info "Waiting for input to change..."
        try
            BetterFileWatching.watch_file(watch_path)
        catch e
            if e isa InterruptException
                break
            else
                throw(e)
            end
        end
    end

    @info "Stopping Jlyfish. Bye!"
end
