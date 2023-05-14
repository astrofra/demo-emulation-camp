/*
	File: scripts/animator_logo.nut
	Author: astrofra
	Desc : Animate the EmuCamp logo with a nice reflexion.
*/

/*!
	@short	AnimatorLogo
	@author	astrofra
*/
class	AnimatorLogo
{
	zoom			=	1.0
	zoom_phase		=	0.0
	zoom_speed		=	1.0

	scroll			=	0.0
	scroll_speed	=	1.0
	blink_timeout	=	0.0

	timeout_seq		=	[Sec(5.0), Sec(5.0), Sec(10.0), Sec(3.0), Sec(5.0), Sec(15.0), Sec(5.0), Sec(20.0)]
	current_timeout	=	0

	scale			=	0

	mat				=	0

	scene_manager	=	0

	dispatch		=	0

	function	OnSetup(item)
	{
		scene_manager = SceneGetScriptInstance(ItemGetScene(item))
		scale = ItemGetScale(item)
		mat = GeometryGetMaterialFromIndex(ItemGetGeometry(item), 0)
		zoom = 0.0
		dispatch = WaitForScrollStart
	}

	function	OnUpdate(item)
	{
		if (dispatch != 0)
			dispatch(item)
		/*
			Audio-synced Animation
		*/
		zoom += scene_manager.audio_manager.TrackGetAudioSync("keyboard", 0.95, 1.0, Sec(0.15)) * 0.025
		local	zdt = -zoom * g_dt_frame * 2.0
		zoom += zdt

		/*
			Commit values to the Bg shader
		*/
		MaterialSetSelf(mat, Vector(EaseInOutQuick(scroll), 0.0, 0.0))
		ItemSetScale(item, scale.Scale(1.0 + zoom))
	}

	function	WaitForScrollStart(item)
	{
		if (g_clock - blink_timeout > SecToTick(timeout_seq[current_timeout]))
			dispatch = BlinkLogo
			
	}

	function	BlinkLogo(item)
	{
		scroll += scroll_speed * g_dt_frame

		if (scroll > 1.0)
		{
			blink_timeout = g_clock
			current_timeout++
			if (current_timeout >= timeout_seq.len())
				current_timeout = 0
			scroll = 0.0
			dispatch = WaitForScrollStart
		}
	}
}
