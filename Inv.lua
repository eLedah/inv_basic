-- USE E TO PICK UP EQUIPMENTS AND F4 TO ACCESS THEM.

------------------------------------------------------------------------------------------------------
------------------------------------------- Entity creator -------------------------------------------
------------------------------------------------------------------------------------------------------

------------
-- Config --
------------

-- Enter weapon IDs as you please.
	-- Cheat sheet: http://cs2d.com/img/ref_items.png
Primary_wpns = {30, 31, 91}
Secondary_wpns = {1, 2, 3, 4}

-- Default value for Inventory limit
DEF_INV_LIMIT = 100

-- Default state of bleeding upon entering the server
	-- false = no bleeding
DEF_BLEEDEING = false

Equipments = {"Bondage"}
Equipments_address = {
	Bondage = "gfx/npc/snark.bmp", 
	--Painkiller = "PAINKILLER_IMAGE_ADDRESS" 
}

Equipmets_count = 0
Equiments_map_type = {}
Equiments_map_id = {}
Equiments_map_x = {}
Equiments_map_y = {}



function Add_entity(X, Y, MODE)
	--X and Y are in tile format
	local rand_num = 1
	if MODE == "PRIMARY_WEAPON" then
		rand_num = math.random(#Primary_wpns)
		parse('spawnitem ' .. Primary_wpns[rand_num] .. ' ' .. X .. ' ' .. Y)
	elseif MODE =="SECONDARY_WEAPON" then
		rand_num = math.random(#Secondary_wpns)
		parse('spawnitem ' .. Secondary_wpns[rand_num] .. ' ' .. X .. ' ' .. Y)
	elseif MODE == "EQUIPMENT" then
		rand_num = math.random(#Equipments)
		Add_equipment(X, Y, Equipments[rand_num])
	end
end

function Add_equipment(X, Y, equip)
	local X1 = ((X * 32) + 16)
	local Y1 = ((Y * 32) + 16)
	local id = image(Equipments_address[equip], X1, Y1, 0)
	Equipmets_count = Equipmets_count + 1
	Equiments_map_type[Equipmets_count] = equip
	Equiments_map_id[Equipmets_count] = id
	Equiments_map_x[Equipmets_count] = X
	Equiments_map_y[Equipmets_count] = Y
end

-- Add_entity(X -tile-, Y -tile-, TYPE -PRIMARY_WEAPON, SECONDARY_WEAPON, EQUIPMENT-)

-- Add_entity(1, 1, "PRIMARY_WEAPON")
-- Add_entity(3, 4, "PRIMARY_WEAPON")
-- Add_entity(3, 6, "SECONDARY_WEAPON")
-- Add_entity(3, 7, "SECONDARY_WEAPON")
-- Add_entity(3, 8, "EQUIPMENT")
-- Add_entity(3, 5, "EQUIPMENT")

------------------------------------------------------------------------------------------------------
------------------------------------------ Inventory system ------------------------------------------
------------------------------------------------------------------------------------------------------

Inventory, Inventory_limit, Inventory_page = {{}}, {}, {}


addhook("use", "_use")
function _use(id)
	local X, Y = math.floor(player(id, "x") / 32), math.floor(player(id, "y") / 32)
	for i = 1, Equipmets_count do
		if Equiments_map_x[i] == X and Equiments_map_y[i] == Y and Inventory_can_carry(id) then
			Equiments_add_to_inventory(id, Equiments_map_type[i])
			Equipment_remove(Equiments_map_id[i], i)
			msg("\169255255255ID#"..id.." picked up "..Equiments_map_type[i])
		end
	end

end

function Inventory_can_carry(id)
	if Inv_count_values(Inventory[id]) < Inventory_limit[id] then return true end
	return false
end

function Equiments_add_to_inventory(id, type)
	table.insert(Inventory[id], type)
end

function Equipment_remove(id, array_pos)
	freeimage(id)
	Equiments_map_x[array_pos], Equiments_map_y[array_pos] = -1 , -1
end

------------------------------------------------------------------------------------------------------
------------------------------------------- Inventory menu -------------------------------------------
------------------------------------------------------------------------------------------------------

addhook("serveraction", "Inv_open")
function Inv_open(id, action)
	Inventory_page[id] = 1
	if action == 3 then menu(id,"Inventory"..Inv_list_items(id, Inventory_page[id])) end
end

addhook("menu", "Inv_select")
function Inv_select(id, title, button)
	if button > 0 and button < 10 then
		-- Clicked a button

		if button == 9 then
			-- Next page / First Page
			if Inv_count_values(Inventory[id]) > Inventory_page[id]*8 then
				Inventory_page[id] = Inventory_page[id] + 1
			else
				-- Reset the menu
				Inventory_page[id] = 1
			end
			Inv_rebuild(id)
			menu(id,"Inventory"..Inv_list_items(id, Inventory_page[id]))
		else
			-- Select and use an item

			Inv_use(id, Inv_calc_equipment(id, Inventory_page[id], button))
			Inv_remove(id, Inventory_page[id], button)
			Inv_rebuild(id)
			-- Reset the menu
			Inventory_page[id] = 1
		end

	else
		-- Canceled
		-- Reset the menu
		Inventory_page[id] = 1
	end
end


function Inv_list_items(id, page)
	local Inv_list = ""
	for i = ((page-1)*8)+1, ((page)*8) do
		if Inventory[id][i] ~= nil then Inv_list = Inv_list..','..Inventory[id][i] else Inv_list = Inv_list..',(|Empty)' end
	end
	if Inv_count_values(Inventory[id]) <= (page)*8 then Inv_list = Inv_list..",<-- First page" else Inv_list = Inv_list..",Next page -->" end
	return Inv_list
end


function Inv_calc_equipment(id, page, button)
	return Inventory[id][((tonumber(page)-1)*8) + tonumber(button)] 
end

function Inv_remove(id, page, button)
	Inventory[id][((tonumber(page)-1)*8) + tonumber(button)] = nil
end

function Inv_rebuild(id)
	for i = 1, Inv_count_values(Inventory[id]) do
		if Inventory[id][i] == nil then 
			local value = Inv_get_closest(Inventory[id], i)
			if value ~= nil then
				Inventory[id][i] = Inventory[id][value]
				Inventory[id][value] = nil 
			end
		end
	end
end

function Inv_get_closest(Inventory_table, j)
	for q = j, (Inv_count_values(Inventory_table)+2) do
		if Inventory_table[q] ~= nil then return q end
	end
	return nil
end

function Inv_count_values(Inventory_table)
	local count = 0
	for _,id in pairs(Inventory_table) do
		count = count + 1
	end
	return count
end
------------------------------------------------------------------------------------------------------
------------------------------------------ Using Equipments ------------------------------------------
------------------------------------------------------------------------------------------------------

function Inv_use(id, equipment)
	-- Use an item
	msg('\169255255255ID#'..id.. ' used ' .. equipment)
end


-------------------------------------------------------------------------------------------------------
--------------------------------------------- Initiatives ---------------------------------------------
-------------------------------------------------------------------------------------------------------

addhook("join", "join")
function join(id)
	reset_stats(id)
end

function reset_stats(id)
	Inv_clear(id)
	Inventory_limit[id] = DEF_INV_LIMIT
	Inventory_page[id] = 1
end

function Inv_clear(id)
	for i=1, Inv_count_values(Inventory[id]) do Inventory[id][i] = nil end
end

