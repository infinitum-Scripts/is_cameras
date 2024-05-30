Config = {}

Config.RequiredJob = false
Config.CheckJobManage = false

Config.AllowedJobs = { -- Jobs allowed to use cameras menu
	['police'] = 0,
	['sheriff'] = 0
}

Config.AllowedManage = { -- Jobs allowed to manage cameras
	['police'] = 5,
	['sheriff'] = 5
}

Config.CameraTypes = {
	'prop_cctv_cam_01a',
	'prop_cctv_cam_06a',
	'prop_cctv_cam_04c'
}

Config.Locales = {
	['too_far'] = 'Za daleko',
	['too_far_camera'] = 'Jesteś za daleko od kamery, aby ją usunąć'
}