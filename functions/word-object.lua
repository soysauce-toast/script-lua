function world_object(object_id)
    for i, object in pairs(getWorldObject()) do
        if object.id == object_id then
            return math.floor(object.pos.x/32), math.floor(object.pos.y/32)
        end
    end
    return 0
end

world_object(object_id)