function inventory(item_id)
    for i, item in pairs(getInventory()) do
        if item.id == item_id then
            return item.amount
        end
    end
    return 0
end

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

AddHook("onvarlist", "HOOK_LABEL", disable_dialog)
drop_item(block_id)