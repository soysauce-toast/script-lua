function inventory(item_id)
    for i, item in pairs(getInventory()) do
        if item.id == item_id then
            return item.amount
        end
    end
    return 0
end

inventory(item_id)