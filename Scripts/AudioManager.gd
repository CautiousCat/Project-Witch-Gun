extends Node

var dic : Dictionary = {}

func play_sfx(audio_clip : AudioStream, volume: float = 0, priority : int = 0):
	for child in $sfx.get_children():
		if child.playing == false:
			child.stream = audio_clip
			child.volume_db = volume
			child.play()
			dic[child.name] = priority
			return child
		if child.get_index() == $sfx.get_child_count() - 1:
			var priority_player = find_oldest_player()
			if priority_player != null:
				priority_player.stream = audio_clip
				priority_player.volume_db = volume
				priority_player.play()
				return priority_player

	
func check_priority(_dic : Dictionary, _priority):
	var prio_list : Array = []
	
	for key in _dic:
		if _priority > _dic[key]:
			prio_list.append(key)
			
	var last_prio = null
	for key in prio_list:
		if last_prio == null:
			last_prio = key
			continue
		if _dic[key] < _dic[last_prio]:
			last_prio = key
	return last_prio
	
func find_oldest_player():
	var last_child = null
	
	for child in $sfx.get_children():
		if last_child == null:
			last_child = child
		
		if child.get_playback_position() > last_child.get_playback_position():
			last_child = child
	return last_child
	
func play_music(music_clip : AudioStream, volume : float = 0):
	$music/music_player_1.stream = music_clip
	$music/music_player_1.volume_db = volume
	$music/music_player_1.play()

