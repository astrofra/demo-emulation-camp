/*
	File: scripts/animator_machines.nut
	Author: astrofra
*/

/*!
	@short	AnimatorMachines
	@author	astrofra
*/
class	AnimatorMachines
{
	angle			=	0.0
	angle_phase		=	Deg(45.0)
	angle_speed		=	1.2

	bump			=	0.0

	sync_bias		=	0.0

	rot				=	0
	pos				=	0
	spin			=	0.0
	spin_speed		=	PI * 2.0

	scene_manager	=	0

	dispatch		=	0

	function	OnSetup(item)
	{
		scene_manager = SceneGetScriptInstance(ItemGetScene(item))

		rot = ItemGetRotation(item)
		pos = ItemGetPosition(item)

		sync_bias = Sec(0.45)
	}

	function	OnUpdate(item)
	{
		if (dispatch != 0)
			dispatch(item)

		local	dt_spin = 0.0
		if (fabs(spin) > 0.0)
			dt_spin = -spin * g_dt_frame * spin_speed

		spin += dt_spin

		/*
			Commit values to the Items
		*/
		ItemSetRotation(item, rot + Vector(0,angle + spin,0))
		ItemSetPosition(item, pos + Vector(0,bump,0))
	}

	function	AnimateItems(item)
	{
		/*
			Animation base
		*/
		angle_phase += 25.0 * g_dt_frame * angle_speed
		if (angle_phase > 360.0)
			angle_phase -= 360.0

		angle = RangeAdjust(sin(Deg(angle_phase)), -1.0, 1.0, -0.025 * PI, 0.025 * PI)

		/*
			Audio-synced Animation
		*/
		//	zoom += scene_manager.audio_manager.TrackGetAudioSync("bass", 0.45, 1.0, Sec(0.25)) * 0.05
		bump = Pow(scene_manager.audio_manager.TrackGetAudioSync("drums", 0.25, 1.0, sync_bias), 2.0) * 0.05
	}

	function	Start()
	{		dispatch = AnimateItems	}

	function	Spin()
	{		spin = -2.0 * PI	}
}

/*!
	@short	AnimatorMachines
	@author	astrofra
*/
class	AnimatorGameBoy extends	AnimatorMachines
{
	function	OnSetup(item)
	{
		base.OnSetup(item)

		sync_bias = Sec(0.25)
	}
}
