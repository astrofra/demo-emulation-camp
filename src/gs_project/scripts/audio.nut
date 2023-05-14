/*
	File: scripts/audio.nut
	Author: astrofra
*/

Include("scripts/audio_sync.nut")
Include("assets/audio_sync/audio_extract_bass.nut")
Include("assets/audio_sync/audio_extract_drums.nut")
Include("assets/audio_sync/audio_extract_keyboard.nut")
Include("assets/audio_sync/audio_extract_keyboard_theme.nut")
Include("scripts/utils.nut")

/*!
	@short	Audio
	@author	astrofra
*/
class	Audio
{
	music_filename		=	"audio/med_music.ogg"
	music_channel		=	-1
	current_channel_idx	=	0
	start_clock			=	-1
	music_length		=	0
	normalized_clock	=	0.0
	audio_sync			=	0

	constructor()
	{
		music_length = (g_sync_bass.len() + g_sync_drums.len() + g_sync_keyboard.len() + g_sync_keyboard_theme.len()) / 4.0 / 60.0 * 10000 // 68.98645 * 10000 // SoundGetDuration(ResourceFactoryLoadSound(g_factory, music_filename))
		print("Audio::constructor() music_length = " + music_length)
		start_clock = -1

		audio_sync = {	bass = MusicSynchro("g_sync_bass")
						drums = MusicSynchro("g_sync_drums")	
						keyboard = MusicSynchro("g_sync_keyboard")	
						keyboard_theme = MusicSynchro("g_sync_keyboard_theme")	
						}

		music_channel = array(2,0)
	}

	function	Start()
	{
		print("Audio::Start()")
		current_channel_idx++
		if (current_channel_idx >= music_channel.len())
			current_channel_idx = 0

		MixerChannelStop(g_mixer, music_channel[current_channel_idx])
		music_channel[current_channel_idx] = MixerStartStream(g_mixer, music_filename)
		MixerChannelSetGain(g_mixer, music_channel[current_channel_idx], 1.0)
		MixerChannelSetPitch(g_mixer, music_channel[current_channel_idx], 1.0)
		MixerChannelSetLoopMode(g_mixer, music_channel[current_channel_idx], LoopNone)

		start_clock = g_clock
	}

	function	Stop()
	{
		print("Audio::Stop()")
	}

	function	Update()
	{
		if (start_clock < 0 || music_length <= 0)
			return

		normalized_clock = (g_clock - start_clock) / music_length

		if (normalized_clock >= 1.0125)
		{
			Stop()
			Start()
		}

		if (EverySecond(2.0, this))
			print("Audio::Update() " + (normalized_clock * 100).tointeger().tostring() + "%.")
	}

	function	TrackGetAudioSync(track = "bass", clamp_in = 0.0, clamp_out = 1.0, bias = 0.0)
	{
		if (start_clock < 0 || music_length <= 0)
			return	0.0

		return RangeAdjust(Clamp(audio_sync[track].GetSynchroValueFromTime(normalized_clock, bias), clamp_in, clamp_out), clamp_in, clamp_out, 0.0, 1.0)
	}
}
