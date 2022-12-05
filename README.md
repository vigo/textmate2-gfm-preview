![Version](https://img.shields.io/badge/version-3.2.1-orange.svg)
![Plaftorm](https://img.shields.io/badge/platform-TextMate-blue.svg)
![macOS](https://img.shields.io/badge/macos-HighSierra-yellow.svg)
![macOS](https://img.shields.io/badge/macos-Mojave-yellow.svg)
![macOS](https://img.shields.io/badge/macos-Catalina-yellow.svg)
![macOS](https://img.shields.io/badge/macos-BigSur-yellow.svg)
![macOS](https://img.shields.io/badge/macos-Monterey-yellow.svg)

# GitHub Flavored Markdown Editor and Preview for TextMate2

Write and preview your Markdown files like a Boss!

## Requirements

Ruby is shipped with macOS. Current builtin ruby version (*macOS Monterey*) is
**2.6.8**. First, install bundler to your user folder;

```bash
$ gem install --user-install bundler

# find users path
$ ruby -r rubygems -e 'puts Gem.user_dir' # returns /Users/${USER}/.gem/ruby/2.6.0
$ export PATH="/Users/${USER}/.gem/ruby/2.6.0/bin:${PATH}" # add local user gem bin path to your shell environment

# or find it automatically
$ export PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:${PATH}"
```

If you have already installed `rbenv` or `rvm`, you’re good to go.

## Install and Update

Make sure that TextMate is not running. Add `TM_RUBY` environment variable to
TextMate:

```bash
$ defaults write com.macromates.TextMate environmentVariables \
    -array-add "{enabled = 1; value = \"$(command -v ruby)\"; name = \"TM_RUBY\"; }"
```

Now clone the repo:

```bash
$ cd ~/Library/Application\ Support/TextMate/Bundles/
$ git clone https://github.com/vigo/textmate2-gfm-preview.git GFM-Preview.tmbundle
$ cd GFM-Preview.tmbundle/Support/
$ bundle config set --local path 'vendor/bundle'
$ bundle
```

That’s it! Bundle installed successfully! You can follow updates via `git
pull` time-to-time.

```bash
$ cd ~/Library/Application\ Support/TextMate/Bundles/GFM-Preview.tmbundle
$ git pull origin main
```


## TextMate Environment Variables

You can define;

- `TM_GFM_ZOOM_FACTOR`: For zooming text.
- `TM_MARKDOWN_MATHJAX`: For Mathjax support.
- `TM_MARKDOWN_MERMAID`: For [Mermaid](https://mermaid-js.github.io/mermaid) support. (new!)
- `TM_GFM_FONT`: For custom font which is installed to your `~/Fonts`
- `TM_GFM_LINK_FONT_WEIGHT`: Optional `font-weight:` css directive for `a` link tags.
- `TM_GFM_LINK_TEXT_DECORATION`: Optional `text-decoration:` css directive for `a` link tags.

variables from *TextMate > Preferences > Variables* for customizing extra
features. Or do it from shell:

```bash
# assuming that, `OpenSans` font already installed on your ~/Library/Fonts

defaults write com.macromates.TextMate environmentVariables -array-add \
    '{enabled = 1; value = "100%"; name = "TM_GFM_ZOOM_FACTOR"; }' \
    '{enabled = 1; value = 1; name = "TM_MARKDOWN_MATHJAX"; }' \
    '{enabled = 1; value = 1; name = "TM_MARKDOWN_MERMAID"; }' \
    '{enabled = 1; value = "OpenSans"; name = "TM_GFM_FONT"; }' \
    '{enabled = 1; value = "500"; name = "TM_GFM_LINK_FONT_WEIGHT"; }' \
    '{enabled = 1; value = "underline"; name = "TM_GFM_LINK_TEXT_DECORATION"; }'
```


### Example Settings

![Example Settings](Support/screenshots/gfm-example-config.png?3)

### Zooming

Without zoom (default/standard)

![Without zoom](Support/screenshots/gfm-without-zoom.png?5)

With **150%** zoom:

![150% zoom](Support/screenshots/gfm-zoomed.png?4)

You name it! Make it `300%` if you like to! Now you can hit `⌃ + ⌥ + ⌘ + p` or
`kntrl + alt + cmd + p`

## Editor Features

With the power or Redcarpet and Rouge gems, we have some special features in
markdown operation!

Shortcuts | Description
:---------|:---------
`c` + <kbd>⇥</kbd> | Insert code block. There are lots of languages supported. Thanks to rouge gem. [List of languages are here][rouge-list].
<kbd>⌃</kbd> + <kbd>C</kbd> | Convert selection to inline code.
<kbd>⌃</kbd> + <kbd>H</kbd> | Convert selection to highlighted text.
<kbd>⌃</kbd> + <kbd>S</kbd> | Convert selection to strikethrough text.
<kbd>⌘</kbd> + <kbd>U</kbd> | Convert selection to underlined text.
`table` + <kbd>⇥</kbd> | Insert markdown table.
`img` + <kbd>⇥</kbd> | Insert markdown image.


## Features

### Mermaid Support (new!)

Add `TM_MARKDOWN_MERMAID` variable and set it to `1`. Example mermaid git graph:

    ```mermaid
    gitGraph
        commit
        commit
        branch develop
        checkout develop
        commit
        commit
        checkout main
        merge develop
        commit
        commit
    ```

or

    ```mermaid
    sequenceDiagram
        Alice->>John: Hello John, how are you?
        John-->>Alice: Great!
        Alice-)John: See you later!
    ```

Mermaid related configuration via env-vars:

- `TM_MARKDOWN_MERMAID_SHOW_SEQUENCE_NUMBERS`: `true` or `false` will
  (dis)allow sequence numbers on screen. (sequenceDiagram). Default value is
  `false`

### Mathjax Support

Add `TM_MARKDOWN_MATHJAX` variable and set it to `1` for mathjax support.
(*TextMate > Preferences > Variables*)

Example:

    $ log\_232 = log\_22\^5 = 5 $

### Strikethrough

You can ~~strikethrough~~ words.
    
    You can ~~strikethrough~~ words.

### Superscript

This is your 2^(nd) attempt.  

    This is your 2^(nd) attempt.

### Underline

This is _underlined_ but this is still *italic*

    This is _underlined_ but this is still *italic*

### Highlight

This is ==highlighted== text.

    This is ==highlighted==

### Quote

This is a "quote"

    This is a "quote"

### Footnotes

Click to jump footnote.[^1]
[^1]: This is a footnote.

    Click to jump footnote.[^1]
    [^1]: This is a footnote.

### Fenced Code Blocks

    ```ruby
    require 'redcarpet'
    markdown = Redcarpet.new("Hello World!")
    puts markdown.to_html
    ```

```ruby
require 'redcarpet'
markdown = Redcarpet.new("Hello World!")
puts markdown.to_html
```

### Tables: Example 1

    | First Header  | Second Header |
    | ------------- | ------------- |
    | Content Cell  | Content Cell  |
    | Content Cell  | Content Cell  |

Output:

| First Header  | Second Header |
| ------------- | ------------- |
| Content Cell  | Content Cell  |
| Content Cell  | Content Cell  |

***

### Tables: Example 2

    | Name          | Description                 |
    | ------------- | --------------------------- |
    | Help          | ~~Display the~~ help window.|
    | Close         | _Closes_ a window           |

Output:

| Name          | Description                 |
| ------------- | --------------------------- |
| Help          | ~~Display the~~ help window.|
| Close         | _Closes_ a window           |

***

### Tables: Example 3

    | Left-Aligned  | Center Aligned  | Right Aligned |
    | :------------ |:---------------:| -------------:|
    | col 3 is      | some wordy text |         $1600 |
    | col 2 is      | centered        |           $12 |
    | zebra stripes | are neat        |            $1 |

Output:

| Left-Aligned  | Center Aligned  | Right Aligned |
| :------------ |:---------------:| -------------:|
| col 3 is      | some wordy text |         $1600 |
| col 2 is      | centered        |           $12 |
| zebra stripes | are neat        |            $1 |

***

## Change Log

**2022-10-04**

* Add Mermaid renderer

**2019-10-17**

* Add bumpversion support

**2018-11-21**

* Update: Installation information, removed ruby version dependency

**2018-11-02**

* Fix latest Safari update `Version 12.0.1 (13606.2.104.1.2)`
* Version bump: `2.2.2`

**2018-10-18**

* Version bump: `2.2.1`
* Installation information update


**2017-11-06**

* Version bump: `2.2.0`
* `TM_GFM_LINK_FONT_WEIGHT` and `TM_GFM_LINK_TEXT_DECORATION` environment
  variables are added.

**2017-10-02**

* Update: <kbd>t</kbd> + ⇥ (*3 spaces for nested list*)
* Fix: `app.js` remote image loading issue.

**2017-09-29**

* Update: table + ⇥
* Fix: README

**2017-07-08**

* Ruby lib `gfm.rb` re-written from scratch!
* Fixed: Live Preview!

**2017-07-02**

* Removed: Pygments
* New syntax highlighter: `rouge`
* Updated to Ruby 2.4.0
* Added: Front-Matter filter for Preview. Thanks to [noniq][noniq] for [Markdown-Front-Matter][markdown-fm-bundle]
* Added: Lots of Markdown Snippets!

**2017-01-08**

* Fix: live preview.

**2017-01-02**

* Fix: Broken footnotes due to base href.
* New feature: Custom font-family via `TM_GFM_FONT` env-var.

**2017-01-01**

* Support for relative image src: `![alt](picture.png "title")` looks for `picture.png` in current folder.

**2016-10-04**

* Fix zoom factor for TABLEs
* Automatic refresh for Preview (*comes with TextMate version 2.0-beta.12.21*) 
when you save file.

**2016-09-14**

* Added: Mathjax support.
* Added more `redcarpet` features: Strikethrough, Superscript, Underline, Highlight, 
Quote, Footnotes. Please preview this readme file via bundle. GitHub doesn’t support
some of the features (*highlight, superscript, underline, footnote etc...*)


**2016-04-25**

* Added: `TM_GFM_ZOOM_FACTOR` for zoom options
* Auto-save! If you open an existing file and hit preview, you don’t need
to save!

**2016-03-20**

* converted TM1 edition of this bundle to TM2
* fixed: You don’t need to `save` before preview!

***

## Contribute

PR’s are very welcome!

1. `fork` (https://github.com/vigo/textmate2-gfm-preview/fork)
2. Create your `branch` (`git checkout -b my-features`)
3. `commit` yours (`git commit -am 'added killer features'`)
4. `push` your `branch` (`git push origin my-features`)
5. Than create a new **Pull Request**!

***

## Contributor(s)

* [Uğur "vigo" Özyılmazel][vigo] - Creator, maintainer

***

## License

This project is licensed under MIT.

[vigo]:  http://ugur.ozyilmazel.com "Official Homepage"
[ln-01]: https://github.com/vigo/textmate1-github-gfm-preview
[noniq]: https://github.com/noniq
[markdown-fm-bundle]: https://github.com/noniq/Markdown-Front-Matter.tmbundle/blob/master/Support/strip_front_matter
[rouge-list]: https://github.com/jneen/rouge/wiki/List-of-supported-languages-and-lexers
