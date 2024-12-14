function collect_item()
    function item_activate(obj)
        pkt = {}
        pkt.type = 11
        pkt.value = obj.oid
        pkt.x = obj.pos.x
        pkt.y = obj.pos.y
        sendPacketRaw(false, pkt)
    end
    tile_range = {{-1, 0}, {0, 0}, {1, 0}}
    for i, obj in pairs(getWorldObject()) do
        for i, tile in pairs(tile_range) do
            if math.floor((obj.pos.x +9)/32) == math.floor((getLocal().pos.x +10)/32) + tile[1] and math.floor((obj.pos.y +9)/32) == math.floor((getLocal().pos.y +15)/32) + tile[2] then
                item_activate(obj)
                sleep(50)
            end
        end
    end
end

collect_item()