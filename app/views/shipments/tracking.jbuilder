tracking_data = @tracking_info.dig(:data, :tracking)
last_checkpoint = tracking_data[:checkpoints].last
last_checkpoint_time = DateTime.parse(last_checkpoint[:checkpoint_time])

json.status tracking_data[:tag]
json.current_location last_checkpoint[:location]
json.last_checkpoint_message last_checkpoint[:message]
json.last_checkpoint_time last_checkpoint_time.strftime('%A, %d %B %Y at %l:%M %p').gsub('at  ', 'at ')
