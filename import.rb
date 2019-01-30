`mkdir -p assets`
`rm -rf _posts`
`cp -r ../blog/published _posts`

Dir.chdir('_posts')

Dir['*'].each do |dir|
  md = Dir["#{dir}/*.markdown"].first
  `mv "#{md}" "#{dir}.md"`
  # `mv "#{dir}/*" "../assets/"`
  `rm -rf "#{dir}"`
end
