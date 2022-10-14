local zones = Config.zones
local vehicleAllowed = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)

		if IsVehicleAllowed(GetVehiclePedIsIn(PlayerPedId())) then
			if not vehicleAllowed then
				vehicleAllowed = true
				startStreetThread()
				startCompassThread()

				SendNUIMessage({ action = "showUI" })
			end
		elseif vehicleAllowed then
			vehicleAllowed = false

			SendNUIMessage({ action = "hideUI" })
		end
	end
end)

function startStreetThread()
	Citizen.CreateThread(function()
		local currentStreet = {}
		local lastStreetName
		while vehicleAllowed do
			local ped = PlayerPedId()
			local vehicle = GetVehiclePedIsIn(ped)

			currentStreet = {}

			-- Current street
			local cCoord = GetEntityCoords(ped)
			local streetA, _ = GetStreetNameAtCoord(cCoord.x, cCoord.y, cCoord.z)

			-- Ahead street
			local nCoord = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 20.0, 0.5)
			local streetB, _ = GetStreetNameAtCoord(nCoord.x, nCoord.y, nCoord.z)
	
			if streetA ~= 0 then
				table.insert(currentStreet, GetStreetNameFromHashKey(streetA))
			end

			if streetB ~= 0 and streetA ~= streetB then
				local streetBName = GetStreetNameFromHashKey(streetB)
				if GetStreetNameFromHashKey(streetA) ~= streetBName then
					table.insert(currentStreet, "(".. streetBName .. ")")
				end
			end
		
			currentStreet = table.concat(currentStreet, " ")

			local currentZone = GetNameOfZone(cCoord.x, cCoord.y, cCoord.z)
			local zoneName = (zones[currentZone] or "")
			SendNUIMessage({action = "setInformation", zone = zoneName, street = currentStreet})
			Citizen.Wait(500)
		end
	end)
end

function startCompassThread()
	Citizen.CreateThread( function()
		local heading, lastHeading = 0, 1
		while vehicleAllowed do
			-- Converts [-180, 180] to [0, 360] where E = 90 and W = 270
			local camRot = GetGameplayCamRot(0)
			heading = round(360.0 - ((camRot.z + 360.0) % 360.0))
			
			if heading == 360 then 
				heading = 0 
			end

			if heading ~= lastHeading then
				SendNUIMessage({ action = "setCompassRotation", rotation = heading })
			end
			lastHeading = heading
			Citizen.Wait(30)
		end
	end)
end

function IsVehicleAllowed(vehicle)
	local model = GetEntityModel(vehicle)
	for k, v in pairs(Config.allowedVehicles) do
		if GetHashKey(v) == model then
			return true
		end
	end
	return false
end