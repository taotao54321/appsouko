-- 今のところ個々の random 入力の確率を変えるようなことはなさそうなので固定
local P_RANDOM = 500

local N_WAIT = 1

function my_main()
    my_random_init()

    --FCEU.speedmode("normal")
    FCEU.speedmode("maximum")
    local state = savestate.create()
    savestate.save(state)

    local frame_best = 2700
    local state_best = savestate.create(1)

    FCEU.message("searching...")

    for i = 1, 1000 do
        attempt_attack_VL()

        for i = 2610, 2650 do
            if i >= frame_best then
                break
            end

            local hp_vl = 101
            local dmg = memory.readbyte(0x006D)
            if dmg >= hp_vl then
                frame_best = i
                savestate.save(state_best)
                FCEU.message("Best: " .. frame_best)
                break
            end

            input_random()
        end

        savestate.load(state)
    end
end

function attempt_attack_VL()
    -- 2474-2494F random
    for i = 2474, 2494 do
        input_random()
    end

    -- 2495-2496F A
    for i = 2495, 2496 do
        input_a()
    end

    -- 2497-2591F random
    for i = 2497, 2591 do
        input_random()
    end

    for i = 1, N_WAIT do
        FCEU.frameadvance()
    end

    -- 2592-2593F A
    for i = 2592, 2593 do
        input_a()
    end

    -- 2594-2597F random
    for i = 2594, 2597 do
        input_random()
    end

    -- 2598F 無入力
    FCEU.frameadvance()

    -- 2599F v
    -- 2600F vA
    -- 2601F A
    input({ down = 1 })
    input({ down = 1, A = 1 })
    input({ A = 1 })

    -- 2602-2607F random
    for i = 2602, 2607 do
        input_random()
    end

    -- 2608-2609F A
    for i = 2608, 2609 do
        input_a()
    end
end

function num2inp(n)
    local inp = {}
    inp.up = (AND(n, 0x01) > 0) and 1 or nil
    inp.down = (AND(n, 0x02) > 0) and 1 or nil
    inp.left = (AND(n, 0x04) > 0) and 1 or nil
    inp.right = (AND(n, 0x08) > 0) and 1 or nil
    return inp
end

function input(inp)
    joypad.set(1, inp)
    FCEU.frameadvance()
end

function input_a()
    local inp = { A = 1 }
    input(inp)
end

function input_random()
    local inp = {}
    inp.up = (my_random(1000) <= P_RANDOM) and 1 or nil
    inp.down = (my_random(1000) <= P_RANDOM) and 1 or nil
    inp.left = (my_random(1000) <= P_RANDOM) and 1 or nil
    inp.right = (my_random(1000) <= P_RANDOM) and 1 or nil
    input(inp)
end

function my_random_init()
    math.randomseed(os.time())
end

function my_random(n)
    return math.random(n)
end

my_main()
