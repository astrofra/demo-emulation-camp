/*
	File: scripts/IntroManager.nut
	Author: astrofra
*/

/*!
	@short	IntroManager
	@author	astrofra
*/
class	IntroManager
{
	scene					= 0
	dispatch				= 0
	dispatch_next			= 0
	all_done				= false
	sequence_clock			= 0.0

	generic_wait_duration	= Sec(0.5)
	generic_wait_callback	= 0

	item_computer_screen	=	0

	constructor(_scene)
	{
		scene = _scene
		item_computer_screen = SceneFindItem(scene, "computer_screen")
		SceneItemActivate(scene, item_computer_screen, false)

		dispatch = GenericWait
		dispatch_next = IgniteComputer
	}

	function	Update()
	{
		if (dispatch != 0)
			dispatch()

		return all_done
	}

	function	IgniteComputer()
	{
		local	_channel = MixerStartStream(g_mixer, "audio/apple2_boot.ogg")
		MixerChannelSetLoopMode(g_mixer, _channel, LoopNone)
		MixerChannelSetGain(g_mixer, _channel, 1.0)
		MixerChannelSetPitch(g_mixer, _channel, 1.0)

		sequence_clock = g_clock
		dispatch = IgniteScreen
		dispatch_next = 0 
	}

	function	IgniteScreen()
	{
		//	Elapsed duration of this function/sequence in seconds.
		local	seq_dt = TickToSec(g_clock - sequence_clock)

		local	_flag = (GenerateSquareFlicker(1) && GenerateSquareFlicker(30) || GenerateSquareFlicker(5) && GenerateSquareFlicker(60) || GenerateSquareFlicker(0.25) && GenerateSquareFlicker(15))
		SceneItemActivate(scene, item_computer_screen, _flag)
		SceneItemActivate(scene, SceneFindItem(scene, "screen_light"), _flag)

		if (seq_dt > Sec(2.15))
		{
			SceneItemActivate(scene, item_computer_screen, true)
			SceneItemActivate(scene, SceneFindItem(scene, "screen_light"), true)
			generic_wait_duration = Sec(1.0)
			generic_wait_callback = FadeScreenLight
			dispatch = GenericWait
			dispatch_next = LightOn
		}
	}

	function	GenericWait()
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

	function	LightOn()
	{
		//	Elapsed duration of this function/sequence in seconds.
		local	seq_dt = TickToSec(g_clock - sequence_clock)

		local	_flag
		if (seq_dt < Sec(0.75))
			_flag = GenerateSquareFlicker(15)
		else
			_flag = GenerateSquareFlicker(30)

		SceneItemActivate(scene, SceneFindItem(scene, "light"), _flag)

		if (seq_dt > Sec(1.75))
		{
			SceneItemActivate(scene, SceneFindItem(scene, "light"), true)
			generic_wait_duration = Sec(0.25)
			generic_wait_callback = FadeScreenLight
			sequence_clock = g_clock
			dispatch = GenericWait
			dispatch_next = IgniteGameboy
		}
	}

	function	IgniteGameboy()
	{
		local	_channel = MixerStartStream(g_mixer, "audio/gameboy_boot.ogg")
		MixerChannelSetLoopMode(g_mixer, _channel, LoopNone)
		MixerChannelSetGain(g_mixer, _channel, 1.0)
		MixerChannelSetPitch(g_mixer, _channel, 1.0)

		dispatch = IgniteGameboyScreen
	}

	function	IgniteGameboyScreen()
	{
		//	Elapsed duration of this function/sequence in seconds.
		local	seq_dt = TickToSec(g_clock - sequence_clock)

		local	_flag = (GenerateSquareFlicker(1) && GenerateSquareFlicker(30))
		SceneItemActivate(scene, SceneFindItem(scene, "gameboy_screen_on"), _flag)

		if (seq_dt > Sec(1.0))
		{
			SceneItemActivate(scene, SceneFindItem(scene, "gameboy_screen_on"), true)
		
			generic_wait_duration = Sec(1.0)
			generic_wait_callback = FadeScreenLight
			sequence_clock = g_clock
			dispatch = GenericWait
			dispatch_next = EndSequence
		}
	}

	function	FadeScreenLight()
	{
		local	_light = ItemCastToLight(SceneFindItem(scene, "screen_light"))
		local	_i = LightGetDiffuseIntensity(_light)
		_i -= (g_dt_frame * 0.85)
		_i = Max(0.0, _i)
		LightSetDiffuseIntensity(_light, _i)
	}

	function	EndSequence()
	{
		ItemGetScriptInstance(SceneFindItem(scene, "machines_handler")).Spin()
		SceneItemActivate(scene, SceneFindItem(scene, "screen_light"), false)
		all_done = true
		dispatch = 0
	}

}
