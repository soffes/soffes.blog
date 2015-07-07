---
tags:
- engineering
- swift
- ruby
---

# NSRegularExpression Notes

I spent awhile today trying to convert a regular expression from Ruby to NSRegularExpression. It was being dumb and took me awhile to figure it out.

The main this is NSRegularExpression's options. By default Ruby, has `AnchorsMatchLines` on and NSRegularExpression doesn't. I simply turned that on and had good luck.

Here's my specific case ([Jekyll front-matter](https://github.com/jekyll/jekyll/blob/master/lib/jekyll/document.rb#L220)):

**Ruby**

```ruby
/\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
```

**Swift**

``` swift
NSRegularExpression(pattern: "\\A(---\\s*\\n.*?\\n?)^(---\\s*$\\n?)", options: .DotMatchesLineSeparators | .AnchorsMatchLines, error: nil)!
```
