/*
	File: scripts/animator_star.nut
	Author: astrofra
	
*/

if (!("g_star_phase" in getroottable()))
	g_star_phase	<-	0.0

/*!
	@short	AnimatorStar
	@author	astrofra
*/
class	AnimatorStar
{

	pos			=	0
	rot			=	0
	scale		=	0
	angle		=	0

	alpha		=	0.0
	phase		=	0.0

	prev_fade	=	0.0
	fade_integr	=	0.0

	dispatch	=	0

	function	OnSetup(item)
	{
		pos = ItemGetPosition(item)
		rot = ItemGetRotation(item)
		scale = ItemGetScale(item)

		phase = g_star_phase
		g_star_phase += Deg(70.0)
	}

	function	OnUpdate(item)
	{
		if (dispatch != 0)
			dispatch(item)

		phase += Deg(45.0) * g_dt_frame

		local fade = 0
		fade +=	0.75 * Clamp(sin(phase), 0.0, 0.25) * 4.0
		fade += 0.25 * Clamp(sin(phase), 0.0, 1.0)

		local fade_dt = fade - prev_fade
		fade_integr += fabs(fade_dt)

//		ItemSetOpacity(item, fade)
		ItemSetScale(item, scale.Scale(fade + fade * (sin(phase * 30.0) * 0.01)))
		ItemSetRotation(item, rot - Vector(0,0, fade_integr * 2 * PI))

		prev_fade = fade
	}

	function	Idle(item)
	{	}
}
