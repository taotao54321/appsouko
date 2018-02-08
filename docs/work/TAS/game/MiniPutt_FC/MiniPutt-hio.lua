--[[
ミニパット (FC) HIO探索スクリプト

カーソルを初期位置から動かしていない状態で起動すること

ログはサブディレクトリ log/ 内に出力される(予め mkdir すること)
--]]


----------------------------------------------------------------------
-- util
----------------------------------------------------------------------

local function mem_read_u8(addr)
    return memory.readbyte(addr)
end

local function mem_write_u8(addr, value)
    memory.writebyte(addr, value)
end

local function mem_read_u16_le(addr)
    local lo = mem_read_u8(addr)
    local hi = mem_read_u8(addr+1)
    return bit.bor(lo, bit.lshift(hi, 8))
end

local function mem_write_u16_le(addr, value)
    local lo = bit.band(value, 0xFF)
    local hi = bit.band(bit.rshift(value, 8), 0xFF)
    mem_write_u8(addr, lo)
    mem_write_u8(addr+1, hi)
end

local function play(input, n)
    if n == nil then n = 1 end
    for i = 1, n do
        joypad.set(1, input)
        emu.frameadvance()
    end
end


----------------------------------------------------------------------
-- log
----------------------------------------------------------------------

local out = nil

local function out_init()
    local path = os.date("log/%Y%m%d-%H%M%S.log")

    out = io.open(path, "w")

    return out and true or false
end

local function out_fin()
    if out then
        out:close()
        out = nil
    end
end

local function info(msg)
    out:write(msg)
    out:write("\n")
    out:flush()
end


----------------------------------------------------------------------
-- game
----------------------------------------------------------------------

local function get_weather()
    return mem_read_u8(0x0545)
end

local function get_course()
    return mem_read_u8(0x04FC)
end

local function get_hole()
    return mem_read_u8(0x04FD)
end

local function get_ball_pos()
    local x = mem_read_u16_le(0xAB)
    local y = mem_read_u16_le(0xAD)
    return { x, y }
end

local function set_power(power)
    mem_write_u8(0x054E, power)
end

local function set_curve(curve)
    mem_write_u8(0x054D, curve)
end

local function get_cursor()
    local x = mem_read_u16_le(0x9B)
    local y = mem_read_u16_le(0x9D)
    return { x, y }
end

local function set_cursor(cursor)
    mem_write_u16_le(0x9B, cursor[1])
    mem_write_u16_le(0x9D, cursor[2])
end

--[[
local function miniputt_sgn(value)
    if value > 0 then
        return 1
    elseif value < 0 then
        return 0xFF
    else
        return 0
    end
end

local function set_vec(vec)
    for i = 0, 1 do
        mem_write_u8(0x8B + i, miniputt_sgn(vec[1+i]))
        mem_write_u16_le(0x97 + 2*i, math.abs(vec[1+i]))
    end
end
--]]


----------------------------------------------------------------------
-- 探索部
----------------------------------------------------------------------

local function shoot(power, curve, vec)
    -- カーソル位置に vec を加算
    local cursor = get_cursor()
    cursor[1] = cursor[1] + vec[1]
    cursor[2] = cursor[2] + vec[2]
    set_cursor(cursor)

    -- 書き換えたカーソル位置を反映させる
    play({})

    -- パワー、カーブ設定用フック
    memory.registerexec(0xD30C, function()
        set_power(power)
    end)
    memory.registerexec(0xD364, function()
        set_curve(curve)
    end)

    -- ボールを打つ操作
    play({ A = 1 }) -- スイング開始
    play({}, 10)
    play({ A = 1 }) -- パワー決定
    play({}, 6)
    play({ A = 1 }) -- カーブ決定

    memory.registerexec(0xD364, nil)
    memory.registerexec(0xD30C, nil)
end

local function is_success()
    local result = nil
    local done = false

    memory.registerexec(0xDF1E, function()
        result = mem_read_u8(0x89) == 0x8F
        done = true
    end)

    -- 4-2でボールが止まらないケースがあったので対処
    -- 上限フレーム数を超えたら強制終了し、 nil を返す

    for frame = 1, 10000 do
        play({})
        if done then break end
    end

    memory.registerexec(0xDF1E, nil)

    --[[
    -- カーソル座標が書き換えられたらカップインしなかったとみなす
    -- FIXME: これだとやや待ち時間が長い
    memory.registerwrite(0x9B, function()
        done = true
    end)

    while not done do
        -- ポインタ $047E が $E0E1 を指していればカップインとみなす
        -- (左下の絵がカップイン時のものになっているはず)
        local ptr_047E = mem_read_u16_le(0x047E)
        if ptr_047E == 0xE0E1 then
            result = true
            done = true
        end

        play({})
    end

    memory.registerwrite(0x9B, nil)
    --]]

    return result
end

local function power_is_valid(power)
    return 0x9D <= power and power <= 0xD3 and power%2 == 1
end

local function curve_is_valid(curve)
    return 0x10 <= curve and curve <= 0x40 and curve%2 == 0
end

-- あまりにカーソルが近すぎると打てない
local function vec_is_valid(vec)
    local abs_x = math.abs(vec[1])
    local abs_y = math.abs(vec[2])

    return (abs_x > 2 or abs_y > 2) or (abs_x == 2 and abs_y == 2)
end

local function print_result(wait, power, curve, vec, n_frame, ball_pos, result)
    -- ボールが止まらず強制終了した場合、ボール座標を (-1,-1) とする
    if result == nil then
        ball_pos = { -1, -1 }
    end

    local line = string.format(
        "%d\t0x%02X\t0x%02X\t%d\t%d\t%d\t%d\t%d\t%d",
        wait, power, curve, vec[1], vec[2],
        n_frame, ball_pos[1], ball_pos[2], result and 1 or 0
    )

    info(line)
    if result then print(line) end
end

local function timestamp()
    return os.date("%Y/%m/%d %H:%M:%S")
end

local function search(power_range, curve_range, vecx_range, vecy_range, waits)
    assert(power_is_valid(power_range[1]) and power_is_valid(power_range[2]))
    assert(curve_is_valid(curve_range[1]) and curve_is_valid(curve_range[2]))

    if waits == nil then waits = { 0, 0, 1 } end

    info(string.format("# SEARCH START (%s)", timestamp()))
    info("")

    local ball_pos = get_ball_pos()
    info(string.format("# weather: %d", get_weather()))
    info(string.format("# hole: %d-%d", 1+get_course(), 1+get_hole()))
    info(string.format("# ball: (%d,%d)", ball_pos[1], ball_pos[2]))
    info("")

    info(string.format("# waits: %d, %d, %d", waits[1], waits[2], waits[3]))
    info(string.format("# power: [0x%02X,0x%02X]", power_range[1], power_range[2]))
    info(string.format("# curve: [0x%02X,0x%02X]", curve_range[1], curve_range[2]))
    info(string.format("# vecx: [%d,%d]", vecx_range[1], vecx_range[2]))
    info(string.format("# vecy: [%d,%d]", vecy_range[1], vecy_range[2]))
    info("")
    info(string.format("# wait\tpower\tcurve\tvecx\tvecy\tnframe\tballx\tbally\tresult"))

    local count = 0
    local frame_start = emu.framecount()

    local state = savestate.object()
    savestate.save(state)

    for wait = waits[1], waits[2], waits[3] do
        for vecx = vecx_range[1], vecx_range[2] do
            for vecy = vecy_range[1], vecy_range[2] do
                local vec = { vecx, vecy }
                if vec_is_valid(vec) then
                    for power = power_range[1], power_range[2], 2 do
                        for curve = curve_range[1], curve_range[2], 2 do
                            savestate.load(state)

                            play({}, wait)

                            shoot(power, curve, vec)
                            local result = is_success()
                            local n_frame = emu.framecount() - frame_start
                            local ball_pos = get_ball_pos()
                            print_result(wait, power, curve, vec,
                                         n_frame, ball_pos, result)

                            count = count + 1
                        end
                    end
                end
            end
        end
    end

    info("")
    info(string.format("# SEARCH END (%s) count=%d", timestamp(), count))
end


----------------------------------------------------------------------
-- main
----------------------------------------------------------------------

local function init()
    if not out_init() then
        print("Can't open file")
        return false
    end

    emu.speedmode("maximum")
    --emu.setrenderplanes(false, false)

    return true
end

local function fin()
    --emu.setrenderplanes(true, true)
    emu.speedmode("normal")

    out_fin()
end

local function main()
    if not init() then
        print("init() failed")
        return
    end
    emu.registerexit(fin)

    -- カーソルが範囲外だとボールが止まらなくなることがあるので注意

    search(
        { 0x9D, 0x9D }, -- power
        { 0x10, 0x10 }, -- curve
        { -10, 10 }, -- vecx
        { -10, 10 }, -- vecy
        { 0, 143, 1 } -- waits
    )
    --[[
    search(
        { 0x9D, 0x9D }, -- power
        { 0x10, 0x10 }, -- curve
        { -2, 2 }, -- vecx
        { -2, 2 }, -- vecy
        nil -- waits
    )
    --]]

    --[[
    search(
        { 0x9D, 0xD3 }, -- power
        { 0x10, 0x40 }, -- curve
        { -2, 2 }, -- vecx
        { -2, 2 }, -- vecy
        nil -- waits
    )
    --]]

    -- "Stop" を押さなくてもログ出力は完了してほしい
    fin()

    emu.pause()
end

main()
