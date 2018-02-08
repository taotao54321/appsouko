FLIPULL_W = 8
FLIPULL_H = 12

CELL_EMPTY = 0
CELL_WALL = -1
CELL_PIPE_V = -3
CELL_EXTEND = 5

CH_CELL = {
    [CELL_EMPTY] = " ",
    [CELL_WALL] = "#",
    [CELL_PIPE_V] = "|",
    [CELL_EXTEND] = "S",
    [1] = "1",
    [2] = "2",
    [3] = "3",
    [4] = "4",
}

function coord1(x, y)
    return x+1 + (FLIPULL_W+2)*(y+1)
end

function get_row(value)
    row = {}

    for i = 0, 7 do
        mask = 2^(7-i)
        if AND(value, mask) > 0 then row[i] = true else row[i] = false end
    end

    return row
end

function get_problem()
    prob = {}

    prob.quota = memory.readbyte(0x031D)
    prob.block = memory.readbyte(0x030F)
    prob.cell = {}

    for y = 0, FLIPULL_H-1 do
        wall = get_row(memory.readbyte(0x0440+y))
        pipe = get_row(memory.readbyte(0x044C+y))
        for x = 0, FLIPULL_W-1 do
            coord = coord1(x,y)
            prob.cell[coord] = CELL_EMPTY
            if wall[x] then prob.cell[coord] = CELL_WALL end
            if pipe[x] then prob.cell[coord] = CELL_PIPE_V end
        end
    end

    for y = 6, FLIPULL_H-1 do
        for x = 0, 7 do
            coord = coord1(x,y)
            cell = memory.readbyte(0x0400 + 8*(y-6) + x)
            if cell > 0 then prob.cell[coord] = cell end
        end
    end

    return prob
end

function print_problem(prob, n)
    path = string.format("problem-N%03d-%02d.txt", memory.readbyte(0xF2)+1, n+1)
    out = io.open(path, "w")

    out:write(string.format("%d\n", prob.quota))
    out:write(string.format("%d\n", prob.block))
    for y = 0, FLIPULL_H-1 do
        for x = 0, FLIPULL_W-1 do
            coord = coord1(x,y)
            out:write(CH_CELL[prob.cell[coord]])
        end
        out:write("\n")
    end

    out:close()
end

function play_wait(n)
    for i = 0, n-1 do
        FCEU.frameadvance()
    end
end

function main()
    state = savestate.create()
    savestate.save(state)
    for i = 0, 9 do
        play_wait(i)
        joypad.set(1, { A = 1 })
        FCEU.frameadvance()
        play_wait(8)

        prob = get_problem()
        print_problem(prob, i)

        savestate.load(state)
    end
end

main()
