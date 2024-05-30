CreateThread(function()
	if GlobalState.cameras_object_save_object == nil then
		GlobalState.cameras_object_save_object = json.decode(LoadResourceFile(GetCurrentResourceName(), 'data/cameras.json'))
	end
end)

RegisterNetEvent('is_cameras:server:saveObject', function(data)
	local mergedData = {}

	if GlobalState.cameras_object_save_object == nil then
		GlobalState.cameras_object_save_object = {}
	end

	for _, v in ipairs(GlobalState.cameras_object_save_object) do
		mergedData[#mergedData + 1] = {
			obj = v.obj,
			coords = v.coords,
			rot = v.rot,
			name = v.name,
			id = #mergedData
		}
	end

	for _, v in ipairs(data) do
		mergedData[#mergedData + 1] = {
			obj = v.obj,
			coords = v.coords,
			rot = v.rot,
			name = v.name,
			id = #mergedData
		}
	end

	GlobalState.cameras_object_save_object = mergedData
	SaveResourceFile(GetCurrentResourceName(), 'data/cameras.json', json.encode(mergedData), -1)
end)

RegisterServerEvent('is_cameras:server:removeCam', function(id)
	local _source = source

	local canManage = false

	for k, v in pairs(Config.AllowedManage) do
		if GetJobName(_source) == k and GetJobGrade(_source) >= v then
			canManage = true
		end
	end

	if Config.CheckJobManage == false then
		canManage = true
	end

	if canManage == false then
		return
	end

	local data = GlobalState.cameras_object_save_object

	local deleted = false

	for k, v in pairs(data) do
		if v.id == tonumber(id) then
			local coords = vec3(v.coords.x, v.coords.y, v.coords.z)
			if #(coords - GetEntityCoords(GetPlayerPed(_source))) > 20.0 then
				Notify(Config.Locales['too_far_camera'])
				return
			end

			table.remove(data, k)
			deleted = true
			break
		end
	end

	if deleted == true then
		for k, v in pairs(data) do
			v.id = k-1
		end
		GlobalState.cameras_object_save_object = data
		Config.ObjectList = GlobalState.cameras_object_save_object

		SaveResourceFile(GetCurrentResourceName(), 'data/cameras.json', json.encode(data), -1)
	end
end)