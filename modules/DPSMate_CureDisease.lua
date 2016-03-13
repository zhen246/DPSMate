-- Global Variables
DPSMate.Modules.CureDisease = {}
DPSMate.Modules.CureDisease.Hist = "Dispels"
DPSMate.Options.Options[1]["args"]["curedisease"] = {
	order = 200,
	type = 'toggle',
	name = 'Diseases cured',
	desc = "Show Diseases cured.",
	get = function() return DPSMateSettings["windows"][DPSMate.Options.Dewdrop:GetOpenedParent().Key]["options"][1]["curedisease"] end,
	set = function() DPSMate.Options:ToggleDrewDrop(1, "curedisease", DPSMate.Options.Dewdrop:GetOpenedParent()) end,
}

-- Register the moodule
DPSMate:Register("curedisease", DPSMate.Modules.CureDisease, "Cure disease")


function DPSMate.Modules.CureDisease:GetSortedTable(arr)
	local b, a, total = {}, {}, 0
	for cat, val in pairs(arr) do -- 3 Owner
		local CV = 0
		for ca, va in pairs(val) do -- 42 Ability
			if ca~="i" then
				for c, v in pairs(va) do -- 3 Target
					for ce, ve in pairs(v) do -- 10 Cured Ability
						if DPSMateAbility[DPSMate:GetAbilityById(ce)][2]=="Disease" then
							CV=CV+ve
						end
					end
				end
			end
		end
		local i = 1
		while true do
			if (not b[i]) then
				table.insert(b, i, CV)
				table.insert(a, i, cat)
				break
			else
				if b[i] < CV then
					table.insert(b, i, CV)
					table.insert(a, i, cat)
					break
				end
			end
			i=i+1
		end
		total = total + CV
	end
	return b, total, a
end

function DPSMate.Modules.CureDisease:EvalTable(user, k)
	local a, b, total, temp = {}, {}, 0, {}
	local arr = DPSMate:GetMode(k)
	if not arr[user[1]] then return end
	for cat, val in pairs(arr[user[1]]) do -- 41 Ability
		if cat~="i" then
			for ca, va in pairs(val) do -- 3 Target
				for c, v in pairs(va) do -- 10 Cured Ability
					if DPSMateAbility[DPSMate:GetAbilityById(c)][2]=="Disease" then
						if temp[c] then temp[c]=temp[c]+v else temp[c]=v end
					end
				end
			end
		end
	end
	for cat, val in pairs(temp) do
		local i = 1
		while true do
			if (not b[i]) then
				table.insert(b, i, val)
				table.insert(a, i, cat)
				break
			else
				if b[i] < val then
					table.insert(b, i, val)
					table.insert(a, i, cat)
					break
				end
			end
			i=i+1
		end
		total = total + val
	end
	return a, total, b
end

function DPSMate.Modules.CureDisease:GetSettingValues(arr, cbt, k)
	local name, value, perc, sortedTable, total, a, p, strt = {}, {}, {}, {}, 0, 0, "", {[1]="",[2]=""}
	if DPSMateSettings["windows"][k]["numberformat"] == 2 then p = "K" end
	sortedTable, total, a = DPSMate.Modules.CureDisease:GetSortedTable(arr)
	for cat, val in pairs(sortedTable) do
		local dmg, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
		if dmg==0 then break end
		local str = {[1]="",[2]="",[3]=""}
		if DPSMateSettings["columnsdisease"][1] then str[1] = " "..dmg..p; strt[2] = " "..tot..p end
		if DPSMateSettings["columnsdisease"][2] then str[3] = " ("..string.format("%.1f", 100*dmg/tot).."%)" end
		table.insert(name, DPSMate:GetUserById(a[cat]))
		table.insert(value, str[1]..str[3])
		table.insert(perc, 100*(dmg/sort))
	end
	return name, value, perc, strt
end

function DPSMate.Modules.CureDisease:ShowTooltip(user,k)
	local a,b,c = DPSMate.Modules.CureDisease:EvalTable(DPSMateUser[user], k)
	if DPSMateSettings["informativetooltips"] then
		for i=1, DPSMateSettings["subviewrows"] do
			if not a[i] then break end
			GameTooltip:AddDoubleLine(i..". "..DPSMate:GetAbilityById(a[i]),c[i].." ("..string.format("%.2f", 100*c[i]/b).."%)",1,1,1,1,1,1)
		end
	end
end

function DPSMate.Modules.CureDisease:OpenDetails(obj, key)
	DPSMate.Modules.DetailsCureDisease:UpdateDetails(obj, key)
end

function DPSMate.Modules.CureDisease:OpenTotalDetails(obj, key)
	--DPSMate.Modules.DetailsDamageTotal:UpdateDetails(obj, key)
	DPSMate:SendMessage("This feature will be added soon!")
end

