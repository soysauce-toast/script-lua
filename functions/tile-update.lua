function tile_update(x, y, id)
    pkt = {}
    pkt.type = 3
    pkt.value = id
    pkt.punchx = math.floor(getLocal().pos.x/32 +x)
    pkt.punchy = math.floor(getLocal().pos.y/32 +y)
    pkt.x = getLocal().pos.x
    pkt.y = getLocal().pos.y
    sendPacketRaw(false, pkt)
end

tile_update(x, y, id)