-- Wiz1-LastEnemy.lua

local FILE_OUTPUT = "Wiz1-W_DMG.txt"

function my_main()
    local out = io.open(FILE_OUTPUT, "w")
    if out == nil then
        error("Can't open file")
    end

    FCEU.speedmode("maximum")
    local state = savestate.create()
    savestate.save(state)

    for i = 0x00, 0xFF do
        for j = 0x00, 0xFF do
            memory.writebyte(0x0040, j)
            memory.writebyte(0x0041, i)

            FCEU.frameadvance()

            local dmg = memory.readbyte(0x006D)

            out:write(string.format("0x%02X%02X\t%u\n", i, j, dmg))

            savestate.load(state)
        end
    end

    out:close()
end

my_main()
