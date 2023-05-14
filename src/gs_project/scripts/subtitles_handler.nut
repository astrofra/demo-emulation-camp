/*
	File: scripts/subtitles_tracker.nut
	Author: Astrofra
*/

Include("scripts/ui.nut")

/*!
	@short	SubtitleHandler
	@author	Astrofra
*/
class	SubtitleHandler
{

	scene					=	0
	display_length 			=	Sec(30.0)
	subs					=	0
	repeat_mode				=	false
	sub_y					=	960.0 / 2.0

	start_clock				=	-1
	normalized_clock		=	0.0

	ui						=	0
	subtitle_label			=	0
	current_sub_index		=	0
	current_sub				=	""
	current_sub_duration	=	0

	parent_window			=	0

	all_done				=	false

	constructor()
	{
		scene = g_scene

		subs = []
		display_length *= 10000
		print("SubtitleHandler::constructor() display_length = " + display_length)
		CreateSubtitleLabel()
	}

	function	SetSubText(_sub)
	{
		subs = _sub
		foreach(sub in subs)
			PreGenerateSub(sub)
	}

	function	SetDisplayLength(l = Sec(30))
	{
		display_length = l * 10000
	}

	function	Start()
	{
		print("SubtitleHandler::Start()")
		start_clock = g_clock
		current_sub_index = 0

		GetNextSub()
	}

	function	Update()
	{
		if (start_clock < 0 || all_done || display_length <= 0)
			return

		normalized_clock = (g_clock - start_clock) / display_length

		if (normalized_clock > current_sub_duration)
			GetNextSub()

	}

	function	GetNextSub()
	{
		print("SubtitleHandler::GetNextSub()")
		if (current_sub_index < subs.len())
		{
			current_sub = subs[current_sub_index]

			local	total_text_len = 0
			foreach(sub in subs)
				total_text_len += sub.len()

			local	current_text_len = 0
			for(local i = 0; i <= current_sub_index; i++)
				current_text_len += subs[i].len()

			print("total_text_len = " + total_text_len + ", current_text_len = " + current_text_len)

			current_sub_duration = (current_text_len.tofloat() / total_text_len.tofloat())
			print("SubtitleHandler::GetNextSub() current_sub_duration = " + current_sub_duration)

			local	text_cmd_duration = (current_sub.len().tofloat() / total_text_len.tofloat()) * display_length - Sec(3.0)
			text_cmd_duration = Max(text_cmd_duration, 0.0)
			DisplaySub(current_sub, text_cmd_duration)

			current_sub_index++
		}
		else
		{
			subtitle_label.label = ""
			subtitle_label.refresh()

			if (repeat_mode)
				Start()
			else
				all_done = true
		}
	}

	function	CreateSubtitleLabel()
	{
		ui = SceneGetUI(scene)
		parent_window = UIAddWindow(ui, -1, 0, 0, 0, 0)
		subtitle_label = Label(ui, 1280, 256, 1280 * 0.5, sub_y, true, true)
		subtitle_label.label_color = 0xffffffff
		subtitle_label.font = "dosis.book"
		subtitle_label.font_size = 40
		subtitle_label.drop_shadow = false
		subtitle_label.font_tracking = -1.0
		subtitle_label.font_leading = -1.0
		subtitle_label.label = ""
		subtitle_label.refresh()

		WindowSetParent(subtitle_label.window, parent_window)
	}

	function	DisplaySub(str, duration = 1.0)
	{
		print("SubtitleHandler::DisplaySub(" + str + ")")
		subtitle_label.label = str
		subtitle_label.refresh()
		WindowSetPosition(subtitle_label.window, 1280 * 0.5, sub_y)
		local	_ox = (subtitle_label.font_size / 4.0).tostring()
		WindowSetCommandList(parent_window, "toposition 0," + _ox + ",0;toposition 0.25,0,0;nop " + duration.tostring() + ";toposition 0.25,-" + _ox + ",0;") 
		WindowSetCommandList(subtitle_label.window, "toalpha 0,0;toalpha 0.25,1.0;nop " + duration.tostring() + ";toalpha 0.5,0.0;")
	}

	function	PreGenerateSub(str)
	{
		print("SubtitleHandler::PreGenerateSub(" + str + ")")
		subtitle_label.label = str
		subtitle_label.refresh()
		WindowSetPosition(subtitle_label.window, 50000, 50000)
	}

}
