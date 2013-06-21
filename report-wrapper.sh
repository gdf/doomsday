#!/bin/bash -x

report() {

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

date
ruby -v
ruby ~/cheese/doomsday/dooms.rb report --expire --email gdfast@gmail.com --from gdfast@gmail.com

}

report >> /home/gdf/log/doomsday.log 2>&1

