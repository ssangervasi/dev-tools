# frozen_string_literal: true

def custom_prompt(obj, nest_level, pry_inst)
  default_proc = default_prompt.first
  default_result = default_proc.call(obj, nest_level, pry_inst)
  abbreviate(default_result)
end

def custom_wait_prompt(obj, nest_level, pry_inst)
  default_proc = default_prompt[1]
  default_result = default_proc.call(obj, nest_level, pry_inst)
  abbreviate(default_result)
end

def abbreviate(str, max_len: 40)
  return str if str.length < max_len

  midpoint = max_len.div 2
  prefix = str[0..midpoint]
  suffix = str[midpoint..(str.length)]
  "#{prefix}...#{suffix}"
end

def default_prompt
  # Modern pry
  Pry::Prompt[:default][:value]
rescue NoMethodError
  # Old pry
  Pry::DEFAULT_PROMPT
rescue
  # If things go super wrong
  [
    proc { |obj, nest_level, _pry_inst| "woop<#{obj}:#{nest_level}> " },
    proc { |obj, nest_level, _pry_inst| "woop<#{obj}:#{nest_level}>* " }
  ]
end

def use_custom_prompt!
  Pry.config.prompt = [
    method(:custom_prompt),
    method(:custom_wait_prompt)
  ]
end

def use_dollar_for_shell_commands!
  shell_command_const = :ShellCommand
  shell_command_class = Pry::Command.const_get(shell_command_const)
  if shell_command_class.nil?
    warn("The #{shell_command_const.inspect} const is not defined.")
    return
  end

  # The original pattern should be `/\.(.*)/` but just to make sure...
  original_pattern, _ =  Pry.commands.find { |k, v| v == shell_command_class }
  if original_pattern.nil?
    warn("There was no pattern for shell command #{shell_command_class.inspect}")
    return
  end

  Pry.commands.delete(original_pattern)

  dollar_prefix_pattern = /\$(.*)/
  Pry.commands[dollar_prefix_pattern] = shell_command_class
end

def try_to_use_awesome_print!
  begin
    require 'awesome_print'
  rescue LoadErrror
    return
  end

  Pry.config.print = proc do |output, value|
    output.ap(value)
  end
end

begin
  use_custom_prompt!
  use_dollar_for_shell_commands!
  # try_to_use_awesome_print!
rescue StandardError => e
  warn(
    "Problem with pryrc '#{__FILE__}':",
    e.message
  )
end
