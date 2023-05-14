/*
	File: scripts/animator_seal.nut
	Author: astrofra
*/

/*!
	@short	AnimatorSeal
	@author	astrofra
*/
class	AnimatorSeal
{
	scale				=	0
	phase				=	0.0
	scale_factor		=	1.0
	scale_factor_target	= 	1.0
	speed				=	5.0

	dispatch			=	0

	function	OnSetup(item)
	{
		scale = ItemGetScale(item)
		scale_factor_target = 10.0
		scale_factor = scale_factor_target

		ItemSetScale(item, scale.Scale(scale_factor))
	}

	function	OnUpdate(item)
	{
		if (dispatch != 0)
			dispatch(item)

		if (fabs(scale_factor_target - scale_factor) > 0.0)
		{
			local	dt = (scale_factor_target - scale_factor) * g_dt_frame * speed
			scale_factor += dt
		}

		ItemSetScale(item, scale.Scale(scale_factor))
	}

	function	Start()
	{
		scale_factor_target = 1.0
	}
}
