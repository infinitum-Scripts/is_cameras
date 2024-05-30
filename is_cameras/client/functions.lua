local Core, framework

CreateThread(function()
	if GetResourceState('es_extended') == 'started' then
		framework = 'esx'
		Core = exports['es_extended']:getSharedObject()
	elseif GetResourceState('qb-core') == 'started' then
		framework = 'qb'
		Core = exports['qb-core']:GetCoreObject()
	else
		framework = 'custom'
		-- your code
	end
end)

Notify = function(message)
	if framework == 'esx' then
		Core.ShowNotification(message)
	elseif framework == 'qb' then
		Core.Functions.Notify(message)
	else
		-- custom framework code
	end
end

GetJobName = function()
	if framework == 'esx' then
		return Core.GetPlayerData().job.name
	elseif framework == 'qb' then
		return QBCore.Functions.GetPlayerData().job.name
	else
		-- your code
	end
end

GetJobGrade = function()
	if framework == 'esx' then
		return Core.GetPlayerData().job.grade
	elseif framework == 'qb' then
		return QBCore.Functions.GetPlayerData().job.grade
	else
		-- your code
	end
end