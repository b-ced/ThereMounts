
--[[

  Modifieurs :
	CTRL	 : monture avec vendeur
	SHIFT	 : force l'invocation d'une monture volante (utile quand on est dans l'eau)
	RCLICK   : Montures de récolte

  To do :
    Ajout des montures AQ40

  Exemple de macro :
j

]]



-- Initialisation du tableau s'il n'existe pas
if not ThereMounts then
	ThereMounts = {Ground={}, Fly={}, Swim={}, Vendor={}, Gather={}}
end

-- Création d'un tableau de types s'il n'existe pas
function ThereMountsType(type)
	if not ThereMounts[type] then
		ThereMounts[type]={}
	end
end

-- Vérification de l'existance d'une monture dans le tableau
function ThereMountsExists(type, mount)
	ThereMountsType(type)
    for index, value in ipairs(ThereMounts[type]) do
        if value == mount then
          return true
        end
    end
	return false
end


-- Ajout d'une monture dans le tableau
function ThereMountsAdd(type, mount)
	ThereMountsType(type)
	if not ThereMountsExists(type, mount) then
		ThereMounts[type][#ThereMounts[type]+1]=mount
	end
end


-- Suppression d'une monture du tableau
function ThereMountsDel(type, mount)
	ThereMountsType(type)
	local TM={}
	local i=1
	while i <= #ThereMounts[type] do
		if ThereMounts[type][i] ~= mount then
			TM[#TM+1]=ThereMounts[type][i]
		end
		i = i + 1
	end
	ThereMounts[type] = TM
end


-- Invocation d'une monture
function ThereMountInvoke(type)
	local usablesMounts, isUsable = {}, false
	local i=1
	while i <= #ThereMounts[type] do
		isUsable, _ = C_MountJournal.GetMountUsabilityByID(ThereMounts[type][i], false)
        if isUsable then
			usablesMounts[#usablesMounts+1]=ThereMounts[type][i]
		end
		i = i + 1
	end
	if #usablesMounts>0 then
		C_MountJournal.SummonByID(usablesMounts[math.random(#usablesMounts)])
	else
		-- Eventuellement mettre un message d'erreur
	end
end

-- MAJ des boutons
function ThereMountUpdate(frameList)
	local types, mountType, i, j, k = {"Ground", "Fly", "Swim", "Vendor", "Gather"}, nil, 1, 1, 0
	while i <= 10 do
		j = 1
		k = 0
		while j <= 5 do
			mountType=types[j]
			if ThereMountsExists(mountType, _G["MountJournalListScrollFrameButton"..i].mountID) then
				frameList[mountType][i]:Show()
				frameList[mountType][i]:SetPoint("RIGHT", -10 -(20*k), 0)
				k = k + 1
			else
				frameList[mountType][i]:Hide()
			end
			j = j + 1
		end
		i = i + 1
	end
end

-- Récupérer les options
function thereParseOptions(option)
	local ret, opt = "", ThereMountsConfig[option]
	if opt == "Ctrl" then
		ret = "[mod:ctrl]"
	end
	if opt == "Shift" then
		ret = "[mod:shift]"
	end
	if opt == "Alt" then
		ret = "[mod:alt]"
	end
	if opt == "Clic droit" then
		ret = "[btn:2]"
	end
	return ret
end

-- Création des icones
function ThereCreateFrame(buttonPos, texture)
	f = CreateFrame("Frame", nil, buttonPos, "BackdropTemplate")
	f:SetHeight(16)
	f:SetWidth(16)
	f:SetPoint("RIGHT", -10, 0)
	local t = f:CreateTexture(nil, "BACKGROUND")
	t:SetTexture("Interface\\icons\\"..texture)
	t:SetAllPoints(f)
	-- f.texture = t
	f:Hide()
	return f
end


-- Main frame
local ThereMountsFrame = CreateFrame("Frame")


-- Events
ThereMountsFrame:RegisterEvent("ADDON_LOADED")


-- Main
ThereMountsFrame:SetScript("OnEvent", function(self,event, arg1)

    if event == "ADDON_LOADED" and arg1 == "Blizzard_Collections" then

		local frameList, i, button = {Ground={}, Fly={}, Swim={}, Vendor={}, Gather={}}, 1, nil
		while i <= 10 do
			button = _G["MountJournalListScrollFrameButton"..i]
			frameList["Ground"][i] = ThereCreateFrame(button, "ability_mount_ridinghorse.blp")
			frameList["Fly"][i] = ThereCreateFrame(button, "Ability_mount_snowygryphon.blp")
			frameList["Swim"][i] = ThereCreateFrame(button, "Ability_mount_progenitorjellyfish_dark.blp")
			frameList["Vendor"][i] = ThereCreateFrame(button, "Ability_mount_mammoth_black.blp")
			frameList["Gather"][i] = ThereCreateFrame(button, "Trade_Herbalism.blp")
			i = i + 1
		end
		
		MountJournalListScrollFrameScrollBar:HookScript("OnUpdate", function(self, delta)
			ThereMountUpdate(frameList)
		end)

		hooksecurefunc("MountOptionsMenu_Init", function(self, level)

			if MountJournal.menuMountID then

				local mID = MountJournal.menuMountID
				local _, _, _, _, mountTypeID = C_MountJournal.GetMountInfoExtraByID(mID)

				UIDropDownMenu_AddSeparator(level)

				-- Titre
				if mountTypeID ~= 232 and mountTypeID ~= 254 then
					local info = UIDropDownMenu_CreateInfo();
					info.text = "Montures aléatoires par type"
					info.keepShownOnClick = true
					info.isTitle = true
					info.notCheckable = true
					UIDropDownMenu_AddButton(info, level)
				end

				-- Monture terrestre
				if mountTypeID ~= 232 and mountTypeID ~= 254 and mountTypeID ~= 407 then
					local info = UIDropDownMenu_CreateInfo();
					info.text = "Utiliser en monture terrestre"
					info.checked = ThereMountsExists("Ground", mID)
					info.isNotRadio = true
					info.func = function()
						if ThereMountsExists("Ground", mID) then
						ThereMountsDel("Ground", mID)
						else
							ThereMountsAdd("Ground", mID)
						end
					end
					UIDropDownMenu_AddButton(info, level)
				end

				-- Monture volante
				if mountTypeID == 247 or mountTypeID == 248 or mountTypeID == 407 then
					local info = UIDropDownMenu_CreateInfo();
					info.text = "Utiliser en monture volante"
					info.checked = ThereMountsExists("Fly", mID)
					info.isNotRadio = true
					info.func = function()
						if ThereMountsExists("Fly", mID) then
							ThereMountsDel("Fly", mID)
						else
							ThereMountsAdd("Fly", mID)
						end
					end
					UIDropDownMenu_AddButton(info, level)
				end

				-- Monture aquatique
				if mountTypeID == 254 or mountTypeID == 407 then
					local info = UIDropDownMenu_CreateInfo();
					info.text = "Utiliser en monture aquatique"
					info.checked = ThereMountsExists("Swim", mID)
					info.isNotRadio = true
					info.func = function()
						if ThereMountsExists("Swim", mID) then
							ThereMountsDel("Swim", mID)
						else
							ThereMountsAdd("Swim", mID)
						end
					end
					UIDropDownMenu_AddButton(info, level)
				end	

				-- Monture avec vendeur
				if mID == 280 or mID == 284 or mID == 460 or mID == 1039 then
					local info = UIDropDownMenu_CreateInfo();
					info.text = "Utiliser en monture avec vendeur"
					info.checked = ThereMountsExists("Vendor", mID)
					info.isNotRadio = true
					info.func = function()
						if ThereMountsExists("Vendor", mID) then
							ThereMountsDel("Vendor", mID)
						else
							ThereMountsAdd("Vendor", mID)
						end
					end
					UIDropDownMenu_AddButton(info, level)
				end

				-- Monture de récolte
				if mID == 522 or mID == 845 then
					local info = UIDropDownMenu_CreateInfo();
					info.text = "Utiliser en monture de récolte"
					info.checked = ThereMountsExists("Gather", mID)
					info.isNotRadio = true
					info.func = function()
						if ThereMountsExists("Gather", mID) then
							ThereMountsDel("Gather", mID)
						else
							ThereMountsAdd("Gather", mID)
						end			
					end
					UIDropDownMenu_AddButton(info, level)
				end

			end

			UIDropDownMenu_AddSeparator(level)

			local info = UIDropDownMenu_CreateInfo();
			info.text = "Options"
			info.checked = false
			info.isNotRadio = true
			info.func = function()
				InterfaceAddOnsList_Update()
				InterfaceOptionsFrame_OpenToCategory(ThereMountsOptions)
			end
			UIDropDownMenu_AddButton(info, level)
		end)


		UIDropDownMenu_Initialize(MountJournal.mountOptionsMenu, MountOptionsMenu_Init, "MENU");

	end
end)


-- La commande /mount
SLASH_THEREMOUNT1 = "/mount"
SlashCmdList["THEREMOUNT"] = function(args)
	-- Compétence de monte ?
	local canFly = false
	local i = 1
	while true do
		local spellName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
		local _, _ ,_, _, _, _, spellId = GetSpellInfo(spellName)
		if not spellName then
			break
		end
		if (spellId == 34090 or spellId == 34091 or spellId == 90265) then
			canFly = true
		end
		i = i + 1
	end

	if (SecureCmdOptionParse(thereParseOptions("SC_Vendor"))) then
		-- Modifier pour monture réparation
		ThereMountInvoke("Vendor")
	elseif (SecureCmdOptionParse(thereParseOptions("SC_Gather"))) then
		-- Modifier pour monture réparation
		ThereMountInvoke("Gather")
	elseif (IsMounted() and not IsFlying()) then
		-- Dismount si eeeeeemonté, sauf si en vol
		Dismount();
	elseif (IsSwimming() and not SecureCmdOptionParse(thereParseOptions("SC_NoSwim"))) then
		-- Monture aquatique
		ThereMountInvoke("Swim")
	elseif (not IsMounted() and not UnitAffectingCombat("player")) then
		m=(canFly and (IsFlyableArea() or SecureCmdOptionParse(thereParseOptions("SC_NoSwim")))) and "Fly" or "Ground";
		ThereMountInvoke(m)
	end
	
end
