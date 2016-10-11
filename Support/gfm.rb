require 'rubygems'
require 'bundler/setup'
Bundler.require

class HTMLwithPygments < Redcarpet::Render::HTML
  def block_code(code, language)
    language ||= 'text'
    Pygments.highlight(code, :lexer => language)
  rescue
    Pygments.highlight(code, :lexer => 'text')
  end
end

def markdown(text)
  renderer = HTMLwithPygments.new
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

css_file_github = "#{ENV['TM_BUNDLE_SUPPORT']}/css/markdown-github.css"
css_file_syntax = "#{ENV['TM_BUNDLE_SUPPORT']}/css/syntax-hightlight-github.css"


$file_preview_title = "Preview"
$file = STDIN.read

if ENV['TM_FILEPATH']
  $file_preview_title = "#{$file_preview_title}: #{File.basename(ENV['TM_FILEPATH'])}"
  save_file = File.new(ENV['TM_FILEPATH'], "w")
  save_file.write($file)
  save_file.close
end

$zoom_factor = ""
if ENV['TM_GFM_ZOOM_FACTOR']
  $zoom_factor = [
    '<style type="text/css">',
      '.github-gfm {',
        'font-size:', ENV['TM_GFM_ZOOM_FACTOR'],
      '}',
    '</style>'
  ].join("")
end

html_header = [
  '<html>', '<head>', '<title>', $file_preview_title, '</title>',
  "<link rel=\"stylesheet\" href=\"file://#{css_file_github}\">",
  "<link rel=\"stylesheet\" href=\"file://#{css_file_syntax}\">",
  $zoom_factor,
  '</head>', '<body>', '<div class="github-gfm">',
]

html_footer = [
  '</div>', 
]

if ENV["TM_MARKDOWN_MATHJAX"].to_i > 0
  html_footer += [
    "<script type=\"text/x-mathjax-config\">
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
    </script>
    <script type=\"text/javascript\" src=\"http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML\"></script>"
  ]
end

html_footer += [
  "\n<script>window.location.hash = \"scroll_here\";</script>",
  '</body>', '</html>',
]

rendered_markdown = markdown($file)

lines = rendered_markdown.split("\n")
n = [ENV["TM_LINE_NUMBER"].to_i, lines.length].min - 7
while n > 0 && !lines[n].match(/<(h\d|p|ul|li|blockquote|pre|div|img|code|table|tr)>/i)
  n -= 1
end
if n > 0 && m = lines[n].match(/<(h\d|p|ul|li|blockquote|pre|div|img|code|table|tr)>(.*)$/i)
  # lines[n] = "<#{m[1]} id=\"scroll_here\">#{m[2]}"
  lines[n] = "<a name=\"scroll_here\"></a>#{lines[n]}"
end

puts html_header.join("")
puts lines.join("\n")
puts html_footer.join("")
