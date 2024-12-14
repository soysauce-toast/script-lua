block_id = 8640 --
drop_x = 93
drop_y = 52

function drop_item(item_id)
    item_count = inventory(block_id)
    sendPacket(2, "action|drop\n|itemID|"..item_id)
    sleep(200)
    sendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|".. item_id .."|\ncount|".. item_count)
    sleep(500)
end

function disable_dialog(var)
    if var[1]:find("drop_item") then
        return true
    end
    return false
end

function drop_block()
    AddHook("onvarlist", "HOOK_LABEL", disable_dialog)
    sleep(1000)
    findPath(drop_x, drop_y)
    sleep(1000)
    drop_item(block_id)
    sleep(2000)
end

function item_activate(obj)
    pkt = {}
    pkt.type = 11
    pkt.value = obj.oid
    pkt.x = obj.pos.x
    pkt.y = obj.pos.y
    sendPacketRaw(false, pkt)
end

function collect_item()
    tile_range = {{-2, 0}, {-1, 0}, {0, 0}, {1, 0}, {2, 0}}
    for i, obj in pairs(getWorldObject()) do
        for i, tile in pairs(tile_range) do
            if math.floor((obj.pos.x +9)/32) == math.floor((getLocal().pos.x +10)/32) + tile[1] and math.floor((obj.pos.y +9)/32) == math.floor((getLocal().pos.y +15)/32) + tile[2] then
                item_activate(obj)
                sleep(5)
            end
        end
    end
end

function inventory(item_id)
    for i, item in pairs(getInventory()) do
        if item.id == item_id then
            return item.amount
        end
    end
    return 0
end

function findPath_to_object(object_id)
    for i, object in pairs(getWorldObject()) do
        if object.id == object_id then
            if math.floor(object.pos.y/32) ~= 52 then
                collect_item()
                findPath(math.floor(object.pos.x/32), math.floor(object.pos.y/32))
                sleep(2000)
            end
        end
    end
    return 0
end

function take_floating_object()
    for x = 0, 99 do
        block_amount = inventory(block_id)
        if block_amount < 200 then
            findPath_to_object(block_id)
            sleep(1000)
        elseif block_amount == 200 then
            drop_block()
        end
        block_amount = inventory(block_id)
    end
end

take_floating_object()



