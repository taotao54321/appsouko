function utos24(n)
    if AND(n, 0x800000) ~= 0 then n = n - 0x1000000; end
    return n
end

function utos8(n)
    if AND(n, 0x80) ~= 0 then n = n - 0x100; end
    return n
end

function stou8(n)
    if n < 0 then n = n + 0x100; end
    return n
end

while true do
    pos_hi = memory.readbyte(0x4D)
    pos_mid = memory.readbyte(0x4C)
    pos_lo = memory.readbyte(0x4E)
    pos_raw = 0x10000*pos_hi + 0x100*pos_mid + pos_lo
    speed_hi = memory.readbyte(0x50)
    speed_mid = memory.readbyte(0x51)
    speed_lo = memory.readbyte(0x52)
    speed = 0x10000*speed_hi + 0x100*speed_mid + speed_lo
    rpm = memory.readbyte(0x53)
    distance_hi = memory.readbyte(0x42)
    distance_lo = memory.readbyte(0x41)
    distance = 0x100*distance_hi + distance_lo
    distance_way = memory.readbyte(0x43)
    lap = memory.readbyte(0x59)
    frame = memory.readbyte(0x4F)

    way_ptr = memory.readbyte(0x3C) + 0x100*memory.readbyte(0x3D)
    way_curve_raw = memory.readbyte(way_ptr)
    way_len = memory.readbyte(way_ptr+1)

    enemy_x = {}
    enemy_z = {}
    enemy_83 = {}
    enemy_89 = {}
    for i = 1, 3 do
        enemy_x[i] = memory.readbyte(0x8C+i-1)
        enemy_z[i] = 0x100*memory.readbyte(0x8F+i-1) + memory.readbyte(0x92+i-1)
        enemy_83[i] = memory.readbyte(0x83+i-1)
        enemy_89[i] = memory.readbyte(0x89+i-1)
    end

    gui.text(0, 48, string.format("POS: %.3f (0x%06X)", utos24(pos_raw)/0x100, pos_raw))
    gui.text(0, 56, string.format("SPD: %.3f (0x%06X)", speed/0x100, speed))
    gui.text(0, 64, string.format("RPM: %u", rpm))
    gui.text(0, 72, string.format("DIS: %.3f (0x%04X)", distance/0x100, distance))
    gui.text(0, 80, string.format("WAY: %d (0x%02X), %u/%u",
                                  utos8(way_curve_raw), way_curve_raw, distance_way, way_len))
    gui.text(0, 88, string.format("LAP: %d", lap))
    gui.text(0, 96, string.format("FRM: %u", frame))

    --[[
    for i = 1, 3 do
        if enemy_z[i] >= 0xF000 then
            e_str = string.format("E%d: -----", i)
            c_str = string.format("C%d: -----", i)
        else
            e_str = string.format("E%d: 0x%02X, 0x%04X", i, enemy_x[i], enemy_z[i])
            c_str = string.format("C%d: 0x%02X, 0x%02X", i, stou8(enemy_83[i]-0x63), stou8(enemy_89[i]-0xA5))
        end
        gui.text(136, 48+8*i, e_str)
        gui.text(136, 72+8*i, c_str)
    end
    ]]

    FCEU.frameadvance()
end
