/*
	File: scripts/scene_manager.nut
	Author: astrofra
*/

Include("scripts/base_scene.nut")
Include("scripts/intro_manager.nut")
Include("scripts/audio.nut")
Include("scripts/subtitles_handler.nut")
Include("scripts/subs.nut")

g_main_part_item <-	[ "plane_grid_handler", "bg_handler", "star", "logo_emucamp", "light", "gameboy_screen_on" ]

/*!
	@short	SceneManager
	@author	astrofra
*/
class	SceneManager	extends BaseScene
{
	audio_manager 			=	0
	title_manager			=	0
	subtitle_handler		=	0
	machine_title_manager	=	0
	intro_manager			=	0

	subtitle_rotary_update	=	0
	subtitle_rotary_idx		=	0

	sequence_clock			= 0.0

	generic_wait_duration	= Sec(0.5)
	generic_wait_callback	= 0

	constructor()
	{	print("SceneManager::constructor()")	}

	function	OnSetup(scene)
	{
		UISetGlobalFadeEffect(SceneGetUI(scene), 1.0)	//	Fade out the whole demo

		base.OnSetup(scene)

		audio_manager = Audio()

		EnableMainPartItems(scene, false)

		//	Intro manager
		intro_manager = IntroManager(scene)

		SubTitleSetupTitle()
		SubTitleSetupMainSub()
		SubTitleSetupMachineTitle()

		subtitle_rotary_update = []
		subtitle_rotary_update.append(title_manager)
		subtitle_rotary_update.append(subtitle_handler)
		subtitle_rotary_update.append(machine_title_manager)

		dispatch = CheckDtFrameStability
		dispatch_next = StartIntro
	}

	function	SubTitleSetupTitle()
	{
		//	Title text display
		print("SceneManager::SubTitleSetupTitle()")
		title_manager = SubtitleHandler()
		title_manager.SetDisplayLength(Sec(25.0))
		title_manager.repeat_mode = true
		title_manager.sub_y = 960.0 - (256.0 * 0.65)
		title_manager.subtitle_label.font = "homenaje-regular"
		title_manager.subtitle_label.font_size = 90
		title_manager.SetSubText(g_title_subs)
	}

	function	SubTitleSetupMainSub()
	{	
		//	Main sub text display
		print("SceneManager::SubTitleSetupMainSub()")
		subtitle_handler = SubtitleHandler()
		subtitle_handler.SetDisplayLength(Sec(60.0))
		subtitle_handler.repeat_mode = true
		subtitle_handler.sub_y = 960.0 - (256.0 * 0.35)
		WindowSetScale(subtitle_handler.subtitle_label.window, 0.95, 1.0)
		subtitle_handler.SetSubText(g_main_subs)
	}

	function	SubTitleSetupMachineTitle()
	{
		//	Main sub text display
		print("SceneManager::SubTitleSetupMachineTitle()")
		machine_title_manager = SubtitleHandler()
		machine_title_manager.SetDisplayLength(Sec(25.0))
		machine_title_manager.repeat_mode = true
		machine_title_manager.sub_y = (256.0 * 0.2)
		WindowSetScale(machine_title_manager.subtitle_label.window, 0.95, 1.0)
		machine_title_manager.subtitle_label.font_size = 40
		machine_title_manager.SetSubText(g_machines)
	}

	function	StartIntro(scene)
	{
		UISetCommandList(SceneGetUI(scene), "globalfade 2.0,0.0;")
		dispatch = UpdateIntro
		dispatch_next = 0
	}

	function	UpdateIntro(scene)
	{
		if (intro_manager.Update())
			dispatch = StartMainPart
	}

	function	StartMainPart(scene)
	{
		audio_manager.Start()
		EnableMainPartItems(scene, true)
		ItemGetScriptInstance(SceneFindItem(scene, "seal")).Start()
		ItemGetScriptInstance(SceneFindItem(scene, "machines_handler")).Start()
		ItemGetScriptInstance(SceneFindItem(scene, "gameboy")).Start()

		generic_wait_duration = Sec(0.75)
		sequence_clock = g_clock
		dispatch = GenericWait
		dispatch_next = StartGridScroller
	}

	function	StartGridScroller(scene)
	{
		ItemGetScriptInstance(SceneFindItem(scene, "grid_scroll")).Start()

		generic_wait_duration = Sec(1.0)
		sequence_clock = g_clock
		dispatch = GenericWait
		dispatch_next = StartMainSubtitles
	}

	function	StartMainSubtitles(scene)
	{
		title_manager.Start()
		machine_title_manager.Start()

		generic_wait_duration = Sec(2.5)
		sequence_clock = g_clock
		dispatch = GenericWait
		dispatch_next = StartSubtitles
	}

	function	StartSubtitles(scene)
	{
		subtitle_handler.Start()

		dispatch = 0
		dispatch_next = 0
	}	

	function	OnUpdate(scene)
	{
		base.OnUpdate(scene)
		audio_manager.Update()

		/*
			Update each text widget alternatively
			To avoid frame drops
		*/
		subtitle_rotary_idx++
		if (subtitle_rotary_idx >= subtitle_rotary_update.len())
			subtitle_rotary_idx = 0
		subtitle_rotary_update[subtitle_rotary_idx].Update()

		if (dispatch != 0)
			dispatch(scene)
	}

	function	EnableMainPartItems(scene, _flag)
	{
		SceneEnableItemListByName(scene, g_main_part_item, _flag)
	}

	function	GenericWait(scene)
	{
		//	Elapsed duration of this function/sequence in seconds.
		local	seq_dt = TickToSec(g_clock - sequence_clock)

		if (generic_wait_callback != 0)
			generic_wait_callback()

		if (seq_dt > generic_wait_duration)
		{
			dispatch = dispatch_next
			dispatch_next = 0
			generic_wait_callback = 0
		}
	}
}
