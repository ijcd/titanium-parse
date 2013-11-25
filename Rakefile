task :clean do
    `[ -d testapp ] && (cd testapp && tishadow clear && ti clean && rm -rf app spec)`
end

task :wipe => :clean do
  `rm -rf testapp tmp`
end

task :alloy do
    `(cd testapp && alloy compile --config platform=ios)`
end

task :ti do
    `(cd testapp && ti build -p ios)`
end

task :compile do
    Rake::Task[:alloy].invoke
    Rake::Task[:ti].invoke
end

task :appify do
    `(cd testapp && mkdir -p ../tmp && tishadow appify -d ../tmp -o localhost)`
    `(cd tmp && ti build -p ios)`
end
