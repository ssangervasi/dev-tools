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
  prefix = str.first(midpoint)
  suffix = str.last(midpoint)
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

use_custom_prompt!
# try_to_use_awesome_print!
