require 'rubygems'
require 'bundler/setup'

Bundler.require
require 'rouge/plugins/redcarpet'

class HTMLwithRouge < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet
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

css_file_github = "#{ENV['TM_BUNDLE_SUPPORT']}/css/github-markdown.css"
css_file_syntax = "#{ENV['TM_BUNDLE_SUPPORT']}/css/syntax-hightlight.css"

$file_preview_title = "Preview"
$file = STDIN.read

$extra_css_information = [
  '<style type="text/css">',
    '.github-gfm {',
    '}',
  '</style>',
]

$current_folder_as_image_path = ""
if ENV['TM_FILEPATH']
  $file_preview_title = "#{$file_preview_title}: #{File.basename(ENV['TM_FILEPATH'])}"
  $current_folder_as_image_path = '<script>let localFilePath = "file://' + File.dirname(ENV['TM_FILEPATH']) + '/";</script>'
end

$extra_css_information.insert(2, 'font-size:', "#{ENV['TM_GFM_ZOOM_FACTOR']};") if ENV['TM_GFM_ZOOM_FACTOR']
$extra_css_information.insert(2, 'font-family:', "#{ENV['TM_GFM_FONT']};") if ENV['TM_GFM_FONT']
$extra_css_information.join 

html_header = [
  '<html>',
    '<head>', 
      '<title>', $file_preview_title, '</title>',
      "<link rel=\"stylesheet\" href=\"file://#{css_file_github}?#{Time.now.strftime('%s')}\">",
      "<link rel=\"stylesheet\" href=\"file://#{css_file_syntax}?#{Time.now.strftime('%s')}\">",
      $current_folder_as_image_path,
      $extra_css_information.join,
    '</head>',
    '<body>',
      '<div class="github-gfm">',
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

if $current_folder_as_image_path
  html_footer += [
    "<script>
        let textMateHandleString = 'x-txmt-filehandle://job/Preview/';
        let fileHandleString = 'file:///Applications/TextMate.app/Contents/Resources/';
        document.addEventListener('DOMContentLoaded', function(event){
          Array.prototype.forEach.call(document.images, function(image){
              if(image.src.indexOf(textMateHandleString) > -1){
                  image.src = localFilePath + image.src.replace(textMateHandleString, '');
              }
              if(image.src.indexOf(fileHandleString) > -1){
                  image.src = localFilePath + image.src.replace(fileHandleString, '');
              }
          });
        });
    </script>"
  ]
end

html_footer += [
  "\n<script>window.location.hash = \"scroll_here\";</script>",
  '</body>', '</html>',
]

DELIMITER = /^---\s*$/

file_lines = $file.split("\n")
if file_lines[0] =~ DELIMITER && (end_of_frontmatter = file_lines[1..-1].find_index{ |l| l =~ DELIMITER }) != nil
  file_lines.slice!(0, end_of_frontmatter + 2)
end

rendered_markdown = markdown(file_lines.join("\n"))

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
