/*
appFolder="E:\\03_Scripting\\3ds2ae\\03_3ds\\rollout code\\"
appAE="C:\\Design\\4_Video\\After Effects 6.5\\Support Files\\afterfx.exe"
iniFile=appFolder+"core\\settings.ini"
*/

/*
*/
(
include "ro options 01.ms"
local roSettings
)

rollout roWarning "Warning" width:344 height:208
(
	label lbl1 "It appears that some settings between the 3dsmax scene and After Effects comp do not match, which could cause timing and / or movement anomalies." pos:[24,16] width:296 height:40
	label lbl2 "Before continuing, would you like to:" pos:[88,72] width:176 height:16
	radiobuttons rdoSel "" pos:[88,96] width:119 height:32 labels:#("Update After Effects", "Update 3dsmax", "Do nothing (not recommended)") columns:1
	button btnOK "OK" pos:[80,168] width:88 height:24 enabled:true
	button btnCancel "Cancel" pos:[176,168] width:88 height:24 enabled:true

	on btnOK pressed do
	(
		--roSettings.checkBeforeExport sel:rdoSel.state
		try(
			SETTINGS.checkBeforeExport sel:rdoSel.state
		)
		catch(
			print "Error: SETTINGS is not yet defined..."
		)
		destroydialog roWarning
	)
	
	on btnCancel pressed do
	(
		destroydialog roWarning
	)
		
)
/*
createdialog roWarning lockHeight:true lockWidth:true --modal:true
*/


rollout roSettings "Settings" width:408 height:64
(

	-----------------------------------------------------------------
	-- interface
	
		label lblComp "Comp:" pos:[16,10] width:32 height:16
			dropdownList ddComps "" pos:[48,8] width:326 height:21 items:#("Current comp")
			button btnRefresh "<" pos:[376,10] width:16 height:16 tooltip:"Import comp list..."
	
		label lblRange "Frames:" pos:[9,35] width:40 height:16
			dropdownList ddRange "" pos:[48,32] width:96 height:21 items:#("Current range", "Current frame", "Custom...")
			spinner spnRangeFrom "From: " pos:[176,35] width:52 height:16 range:[0,9999,0] type:#integer scale:1
			spinner spnRangeTo "To: " pos:[248,35] width:52 height:16 range:[0,9999,100] type:#integer scale:1
			spinner spnRangeBy "By:" pos:[328,35] width:40 height:16 range:[1,100,10] type:#integer scale:1

			button btnOptions "" pos:[376,35] width:16 height:16 tooltip:"Options..."  images:#("ui/options.bmp", "ui/optionsMask.bmp", 1, 1, 1, 1, 1) toolTip:"Copy settings"

	-----------------------------------------------------------------
	-- includes
	
		include "core/jsx.ms"
		include "core/utility.ms"


	-----------------------------------------------------------------
	-- declarations
		local appFirstRun

		local maxSceneInfo=#()
		local aeCompInfo=#()
		
		local compName, compWidth, compHeight, compPixelAspect, compFps, compDuration

		local animRange=#(0,100,25)
		local animSpace=#parent--#world


-------------------------------------------------------------------------------------------------------------------
-- COMPS
-------------------------------------------------------------------------------------------------------------------
	
	-----------------------------------------------------------------
	-- declarations

		local compArr=#(#(undefined,undefined,undefined,undefined,undefined,undefined))
		local ddItems=#()
	
	-----------------------------------------------------------------
	-- functions
	
		fn setComp sel=
		(
			compName=		compArr[sel][1] as string
			compWidth=		compArr[sel][2]
			compHeight=		compArr[sel][3]
			compPixelAspect=	compArr[sel][4]
			compFps=		compArr[sel][5]
			compDuration=	compArr[sel][6]
			--messagebox (compName as string)
		)

		function getCompList=
		(
			-- run the AE script
				runJSX "getCompList.jsx"
				sleep 0.1
	
			-- pick up the file
				local compListFile=(appFolder+"jsx\\comps.dat")
				f=openFile compListFile mode:"r"
				if f != undefined then
				(
					compArr=#()
					while not eof f do
					(
						txt=readline f
						if txt.count>1 then append compArr (filterstring txt "\t")
					)
					close f
					--deleteFile compListFile

				-- populate the list
					ddItems=#()
					local activeComp=undefined
					for i = 1 to compArr.count do
					(
						-- variables
							local data=compArr[i]
							local str=stringstream ""
							local n=data[1]
							local w=data[2]
							local h=data[3] 
							local pa=data[4]
							local fps=round (data[5] as float)
							local dur=(data[6] as float*fps) as integer
						-- create array
							format "% :     % x % x %f" n w h dur to:str
							append ddItems (str as string)
							if data[data.count]=="true" then activeComp = i
					)
	
				-- add easy option of "current comp"
					append ddItems "Current comp"
					append compArr #(undefined,undefined,undefined,undefined,undefined,undefined)
	
				-- update all
					ddComps.items=ddItems
					if activeComp != undefined then ddComps.selection=activeComp
					setComp ddComps.selection
					--getTextExtent "Comp Cube"
					-- a space is 3 px
				)
			)
	
	-----------------------------------------------------------------
	-- handlers
	
		on ddComps selected sel do setComp sel
	
		on btnRefresh pressed do getCompList()
		
		on btnOptions pressed do createdialog roOptions
		
-------------------------------------------------------------------------------------------------------------------
-- TIME
-------------------------------------------------------------------------------------------------------------------

	
		fn updateRangeUI sel =
		(
			spnRangeFrom.enabled=spnRangeTo.enabled=(sel==3)
			spnRangeBy.enabled=(sel!=2)
			if sel==1 then
			(
				spnRangeFrom.value=animationRange.start
				spnRangeTo.value=animationRange.end
			)
		)


		on spnRangeFrom changed val do	if val >= spnRangeTo.value then spnRangeTo.value=val
		on spnRangeTo changed val do 	if val <= spnRangeFrom.value then spnRangeFrom.value=val
		on ddRange selected sel do		updateRangeUI sel


-------------------------------------------------------------------------------------------------------------------
-- SETTINGS
-------------------------------------------------------------------------------------------------------------------
	


	-----------------------------------------------------------------
	-- functions
	
		fn checkForAE=
		(
		-- check for ae
			if appAE== "" then
			(
				messagebox "The file 'AfterFX.exe' could not be found. Please locate it in the next dialog box." title:"Warning"
				appAE=getAppAE()
			)
			setIniSetting iniFile "After Effects" "app" appAE
			if appAE== undefined then
			(
				messagebox "AfterFX.exe could not be found. The application will now close." beep:true
				try(destroydialog roSettings);catch()
				try(destroyDialog max2ae);catch()
			)
			format "AfterFX: %\n" appAE
		)


		fn checkBeforeExport sel:undefined=
		(
			-- OVERRIDE!!!!
				return true
			
			-- check if warning dialog wanted to make update
				if sel!=undefined then
				(
					if sel==1 then format "Updating After Effects...\n"
					else if sel==2 then format "Updating 3dsmax...\n"
					for i = 2 to aeCompInfo.count do
					(
					)
					return "Updated settings..."
				)

			-- update range settings
				updateRangeUI ddRange.selection
				animRange=case ddRange.selection of
				(
					1:	#(animationRange.start,animationRange.end,spnRangeBy.value)
					2:	#(currentTime,currentTime,1)
					3:	#(spnRangeTo.value,spnRangeTo.value,spnRangeBy.value)
				)

			-- check comp properties against max scene
				if compName != undefined then
				(
					maxSceneInfo=#(maxfilename,renderWidth, renderHeight, renderPixelAspect, frameRate, (animationrange.end-animationrange.start))
					aeCompInfo=#(compName, compWidth, compHeight, compPixelAspect, compFps, compDuration)
	
					for i = 2 to aeCompInfo.count do
					(
						--format "% : % | %\n" (i as string) aeCompInfo[i] maxSceneInfo[i]
						if aeCompInfo[i] != maxSceneInfo[i] then
						(
							--messagebox "It appears that some settings between the 3dsmax scene and After Effects comp do not match, which could cause timing and / or movement anomalies."
							createdialog roWarning lockHeight:true lockWidth:true modal:true/**/
							exit
						)
					)
				)
				return true
		)



-------------------------------------------------------------------------------------------------------------------
-- ROLLOUTS
-------------------------------------------------------------------------------------------------------------------

		fn setTitle state=
		(
			if compArr.count>1 then
			(
				local range
				case ddRange.selection of
				(
					1:	range=spnRangeFrom.value as string +" - "+spnRangeTo.value as string+" / "+spnRangeBy.value as string
					2:	range="current frame"
					3:	range=spnRangeFrom.value as string +" - "+spnRangeTo.value as string+" / "+spnRangeBy.value as string
				)
	
				if state then
				(
					if compName != undefined then roSettings.title="Settings : "+compName+ "  ("+range+")"
					else roSettings.title="Settings"
				)
				else roSettings.title="Settings"
			)
		)

		on roSettings open do
		(
			if iniFile != undefined then appFirstRun=getIniSetting iniFile  "3dsmax" "FirstRun"
			--checkForAE()
			updateRangeUI 1
		)

)

if aeBridge==undefined then createDialog roSettings
--SETTINGS=roSettings
