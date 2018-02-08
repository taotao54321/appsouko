

function parse_sol_file()
    sol_list = {}

    inp = io.open("sol.txt", "r")
    for line in inp:lines() do
        sol = {}
        string.gsub(line, "%d+", function(s) table.insert(sol, tonumber(s)) end)
        table.insert(sol_list, sol)
    end
    inp:close()

    return sol_list
end

function play_wait(n)
    for i = 0, n-1 do FCEU.frameadvance() end
end

function play_move(y_dst)
    y_src = memory.readbyte(0x0302)/16 - 2

    if y_src == y_dst then
        return
    elseif y_src < y_dst then
        input = { down = 1 }
        n_move = y_dst - y_src
    else
        input = { up = 1 }
        n_move = y_src - y_dst
    end

    for i = 0, n_move-1 do
        joypad.set(1, input)
        FCEU.frameadvance()
        play_wait(15)
    end
end

function play_throw()
    joypad.set(1, { A = 1 })
    FCEU.frameadvance()
    play_wait(9)

    while memory.readbyte(0x0306) ~= 0xA0 do
        FCEU.frameadvance()
    end
end

function play_sol(sol)
    for i,move in ipairs(sol) do
        play_move(move)
        play_throw()
    end
end

sol_optimal = -1
frame_min = 99999999
function main()
    FCEU.speedmode("maximum")

    sol_list = parse_sol_file()

    state_orig = savestate.create()
    state_ok = nil
    savestate.save(state_orig)
    for i,sol in ipairs(sol_list) do
        play_sol(sol)

        --[[
        num_block = memory.readbyte(0x0313)
        quota = memory.readbyte(0x031D)

        if num_block > quota then
            gui.popup(string.format("Solution #%d error", i))
        end
        ]]

        -- "JUST CLEAR" チェック
        play_wait(5)
        if memory.readbyte(0x0586) == 0x4A then
            frame = movie.framecount()
            if frame < frame_min then
                sol_optimal = i
                frame_min = frame
                state_ok = savestate.create(1)
                savestate.save(state_ok)
            end
        end

        savestate.load(state_orig)
    end

    gui.popup(string.format("Optimal solution: #%d", sol_optimal))

    if state_ok then savestate.load(state_ok) end
end

main()
