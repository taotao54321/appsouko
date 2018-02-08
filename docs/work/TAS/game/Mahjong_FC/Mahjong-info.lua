if not bit then require("bit"); end

local GUI_OPACITY = 0.8

local RAND_INI = {
    0x0C, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0
}

local rand_table = {}

function array_append(a, v)
    a[#a+1] = v
end

function array_equals(a1, a2)
    if #a1 ~= #a2 then return false; end
    for i = 1, #a1 do
        if a1[i] ~= a2[i] then return false; end
    end
    return true
end

function mem_read_bytes(addr, n)
    local ary = {}
    for i = 1, n do
        array_append(ary, memory.readbyte(addr+i-1))
    end
    return ary
end

function rand_update(r)
    local c = bit.rshift(bit.bxor(bit.band(r[1], 0x02), bit.band(r[2], 0x02)), 1)
    for i = 1, 32 do
        local c2 = bit.band(r[i], 0x01)
        r[i] = bit.rshift(r[i], 1)
        r[i] = bit.bor(r[i], bit.lshift(c, 7))
        c = c2
    end
end

function init_rand_table()
    local r = { unpack(RAND_INI) }
    for i = 1, 237+32767 do
        array_append(rand_table, { unpack(r) })
        rand_update(r)
    end
end

local info = {}
info.rand_idx = -1

function on_exec_CA95()
    info.rand_idx = -1
    local r = mem_read_bytes(0x23, 0x20)
    for i = 1, #rand_table do
        if array_equals(r, rand_table[i]) then
            info.rand_idx = i-1
            break
        end
    end
end

function on_draw()
    gui.text(0, 0, string.format("R:%d", info.rand_idx))
end

function main()
    init_rand_table()

    memory.registerexec(0xCA95, on_exec_CA95)

    gui.opacity(GUI_OPACITY)
    gui.register(on_draw)
end

main()
