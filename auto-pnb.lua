-- ID blok dan seed
local block_id = 184
local seed_id = block_id + 1

-- Posisi break dan drop seed
local block_pos_x = 95
local block_pos_y = 53

local break_pos_x = 98
local break_pos_y = 51

local drop_seed_x = 96
local drop_seed_y = 53

-- Fungsi memperbarui tile
function tile_update(offset_x, offset_y, id)
    local pkt = {
        type = 3,
        value = id,
        punchx = math.floor(getLocal().pos.x / 32) + offset_x,
        punchy = math.floor(getLocal().pos.y / 32) + offset_y,
        x = getLocal().pos.x,
        y = getLocal().pos.y
    }
    sendPacketRaw(false, pkt)
end

-- Fungsi untuk memeriksa posisi
function get_position(x, y)
    return math.floor(getLocal().pos.x / 32) == x and math.floor(getLocal().pos.y / 32) == y
end

-- Fungsi untuk berpindah posisi
function move_to_position(x, y)
    if not get_position(x, y) then
        findPath(x, y)
        sleep(1000)
    end
end

-- Fungsi mendapatkan posisi objek berdasarkan ID
function get_object_position(item_id)
    for _, obj in pairs(getWorldObject()) do
        if obj.id == item_id then
            return math.floor(obj.pos.x / 32), math.floor(obj.pos.y / 32)
        end
    end
    return nil, nil
end

-- Fungsi mendapatkan jumlah item di inventory
function get_item_amount(item_id)
    for _, item in pairs(getInventory()) do
        if item.id == item_id then
            return item.amount
        end
    end
    return 0
end

-- Fungsi untuk memblokir dialog tertentu
function disable_dialog(var)
    if var[1]:find("drop_item") then
        return true
    end
    return false
end

-- Fungsi membuang item
function drop_item(item_id)
    AddHook("onvarlist", "HOOK_LABEL", disable_dialog)
    local item_count = get_item_amount(item_id)
    if item_count > 0 then
        sendPacket(2, "action|drop\n|itemID|" .. item_id)
        sleep(200)
        sendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. item_id .. "|\ncount|" .. item_count)
        sleep(500)
    end
    sleep(1000)
end

-- Fungsi memeriksa tile
function check_tile(offset_x, offset_y)
    local tile = checkTile(math.floor(getLocal().pos.x / 32) + offset_x, math.floor(getLocal().pos.y / 32) + offset_y)
    return tile and tile.fg or 0
end

-- Fungsi untuk aktivasi objek
function item_activate(obj)
    local pkt = {
        type = 11,
        value = obj.oid,
        x = obj.pos.x,
        y = obj.pos.y
    }
    sendPacketRaw(false, pkt)
end

-- Fungsi untuk mengumpulkan item di sekitar
function collect_item()
    local tile_offsets = {{-1, 0}, {1, -1}, {1, 0}, {1, 1}}
    for _, obj in pairs(getWorldObject()) do
        for _, offset in ipairs(tile_offsets) do
            local pos_x = math.floor((obj.pos.x + 9) / 32)
            local pos_y = math.floor((obj.pos.y + 9) / 32)
            local target_x = math.floor((getLocal().pos.x + 10) / 32) + offset[1]
            local target_y = math.floor((getLocal().pos.y + 15) / 32) + offset[2]
            if pos_x == target_x and pos_y == target_y then
                item_activate(obj)
                sleep(1) -- Menambahkan sleep saat mengambil block
            end
        end
    end
end

-- Fungsi utama: place dan break block
function put_and_break()
    while true do
        -- Pastikan berada di posisi break
        move_to_position(break_pos_x, break_pos_y)

        -- Jika seed penuh, buang seed di drop_seed
        local seed_amount = get_item_amount(seed_id)
        if seed_amount >= 200 then
            move_to_position(drop_seed_x, drop_seed_y)
            drop_item(seed_id)
            seed_amount = get_item_amount(seed_id)
            if seed_amount == 0 then
                move_to_position(break_pos_x, break_pos_y)
            end
        end

        -- Proses untuk meletakkan dan menghancurkan block
        local tile_states = {
            check_tile(1, -1),
            check_tile(1, 0),
            check_tile(1, 1)
        }

        -- Mengecek apakah ketiga tile kosong
        local all_tiles_empty = true
        for _, state in ipairs(tile_states) do
            if state ~= 0 then
                all_tiles_empty = false
                break
            end
        end

        if not all_tiles_empty then
            -- Jika salah satu tile tidak kosong, hancurkan block
            for i, state in ipairs(tile_states) do
                if state ~= 0 then
                    -- Hancurkan block pada tile yang tidak kosong
                    while state ~= 0 do
                        collect_item()
                        tile_update(1, i - 2, 18) -- ID untuk menghancurkan block
                        state = check_tile(1, i - 2)
                        sleep(200)
                    end
                end
            end
        else
            -- Jika ketiga tile kosong, kumpulkan item dan letakkan block
            collect_item()
            tile_update(1, -1, block_id)  -- Letakkan block di tile (1, -1)
            sleep(200)
            tile_update(1, 0, block_id)   -- Letakkan block di tile (1, 0)
            sleep(200)
            tile_update(1, 1, block_id)   -- Letakkan block di tile (1, 1)
            sleep(200) -- Menambahkan sleep setelah update tile
        end

        -- Update jumlah block setelah manipulasi tile
        local block_amount = get_item_amount(block_id)

        -- Jika block habis, cari block
        if block_amount == 0 then
            local obj_x, obj_y = get_object_position(block_id)
            if obj_x and obj_y then
                move_to_position(block_pos_x, block_pos_y)
                collect_item()
                sleep(1000) -- Waktu untuk mengambil blok
                move_to_position(break_pos_x, break_pos_y)
            else
                logToConsole("Tidak ada blok untuk diambil.")
                sleep(1000)
                move_to_position(drop_seed_x,drop_seed_y)
                drop_item(seed_id)
                break
            end
        end
    end
end


put_and_break()
