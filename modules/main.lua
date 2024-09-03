-- Function to display the equipped item's level
local function displayEquippedItemLevel(tooltip, data)
    
    -- Check if the tooltip is showing item information
    if tooltip:GetName() ~= "GameTooltip" then
        return -- Do nothing for other tooltips
    end
    
    if tooltip:GetItem() then 
        local _, itemLink = tooltip:GetItem()

        if itemLink then
            -- Get item information
            local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)

            -- Handle itemEquipLoc as a table
            if type(itemEquipLoc) == "table" then
                itemEquipLoc = itemEquipLoc[1] 
            end

            -- Ignore non-equippable items
            if  itemEquipLoc == "INVTYPE_NON_EQUIP" or itemEquipLoc == "" 
            or itemEquipLoc == "INVTYPE_NON_EQUIP_IGNORE" or itemEquipLoc == "INVTYPE_TABARD"
            or itemEquipLoc == "INVTYPE_PROFESSION_GEAR" or itemEquipLoc == "INVTYPE_PROFESSION_TOOL"
            or itemEquipLoc == "INVTYPE_BAG" then 
            return
        end

            -- Translate equipLoc to slotName
            local slotName = "" 
            if itemEquipLoc == "INVTYPE_HEAD" then
                slotName = "HeadSlot"
            elseif itemEquipLoc == "INVTYPE_NECK" then
                slotName = "NeckSlot"
            elseif itemEquipLoc == "INVTYPE_SHOULDER" then 
                slotName = "ShoulderSlot"
            elseif itemEquipLoc == "INVTYPE_BODY" then
                slotName = "ShirtSlot"
            elseif itemEquipLoc == "INVTYPE_CHEST" then
                slotName = "ChestSlot"
            elseif itemEquipLoc == "INVTYPE_ROBE" then -- Robes also occupy the ChestSlot
                slotName = "ChestSlot"
            elseif itemEquipLoc == "INVTYPE_WAIST" then
                slotName = "WaistSlot"
            elseif itemEquipLoc == "INVTYPE_LEGS" then
                slotName = "LegsSlot"
            elseif itemEquipLoc == "INVTYPE_FEET" then
                slotName = "FeetSlot"
            elseif itemEquipLoc == "INVTYPE_WRIST" then
                slotName = "WristSlot"
            elseif itemEquipLoc == "INVTYPE_HAND" then
                slotName = "HandsSlot"
            elseif itemEquipLoc == "INVTYPE_FINGER" then
                slotName = "Finger0Slot" 
            elseif itemEquipLoc == "INVTYPE_TRINKET" then
                slotName = "Trinket0Slot"
            elseif itemEquipLoc == "INVTYPE_CLOAK" then
                slotName = "BackSlot"
            elseif itemEquipLoc == "INVTYPE_WEAPON" then
                slotName = "MainHandSlot"
            elseif itemEquipLoc == "INVTYPE_SHIELD" or itemEquipLoc == "INVTYPE_WEAPONOFFHAND" or itemEquipLoc == "INVTYPE_HOLDABLE" then
                slotName = "SecondaryHandSlot"
            elseif itemEquipLoc == "INVTYPE_2HWEAPON" then
                slotName = "MainHandSlot"
            elseif itemEquipLoc == "INVTYPE_RANGED" or itemEquipLoc == "INVTYPE_RANGEDRIGHT" or itemEquipLoc == "INVTYPE_THROWN" then 
                slotName = "MainHandSlot"
            elseif itemEquipLoc == "INVTYPE_PROFESSION_GEAR" then
                return -- Ignore profession gear items
            elseif itemEquipLoc == "INVTYPE_PROFESSION_GEAR" or itemEquipLoc == "INVTYPE_PROFESSION_TOOL" then
                return -- Ignore profession gear and tool items
            elseif itemEquipLoc == "INVTYPE_BAG" then -- Add this check to filter out bags
                return -- Ignore bag tooltips
            else
                print("Error: Unhandled equipLoc: " .. tostring(itemEquipLoc))
                return
            end

            -- Get the slot ID for the equipped item
            local slotID = GetInventorySlotInfo(slotName)
            if not slotID then return end

            local equippedItemLink = GetInventoryItemLink("player", slotID)

            if equippedItemLink then
                local effectiveItemLevel, baseItemLevel = GetDetailedItemLevelInfo(equippedItemLink)

                 -- Parse the tooltip to get the hovered item's level
                local hoveredItemLevel = nil
                for i = 1, tooltip:NumLines() do
                    local lineText = _G["GameTooltipTextLeft" .. i]:GetText()
                    if lineText and lineText:find("Item Level (%d+)") then
                        hoveredItemLevel = tonumber(lineText:match("Item Level (%d+)"))
                        break 
                    end
                end
               
                
            if hoveredItemLevel then
                -- Determine the comparison symbol
                local comparisonSymbol = ""
                if effectiveItemLevel > hoveredItemLevel then
                    comparisonSymbol = " <"  -- Upwards arrow replaced with ">"
                elseif effectiveItemLevel < hoveredItemLevel then
                    comparisonSymbol = " >"  -- Downwards arrow replaced with "<"
                end

                -- Modify the item level line in the tooltip
                for i = 1, tooltip:NumLines() do
                    local lineText = _G["GameTooltipTextLeft" .. i]:GetText()
                    if lineText and lineText:find("Item Level %d+") then
                        _G["GameTooltipTextLeft" .. i]:SetText(lineText .. comparisonSymbol .. " (Curr: " .. effectiveItemLevel ..")")
                        break 
                    end
                end
            else
                print("Warning: Could not find hovered item level in the tooltip.")
            end
            end

            -- Set the modifiedForItem flag and show the tooltip
            tooltip.modifiedForItem = true 
            tooltip:Show() 

        end
    end 
end

-- Register the function to handle item tooltips
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, displayEquippedItemLevel)

-- Function to reset the modifiedForItem flag when the tooltip is hidden
local function resetModifiedFlag(self)
    self.modifiedForItem = false
end

-- Hook into the tooltip's OnHide event ONCE, when the addon loads
GameTooltip:HookScript("OnHide", resetModifiedFlag)

-- Function to prevent tooltip hiding on mouse leave
local function preventTooltipHide(self)
    if self.modifiedForItem then  -- Only prevent hiding if we modified it
        self:Show()  -- Force the tooltip to stay visible
    end
end

-- Hook into the tooltip's OnLeave event
--GameTooltip:HookScript("OnLeave", preventTooltipHide)