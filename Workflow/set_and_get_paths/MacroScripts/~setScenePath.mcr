macroScript setScenePath
	icon:#("~set_and_get_paths",2)
	category:"Tools"
	toolTip:"Set Scene path to current directory"
	(
	local dir=sysinfo.currentdir
	setdir #scene dir
	format "Scene path set to %\n" dir
	)
