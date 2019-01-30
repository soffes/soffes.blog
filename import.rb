`rm -rf _posts assets`
`mkdir -p assets`
`cp -r ../blog/published _posts`

Dir.chdir('_posts')

Dir['*'].each do |dir|
  md = Dir["#{dir}/*.markdown"].first
  `mv "#{md}" "#{dir}.md"`

  if Dir.empty?(dir)
    `rm -rf "#{dir}"`
  else
    `mv "#{dir}" "../assets/"`
  end

  `rm -rf "#{dir}"`
end
