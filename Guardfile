ALL_ON_START = true

# ignore build directories
ignore %r{/build/}

guard 'bundler' do
  watch('Gemfile')
  # Uncomment next line if Gemfile contain `gemspec' command
  # watch(/^.+\.gemspec/)
end

guard 'tishadow', :app_root => "testapp" do
  watch(%r{^testapp/app/.*})
  watch(%r{^testapp/tiapp.xml})
  watch(%r{^testapp/spec/(.*)\.js})
end

guard 'shell', :all_on_start => ALL_ON_START do

  # any -> any
  watch(%r{^src/(.+)$}) do |m|
    build_other(m[0])
  end

  # coffee -> js
  watch(%r{^(src|spec)/(.+)\.coffee$}) do |m|
    build_coffee(m[0])    
  end

end

def build_coffee(from)
  to = from.gsub(/^src\/spec\//, 'testapp/spec/').gsub(/^src\//, 'testapp/app/').gsub(/\.coffee$/, '.js')

  return if File.exist?(to) && (File.mtime(to) > File.mtime(from))

  UI.info "COFFEE: #{from} -> #{to}"

  # use a temp path to prevent errors from triggering and app deploy (jade is creating an empty file)
  FileUtils.mkdir_p(File.dirname(to))
  Dir.mktmpdir('guard') do |tmp_dir|
    cmd = "coffee --compile --bare --map --output #{tmp_dir} #{from} 2>&1 && cp #{tmp_dir}/* #{File.dirname(to)}"
    error = `#{cmd}`.strip
    UI.error(error) unless error.empty?
  end
end

def build_other(from)
  return if from =~ /\.(coffee|jade|ltss|styl|swp)$/i
  return unless File.file?(from)

  if from =~ %r{^src/testapp}
    to = from.gsub(/^src\/testapp\//, 'testapp/app/')
  else
    to = from.gsub(/^src\//, 'testapp/app/')
  end
  return if File.exist?(to) && (File.mtime(to) > File.mtime(from))

  UI.info "COPY: #{from} -> #{to}"

  FileUtils.mkdir_p(File.dirname(to))
  FileUtils.cp(from, to)  
end
