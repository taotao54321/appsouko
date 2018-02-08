-- 今のところ個々の random 入力の確率を変えるようなことはなさそうなので固定
local P_RANDOM = 500

local LAG_VIRTUAL = 20

function my_main()
    my_random_init()

    --FCEU.speedmode("normal")
    FCEU.speedmode("maximum")
    local state = savestate.create()
    savestate.save(state)

    FCEU.message("searching...")

    for i = 1, 1000 do
        attempt_MALOR()

        -- 念のため数フレーム待ち(テレポーターの例から)
        for i = 1, 5 do
            FCEU.frameadvance()
        end

        local level = memory.readbyte(0x003D)
        local x = memory.readbyte(0x003B)
        local y = memory.readbyte(0x003C)
        if level == 10 and x == 17 and y == 4 then
            local state_good = savestate.create(1)
            savestate.save(state_good)
            FCEU.message("Success!! saved state 1.")
            break
        end

        savestate.load(state)
    end
end

function attempt_MALOR()
    -- 2191-2286F random
    for i = 2191, 2286 do
        input_random()
    end

    -- 2287F 無入力
    FCEU.frameadvance()

    -- 2288-2289F v
    for i = 2288, 2289 do
        input({ down = 1 })
    end

    -- 2290F 無入力
    FCEU.frameadvance()

    -- 2291F v
    -- 2292F vA
    -- 2293F A
    input({ down = 1 })
    input({ down = 1, A = 1 })
    input({ A = 1 })

    -- 2294-2299F random
    for i = 2294, 2299 do
        input_random()
    end

    -- 2300-2301F A
    for i = 2300, 2301 do
        input_a()
    end

    -- 2302-2307F random
    for i = 2302, 2307 do
        input_random()
    end

    -- 2308-2309F A
    for i = 2308, 2309 do
        input_a()
    end

    -- 1-nF random (仮想ラグ)
    for i = 1, LAG_VIRTUAL do
        input_random()
    end

    -- 1-2F A
    for i = 1, 2 do
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
