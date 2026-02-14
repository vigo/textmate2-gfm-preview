require 'rubygems'
require 'bundler/setup'
require 'json'
Bundler.require

require 'rouge/plugins/redcarpet'

DELIMITER = /^---\s*$/
TIME_STAMP = Time.now.strftime('%s')

CSS_FILES = ['github-markdown', 'syntax-hightlight'].map do |f|
  "<link rel=\"stylesheet\" href=\"file://#{ENV['TM_BUNDLE_SUPPORT']}/css/#{f}.css?#{TIME_STAMP}\">"
end

jl = ['jquery.1.12.4.min', 'app']
jl.map! do |f|
  "<script type=\"text/javascript\" src=\"file://#{ENV['TM_BUNDLE_SUPPORT']}/js/#{f}.js?#{TIME_STAMP}\"></script>"
end

if ENV['TM_MARKDOWN_MATHJAX'].to_i > 0
  jl << "<script type=\"text/x-mathjax-config\">
MathJax.Hub.Config({
    extensions: [\"tex2jax.js\"],
    jax: [\"input/TeX\", \"output/HTML-CSS\"],
    tex2jax: {
        inlineMath: [ [\"$\",\"$\"], [\"\\\\(\",\"\\\\)\"] ],
        displayMath: [ [\"$$\",\"$$\"], [\"\\\\[\",\"\\\\]\"] ],
        processEscapes: false
    },
    \"HTML-CSS\": { availableFonts: [\"TeX\"] }
});
</script>"
  jl << "<script type=\"text/javascript\" async src=\"https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML\"></script>"
end

if ENV['TM_MARKDOWN_MERMAID'].to_i > 0
  mermaid_options = {}
  mermaid_options["startOnLoad"] = true

  if ENV['TM_MARKDOWN_MERMAID_SHOW_SEQUENCE_NUMBERS']
    opt_show_seq_numbers = false
    opt_show_seq_numbers = true if ['true','TRUE'].include?(ENV['TM_MARKDOWN_MERMAID_SHOW_SEQUENCE_NUMBERS'])
    mermaid_options["sequence"] = {"showSequenceNumbers": opt_show_seq_numbers}
  end
  
  jl << "<script src=\"https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js\"></script>"
  jl << "<script>var mm_opts = #{mermaid_options.to_json};mermaid.initialize(mm_opts);</script>"
end


JS_FILES = jl

class HTMLwithRouge < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet

  def block_code(code, language)
    if language == 'mermaid'
      if ENV['TM_MARKDOWN_MERMAID'].to_i > 0
        return "<div class='mermaid'>#{code}</div>"
      else
        return "<code>you need to set TM_MARKDOWN_MERMAID to 1</code>"
      end
    end
    super
  end
end

def markdown(text)
  renderer = HTMLwithRouge.new
  options = {
    :autolink            => true,
    :space_after_headers => true,
    :fenced_code_blocks  => true,
    :tables              => true,
    :strikethrough       => true, # this is ~~good~~ bad
    :superscript         => true, # this is the 2^(nd) time
    :underline           => true, # This is _underlined_ but this is still *italic*
    :highlight           => true, # This is ==highlighted==
    :quote               => true, # This is a "quote"
    :footnotes           => true, # This is a sentence.[^1]
                                  # [^1]: This is a footnote.
    :smart               => true,
    :safelink            => true,
    :no_intraemphasis    => true,
    :filter_html         => false,
  }
  Redcarpet::Markdown.new(renderer, options).render(text)
end


gfm_props = []
gfm_props << "zoom: #{ENV['TM_GFM_ZOOM_FACTOR']};" if ENV['TM_GFM_ZOOM_FACTOR']
gfm_props << "font-family: #{ENV['TM_GFM_FONT']};" if ENV['TM_GFM_FONT']

link_props = []
link_props << "font-weight: #{ENV['TM_GFM_LINK_FONT_WEIGHT']};" if ENV['TM_GFM_LINK_FONT_WEIGHT']
link_props << "text-decoration: #{ENV['TM_GFM_LINK_TEXT_DECORATION']};" if ENV['TM_GFM_LINK_TEXT_DECORATION']

extra_css_rules = []
extra_css_rules << ".github-gfm {\n     #{gfm_props.join("\n     ")}\n   }" unless gfm_props.empty?
extra_css_rules << ".github-gfm a {\n     #{link_props.join("\n     ")}\n   }" unless link_props.empty?

macos_major = begin
  `sw_vers -productVersion`.strip.split('.').first.to_i
rescue Errno::ENOENT
  0
end
if macos_major >= 26
  extra_css_rules << "@media print {\n     body {\n       padding-left: 32em !important;\n       padding-right: 32em !important;\n     }\n   }"
end

extra_css_information = if extra_css_rules.empty?
  ""
else
  "<style type=\"text/css\">\n   #{extra_css_rules.join("\n   ")}\n</style>"
end

preview_title = "Markdown Preview"
preview_title= "#{preview_title}: #{File.basename(ENV['TM_FILEPATH'])}" if ENV['TM_FILEPATH']

input_file = STDIN.read

def html_header(**kwargs)
  <<-EOT
<html>
<head>
<title>#{kwargs[:title]}</title>
#{kwargs[:css]}
#{kwargs[:extra_css]}
#{kwargs[:inline_js]}
</head>
<body>
<div class="github-gfm">
  EOT
end

def html_footer(**kwargs)
  <<-EOT
</div>
#{kwargs[:js]}
</body>
</html>
  EOT
end

def clear_front_matter(**kwargs)
  lines = kwargs[:input].split("\n")
  if lines[0] =~ DELIMITER && (end_of_frontmatter = lines[1..-1].find_index{ |l| l =~ DELIMITER }) != nil
    lines.slice!(0, end_of_frontmatter + 2)
  end
  lines
end

def render(input, debug=false)
  return "<textarea rows=\"80\" cols=\"100\">#{input}</textarea>" if debug
  input
end

def any_inline_js
  if ENV['TM_FILEPATH']
    "<script type=\"text/javascript\">\nlet localFilePath = \"file://#{File.dirname(ENV['TM_FILEPATH'])}/\";\n</script>"
  end
end

html_out = html_header(title: preview_title,
                       css: CSS_FILES.join("\n"),
                       extra_css: extra_css_information,
                       inline_js: any_inline_js)

lines = clear_front_matter(input: input_file)

current_line = nil

if ENV['TM_CURRENT_LINE']
  current_line = ENV['TM_CURRENT_LINE'] 
else
  selection_line = ENV['TM_SELECTION'].split(':').first.to_i
  selection_line_index = selection_line - 1
  current_line = lines[selection_line_index]
end

tm_line_number = ENV['TM_LINE_NUMBER'].to_i

ANCHOR_IDENTIFIER = 'REPLACEMEMEFORANCHOROPZ'

if tm_line_number > lines.length
  (lines.length+1..tm_line_number-1).each do |n|
    lines << ''
  end
  lines << ANCHOR_IDENTIFIER
else
  if current_line.chomp == lines[tm_line_number-1].chomp
    lines[tm_line_number-1] = "#{lines[tm_line_number-1]} #{ANCHOR_IDENTIFIER}"
  else
    need_index = lines.index(current_line.chomp)
    need_index = 0 if need_index.nil?
    lines[need_index] = "#{lines[need_index]} #{ANCHOR_IDENTIFIER}"
  end
end

markdown_lines = markdown(lines.join("\n"))

html_out = html_out + markdown_lines
html_out = html_out + html_footer(js: JS_FILES.join("\n"))

if ENV['TM_GFM_DEBUG']
  puts render html_out, true
else
  puts render html_out
end
