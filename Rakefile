desc "Remove all intermediate files"
task :clean do
  system '[ -d testapp ] && (cd testapp && tishadow clear && ti clean && rm -rf app spec)'
end

desc "Remove test app and all intermediate files"
task :wipe => :clean do
  system 'rm -rf testapp tmp'
end

desc "Perform the 'alloy compile' part of the build process"
task :alloy do
  system '(cd testapp && alloy compile --config platform=ios)'
end

desc "Perform the 'ti build' part of the build process"
task :ti do
  system '(cd testapp && ti build -p ios)'
end

desc "Compile and install a non-tishadow version of titanium-parse and deploy it to the device"
task :deploy => [:alloy, :ti] 

desc "Create a testapp for tishadow testing of titanium-parse"
directory "testapp" do
  system 'titanium create --name=titaniumparse --id=com.ijcd.titaniumparse --platforms=android,ipad,iphone,mobileweb --workspace-dir tmp'
  system 'mv tmp/titaniumparse testapp'
  system 'rm testapp/Resources/app.js'
  system '(cd testapp && alloy new && ti clean)'
  Rake::Task[:install].invoke
end

desc "Copy files into the development app"
task :install => :testapp do
  system 'rsync -r src/lib/ testapp/app/lib/'
  system 'rsync -r src/testapp/ testapp/app/'
  Rake::Task[:alloy].invoke
end

desc "Convert testapp into a standalone tishadow app and deploy it to the device"
task :appify => :install do
  system '(cd testapp && mkdir -p ../tmp && tishadow appify -d ../tmp -o localhost)'
  system '(cd tmp && ti build -p ios)'
end

task :spec do
  system '(cd testapp && tishadow spec)'
end

task :default => :testapp
