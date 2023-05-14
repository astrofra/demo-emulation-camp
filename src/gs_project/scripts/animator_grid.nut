/*
	File: scripts/animator_grid.nut
	Author: astrofra
*/

/*!
	@short	AnimatorGrid
	@author	astrofra
*/
class	AnimatorGrid
{
	grid_width		=	0
	speed			=	0.35
	original_pos	=	0
	pos				=	0

	y_offset_target	=	-2.0
	y_offset		=	-2.0
	y_speed			=	5.0

	function	OnSetup(item)
	{
		local	c = ItemGetChild(item, "plane_grid")
		local	b = GeometryGetMinMax(ItemGetGeometry(c))
		grid_width = fabs(b.min.x - b.max.x)
		print("AnimatorGrid::OnSetup() grid_width = " + grid_width)

		original_pos = ItemGetPosition(item)
		pos = clone(original_pos)

		ItemSetPosition(item, pos + Vector(0,y_offset,0))
	}

	function	OnUpdate(item)
	{
		pos.x -= speed * g_dt_frame
		if (pos.x < original_pos.x - grid_width)
			pos.x += grid_width

		if (fabs(y_offset_target - y_offset) > 0.0)
		{
			local	dt = (y_offset_target - y_offset) * g_dt_frame * y_speed
			y_offset += dt
		}

		ItemSetPosition(item, pos + Vector(0,y_offset,0))
	}

	function	Start()
	{
		y_offset_target = 0.0
	}
}
