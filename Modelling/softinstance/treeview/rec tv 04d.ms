fileIn "bmpArr.ms"
fileIn "classArr.ms"

if (NOT isvalidnode b) OR $.count>0 then
(
	b=box()
	addModifier b (Bend ())
	addModifier b (Taper ())
/*
	addModifier b (Twist ())
	addModifier b (Noisemodifier ())
	addModifier b (Stretch ())
	addModifier b (Squeeze ())
	addModifier b (Push ())
	addModifier b (Relax ())
	addModifier b (Ripple ())
	addModifier b (Wave ())
	addModifier b (Skew ())
	addModifier b (SliceModifier ())
	addModifier b (Spherify ())
	addModifier b (Affect_Region ())
	addModifier b (Lattice ())
	addModifier b (Mirror ())
	addModifier b (Displace ())
	addModifier b (XForm ())
	addModifier b (Preserve ())
	b.material = meditmaterials[1]
*/
	select b
)
if test!=undefined then destroydialog test
	
--------------------------------------------------------


	rollout test "Copy Properties" width:512 height:584
	(

	-- user interface 
		activeXControl il "MSComctlLib.ImageListCtrl.2" width:1 height:1 pos:[-50,-50]
		ActiveXControl tv1 "MSComctlLib.TreeCtrl" pos:[5,5] width:400 height:590
		label lbl1 "Label" pos:[5,615] width:400 height:15
	
		spinner spn1 "" pos:[5,630] range:[1,500,1] width:48 height:16 type:#integer
		label lbl2 "Label" pos:[64,630] width:264 height:16

-- declarations

		local addToTreeView
		local obj, replaceAll
		local addNode, obj, tv, tvNode, d, i, index
		
		local classArr=#(), bmpArr=#()
		
		local setUpTreeView, styleTreeView, recurseSubAnims
		
		local getSAStringFromNode, styleTreeView
		local tv



-- utility functions
		fn pad num padLength =
		(
			num=num as string
			while num.count < padLength do num = ("0"+num)
			return num
		)
	

		fn replaceAll str outStr inStr =
		(
			-- str the original string
			-- the string/character to replace
			-- the replacement string/character
			
			origStr=str
			while ((n=findstring str outStr) != undefined) do str = replace str n inStr.count inStr
			if str != undefined then return str
			else return origStr
		)


		fn reverseArray inArr =
		(
			local outArr = #()
			while inArr.count > 0 do
			(
				append outArr inArr[inArr.count]
				deleteItem inArr inArr.count
			)
			return outArr
		)




-- treeview functions

		fn styleTreeView tv singleSel=
		(
			-- linestyles
				tv.lineStyle = #tvwRootLines
				tv.lineStyle = #tvwTreeLines
				--tv.Checkboxes= true
				tv.BorderStyle=#ccFixedSingle
				tv.Appearance=#ccFlat
				tv.LabelEdit=#tvwManual
				tv.style = #tvwTreelinesPlusMinusText
				tv.style = #tvwTreelinesPlusMinusPictureText
				tv.SingleSel=false--singleSel
				tv.PathSeparator = "\\"
				tv.indentation=0
				tv.fullrowselect=false

			-- associate imagelist with treeview
				tv.ImageList = il

		)

	
		fn setUpTreeView tv obj=
		(
			tv.nodes.Clear()
			addToTreeView tv obj false
			local n = tv.nodes[1].LastSibling.index
			tv.selectedItem = tv.nodes[n]
		)


-- utility functions when adding nodes

		fn loadAllIcons =
		(
			-- set variables
				local bmpRel ="icons\\final\\"
				local j=0
				local iconStr=""
			-- start the loop
				for i = 1 to libraryClassArr.count do
				(
					try (
					-- get and load the bitmap file
						local bmpFile =bmpRel + libraryBmpArr[i]
						il.listimages.Add (j+=1) "" (LoadPicture bmpFile)

					-- update local array with classname
						append classArr libraryClassArr[i]

					-- update ebug info
						iconStr+=(pad j 3) +" | "+ libraryClassArr[i] +" | "+ libraryBmpArr[i] +"\n"
					)
					catch(j-=1)
				)
			-- write debug info
				--format "%" iconStr to:(win=newScript())
				--format "libraryClassArr.count:%\nj:%\n" libraryClassArr.count j to:win
		)


	fn getSAStringFromNode tvNode =
	(
		-- set up variables
			local nodeArr=#()
			local saStr="$"

		-- work up tree and add index to array
			while tvNode.parent!=undefined do
			(
				append nodeArr (tvNode.tag as Integer)
				tvNode=tvNode.parent
			)
		
		-- reverse, convert and return Array
			nodeArr= reverseArray nodeArr
			for n in nodeArr do saStr+="["+n as string+"]"
			return saStr

	)

/*
	fn getIconIndex obj =
	(
		local i=il.ListImages.Count
		try(
			local maxObject = exprformaxobject obj
			local class = execute ("classof "+maxObject)
			i= findItem classArr (class as string)
		)
		catch()
		format"%\n" i
		return i
	)
*/
	fn getIconIndex tvNode =
	(
		--format ">>%\n" obj
		local iconIndex=il.ListImages.Count
		local class=""
		try(
			saStr = getSAStringFromNode tvNode
			--local sa = (getSAStringFromNode tvNode)
			--local class = (getSubAimName sa i) as string
			--local class = execute ("classof "+execute("exprformaxobject " +saStr))
			class = classof (execute("exprformaxobject " +saStr))
			format"%\n" class
			--iconIndex= findItem classArr class
		)
		catch()
		format"%\n" iconIndex
		return iconIndex
	)






-- main recursive function

		fn recurseSubAnims obj tv tvNode d=
		(
			d+=1
			for i = 1 to obj.numSubs do
			(

			 -- flag if not visibility, transform, modified object or material
				local oktoBuild=true
				if d==1 AND (i<3 OR i>5) then oktobuild=false

			-- build the nodes
				if oktobuild == true then
				(
				-- build the node
					newNode = tv.nodes.add tvNode.index 4 ""

				-- update node properties
					-- text
						local nodeText = (getSubAnimName obj i) as string
						nodeText=replaceAll nodeText "_" " "
						newNode.text = nodeText
					-- icon
						local nodeIcon = getIconIndex newNode
						newNode.image=10 

					-- expanded
						if d!=2 then newNode.expanded=true
						
					-- tag
						newNode.tag=i as string

				-- do children
					recurseSubAnims obj[i] tv newNode d
				)
			)
		)

/*
	.Add
		Relative:undefined 
		Relationship:undefined 
		Key:undefined 
		Text:undefined 
		Image:undefined 
		SelectedImage:undefined
*/







-- rollout handlers
	
	on test open do
	(

	-- TIMESTAMP
			t1=timestamp()

	-- DO ICONS
			loadAllIcons()

	-- STYLE TREE
			styleTreeView tv1 true
	


	-- POPULATE TREEVIEWS
			obj=$
			local newNode = tv1.nodes.add()
			newNode.text = obj.name as string
			--newNode.image = getIconIndex obj
			newNode.expanded=true
			recurseSubAnims obj tv1 newNode 0

	-- TIMESTAMP
			t2=timestamp()
			t=(t2-t1)/1000 as float
			format "Processing took % seconds\n" t
	
	-- END
	)

	
	on tv1 NodeClick tvNode do
	(
		-- update the label
			lbl1.text = tvNode.fullpath

		-- get the max object
			format "%\n" (getSAStringFromNode tvNode)
	)

	
)

createdialog test 410 650 50 50 style:#(#style_minimizebox,#style_titlebar, #style_border, #style_sysmenu,#style_resizing)
