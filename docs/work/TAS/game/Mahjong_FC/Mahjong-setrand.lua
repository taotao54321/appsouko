if not bit then require("bit"); end

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

function mem_read_bytes(addr, n)
    local ary = {}
    for i = 1, n do
        array_append(ary, memory.readbyte(addr+i-1))
    end
    return ary
end

function mem_write_bytes(addr, n, ary)
    for i = 1, n do
        memory.writebyte(addr+i-1, ary[i])
    end
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

function on_exec_D2BF()
    mem_write_bytes(0x23, 0x20, rand_table[8649])
end

function main()
    init_rand_table()

    memory.registerexec(0xD2BF, on_exec_D2BF)
end

main()
