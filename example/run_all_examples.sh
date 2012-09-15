# # assuming ruby 1.9.3
# if ! lsof -i :9393>/dev/null; then
#   echo 'You need to set up the sandbox for the sandbox example.'
#   echo 'cd sandbox/server; bundle && bundle exec rackup -p 9393'
#   exit
# fi
# 
# orig_dir=`pwd`
# for d in */; do
#   cd $d
# 
#   cd server
#   printf '####'; pwd
#   bundle install && bundle exec ruby test.rb
#   cd ../ 
# 
#   cd client
#   printf '####'; pwd
#   bundle install && bundle exec ruby test.rb
#   cd ../../
# 
# done
# 
# cd fakes/client
# USE_REAL=1 bundle exec ruby test.rb
# cd $orig_dir
# 
# echo 'done'