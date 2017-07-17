require 'rubygems'
require 'bundler/setup'

Bundler.require

LINK_REGEX_PATTERN = /^\[(.+)\]\(([a-z\-\.]+)\)$/

if ENV['TM_SELECTED_TEXT']
  input = ENV['TM_SELECTED_TEXT']

  input_has_patched = input.scan(LINK_REGEX_PATTERN)

  if input_has_patched.size > 0
    text = input_has_patched.first.first
    link = input_has_patched.first.last
    out = text if input == "[#{text}](#{link})"
  else
    out = "[#{input}](#{input.to_url}.md)"
  end
  print out
end
