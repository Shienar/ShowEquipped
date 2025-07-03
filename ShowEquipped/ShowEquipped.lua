SE = { name = "ShowEquipped" }

SE.trackedSets = {}

--returns -1 or index k
local function containsVal_SetItem(list, val)
	for k, v in pairs(list) do
		if v.name == val.name then return k end
	end
	return -1
end

local function comparator_Sets(arg1, arg2)
	if arg1.count > arg2.count then 
		return true 
	elseif arg1.count == arg2.count and arg1.maxCount > arg2.maxCount then
		return true
	else
		return false
	end
end

function SE.onUpdateEquips(code, bagID, slotIndex, isNewItem, soundCategory, updateReason, stackChange)

	if bagID == BAG_WORN then
		
		
		local equips = {
			EQUIP_SLOT_HEAD,
			EQUIP_SLOT_CHEST,
			EQUIP_SLOT_SHOULDERS,
			EQUIP_SLOT_HAND,
			EQUIP_SLOT_WAIST,
			EQUIP_SLOT_LEGS,
			EQUIP_SLOT_FEET,
			EQUIP_SLOT_MAIN_HAND,
			EQUIP_SLOT_OFF_HAND,
			EQUIP_SLOT_BACKUP_MAIN,
			EQUIP_SLOT_BACKUP_OFF,
			EQUIP_SLOT_NECK,
			EQUIP_SLOT_RING1,
			EQUIP_SLOT_RING2,
		}
		
		SE.trackedSets = {}
		
		for k, equip in pairs(equips) do
			
			local itemLink = GetItemLink(BAG_WORN, equip)
			--Doesn't track equipped on other bar, which I'd like to do.
			local hasSet, setName, numBonuses, numNormal, maxEquipped, setID, numPerfected = GetItemLinkSetInfo(itemLink)
			
			if setName ~= "" then
				
				local item = {
					name = setName,
					count = 1,
					maxCount = maxEquipped,
				}
				
				local wType = GetItemLinkWeaponType(itemLink)
				if wType ~= nil and 
					(wType == WEAPONTYPE_FROST_STAFF or
					wType == WEAPONTYPE_HEALING_STAFF or
					wType == WEAPONTYPE_LIGHTNING_STAFF or
					wType == WEAPONTYPE_FIRE_STAFF or
					wType == WEAPONTYPE_TWO_HANDED_AXE or
					wType == WEAPONTYPE_TWO_HANDED_HAMMER or
					wType == WEAPONTYPE_TWO_HANDED_SWORD)then
					
						item.count = item.count + 1
				end
					
				local index = containsVal_SetItem(SE.trackedSets, item)
				if index == -1 then 
					SE.trackedSets[#SE.trackedSets+1] = item 
				else
					SE.trackedSets[index].count = SE.trackedSets[index].count + item.count
				end
				
			end
		end
		
		--Descending order
		table.sort(SE.trackedSets, comparator_Sets)
		
		--clear text
		for k, v in pairs(SE.rows) do
			v:SetText("")
		end
		
		
		for k, v in pairs(SE.trackedSets) do
			--refill text
			SE.rows[k]:SetText("("..v.count.."/"..v.maxCount..") "..v.name)
			
			--update color
			if v.count ~= nil and v.maxCount ~= nil and v.count ~= v.maxCount then
				SE.rows[k]:SetColor(SE.savedVariables.colorR_Incomplete, SE.savedVariables.colorG_Incomplete, SE.savedVariables.colorB_Incomplete)
				SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Incomplete)
			else
				SE.rows[k]:SetColor(SE.savedVariables.colorR_Complete, SE.savedVariables.colorG_Complete, SE.savedVariables.colorB_Complete)
				SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Complete)
			end
		end
		
	end
end

function SE.applyValues()
	--toggle
	ShowEquipped:SetHidden(SE.savedVariables.checked)
	
	--Color
	ShowEquippedName:SetColor(SE.savedVariables.colorR_Title, SE.savedVariables.colorG_Title, SE.savedVariables.colorB_Title)
	ShowEquippedName:SetAlpha(SE.savedVariables.colorA_Title)
	for k, v in pairs(SE.trackedSets) do
		if v.count ~= nil and v.maxCount ~= nil and v.count ~= v.maxCount then
			SE.rows[k]:SetColor(SE.savedVariables.colorR_Incomplete, SE.savedVariables.colorG_Incomplete, SE.savedVariables.colorB_Incomplete)
			SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Incomplete)
		else
			SE.rows[k]:SetColor(SE.savedVariables.colorR_Complete, SE.savedVariables.colorG_Complete, SE.savedVariables.colorB_Complete)
			SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Complete)
		end
	end
	
	--Text Size
	ShowEquippedName:SetFont(SE.savedVariables.selectedFont_Title)
	for k, v in pairs(SE.rows) do
		v:SetFont(SE.savedVariables.selectedFont)
	end
	
	--Position
	ShowEquipped:ClearAnchors()
	ShowEquipped:SetAnchor(SE.savedVariables.selectedPos, GuiRoot, SE.savedVariables.selectedPos, SE.savedVariables.offset_x, SE.savedVariables.offset_y)
end

function SE.Initialize()

	SE.defaults = {
		colorR_Title = 1.0,
		colorG_Title = 1.0,
		colorB_Title = 1.0,
		colorA_Title = 1.0,
		
		colorR_Complete = 1.0,
		colorG_Complete = 1.0,
		colorB_Complete = 1.0,
		colorA_Complete = 1.0,
		
		colorR_Incomplete = 1.0,
		colorG_Incomplete = 1.0,
		colorB_Incomplete = 1.0,
		colorA_Incomplete = 1.0,
			
		selectedText_font_Title = "22",
		selectedFont_Title = "ZoFontGamepad22",
			
		selectedText_font = "22",
		selectedFont = "ZoFontGamepad22",
			
		selectedPos = 3,
		selectedText_pos = "Top Left",
		checked = false,
		offset_x = 0,
		offset_y = 0,
	}

	SE.savedVariables = ZO_SavedVars:NewAccountWide("SESavedVariables", 1, nil, SE.defaults, GetWorldName())
	
	--UI
	SE.rows = {}
	for i = 1, 14 do
		SE.rows[i] = ShowEquipped:GetNamedChild("Row"..i)
	end
	
	SE.applyValues()
	
	--settings
	local settings = LibHarvensAddonSettings:AddAddon("Show Equipped")
	local areSettingsDisabled = false
	
	local generalSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "General",}
	local colorSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "Color",}
	local sizeSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "Text Size",}
	local positionSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "General",}
	
	local resetDefaults = {
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset Defaults",
        tooltip = "",
        buttonText = "RESET",
        clickHandler = function(control, button)
			--Reset values
			SE.savedVariables.colorR_Title = SE.defaults.colorR_Title
			SE.savedVariables.colorG_Title = SE.defaults.colorG_Title
			SE.savedVariables.colorB_Title = SE.defaults.colorB_Title
			SE.savedVariables.colorA_Title = SE.defaults.colorA_Title
			
			SE.savedVariables.colorR_Complete = SE.defaults.colorR_Complete
			SE.savedVariables.colorG_Complete = SE.defaults.colorG_Complete
			SE.savedVariables.colorB_Complete = SE.defaults.colorB_Complete
			SE.savedVariables.colorA_Complete = SE.defaults.colorA_Complete
			
			SE.savedVariables.colorR_Incomplete = SE.defaults.colorR_Incomplete
			SE.savedVariables.colorG_Incomplete = SE.defaults.colorG_Incomplete
			SE.savedVariables.colorB_Incomplete = SE.defaults.colorB_Incomplete
			SE.savedVariables.colorA_Incomplete = SE.defaults.colorA_Incomplete
				
			SE.savedVariables.selectedText_font_Title = SE.defaults.selectedText_font_Title
			SE.savedVariables.selectedFont_Title = SE.defaults.selectedFont_Title
				
			SE.savedVariables.selectedText_font = SE.defaults.selectedText_font
			SE.savedVariables.selectedFont = SE.defaults.selectedFont
				
			SE.savedVariables.selectedPos = SE.defaults.selectedPos
			SE.savedVariables.selectedText_pos = SE.defaults.selectedText_pos
			SE.savedVariables.checked = SE.defaults.checked
			SE.savedVariables.offset_x = SE.defaults.offset_x
			SE.savedVariables.offset_y = SE.defaults.offset_y
			
			SE.applyValues()
		end,
        disable = function() return areSettingsDisabled end,
    }
	
	local toggle = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Hide Display?", 
        tooltip = "Disables the display when set to \"On\"",
        default = SE.defaults.checked,
        setFunction = function(state) 
            SE.savedVariables.checked = state
			ShowEquipped:SetHidden(state)
        end,
        getFunction = function() 
            return SE.savedVariables.checked
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local titleColor = {
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Title Color",
        tooltip = "Change the text color of the display's title.",
        setFunction = function(...) --newR, newG, newB, newA
            SE.savedVariables.colorR_Title, SE.savedVariables.colorG_Title, SE.savedVariables.colorB_Title, SE.savedVariables.colorA_Title = ...
			ShowEquippedName:SetColor(SE.savedVariables.colorR_Title, SE.savedVariables.colorG_Title, SE.savedVariables.colorB_Title)
			ShowEquippedName:SetAlpha(SE.savedVariables.colorA_Title)
        end,
        default = {SE.defaults.colorR_Title, SE.defaults.colorG_Title, SE.defaults.colorB_Title, SE.defaults.colorA_Title},
        getFunction = function()
            return SE.savedVariables.colorR_Title, SE.savedVariables.colorG_Title, SE.savedVariables.colorB_Title, SE.savedVariables.colorA_Title
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local completeColor = {
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Complete Color",
        tooltip = "Change the text color of completed item sets (e.g. 2/2 or 5/5)",
        setFunction = function(...) --newR, newG, newB, newA
            SE.savedVariables.colorR_Complete, SE.savedVariables.colorG_Complete, SE.savedVariables.colorB_Complete, SE.savedVariables.colorA_Complete = ...
			
			for k, v in pairs(SE.trackedSets) do
				if v.count ~= nil and v.maxCount ~= nil and v.count ~= v.maxCount then
					SE.rows[k]:SetColor(SE.savedVariables.colorR_Incomplete, SE.savedVariables.colorG_Incomplete, SE.savedVariables.colorB_Incomplete)
					SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Incomplete)
				else
					SE.rows[k]:SetColor(SE.savedVariables.colorR_Complete, SE.savedVariables.colorG_Complete, SE.savedVariables.colorB_Complete)
					SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Complete)
				end
			end
        end,
        default = {SE.defaults.colorR_Complete, SE.defaults.colorG_Complete, SE.defaults.colorB_Complete, SE.defaults.colorA_Complete},
        getFunction = function()
            return SE.savedVariables.colorR_Complete, SE.savedVariables.colorG_Complete, SE.savedVariables.colorB_Complete, SE.savedVariables.colorA_Complete
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local incompleteColor = {
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Incomplete Color",
        tooltip = "Change the text color of incomplete item sets.",
        setFunction = function(...) --newR, newG, newB, newA
            SE.savedVariables.colorR_Incomplete, SE.savedVariables.colorG_Incomplete, SE.savedVariables.colorB_Incomplete, SE.savedVariables.colorA_Incomplete = ...
			
			for k, v in pairs(SE.trackedSets) do
				if v.count ~= nil and v.maxCount ~= nil and v.count ~= v.maxCount then
					SE.rows[k]:SetColor(SE.savedVariables.colorR_Incomplete, SE.savedVariables.colorG_Incomplete, SE.savedVariables.colorB_Incomplete)
					SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Incomplete)
				else
					SE.rows[k]:SetColor(SE.savedVariables.colorR_Complete, SE.savedVariables.colorG_Complete, SE.savedVariables.colorB_Complete)
					SE.rows[k]:SetAlpha(SE.savedVariables.colorA_Complete)
				end
			end
        end,
        default = {SE.defaults.colorR_Incomplete, SE.defaults.colorG_Incomplete, SE.defaults.colorB_Incomplete, SE.defaults.colorA_Incomplete},
        getFunction = function()
            return SE.savedVariables.colorR_Incomplete, SE.savedVariables.colorG_Incomplete, SE.savedVariables.colorB_Incomplete, SE.savedVariables.colorA_Incomplete
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local title_font = {
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Title Font Size",
        tooltip = "Change the size of the Title.",
        setFunction = function(combobox, name, item)
			ShowEquippedName:SetFont(item.data)
			SE.savedVariables.selectedText_font_Title = name
			SE.savedVariables.selectedFont_Title = item.data
        end,
        getFunction = function()
            return SE.savedVariables.selectedText_font_Title
        end,
        default = SE.defaults.selectedText_font_Title,
        items = {
            {
                name = "18",
                data = "ZoFontGamepad18"
            },
            {
                name = "20",
                data = "ZoFontGamepad20"
            },
            {
                name = "22",
                data = "ZoFontGamepad22"
            },
            {
                name = "25",
                data = "ZoFontGamepad25"
            },
            {
                name = "34",
                data = "ZoFontGamepad34"
            },
        },
        disable = function() return areSettingsDisabled end,
    }
	
	local set_font = {
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Set Font Size",
        tooltip = "Change the size of the displayed sets.",
        setFunction = function(combobox, name, item)
		
			for k, v in pairs(SE.rows) do
				v:SetFont(item.data)
			end
			
			SE.savedVariables.selectedText_font = name
			SE.savedVariables.selectedFont = item.data
        end,
        getFunction = function()
            return SE.savedVariables.selectedText_font
        end,
        default = SE.defaults.selectedText_font,
        items = {
            {
                name = "18",
                data = "ZoFontGamepad18"
            },
            {
                name = "20",
                data = "ZoFontGamepad20"
            },
            {
                name = "22",
                data = "ZoFontGamepad22"
            },
            {
                name = "25",
                data = "ZoFontGamepad25"
            },
            {
                name = "34",
                data = "ZoFontGamepad34"
            },
        },
        disable = function() return areSettingsDisabled end,
    }
	
	local position = {
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Tracker Position",
        tooltip = "",
        setFunction = function(combobox, name, item)
			SE.savedVariables.selectedText_pos = name
			SE.savedVariables.selectedPos = item.data
			
			ShowEquipped:ClearAnchors()
			ShowEquipped:SetAnchor(SE.savedVariables.selectedPos, GuiRoot, SE.savedVariables.selectedPos, SE.savedVariables.offset_x, SE.savedVariables.offset_y)
		 end,
        getFunction = function()
            return SE.savedVariables.selectedText_pos
        end,
        default = SE.defaults.selectedText_pos,
        items = {
            {
                name = "Top Left",
                data = 3
            },
			{
                name = "Top",
                data = 1
            },
            {
                name = "Top Right",
                data = 9
            },
			{
                name = "Left",
                data = 2
            },
			{
                name = "Center",
                data = 128
            },
			{
                name = "Right",
                data = 8
            },
			{
                name = "Bottom Left",
                data = 6
            },
			{
                name = "Bottom",
                data = 4
            },
			{
                name = "Bottom Right",
                data = 12
            },
        },
        disable = function() return areSettingsDisabled end,
    }
	
	local offset_x = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "X Offset",
        tooltip = "",
        setFunction = function(value)
			SE.savedVariables.offset_x = value
			
			ShowEquipped:ClearAnchors()
			ShowEquipped:SetAnchor(SE.savedVariables.selectedPos, GuiRoot, SE.savedVariables.selectedPos, SE.savedVariables.offset_x, SE.savedVariables.offset_y)
		  end,
        getFunction = function()
            return SE.savedVariables.offset_x
        end,
        default = 0,
        min = -750,
        max = 750,
        step = 5,
        unit = "", --optional unit
        format = "%d", --value format
        disable = function() return areSettingsDisabled end,
    }
	
	local offset_y = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Y Offset",
        tooltip = "",
        setFunction = function(value)
			SE.savedVariables.offset_y = value
		
			ShowEquipped:ClearAnchors()
			ShowEquipped:SetAnchor(SE.savedVariables.selectedPos, GuiRoot, SE.savedVariables.selectedPos, SE.savedVariables.offset_x, SE.savedVariables.offset_y)
		 end,
        getFunction = function()
            return SE.savedVariables.offset_y
        end,
        default = 0,
        min = -750,
        max = 750,
        step = 5,
        unit = "", --optional unit
        format = "%d", --value format
        disable = function() return areSettingsDisabled end,
    }
	
	settings:AddSettings({generalSection, resetDefaults, toggle})
	settings:AddSettings({colorSection, titleColor, completeColor, incompleteColor})
	settings:AddSettings({sizeSection, title_font, set_font})
	settings:AddSettings({positionSection, position, offset_x, offset_y})
	
	EVENT_MANAGER:RegisterForEvent(SE.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SE.onUpdateEquips)
	EVENT_MANAGER:RegisterForEvent(SE.name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, SE.onUpdateEquips)

	SE.onUpdateEquips(_, BAG_WORN, _, _, _, _, _)
end
	
function SE.OnAddOnLoaded(event, addonName)
	if addonName == SE.name then
		SE.Initialize()
		EVENT_MANAGER:UnregisterForEvent(SE.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(SE.name, EVENT_ADD_ON_LOADED, SE.OnAddOnLoaded)