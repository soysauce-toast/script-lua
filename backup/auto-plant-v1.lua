seed_id = 8641 -- ID Seed
delay_1 = 500
delay_2 = 500

-- Fungsi untuk memperbarui tile
function tile_update(offset_x, offset_y, item_id)
    local pkt = {
        type = 3,
        value = item_id,
        punchx = math.floor(getLocal().pos.x / 32) + offset_x,
        punchy = math.floor(getLocal().pos.y / 32) + offset_y,
        x = getLocal().pos.x,
        y = getLocal().pos.y
    }
    sendPacketRaw(false, pkt)
end

-- Fungsi untuk mengecek jumlah item di inventory
function get_item_amount(item_id)
    for _, item in pairs(getInventory()) do
        if item.id == item_id then
            return item.amount
        end
    end
    return 0
end

-- Fungsi untuk mendapatkan posisi objek di dunia
function get_object_position(object_id)
    for _, object in pairs(getWorldObject()) do
        if object.id == object_id then
            return math.floor(object.pos.x / 32), math.floor(object.pos.y / 32)
        end
    end
    return nil
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
    local tile_offsets = {{-1, 0}, {0, 0}, {1, 0}}
    for _, obj in pairs(getWorldObject()) do
        for _, offset in ipairs(tile_offsets) do
            local pos_x = math.floor((obj.pos.x + 9) / 32)
            local pos_y = math.floor((obj.pos.y + 9) / 32)
            local target_x = math.floor((getLocal().pos.x + 10) / 32) + offset[1]
            local target_y = math.floor((getLocal().pos.y + 15) / 32) + offset[2]
            if pos_x == target_x and pos_y == target_y then
                item_activate(obj)
                sleep(5) -- Menambahkan sleep saat mengambil block
            end
        end
    end
end

-- Fungsi utama untuk menanam
function planting()
    for y = 1, 54 do
        for x = 0, 99 do
            local tile_down = checkTile(x, y)
            local tile_up = checkTile(x, y - 1)
            local seed_amount = get_item_amount(seed_id)

            if tile_down.fg ~= 0 and tile_down.fg ~= seed_id and tile_up.fg == 0 and seed_amount > 0 then
                -- Pindah ke lokasi dan tanam seed
                findPath(tile_down.pos.x, tile_down.pos.y - 1)
                sleep(delay_1)
                tile_update(0, 0, seed_id)
                sleep(delay_2)
            elseif seed_amount == 0 then
                -- Jika seed habis, cari lokasi objek seed
                local obj_x, obj_y = get_object_position(seed_id)
                if obj_x and obj_y then
                    sleep(1000)
                    findPath(obj_x, obj_y)
                    collect_item()
                    sleep(3000)
                else
                    print("Seed habis dan objek tidak ditemukan.")
                    return
                end
            end
        end
    end
end

-- Eksekusi fungsi planting
planting()






























