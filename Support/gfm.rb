require 'rubygems'
require 'bundler/setup'
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
  jl << "<script src=\"https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js\"></script>"
  jl << "<script>mermaid.initialize({startOnLoad:true});</script>"
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


extra_css_information = "<style type=\"text/css\">
   .github-gfm {
     %{gfm_zoom_factor}
     %{gfm_font_factor}
   }
   .github-gfm a {
     %{gfm_link_font_weight}
     %{gfm_link_text_decoration}
   }
</style>"


extra_css_information = extra_css_information % {
  gfm_zoom_factor: ENV['TM_GFM_ZOOM_FACTOR'] ? "zoom: #{ENV['TM_GFM_ZOOM_FACTOR']};" : "",
  gfm_font_factor: ENV['TM_GFM_FONT'] ? "font-family: #{ENV['TM_GFM_FONT']};" : "",
  gfm_link_font_weight: ENV['TM_GFM_LINK_FONT_WEIGHT'] ? "font-weight: #{ENV['TM_GFM_LINK_FONT_WEIGHT']};" : "",
  gfm_link_text_decoration: ENV['TM_GFM_LINK_TEXT_DECORATION'] ? "text-decoration: #{ENV['TM_GFM_LINK_TEXT_DECORATION']};": "",
}

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
