local GUI_OPACITY = 0.8

local COLOR_TEXT_FILL = 0x00FF00FF
local COLOR_TEXT_BORDER = 0x000000FF

function mem_read_u8(addr)
    return memory.readbyte(addr)
end

function mem_read_s8(addr)
    local n = memory.readbyte(addr)
    return n >= 0x80 and n-0x100 or n
end

function mem_read_u16le(addr)
    return memory.readbyte(addr) + 0x100*memory.readbyte(addr+1)
end

function mem_read_u16be(addr)
    return 0x100*memory.readbyte(addr) + memory.readbyte(addr+1)
end

function draw_text(x, y, msg)
    gui.text(x, y, msg, COLOR_TEXT_FILL, COLOR_TEXT_BORDER)
end

function get_info()
    info = {}
    info.pos_x = mem_read_u16le(0xC205)
    info.pos_y = mem_read_u16le(0xC207)
    info.vel_x = mem_read_s8(0xC209)
    info.vel_y = mem_read_s8(0xC20A)
    return info
end

function on_draw()
    info = get_info()

    draw_text(0, 0, string.format("POS:(%d,%d) VEL:(%d,%d)",
        info.pos_x, info.pos_y, info.vel_x, info.vel_y
    ))
end

function main()
    gui.opacity(GUI_OPACITY)
    gui.register(on_draw)
end

main()
