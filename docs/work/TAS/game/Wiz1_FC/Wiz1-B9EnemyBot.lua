-- 今のところ個々の random 入力の確率を変えるようなことはなさそうなので固定
local P_RANDOM = 500

local HP_MAX = 24

function my_main()
    my_random_init()

    --FCEU.speedmode("normal")
    FCEU.speedmode("maximum")
    local state = savestate.create()
    savestate.save(state)

    FCEU.message("searching...")

    for i = 1, 1000 do
        local inp_user = joypad.read(1)
        if inp_user.select ~= nil then
            break
        end

        attempt_enemy()

        local id = memory.readbyte(0x7AD1)
        local count = memory.readbyte(0x7AC5)
        local hp = memory.readbyte(0x7BE4)
        local count2 = memory.readbyte(0x7AC6)
        if id >= 80 and count == 1 and hp <= HP_MAX and count2 == 0 then
            local state_good = savestate.create(1)
            savestate.save(state_good)
            FCEU.message("Success!! saved state 1.")
            break
        end

        -- 謎リセットが発生するので数フレーム待つ
        for i = 1, 5 do
            FCEU.frameadvance()
        end
        savestate.load(state)
    end
end

function attempt_enemy()
    -- 1616-1683F random
    for i = 1616, 1683 do
        input_random()
    end
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
