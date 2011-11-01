stats={}
command(:stats,
  :optional => :action,
  :description => "show stats for the bot"
) do |sender,action|
  action = action ? action.strip : 'show'
  case action
  when 'clear'
    plugin.data_save_yaml({})
    stats = {}
  when 'show'
    plugin.bot.commands(!plugin.bot.master?(sender)).map{|cmd| "%s=%d" % [cmd.name,stats[cmd.name]||0]}.join("\n")
  else 
    "Sorry, I don't know how to stats #{action}"
  end
end

subscribe :command_match do |cmd,*params|
  stats[cmd.name] ||= 0
  stats[cmd.name] += 1
  plugin.data_save_yaml(stats)
end

init do 
  commands = plugin.bot.commands
  (plugin.data_load_yaml||{}).each{|name,count| 
    stats[name] = count.to_i if commands.detect{|cmd| cmd.name.to_s==name.to_s }}
end
