-- MerchantMagic v1.4
-- By xdpirate

local MerchantMagic_color = "|cFF3FC7EB"
local MerchantMagic_HighLightColor = "|cFF0070DD"
local original = "|r"

local validParameters = {"name", "rarity", "type", "subtype", "ilvl", "level", "sellprice", "bindtype"}
local validTypes = {"armor", "consumable", "container", "gem", "key", "miscellaneous", "money", "reagent", "recipe", "projectile", "quest", "quiver", "trade goods", "weapon"}
local validSubTypes = {"miscellaneous", "cloth", "leather", "mail", "plate", "shields", "librams", "idols", "totems", "sigils", "food & drink", "potion", "elixir", "flask", "bandage", "item enhancement", "scroll", "other", "consumable", "bag", "enchanting bag", "engineering bag", "gem bag", "herb bag", "mining bag", "soul bag", "leatherworking bag", "blue", "green", "orange", "meta", "prismatic", "purple", "red", "simple", "yellow", "key", "junk", "reagent", "pet", "holiday", "mount", "other", "reagent" , "alchemy", "blacksmithing", "book", "cooking", "enchanting", "engineering", "first aid", "leatherworking", "tailoring", "arrow", "bullet", "quest", "ammo pouch", "quiver", "cloth", "devices", "elemental", "enchanting", "explosives", "herb", "item enchantment", "jewelcrafting", "leather", "materials", "meat", "metal & stone", "other", "parts", "trade goods", "bows", "crossbows", "daggers", "guns", "fishing poles", "fist weapons", "miscellaneous", "one-handed axes", "one-handed maces", "one-handed swords", "polearms", "staves", "thrown", "two-handed axes", "two-handed maces", "two-handed swords", "wands", "alcohol"}
local validBindTypes = {"none", "bop", "boe", "bou"}

local clearConfirmation = false
local whitelistClearConfirmation = false

local tooltipScanner = _G['LibItemSearchTooltipScanner'] or CreateFrame('GameTooltip', 'LibItemSearchTooltipScanner', UIParent, 'GameTooltipTemplate')

function MM_OnLoad()
    SLASH_MERCHANTMAGIC1, SLASH_MERCHANTMAGIC2 = '/merchantmagic', '/mm'
    MMPrint("Loaded! Use /mm or /merchantmagic")
    
    MerchantMagicFrame:RegisterEvent("ADDON_LOADED")
    MerchantMagicFrame:RegisterEvent("MERCHANT_SHOW")
end

function SlashCmdList.MERCHANTMAGIC(msg, editbox)
    local message = strlower(trim(msg))
    
    if message == "toggle" then
        MMSettings.enabled = not MMSettings.enabled
        
        if MMSettings.enabled then
            MMPrint("MerchantMagic is now enabled.")
        else
            MMPrint("MerchantMagic is now disabled.")
        end
    elseif message == "verbose" then
        MMSettings.verbose = not MMSettings.verbose
        
        if MMSettings.verbose then
            MMPrint("Verbose mode enabled.")
        else
            MMPrint("Verbose mode disabled.")
        end
    elseif message == "max12" then
        MMSettings.max12 = not MMSettings.max12
        
        if MMSettings.max12 then
            MMPrint("Max12 mode enabled.")
        else
            MMPrint("Max12 mode disabled.")
        end
    elseif message == "tooltip" then
        MMSettings.tooltipEnabled = not MMSettings.tooltipEnabled
        
        if MMSettings.tooltipEnabled then
            MMPrint("MM tooltip enabled.")
        else
            MMPrint("MM tooltip disabled.")
        end
    elseif message == "tooltip verbose" then
        MMSettings.tooltipVerbose = not MMSettings.tooltipVerbose
        
        if MMSettings.tooltipVerbose then
            MMPrint("Verbose item tooltip information enabled.")
        else
            MMPrint("Verbose item tooltip information disabled.")
        end
    elseif message == "tooltip info" then
        MMSettings.tooltipInfo = not MMSettings.tooltipInfo
        
        if MMSettings.tooltipInfo then
            MMPrint("Item info in tooltips enabled.")
        else
            MMPrint("Item info in tooltips disabled.")
        end
    elseif message == "list" then
        if table_length(MMRules) > 0 then
            for rule=1,table_length(MMRules)
            do
                local stateMsg = "|cFFFF0000OFF|r"
                if string.sub(MMRules[rule], 1, 1) == "1" then
                    stateMsg = "|cFF00FF00ON|r"
                end
                
                MMPrint("Ruleset #" .. rule .. " (" .. stateMsg .. "): " .. string.sub(MMRules[rule], 3))
            end
        else
            MMPrint("There are currently no rulesets defined.")
        end
    elseif starts_with(message, "add ") then
        local newRuleset = string.sub(message, 5)
        local validationResult = ValidateRuleset(newRuleset)

        if validationResult == "Success" then
            MMPrint("Ruleset (" .. newRuleset .. ") seems to be valid!")
            table.insert(MMRules, "0*" .. newRuleset)
            
            MMPrint("Ruleset #" .. table_length(MMRules) .. " added! To enable it, enter "..MerchantMagic_Highlight("/mm enable " .. table_length(MMRules)))
        else
            MMPrint("Error: " .. validationResult)
        end
    elseif starts_with(message, "remove ") then
        local rulesetToRemove = tonumber(string.sub(message, 8))
        
        if rulesetToRemove ~= nil then
            if(rulesetToRemove < 1 or rulesetToRemove > table_length(MMRules)) then
                MMPrint("Invalid ruleset ID. There are currently " .. table_length(MMRules) .. " rulesets registered.")
            else
                local result = table.remove(MMRules, rulesetToRemove)
                
                if result ~= nil then
                    MMPrint("Ruleset #" .. rulesetToRemove .. " has been removed.")
                else
                    MMPrint("Could not remove ruleset.")
                end
            end
        else
            MMPrint("Ruleset must be a number.")
        end
    elseif starts_with(message, "clone ") then
        local rulesetToClone = strmatch(message, "clone (%d+)")
        rulesetToClone = tonumber(rulesetToClone)

        if MMRules[rulesetToClone] then
            table.insert(MMRules, "0*" .. string.sub(MMRules[rulesetToClone], 3))
            MMPrint("Cloned ruleset #" .. rulesetToClone .. " to new ruleset #".. table_length(MMRules) .. "! To enable it, enter "..MerchantMagic_Highlight("/mm enable " .. table_length(MMRules)))
        else
            MMPrint("Ruleset " .. rulesetToClone .. " doesn't exist!")
        end
    elseif starts_with(message, "edit ") then
        local rulesetToEdit = strmatch(message, "edit (%d+)")
        local newRuleset = strmatch(message, "edit %d+ (.+)")
        rulesetToEdit = tonumber(rulesetToEdit)
        
        if rulesetToEdit ~= nil and newRuleset == nil then
            -- If commandline is just "/mm edit xx" then insert text from the given ruleset, for ease of editing
            if MMRules[rulesetToEdit] then
                DelayedChatInsert("/mm edit " .. rulesetToEdit .. " " .. string.sub(MMRules[rulesetToEdit], 3))
            else
                MMPrint("Ruleset " .. rulesetToEdit .. " doesn't exist!")
            end
        elseif rulesetToEdit ~= nil and newRuleset ~= nil then
            if(rulesetToEdit < 1 or rulesetToEdit > table_length(MMRules)) then
                MMPrint("Invalid ruleset ID. There are currently " .. table_length(MMRules) .. " rulesets registered.")
            else
                local validationResult = ValidateRuleset(newRuleset)
                
                if validationResult == "Success" then
                    MMPrint("Ruleset (" .. newRuleset .. ") seems to be valid!")
                    MMRules[rulesetToEdit] = "0*" .. newRuleset
                    
                    MMPrint("Ruleset #" .. rulesetToEdit .. " edited! To enable it, enter "..MerchantMagic_Highlight("/mm enable " .. rulesetToEdit))
                else
                    MMPrint("Error: " .. validationResult)
                end
            end
        else
            if rulesetToEdit == nil then
                MMPrint("Ruleset must be a number.")
            elseif newRuleset == nil then
                MMPrint("You must specify a ruleset.")
            end
        end
    elseif starts_with(message, "enable ") then
        local rulesetToEnable = tonumber(string.sub(message, 8))
        
        if rulesetToEnable ~= nil then
            if rulesetToEnable < 1 or rulesetToEnable > table_length(MMRules) then
                MMPrint("Out of range. The ruleset must be an existing ruleset. There are currently " .. table_length(MMRules) .. " rulesets.")
            else
                if string.sub(MMRules[rulesetToEnable], 1, 1) == "1" then
                    MMPrint("Ruleset #" .. rulesetToEnable .. " is already enabled.")
                else
                    MMRules[rulesetToEnable] = "1" .. string.sub(MMRules[rulesetToEnable], 2)
                    MMPrint("Ruleset #" .. rulesetToEnable .. " is now enabled.")
                end
            end
        else
            MMPrint("Ruleset must be a number. Example: "..MerchantMagic_Highlight("/mm enable 7"))
        end
    elseif starts_with(message, "disable ") then
        local rulesetToDisable = tonumber(string.sub(message, 9))
        
        if rulesetToDisable ~= nil then
            if rulesetToDisable < 1 or rulesetToDisable > table_length(MMRules) then
                MMPrint("Out of range. The ruleset must be an existing ruleset. There are currently " .. table_length(MMRules) .. " rulesets.")
            else
                if string.sub(MMRules[rulesetToDisable], 1, 1) == "0" then
                    MMPrint("Ruleset #" .. rulesetToDisable .. " is already disabled.")
                else
                    MMRules[rulesetToDisable] = "0" .. string.sub(MMRules[rulesetToDisable], 2)
                    MMPrint("Ruleset #" .. rulesetToDisable .. " is now disabled.")
                end
            end
        else
            MMPrint("Ruleset must be a number. Example: "..MerchantMagic_Highlight("/mm disable 5"))
        end
    elseif starts_with(message, "move ") then
        local from, to = strmatch(message, "move (%d+) (%d+)")
        from = tonumber(from)
        to = tonumber(to)
        
        if from ~= nil and to ~= nil then
            local movedRule = MMRules[from]
            table.remove(MMRules, from)
            table.insert(MMRules, to, movedRule)
            MMPrint("Ruleset #" .. from .. " moved to ruleset #" .. to .. ".")
        else
            MMPrint("Invalid ruleset numbers. Example usage: ".. MerchantMagic_Highlight("/mm move 3 7") .. " - Moves rule #3 to rule #7.")
        end
    elseif starts_with(message, "swap ") then
        local from, to = strmatch(message, "swap (%d+) (%d+)")
        from = tonumber(from)
        to = tonumber(to)
        
        if from ~= nil and to ~= nil then
            local fromRuleset = MMRules[from]
            local toRuleset = MMRules[to]
            
            MMRules[from] = toRuleset
            MMRules[to] = fromRuleset
            
            MMPrint("Swapped positions for ruleset #" .. from .. " and ruleset #" .. to .. ".")
        else
            MMPrint("Invalid ruleset numbers. Example usage: ".. MerchantMagic_Highlight("/mm swap 3 7") .. " - Swaps positions of rule #3 and rule #7.")
        end
    elseif message == "clear" then
        if clearConfirmation then
            clearConfirmation = false
            MMRules = {}
            MMPrint("All rulesets cleared.")
        else
            MMPrint("This cannot be undone. Are you sure you want to clear all rulesets? To confirm, enter "..MerchantMagic_Highlight("/mm clear").." again.")
            clearConfirmation = true
        end
    elseif starts_with(message, "test ") then
        local item = trim(string.sub(message, 6))
        local _, link = GetItemInfo(item)
        
        if(starts_with(link, "|c")) then
            TestItemAgainstRulesets(link, true)
        else
            MMPrint("Not a valid item link to test against.")
        end
    elseif starts_with(message, "info ") then
        local item = trim(string.sub(message, 6))
        local _, link, _, _, _, _, _, _, _, _, _ = GetItemInfo(item)
        
        if(starts_with(link, "|c")) then
            MMPrint("-- Info about " .. link .. " --")
            local returnedInfo = MMItemInfo(link)
            for index=1,table_length(returnedInfo)
            do
                MMPrint(returnedInfo[index])
            end
        else
            MMPrint("Not a valid item link to show info about.")
        end
    elseif starts_with(message, "whitelist") then
        local command = trim(strlower(string.sub(message, 11)))
        
        if starts_with(command, "add ") then
            local item = trim(string.sub(command, 5))
            
            if(item == nil or item == "") then
                MMPrint("Please specify a valid item name or item link")
                MMPrint("For example: "..MerchantMagic_Highlight("/mm add latro's dancing blade"))
            elseif(starts_with(item, "|c")) then
                itemName = GetItemInfo(item)
                itemName = strlower(itemName)
                
                if(has_value(MMWhitelist, itemName)) then
                    MMPrint("\"" .. itemName .. "\" is already in the whitelist.")
                else
                    table.insert(MMWhitelist, itemName)
                    MMPrint("Added \""..itemName.."\" to the whitelist!")
                end
            else
                if(has_value(MMWhitelist, item)) then
                    MMPrint("\""..item.."\" is already in the whitelist.")
                else
                    table.insert(MMWhitelist, item)
                    MMPrint("Added \""..item.."\" to the whitelist!")
                end
            end
        elseif starts_with(command, "remove ") then
            local item = trim(strlower(string.sub(command, 8)))
        
            if(item == nil or item == "") then
                MMPrint("Please specify a valid item name or item link")
                MMPrint("For example: "..MerchantMagic_Highlight("/mm remove latro's dancing blade"))
            elseif(starts_with(item, "|c")) then
                itemName = GetItemInfo(item)
                itemName = strlower(itemName)
                
                if(has_value(MMWhitelist, itemName)) then
                    local itemIndex = table_index(MMWhitelist, itemName)
                    table.remove(MMWhitelist, itemIndex)
                    MMPrint("Removed \""..itemName.."\" from the whitelist!")
                else
                    MMPrint("\""..itemName.."\" was not found in the whitelist.")
                end
            else
                if(has_value(MMWhitelist, item)) then
                    local itemIndex = table_index(MMWhitelist, item)
                    table.remove(MMWhitelist, itemIndex)
                    MMPrint("Removed \""..item.."\" from the whitelist!")
                else
                    MMPrint("\""..item.."\" was not found in the whitelist.")
                end
            end
        elseif starts_with(command, "list") then
            if table_length(MMWhitelist) > 0 then
                for index=1,table_length(MMWhitelist)
                do                   
                    MMPrint("#" .. index .. ": " .. MMWhitelist[index])
                end
            else
                MMPrint("There are currently no items defined in the whitelist.")
            end
        elseif command == "clear" then
            if whitelistClearConfirmation then
                whitelistClearConfirmation = false
                MMRules = {}
                MMPrint("All whitelist items cleared.")
            else
                MMPrint("This cannot be undone. Are you sure you want to clear all whitelist items? To confirm, enter "..MerchantMagic_Highlight("/mm whitelist clear").." again.")
                whitelistClearConfirmation = true
            end
        else
            ShowWhitelistUsage()
        end
    elseif message == "testbags" then
        DoTheMagic(true)
    elseif message == "rulesethelp" then
        ShowRulesetUsage()
    elseif message == "help" then
        ShowMMUsage()
    else
        ShowMMUsage()
    end
end

function DelayedChatInsert(text)
    local f = CreateFrame("Frame")
    f.elapsed = 0
    f:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed > 0.01 then
            ChatFrame_OpenChat(text or "")
            self:SetScript("OnUpdate", nil)
            self:Hide()
        end 
    end)
    f:Show()
end

function MMItemInfo(link)
    local itemName, link, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, _, _, _, sellPrice = GetItemInfo(link)
    
    local returnedLines = {}
    table.insert(returnedLines, "name="..strlower(itemName))
    table.insert(returnedLines, "rarity="..itemQuality)
    table.insert(returnedLines, "type="..strlower(itemType))
    table.insert(returnedLines, "subtype="..strlower(itemSubType))

    -- Check for custom subtypes
    tooltipScanner:SetOwner(UIParent, 'ANCHOR_NONE')
    tooltipScanner:SetHyperlink(link)

    if tooltipScanner:NumLines() > 0 then
        local textLine = _G[tooltipScanner:GetName() .. 'TextLeft2']:GetText()
        tooltipScanner:Hide()
        
        if textLine ~= nil and strmatch(textLine, "alcohol") ~= nil then
            table.insert(returnedLines, "subtype=alcohol")
        end
    end

    table.insert(returnedLines, "ilvl="..strlower(itemLevel))
    table.insert(returnedLines, "level="..strlower(itemMinLevel))
    table.insert(returnedLines, "sellprice="..strlower(sellPrice))

    local isBOE = link_FindSearchInTooltip(link, ITEM_BIND_ON_EQUIP)
    local isBOP = link_FindSearchInTooltip(link, ITEM_BIND_ON_PICKUP)
    local isBOU = link_FindSearchInTooltip(link, ITEM_BIND_ON_USE)
    local isBQ = link_FindSearchInTooltip(link, ITEM_BIND_QUEST)
    local isBTA = link_FindSearchInTooltip(link, ITEM_BIND_TO_ACCOUNT)            
    local isBound = link_FindSearchInTooltip(link, ITEM_SOULBOUND)

    if isBOE == false and isBOP == false and isBOU == false and isBQ == false and isBTA == false and isBound == false then
        table.insert(returnedLines, "bindtype=none")
    elseif isBOP or isBound then
        table.insert(returnedLines, "bindtype=bop")
    elseif isBOE then
        table.insert(returnedLines, "bindtype=boe")
    elseif isBOU then
        table.insert(returnedLines, "bindtype=bou")
    else
        table.insert(returnedLines, "Quest/BtA items cannot be filtered on bind type.")
    end
    
    return returnedLines
end

function ValidateRuleset(ruleset)
    local rules = string_split(ruleset, ";")
    
    for rule=1,table_length(rules)
    do
        local ruleComponents, operator
        if string.find(rules[rule], "=") then
            operator = "="
            ruleComponents = string_split(rules[rule], "=")
        elseif string.find(rules[rule], "<") then
            operator = "<"
            ruleComponents = string_split(rules[rule], "<")
        elseif string.find(rules[rule], ">") then
            operator = ">"
            ruleComponents = string_split(rules[rule], ">")
        else
            return MerchantMagic_Highlight(rules[rule]) .. " does not contain an operator (=, <, or >)."
        end
        
        local argument = ruleComponents[1]
        local parameterString = ruleComponents[2]
        
        if has_value(validParameters, argument) == false then
            -- Argument is invalid
            return MerchantMagic_Highlight(argument) .. " is not a valid argument."
        else
            -- Argument is valid, validate parameter(s)
            local parameters = string_split(parameterString, ",")
            for param=1,table_length(parameters)
            do
                if argument == "rarity" then
                    local rarityInteger = tonumber(parameters[param])
                    
                    if rarityInteger == nil then
                        return MerchantMagic_Highlight("rarity").." must be a number. Accepted values are as follows: 0 (".. ITEM_QUALITY_COLORS[0].hex .. "Poor" .. original .. "), 1 (" .. ITEM_QUALITY_COLORS[1].hex .. "Common"..original.."), 2 ("..ITEM_QUALITY_COLORS[2].hex.."Uncommon"..original.."), 3 ("..ITEM_QUALITY_COLORS[3].hex.."Rare" .. original .. "), 4 ("..ITEM_QUALITY_COLORS[4].hex.."Epic" .. original .. ")."
                    elseif rarityInteger > 4 then
                        return MerchantMagic_Highlight("rarity").." cannot be higher than 4. Accepted values are as follows: 0 (".. ITEM_QUALITY_COLORS[0].hex .. "Poor" .. original .. "), 1 (" .. ITEM_QUALITY_COLORS[1].hex .. "Common"..original.."), 2 ("..ITEM_QUALITY_COLORS[2].hex.."Uncommon"..original.."), 3 ("..ITEM_QUALITY_COLORS[3].hex.."Rare" .. original .. "), 4 ("..ITEM_QUALITY_COLORS[4].hex.."Epic" .. original .. ")."
                    end
                elseif argument == "type" then
                    if operator ~= "=" then
                        return MerchantMagic_Highlight("type") .. " can only have an equals sign (=) as its operator."
                    else
                        if has_value(validTypes, parameters[param]) == false then
                            return MerchantMagic_Highlight(parameters[param]) .. " is not a valid parameter to " .. MerchantMagic_Highlight("type") .. ". Accepted values are as follows: \"armor\", \"consumable\", \"container\", \"gem\", \"key\", \"miscellaneous\", \"money\", \"reagent\", \"recipe\", \"projectile\", \"quest\", \"quiver\", \"trade goods\", \"weapon\"."
                        end    
                    end
                elseif argument == "subtype" then
                    if operator ~= "=" then
                        return MerchantMagic_Highlight("subtype") .. " can only have an equals sign (=) as its operator."
                    else
                        if has_value(validSubTypes, parameters[param]) == false then
                            return MerchantMagic_Highlight(parameters[param]) .. " is not a valid parameter to " .. MerchantMagic_Highlight("subtype") .. ". Accepted values are as follows: \"miscellaneous\", \"cloth\", \"leather\", \"mail\", \"plate\", \"shields\", \"librams\", \"idols\", \"totems\", \"sigils\", \"food & drink\", \"potion\", \"elixir\", \"flask\", \"bandage\", \"item enhancement\", \"scroll\", \"other\", \"consumable\", \"bag\", \"enchanting bag\", \"engineering bag\", \"gem bag\", \"herb bag\", \"mining bag\", \"soul bag\", \"leatherworking bag\", \"blue\", \"green\", \"orange\", \"meta\", \"prismatic\", \"purple\", \"red\", \"simple\", \"yellow\", \"key\", \"junk\", \"reagent\", \"pet\", \"holiday\", \"mount\", \"other\", \"reagent\" , \"alchemy\", \"blacksmithing\", \"book\", \"cooking\", \"enchanting\", \"engineering\", \"first aid\", \"leatherworking\", \"tailoring\", \"arrow\", \"bullet\", \"quest\", \"ammo pouch\", \"quiver\", \"cloth\", \"devices\", \"elemental\", \"enchanting\", \"explosives\", \"herb\", \"item enchantment\", \"jewelcrafting\", \"leather\", \"materials\", \"meat\", \"metal & stone\", \"other\", \"parts\", \"trade goods\", \"bows\", \"crossbows\", \"daggers\", \"guns\", \"fishing poles\", \"fist weapons\", \"miscellaneous\", \"one-handed axes\", \"one-handed maces\", \"one-handed swords\", \"polearms\", \"staves\", \"thrown\", \"two-handed axes\", \"two-handed maces\", \"two-handed swords\", \"wands\", \"alcohol\"."
                        end
                    end
                elseif argument == "ilvl" then
                    local ilvlInteger = tonumber(parameters[param])
                    if ilvlInteger == nil then
                        return MerchantMagic_Highlight("ilvl").." must be a number."
                    elseif ilvlInteger < 1 or ilvlInteger > 600 then
                        return MerchantMagic_Highlight("ilvl").." must be greater than 1 and less than 600."
                    end
                elseif argument == "level" then
                    local levelInteger = tonumber(parameters[param])
                    if levelInteger == nil then
                        return MerchantMagic_Highlight("level").." must be a number."
                    elseif levelInteger < 0 or levelInteger > 90 then
                        return MerchantMagic_Highlight("level").." must be a number from 0 to 90."
                    end
                elseif argument == "sellprice" then
                    local priceInteger = tonumber(parameters[param])
                    if priceInteger == nil then
                        return MerchantMagic_Highlight("sellprice").." must be a number, and is expressed in copper (e.g. 10 = "..GetCoinTextureString(10)..", 100 = "..GetCoinTextureString(100)..", 10000 = "..GetCoinTextureString(10000)..")"
                    elseif priceInteger < 0 then
                        return MerchantMagic_Highlight("sellprice").." must be a number greater than 0, and is expressed in copper (e.g. 10 = "..GetCoinTextureString(10)..", 100 = "..GetCoinTextureString(100)..", 10000 = "..GetCoinTextureString(10000)..")"
                    end
                elseif argument == "bindtype" then
                    if operator ~= "=" then
                        return MerchantMagic_Highlight("bindtype") .. " can only have an equals sign (=) as its operator."
                    else
                        if has_value(validBindTypes, parameters[param]) == false then
                            return MerchantMagic_Highlight(parameters[param]) .. " is not a valid parameter to "..MerchantMagic_Highlight("bindtype")..". Accepted values are as follows: \"none\" (Does not bind), \"bop\" (Bind on Pickup), \"boe\" (Bind on Equip), \"bou\" (Binds on Use)"
                        end
                    end
                end
            end
        end
    
    end
    
    return "Success"
end

function MM_OnEvent(self, event, ...) -- Event handler
    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = ...;
    if event=="ADDON_LOADED" then
        if arg1=="MerchantMagic" then
        
            -- Set default settings
            if MMSettings == nil then
                MMSettings = {enabled = true, verbose = true, max12 = false}
            else
                if MMSettings.enabled == nil then
                    MMSettings.enabled = true
                end
                
                if MMSettings.verbose == nil then
                    MMSettings.verbose = true
                end
                
                if MMSettings.max12 == nil then
                    MMSettings.max12 = false
                end
                
                if MMSettings.tooltipEnabled == nil then
                    MMSettings.tooltipEnabled = true
                end
                
                if MMSettings.tooltipVerbose == nil then
                    MMSettings.tooltipVerbose = false
                end
                
                if MMSettings.tooltipInfo == nil then
                    MMSettings.tooltipInfo = false
                end
            end

            if MMRules == nil then
                MMRules = {"0*rarity=0"} -- Start with an example ruleset, sell all grays
            end
            
            if MMWhitelist == nil then
                MMWhitelist = {}
            end
            
            -- Hook gametooltip for displaying ruleset info on item tooltips
            GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
                if MMSettings.tooltipEnabled then
                    local itemName, link = tooltip:GetItem()
                    if not link then return; end
                    
                    local textAdded = false
                    
                    if has_value(MMWhitelist, strlower(itemName)) then
                        tooltip:AddLine(" ")
                        tooltip:AddLine(MerchantMagic_color .. "MerchantMagic" .. original ..": Item is in your whitelist")
                        textAdded = true
                    else
                        local success, rulesetIndex = TestItemAgainstRulesets(link, false)
                        if success then
                            tooltip:AddLine(" ")
                            tooltip:AddLine(MerchantMagic_color .. "MerchantMagic" .. original ..": Will be sold, matches ruleset #" .. rulesetIndex .. (MMSettings.tooltipVerbose and ":\n" .. "|cFFFFFFFF" .. string.sub(MMRules[rulesetIndex], 3) .. original .. "\n" or ""))
                            textAdded = true
                        end          
                    end
                    
                    if MMSettings.tooltipInfo then
                        tooltip:AddLine(" ")
                        tooltip:AddLine(MerchantMagic_color .. "MerchantMagic info:" .. original)
                        
                        local returnedLines = MMItemInfo(link)
                        for index=1,table_length(returnedLines)
                        do
                            tooltip:AddLine(returnedLines[index])
                        end
                        
                        textAdded = true
                    end
                    
                    if textAdded then
                        tooltip:AddLine(" ")
                    end
                end
            end)
        end
    elseif event == "MERCHANT_SHOW" then
        -- Parse rules and sell shit!
        
        if MMSettings.enabled then
            DoTheMagic(false)
        end
    end
end

function DoTheMagic(testing)
    local soldItems = 0
    local soldSlots = 0
    local soldValue = 0
    
    for bag=0,4
    do
        if MMSettings.max12 and soldSlots == 12 and not testing then
            break
        end
        
        for slot = 1,GetContainerNumSlots(bag) 
        do
            if MMSettings.max12 and soldSlots == 12 and not testing then
                break
            end
            
            local link = GetContainerItemLink(bag, slot)
            
            if link then
                local itemName = select(1, GetItemInfo(link))
                if itemName then
                    itemName = strlower(itemName)
                    
                    local sellprice = select(11, GetItemInfo(link))

                    local _, itemCount = GetContainerItemInfo(bag, slot)
                    local slotValue = sellprice * itemCount
                    
                    if has_value(MMWhitelist, itemName) == false then -- Not in whitelist
                        local success, rulesetIndex = TestItemAgainstRulesets(link, false)
                        if success then -- Item matched a ruleset
                            if sellprice == 0 and MMSettings.verbose then
                                MMPrint(link .. " has no sell price and was ignored.")
                            else
                                if testing == false then
                                    ShowMerchantSellCursor(1)
                                    UseContainerItem(bag, slot)
                                end
                                
                                soldSlots = soldSlots + 1
                                soldItems = soldItems + itemCount
                                soldValue = soldValue + slotValue
      
                                if MMSettings.verbose then
                                    MMPrint("Sold: " .. itemCount .. "x ".. link .. " (RS#" .. rulesetIndex .. ")")
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if soldItems > 0 then
        MMPrint("Sold " .. soldItems .. " |4item:items; (" .. soldSlots .. " |4slot:slots;), gained " .. GetCoinTextureString(soldValue))
    else
        if testing then
            MMPrint("No items in your bags matched any of your rulesets!")
        end
    end
end

function TestItemAgainstRulesets(link, testing)
    if testing then
        MMPrint("Testing " .. link .. " against all rulesets.")
    end
    
    -- "name", "rarity", "type", "subtype", "ilvl", "level", "sellprice", "bindtype"
    local itemName, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, _, _, _, sellPrice = GetItemInfo(link)
    
    -- Iterate over all rulesets and see if this item matches any
    for rulesetIndex=1,table_length(MMRules)
    do
        local currentRuleset = MMRules[rulesetIndex]
        if string.sub(currentRuleset, 1, 1) == "1" then -- Ruleset is enabled
            currentRuleset = string.sub(currentRuleset, 3)
            local rules = string_split(currentRuleset, ";")
            local matchedRules = 0
            
            for ruleIndex=1,table_length(rules)
            do
                local ruleComponents, operator
                if string.find(rules[ruleIndex], "=") then
                    operator = "="
                    ruleComponents = string_split(rules[ruleIndex], "=")
                elseif string.find(rules[ruleIndex], "<") then
                    operator = "<"
                    ruleComponents = string_split(rules[ruleIndex], "<")
                elseif string.find(rules[ruleIndex], ">") then
                    operator = ">"
                    ruleComponents = string_split(rules[ruleIndex], ">")
                end
                
                local argument = ruleComponents[1]
                local parameterString = ruleComponents[2]
                
                local parameters = string_split(parameterString, ",")
                for param=1,table_length(parameters)
                do
                    local currentParameter = parameters[param]
                    if argument == "name" then
                        if itemName and currentParameter == strlower(itemName) then
                            if testing then
                                MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                            end
                            
                            matchedRules = matchedRules + 1
                            break
                        end
                    elseif argument == "rarity" then
                        local rarityInteger = tonumber(currentParameter)
                        
                        if operator == "=" then
                            if itemQuality and itemQuality == rarityInteger then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        elseif operator == "<" then
                            if itemQuality and itemQuality < rarityInteger then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        elseif operator == ">" then
                            if itemQuality and itemQuality > rarityInteger then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        end    
                    elseif argument == "type" then
                        if itemType and currentParameter == strlower(itemType) then
                            if testing then
                                MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                            end
                            
                            matchedRules = matchedRules + 1
                            break
                        end
                    elseif argument == "subtype" then
                        -- Parse some custom subtypes to make things easier for the user, not everything is categorized down to a T by the game
                        if currentParameter == "alcohol" then
                            tooltipScanner:SetOwner(UIParent, 'ANCHOR_NONE')
                            tooltipScanner:SetHyperlink(link)
                            
                            if tooltipScanner:NumLines() > 0 then
                                local textLine = _G[tooltipScanner:GetName() .. 'TextLeft2']:GetText()
                                tooltipScanner:Hide()
                                
                                if textLine ~= nil and strmatch(textLine, "alcohol") ~= nil then
                                    if testing then
                                        MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                    end
                                    
                                    matchedRules = matchedRules + 1
                                    break
                                end
                            end
                        elseif itemSubType and currentParameter == strlower(itemSubType) then
                            if testing then
                                MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                            end
                            
                            matchedRules = matchedRules + 1
                            break
                        end
                    elseif argument == "ilvl" then
                        local ilvlInteger = tonumber(currentParameter)
                        
                        if operator == "=" then
                            if itemLevel and itemLevel == ilvlInteger then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        elseif operator == "<" then
                            if itemLevel and itemLevel < ilvlInteger then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        elseif operator == ">" then
                            if itemLevel and itemLevel > ilvlInteger then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        end    
                    elseif argument == "level" then
                        local levelInteger = tonumber(currentParameter)
                        
                        if operator == "=" then
                            if itemMinLevel and itemMinLevel == levelInteger then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        elseif operator == "<" then
                            if itemMinLevel and itemMinLevel < levelInteger then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        elseif operator == ">" then
                            if itemMinLevel and itemMinLevel > levelInteger then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        end   
                    elseif argument == "sellprice" then
                        local priceInteger = tonumber(currentParameter)
                        
                        if operator == "=" then
                            if sellPrice == priceInteger then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        elseif operator == "<" then
                            if sellPrice < priceInteger then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        elseif operator == ">" then
                            if sellPrice > priceInteger then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        end   
                    elseif argument == "bindtype" then
                        local isBOE = link_FindSearchInTooltip(link, ITEM_BIND_ON_EQUIP)
                        local isBOP = link_FindSearchInTooltip(link, ITEM_BIND_ON_PICKUP)
                        local isBOU = link_FindSearchInTooltip(link, ITEM_BIND_ON_USE)
                        local isBQ = link_FindSearchInTooltip(link, ITEM_BIND_QUEST)
                        local isBTA = link_FindSearchInTooltip(link, ITEM_BIND_TO_ACCOUNT)
                        
                        if currentParameter == "none" then
                            if isBOE == false and isBOP == false and isBOU == false and isBQ == false and isBTA == false then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        elseif currentParameter == "bop" then
                            if isBOP then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        elseif currentParameter == "boe" then
                            if isBOE then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        elseif currentParameter == "bou" then
                            if isBOU then
                                if testing then
                                    MMPrint(link .. " matched "..argument..operator..currentParameter.." in ruleset #"..rulesetIndex..".")
                                end
                                
                                matchedRules = matchedRules + 1
                                break
                            end
                        end
                    end
                end
            end
            
            if table_length(rules) == matchedRules then -- Matched all rules, sell item and break out to next item
                if testing then
                    MMPrint(link .. " matched all rules in ruleset #"..rulesetIndex..".")
                end
                
                return true, rulesetIndex
            else
                if testing then
                    MMPrint(link .. " did not match all rules in ruleset #"..rulesetIndex..".")
                end                                    
            end
        end
    end
    
    return false, false
end

function ShowMMUsage() -- Show available functions
    MMPrint("Usage: "..MerchantMagic_color.."/mm "..MerchantMagic_Highlight("<command>"))
    MMPrint("(/merchantmagic can be substituted for /mm)")
    MMPrint("+ Addon settings:")
    MMPrint(MerchantMagic_Highlight("toggle").." -- Turn MerchantMagic on/off (currently " .. (MMSettings.enabled and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r") .. ")")
    MMPrint(MerchantMagic_Highlight("verbose").." -- Turn verbose mode on/off (currently " .. (MMSettings.verbose and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r") .. ")")
    MMPrint(MerchantMagic_Highlight("max12").." -- Turn Max12 mode on/off (currently " .. (MMSettings.max12 and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r") .. ")")
    MMPrint(MerchantMagic_Highlight("tooltip").." -- Turn MM tooltip info on/off (currently " .. (MMSettings.tooltipEnabled and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r") .. ")")
    MMPrint(MerchantMagic_Highlight("tooltip verbose").." -- Show ruleset content in item tooltip info (currently " .. (MMSettings.tooltipVerbose and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r") .. ")")
    MMPrint(MerchantMagic_Highlight("tooltip info").." -- Show item info in MM tooltip (currently " .. (MMSettings.tooltipInfo and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r") .. ")")
    MMPrint("+ Ruleset settings:")
    MMPrint(MerchantMagic_Highlight("add <ruleset>").." -- Add a new ruleset")
    MMPrint(MerchantMagic_Highlight("remove <rulesetID>").." -- Remove ruleset <rulesetID>")
    MMPrint(MerchantMagic_Highlight("edit <rulesetID>").." -- Edit ruleset <rulesetID> in-place")
    MMPrint(MerchantMagic_Highlight("edit <rulesetID> <newRuleset>").." -- Edit ruleset <rulesetID>, replacing it with <newRuleset>")
    MMPrint(MerchantMagic_Highlight("enable <rulesetID>").." -- Enable ruleset <rulesetID>")
    MMPrint(MerchantMagic_Highlight("disable <rulesetID>").." -- Disable ruleset <rulesetID>")
    MMPrint(MerchantMagic_Highlight("move <fromID> <toID>").." -- Move ruleset from <fromID> to <toID>, reordering the list")
    MMPrint(MerchantMagic_Highlight("swap <fromID> <toID>").." -- Swap <fromID> <toID> ruleset positions")
    MMPrint(MerchantMagic_Highlight("clone <rulesetID>").." -- Clone <rulesetID> into a new entry")
    MMPrint(MerchantMagic_Highlight("test <itemLink>").." -- Test <itemLink> against current rulesets")
    MMPrint(MerchantMagic_Highlight("testbags").." -- Test contents of bags against current rulesets (dry run)")
    MMPrint(MerchantMagic_Highlight("info <itemLink>").." -- Show relevant info about <itemLink>")
    MMPrint(MerchantMagic_Highlight("whitelist").." -- Show whitelist commands")
    MMPrint(MerchantMagic_Highlight("clear").." -- Clear all rulesets")
    MMPrint(MerchantMagic_Highlight("rulesethelp").." -- Show help on how to write a ruleset")
end

function ShowRulesetUsage()
    MMPrint("A ruleset is a semicolon (;) separated list of rules MerchantMagic will parse.")
    MMPrint(MerchantMagic_Highlight("Example: ") .. "type=consumable;subtype=scroll  - Matches all scrolls")
    MMPrint("An equals sign (=) separates arguments from parameters within each rule.")
    MMPrint(MerchantMagic_Highlight("Example: ") .. "type=recipe  - Matches all items classed as recipes")
    MMPrint("If the parameter is an integer, you can use less-than (<) or greater than (>) instead of an equals sign.")
    MMPrint(MerchantMagic_Highlight("Example: ") .. "ilvl<400  - Matches all items with an item level less than 400")
    MMPrint("A comma (,) separates boolean OR parameters within each rule.")
    MMPrint(MerchantMagic_Highlight("Example: ") .. "type=weapon,armor  - Matches both weapons and armor")
    MMPrint("When a merchant window is opened, MerchantMagic starts checking inventory contents against user's defined rules. Rules are processed top-down, in decreasing priority. If an item matches, it will be sold, and processing will move to the next bag slot without parsing lower priority rules.")
    MMPrint("For a full explanation of all possible options, visit https://github.com/xdpirate/MerchantMagic")
end

function ShowWhitelistUsage()
    MMPrint("Usage: "..MerchantMagic_color.."/mm whitelist "..MerchantMagic_Highlight("<command>"))
    MMPrint("(/merchantmagic can be substituted for /mm)")
    MMPrint("===================")
    MMPrint("The whitelist is a list of items that will never be automatically sold.")
    MMPrint("Add an item by name or link to ensure that it is never sold by mistake!")
    MMPrint("Available whitelist commands:")
    MMPrint("===================")
    MMPrint(MerchantMagic_Highlight("add <item name or link>").." -- Add an item to the whitelist")
    MMPrint(MerchantMagic_Highlight("remove <item name or link>").." -- Remove specified item from whitelist")
    MMPrint(MerchantMagic_Highlight("list").." -- List all items currently in the whitelist")
    MMPrint(MerchantMagic_Highlight("clear").." -- Clear the whitelist of all item names")
end

function MMPrint(msg) -- Print a chat frame message in MerchantMagic format
    print(MerchantMagic_color.."MerchantMagic"..original..": "..msg)
end

function MerchantMagic_Highlight(msg) -- Highlight a piece of text
    if msg ~= nil then
        return MerchantMagic_HighLightColor..msg..original
    end
end

function string_split(inputString, separator)
    local t={}
    for str in string.gmatch(inputString, "([^"..separator.."]+)") do
        table.insert(t, str)
    end
    return t
end

function starts_with(str, start)
    return str:sub(1, #start) == start
end

function has_value (tab, val) -- Shamelessly stolen from Stack Overflow
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    
    return false
end

function table_index(whichTable, whichValue)
    local index={}
    for k,v in pairs(whichTable) do
        index[v]=k
    end
    return index[whichValue]
end

function table_length(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- The following code to detect bind type is borrowed (and slightly modified) from tekkub's wonderful GnomishVendorShrinker. 
-- I couldn't find a license for it, so it is assumed to be public domain.
-- https://github.com/TekNoLogic/GnomishVendorShrinker

function link_FindSearchInTooltip(itemLink, search)
    tooltipScanner:SetOwner(UIParent, 'ANCHOR_NONE')
    tooltipScanner:SetHyperlink(itemLink)
    
    local result = false
    if tooltipScanner:NumLines() > 1 and _G[tooltipScanner:GetName() .. 'TextLeft2']:GetText() == search then
        result = true
    elseif tooltipScanner:NumLines() > 2 and _G[tooltipScanner:GetName() .. 'TextLeft3']:GetText() == search then
        result = true
    end
    tooltipScanner:Hide()
    
    return result
end
