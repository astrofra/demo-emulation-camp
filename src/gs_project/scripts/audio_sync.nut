/*
	File: scripts/music.nut
	Author: Astrofra
*/

/*!
	@short	MusicSynchro
	@author	Astrofra
*/
class	MusicSynchro
{

	table_reference		=	0
	table_length		=	0

	constructor(table_name)
	{
		table_reference = getroottable()[table_name]
		table_length = table_reference.len()
	}

	function	GetSynchroValueFromTime(_normalized_clock = 0.0, _bias = 0.0)
	{
		local	_val = 0.0
		local	_blur = 8

		for(local i = 0; i < _blur; i++)
		{
			local	_idx = _normalized_clock * table_length
			_idx += (_bias * 60.0)
			_idx += (-i + (_blur / 2.0))
			_idx = Clamp(_idx, 0.0, table_length.tofloat() - 1.0).tointeger()
			_val += table_reference[_idx]
		}

		_val /= _blur

		return _val
	}

}