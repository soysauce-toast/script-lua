block_id = 8640
seed_id = block_id + 1

delay_1 = 300
delay_2 = 500

drop_x = 94
drop_y = 52

-- Fungsi pembaruan tile
function tile_update(x, y, id)
    local pkt = {
        type = 3,
        value = id,
        punchx = math.floor(getLocal().pos.x / 32) + x,
        punchy = math.floor(getLocal().pos.y / 32) + y,
        x = getLocal().pos.x,
        y = getLocal().pos.y
    }
    sendPacketRaw(false, pkt)
end

-- Fungsi aktivasi item
function item_activate(obj)
    local pkt = {
        type = 11,
        value = obj.oid,
        x = obj.pos.x,
        y = obj.pos.y
    }
    sendPacketRaw(false, pkt)
end

-- Fungsi pengumpulan item
function collect_item()
    local tile_range = {{-4, 0}, {-3, 0}, {-2, 0}, {-1, 0}}
    local world_objects = getWorldObject()
    for _, obj in pairs(world_objects) do
        for _, tile in pairs(tile_range) do
            if math.floor((obj.pos.x + 9) / 32) == math.floor((getLocal().pos.x + 10) / 32) + tile[1] and
               math.floor((obj.pos.y + 9) / 32) == math.floor((getLocal().pos.y + 15) / 32) + tile[2] then
                item_activate(obj)
                sleep(3) -- Kurangi waktu tidur
            end
        end
    end
end

-- Fungsi untuk menghitung jumlah item di inventaris
function inventory(item_id)
    local inv = getInventory()
    for _, item in pairs(inv) do
        if item.id == item_id then
            return item.amount
        end
    end
    return 0
end

-- Fungsi untuk membuang item
function drop_item(item_id)
    local item_count = inventory(item_id)
    sendPacket(2, "action|drop\n|itemID|" .. item_id)
    sleep(100)
    sendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. item_id .. "|\ncount|" .. item_count)
    sleep(300) -- Kurangi waktu tidur
end

-- Fungsi untuk menonaktifkan dialog
function disable_dialog(var)
    return var[1]:find("drop_item") ~= nil
end

-- Fungsi untuk membuang blok
function drop_block()
    AddHook("onvarlist", "HOOK_LABEL", disable_dialog)
    sleep(500)
    findPath(drop_x, drop_y)
    sleep(500)
    drop_item(block_id)
    sleep(1000)
end

-- Fungsi utama untuk memanen
function harvesting()
    local max_blocks = 200
    for y = 0, 53 do
        for x = 0, 99 do
            local block_amount = inventory(block_id)
            local tile_up = checkTile(x, y)
            local tile_extra = getExtraTile(x, y)

            if block_amount < max_blocks and tile_up.fg == seed_id and tile_extra.fruitCount > 0 then
                findPath(tile_up.pos.x, tile_up.pos.y)
                sleep(delay_1)
                tile_update(0, 0, 18)
                collect_item()
                sleep(delay_2)
            elseif block_amount >= max_blocks then
                drop_block()
                block_amount = 0
            end
        end
    end
end

harvesting()










































