
ThereMountsOptions = CreateFrame("Frame")
ThereMountsOptions.name = "ThereMounts"
InterfaceOptions_AddCategory(ThereMountsOptions)

ThereMountsOptions:RegisterEvent("ADDON_LOADED")



-- Main
ThereMountsOptions:SetScript("OnEvent", function(self,event, arg1)

    if event == "ADDON_LOADED" and arg1 == "ThereMounts" then

		-- Initialisation du tableau s'il n'existe pas
		if not ThereMountsConfig then
			ThereMountsConfig = {SC_NoSwim="Shift", SC_Vendor="Ctrl", SC_Gather="Clic droit"}
		end

		-- Titre
		title = ThereMountsOptions:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
		title:SetPoint("TOPLEFT", 20, -18)
		title:SetText("ThereMounts")

		-- Description
		desc = ThereMountsOptions:CreateFontString("ARTWORK", nil, "GameTooltipText")
		desc:SetPoint("TOPLEFT", 20, -60)
		desc:SetText("Configuration des raccourcis")


		function createDropDown(options)

			local label = ThereMountsOptions:CreateFontString("ARTWORK", nil, "GameTooltipText")
			local default = ThereMountsConfig[options["name"]]
			label:SetPoint("TOPLEFT", options["posX"], options["posY"])
			label:SetText(options["label"])

			local dropdown = CreateFrame("Frame", "dropdown"..options["name"], ThereMountsOptions, 'UIDropDownMenuTemplate')
			dropdown:SetPoint("TOPLEFT", options["posX"]+250, options["posY"]+6)
			

			
			-- UIDropDownMenu_SetWidth(dropdown, 150)
			-- UIDropDownMenu_SetText(dropdown, options["defaultVal"])
			UIDropDownMenu_SetText(dropdown, default)
			-- dd_title:SetText(title_text)

			UIDropDownMenu_Initialize(dropdown, function(self, level, _)
				local info = UIDropDownMenu_CreateInfo()
				for key, val in pairs(options["items"]) do
					info.text = "     "..val.."     ";
					-- info.checked = val == default and true or false 
					info.checked = false 
					info.isNotRadio = true
					info.notCheckable = true
					-- info.padding = 10
					info.menuList= key
					info.hasArrow = false
					info.func = function(b)
						local selected = val:gsub("^%s*(.-)%s*$", "%1")
						UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
						UIDropDownMenu_SetText(dropdown, selected)
						-- b.checked = true
						ThereMountsConfig[options["name"]] = selected
					end
					-- UIDropDownMenu_SetWidth(dropdown, 120, 20) 
					-- UIDropDownMenu_SetButtonWidth(dropdown, 120)
					UIDropDownMenu_AddButton(info)
				end
			end)
		end

		createDropDown({
			['posX']=20,
			['posY']=-106,
			['name']="SC_Vendor",
			['parent']=ThereMountsOptions,
			['label']='Monture avec réparateur',
			['items']= {'Shift', 'Ctrl', 'Alt', 'Clic droit'},
		})
		createDropDown({
			['posX']=20,
			['posY']=-146,
			['name']='SC_Gather',
			['parent']=ThereMountsOptions,
			['label']='Monture de récolte',
			['items']= {'Shift', 'Ctrl', 'Alt', 'Clic droit'},
		})
		createDropDown({
			['posX']=20,
			['posY']=-186,
			['name']='SC_NoSwim',
			['parent']=ThereMountsOptions,
			['label']='Forcer la monture volante quand on nage',
			['items']= {'Shift', 'Ctrl', 'Alt', 'Clic droit'},
		})

	end
end)
