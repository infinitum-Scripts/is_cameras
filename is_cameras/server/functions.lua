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

Notify = function(source, message)
	if framework == 'esx' then
		TriggerClientEvent('esx:showNotification', source, message)
	elseif framework == 'qb' then
		TriggerClientEvent('QBCore:Notify', source, message)
	else
		-- custom framework code
	end
end

GetJobName = function(source)
	if framework == 'esx' then
		return Core.GetPlayerFromId(source).job.name
	elseif framework == 'qb' then
		return Core.GetPlayer(source).job.name
	else
		-- custom framework code
	end
end

GetJobGrade = function(source)
	if framework == 'esx' then
		return Core.GetPlayerFromId(source).job.grade
	elseif framework == 'qb' then
		return Core.GetPlayer(source).job.grade
	else
		-- custom framework code
	end
end