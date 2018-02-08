--[[
ダブルムーン伝説 (FC) ワールドマップ作成

ゲートまたはバドンの羽で行き先(どこでもよい)を決定し、キー入力待ちになってい
る状態から起動すること。

ファンタム島を含めたい場合は予め浮上イベントをこなしておくのを忘れずに。
]]

local emu = emu or FCEU
if not emu then error("Not emulua.") end

if not bit then require("bit") end
if not gd then require("gd") end

-- マップのサイズ(座標単位)
local MAP_W = 256
local MAP_H = 256

-- マップチップのサイズ(px)
local CELL_W = 16
local CELL_H = 16

-- 左右上下の中途半端な描画領域(px)
local MARGIN_LEFT   = 8
local MARGIN_RIGHT  = 8
local MARGIN_TOP    = 8
local MARGIN_BOTTOM = 8

-- 画面上の主人公座標
local HERO_OFF_X = 6
local HERO_OFF_Y = 6

-- メモリアドレス
local ADDR_HERO_X = 0x04
local ADDR_HERO_Y = 0x05

-- マップ断片のサイズ(座標単位)
local PIECE_W = 8
local PIECE_H = 8

local OUTPUT_PATH = "DoubleMoon-worldmap.png"

function emu_advance(n, pads)
    if n == nil then
        emu.frameadvance()
    else
        for i = 1, n do
            if pads then
                for i,pad in ipairs(pads) do
                    joypad.set(i, pad)
                end
            end
            emu.frameadvance()
        end
    end
end

function hook_pos(x, y)
    local function on_write_x()
        memory.register(ADDR_HERO_X, nil)
        memory.writebyte(ADDR_HERO_X, x)
    end
    local function on_write_y()
        memory.register(ADDR_HERO_Y, nil)
        memory.writebyte(ADDR_HERO_Y, y)
    end
    memory.register(ADDR_HERO_X, on_write_x)
    memory.register(ADDR_HERO_Y, on_write_y)
end

function unhook_pos()
    memory.register(ADDR_HERO_X, nil)
    memory.register(ADDR_HERO_Y, nil)
end

function create_piece(x, y, state)
    savestate.load(state)
    local hero_x = (PIECE_W*x + HERO_OFF_X) % 256
    local hero_y = (PIECE_H*y + HERO_OFF_Y) % 256
    hook_pos(hero_x, hero_y)
    emu_advance(2, {{ A = 1 }})
    emu_advance(200)
    unhook_pos()

    local ss = gd.createFromGdStr(gui.gdscreenshot())
    if not ss then error("gd.createFromGdStr() failed.") end
    local piece = gd.createTrueColor(PIECE_W*CELL_W, PIECE_H*CELL_H)
    if not piece then error("gd.createTrueColor() failed.") end
    piece:copy(ss, 0, 0, MARGIN_LEFT, MARGIN_TOP, piece:sizeX(), piece:sizeY())

    return piece
end

function create_map()
    local img = gd.createTrueColor(MAP_W*CELL_W, MAP_H*CELL_H)
    if not img then error("gd.createTrueColor() failed.") end

    local state = savestate.create()
    savestate.save(state)
    for y = 0, (MAP_H/PIECE_H)-1 do
        for x = 0, (MAP_W/PIECE_W)-1 do
            local piece = create_piece(x, y, state)
            img:copy(piece, piece:sizeX()*x, piece:sizeY()*y, 0, 0, piece:sizeX(), piece:sizeY())
        end
    end
    savestate.load(state)

    return img
end

function main()
    emu.setrenderplanes(false, true)
    local img = create_map()
    if not img:png(OUTPUT_PATH) then error("gdImage:png() failed.") end
    emu.setrenderplanes(true, true)
end

main()
