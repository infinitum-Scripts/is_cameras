local placingObject = false
local allobj = {}

CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
			Config.ObjectList = GlobalState.cameras_object_save_object
			refreshObject()
			return
		end
	end
end)

RegisterNUICallback('close', function()
	SetNuiFocus(false, false)
end)

RegisterCommand('cam', function()
	openCam()
end)

openCam = function()
	local canOpen = false

	if Config.RequiredJob then
		for k, v in pairs(Config.AllowedJobs) do
			if GetJobName() == k and GetJobGrade() >= v then
				canOpen = true
			end
		end

		if canOpen == false then
			return
		end
	else
		canOpen = true
	end

	local manage = false
	if Config.CheckJobManage then
		for k, v in pairs(Config.AllowedManage) do
			if GetJobName() == k and GetJobGrade() >= v then
				manage = true
			end
		end
	else
		manage = true
	end

	SendNUIMessage({action = 'show', cameras = GlobalState.cameras_object_save_object, manage = manage, cameraTypes = Config.CameraTypes})
	SetNuiFocus(true, true)
end

exports('openCam', openCam)

RegisterNUICallback('place', function(data, cb)
	local newData = {}
	local nData = data
	local model = nData.model
	placeObject({
		model = model,
		onFinish = function(data)
			newData[#newData + 1] = {
				obj = model,
				coords = data.pos,
				rot = data.rot,
				name = nData.name
			}
			TriggerServerEvent('is_cameras:server:saveObject', newData)
		end
	})
end)

local function RotationToDirection(rotation)
    local adjustedRotation =
    {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction =
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination =
    {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestSweptSphere(cameraCoord.x, cameraCoord.y, cameraCoord.z,
        destination.x, destination.y, destination.z, 0.2, 339, PlayerPedId(), 4))
    return b, c, e
end

placeObject = function(data)
	local model = type(data.model) == 'string' and joaat(data.model) or data.model

	if placingObject then return end

	local coords = GetEntityCoords(PlayerPedId())
	requestModel(model)
	local tempObj = CreateObject(model, coords.x, coords.y, coords.z, false, true, false)
	local heading = 0.0
	SetEntityHeading(tempObj, 0)

	SetEntityAlpha(tempObj, 150)
	SetEntityCollision(tempObj, false, false)
	FreezeEntityPosition(tempObj, true)

	placingObject = true

	local objCoords = nil
	local inRange = false
	local lz = coords.z

	local function deleteObj()
		placingObject = false
		SetEntityDrawOutline(tempObj, false)
		DeleteEntity(tempObj)
		tempObj = nil
	end

	FreezeEntityPosition(PlayerPedId(), true)

	CreateThread(function()
		local hit, coords, entity = RayCastGamePlayCamera(20.0)
		local objCoords = coords
		while placingObject do
			Wait(0)
			DisableControlAction(0, 44, true) -- q
			DisableControlAction(0, 38, true) -- e
			DisableControlAction(0, 188, true)
			DisableControlAction(0, 187, true)
			DisableControlAction(0, 32, true)
			DisableControlAction(0, 33, true)
			DisableControlAction(0, 34, true)
			DisableControlAction(0, 35, true)

			SetEntityCoords(tempObj, objCoords.x, objCoords.y, lz)
			SetEntityDrawOutline(tempObj, true)

			if #(objCoords - GetEntityCoords(PlayerPedId())) < 10.0 then
				SetEntityDrawOutlineColor(2, 241, 181, 255)
                inRange = true
			else
				inRange = false
				SetEntityDrawOutlineColor(244, 68, 46, 255)
			end

			if IsControlPressed(0, 73) then
				deleteObj()
				placingObject = false
			end

			if IsDisabledControlPressed(0, 44) then
				heading = heading + 2
				if heading > 360 then heading = 0.0 end
			end

			if IsDisabledControlPressed(0, 38) then
				heading = heading - 2
				if heading < 0 then heading = 360.0 end
			end

			if IsControlPressed(0, 172) then
				lz = lz + 0.05
			end

			if IsControlPressed(0, 173) then
				lz = lz - 0.05
			end

			if IsDisabledControlPressed(0, 32) then
				local coords = {
					x = objCoords.x,
					y = objCoords.y,
					z = objCoords.z
				}
				coords.y = coords.y + 0.01
				objCoords = vec3(coords.x, coords.y, lz)
			end

			if IsDisabledControlPressed(0, 33) then
				local coords = {
					x = objCoords.x,
					y = objCoords.y,
					z = objCoords.z
				}
				coords.y = coords.y - 0.01
				objCoords = vec3(coords.x, coords.y, lz)
			end

			if IsDisabledControlPressed(0, 34) then
				local coords = {
					x = objCoords.x,
					y = objCoords.y,
					z = objCoords.z
				}
				coords.x = coords.x + 0.01
				objCoords = vec3(coords.x, coords.y, lz)
			end

			if IsDisabledControlPressed(0, 35) then
				local coords = {
					x = objCoords.x,
					y = objCoords.y,
					z = objCoords.z
				}
				coords.x = coords.x - 0.01
				objCoords = vec3(coords.x, coords.y, lz)
			end

			SetEntityHeading(tempObj, heading)
			if IsControlJustPressed(0, 18) then
				if not inRange then
					Notify(Config.Locales['too_far'])
				else
					local objRot = GetEntityHeading(tempObj)
					local objPos = GetEntityCoords(tempObj)
					deleteObj()
					if data.onFinish then
						data.onFinish({rot = objRot, pos = objPos})
					end
				end
			end
		end
		FreezeEntityPosition(PlayerPedId(), false)
	end)
end

requestModel = function(model)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
	end
	return true
end

refreshObject = function()
	local placedObj = {}

	for pos, v in ipairs(Config.ObjectList) do
		local model = type(v.obj) == 'string' and joaat(v.obj) or v.obj
		requestModel(model)
		placedObj = CreateObject(model, v.coords.x, v.coords.y, v.coords.z-0.3, false, true, false)
		SetEntityHeading(placedObj, v.rot)
		SetEntityCollision(placedObj, true, true)
		FreezeEntityPosition(placedObj, true)

		allobj[#allobj + 1] = {
			obj = placedObj
		}
	end	
end

AddStateBagChangeHandler('cameras_object_save_object', 'global', function(bagname, key, value)
	if value then
		Config.ObjectList = value
		for i=1, #allobj do
			DeleteEntity(allobj[i].obj)
		end
		refreshObject()
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource ~= GetCurrentResourceName() then return end

    for i = 1, #allobj do
        DeleteEntity(allobj[i].obj)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
	Config.ObjectList = GlobalState.cameras_object_save_object
    refreshObject()
end)

local createdCamera = nil

RegisterNUICallback('selectCam', function(data, cb)
	local id = tonumber(data.id)

	local coords = nil

	for k, v in pairs(GlobalState.cameras_object_save_object) do
		if v.id == id then
			coords = v.coords
		end
	end

	SendNUIMessage({action = 'loading'})

	Wait(500)

	SetFocusArea(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z)

	local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	SetCamActive(cam, true)
	RenderScriptCams(true, true, true, true, true)
	SetCamCoord(cam, coords.x, coords.y, coords.z-0.5)
	SetCamRot(cam, 0.0, 0.0, 0.0, 2)

	createdCamera = cam
end)

function handleCameraRotation()
    local getCameraRot = GetCamRot(createdCamera, 2)
    -- ROTATE UP
    if IsControlPressed(0, 172) then if getCameraRot.x <= 0.0 then SetCamRot(createdCamera, getCameraRot.x + 0.7, 0.0, getCameraRot.z, 2) end end
    -- ROTATE DOWN
    if IsControlPressed(0, 173) then if getCameraRot.x >= -50.0 then SetCamRot(createdCamera, getCameraRot.x - 0.7, 0.0, getCameraRot.z, 2) end end
    -- ROTATE LEFT
    if IsControlPressed(0, 174) then SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z + 0.7, 2) end
    -- ROTATE RIGHT
    if IsControlPressed(0, 175) then SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z - 0.7, 2) end
end

CreateThread(function()
    while true do
        local sleep = 2000
        if createdCamera ~= nil then
            sleep = 5
            SetTimecycleModifier("scanline_cam_cheap")
            SetTimecycleModifierStrength(1.0)
            if hideradar then DisplayRadar(false) end
            if IsControlJustPressed(1, 177) then
				ClearTimecycleModifier("scanline_cam_cheap")
				DestroyCam(createdCamera, 0)
				RenderScriptCams(0, 0, 1, 1, 1)
				createdCamera = nil
				ClearFocus()
            end
            handleCameraRotation()
		else
			ClearTimecycleModifier("scanline_cam_cheap")
        end
        Wait(sleep)
    end
end)

RegisterNUICallback('removeCam', function(data, cb)
	TriggerServerEvent('is_cameras:server:removeCam', tonumber(data.id))
end)