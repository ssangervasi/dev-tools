# frozen_string_literal: true

def custom_prompt(obj, nest_level, pry_inst)
  default_proc = default_prompt.first
  default_result = default_proc.call(obj, nest_level, pry_inst)
  abbreviate(default_result)
end

def custom_wait_prompt(obj, nest_level, pry_inst)
  default_proc = default_prompt.second
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
  Pry::Prompt[:default][:value]
rescue NoMethodError
  Pry::DEFAULT_PROMPT
rescue
  [
    proc { |obj, nest_level, _pry_inst| "woop<#{obj}:#{nest_level}> " },
    proc { |obj, nest_level, _pry_inst| "woop<#{obj}:#{nest_level}>* " }
  ]
end

Pry.config.prompt = [
  method(:custom_prompt),
  method(:custom_wait_prompt)
]
