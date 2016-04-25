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
    :strikethrough       => true,
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
  "\n<script>window.location.hash = \"scroll_here\";</script>",
  '</body>', '</html>',
]

rendered_markdown = markdown($file)

puts html_header.join("")
puts rendered_markdown
puts html_footer.join("")
