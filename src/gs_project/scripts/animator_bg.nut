/*
	File: scripts/animator_bg.nut
	Author: astrofra
	Desc : rotozoom style.
*/

/*!
	@short	AnimatorBg
	@author	astrofra
*/
class	AnimatorBg
{
	scene		=	0

	zoom		=	1.0
	zoom_phase	=	0.0
	zoom_speed	=	1.0

	angle		=	0.0
	angle_phase	=	Deg(45.0)
	angle_speed	=	0.8

	fade		=	1.0

	mat			=	0

	scene_manager	=	0

	function	OnSetup(item)
	{
		scene = ItemGetScene(item)
		scene_manager = SceneGetScriptInstance(ItemGetScene(item))
		mat = GeometryGetMaterialFromIndex(ItemGetGeometry(item), 0)
	}

	function	OnUpdate(item)
	{
		/*
			Animation base (sin/cos loop)
		*/
		zoom_phase += 25.0 * g_dt_frame * zoom_speed
		if (zoom_phase > 360.0)
			zoom_phase -= 360.0

		angle_phase += 25.0 * g_dt_frame * angle_speed
		if (angle_phase > 360.0)
			angle_phase -= 360.0

		zoom = Clamp(RangeAdjust(sin(Deg(zoom_phase)), -1.0, 1.0, 0.0, 1.0), 0.0, 1.0)

		angle = RangeAdjust(sin(Deg(angle_phase)), -1.0, 1.0, -0.05 * PI, 0.05 * PI)

		fade = Clamp(fade - g_dt_frame * 0.5, 0.0, 1.0)

		/*
			Audio-synced Animation
		*/
		//	zoom += scene_manager.audio_manager.TrackGetAudioSync("drums", 0.45, 1.0, Sec(0.25)) * 0.05

		/*
			Commit values to the Bg shader
		*/
		MaterialSetSelf(mat, Vector(zoom, angle, fade))

		local	_scale = ItemGetScale(SceneFindItem(scene, "seal"))
		ItemSetScale(item, _scale * _scale)
	}
}
