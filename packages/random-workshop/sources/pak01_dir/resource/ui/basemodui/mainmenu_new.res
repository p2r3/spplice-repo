"Resource/UI/MainMenu.res"
{
	"MainMenu"
	{
		"ControlName"				"Frame"
		"fieldName"					"MainMenu"
		"xpos"						"0"
		"ypos"						"40"
		"wide"						"f0"
		"tall"						"f0"
		"autoResize"				"0"
		"pinCorner"					"0"
		"visible"					"1"
		"enabled"					"1"
		"tabPosition"				"0"
		"PaintBackgroundType"		"0"
	}

	"BtnExtras"
	{
		"ControlName"				"BaseModHybridButton"
		"fieldName"					"BtnExtras"
		"xpos"						"88"	[$WIN32WIDE]
		"xpos"						"63"	[!$WIN32WIDE]
		"ypos"						"228"
		"wide"						"280"
		"tall"						"20"
		"autoResize"				"1"
		"pinCorner"					"0"
		"visible"					"1"
		"enabled"					"1"
		"tabPosition"				"0"
		"navUp"					"BtnQuit"
		"navDown"					"BtnCoOp"
		"labelText"					"PLAY SINGLE PLAYER"
		"style"					"MainMenuButton"
		"command"					"Extras"
		"ActivationType"			"1"
	}

	"BtnCoOp"
	{
		"ControlName"				"BaseModHybridButton"
		"fieldName"					"BtnCoOp"
		"xpos"						"88"	[$WIN32WIDE]
		"xpos"						"63"	[!$WIN32WIDE]
		"ypos"						"258"
		"wide"						"280"
		"tall"						"20"
		"autoResize"				"1"
		"pinCorner"					"0"
		"visible"					"1"
		"enabled"					"1"
		"tabPosition"				"0"
		"navUp"					"BtnExtras"
		"navDown"					"BtnOptions"
		"labelText"					"PLAY COOPERATIVE"
		"style"					"MainMenuButton"
		"command"					"CoopPlay"
		"ActivationType"			"1"
	}

	"BtnOptions"
	{
		"ControlName"				"BaseModHybridButton"
		"fieldName"					"BtnOptions"
		"xpos"						"88"	[$WIN32WIDE]
		"xpos"						"63"	[!$WIN32WIDE]
		"ypos"						"288"
		"wide"						"280"
		"tall"						"20"
		"autoResize"				"1"
		"pinCorner"					"0"
		"visible"					"1"
		"enabled"					"1"
		"tabPosition"				"0"
		"navUp"						"BtnCoOp"
		"navDown"					"BtnQuit"
		"labelText"					"#PORTAL2_MainMenu_Options"
		"style"						"MainMenuButton"
		"command"					"Options"
		"ActivationType"			"1"
	}

	"BtnQuit"
	{
		"ControlName"				"BaseModHybridButton"
		"fieldName"					"BtnQuit"
		"xpos"						"88"	[$WIN32WIDE]
		"xpos"						"63"	[!$WIN32WIDE]
		"ypos"						"318"
		"wide"						"280"
		"tall"						"20"
		"autoResize"				"1"
		"pinCorner"					"0"
		"visible"					"1"
		"enabled"					"1"
		"tabPosition"				"0"
		"navUp"						"BtnOptions"
		"navDown"					"BtnExtras"
		"labelText"					"#PORTAL2_MainMenu_Quit"
		"style"						"MainMenuButton"
		"command"					"QuitGame"
		"ActivationType"			"1"
	}

	"PnlCloudPic"
	{
		"ControlName"			"ImagePanel"
		"fieldName"				"PnlCloudPic"
		"xpos"					"310"
		"ypos"					"288"
		"wide"					"50"
		"tall"					"50"
		"visible"				"0"
		"enabled"				"1"
		"tabPosition"			"0"
		"scaleImage"			"1"
		"image"					"resource/icon_cloud_small"
	}
}
