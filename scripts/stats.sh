#!/bin/sh
source "$HOME/.rvm/scripts/rvm"

cd /var/rails/q2012.org/public/web

wget -N http://qms.q2012.org/dn_teamstandings.html
wget -N http://qms.q2012.org/dn_indstandings.html
wget -N http://qms.q2012.org/dx1_teamstandings.html
wget -N http://qms.q2012.org/dx1_indstandings.html
wget -N http://qms.q2012.org/dx2_teamstandings.html
wget -N http://qms.q2012.org/dx2_indstandings.html
wget -N http://qms.q2012.org/dx_indstandings.html
wget -N http://qms.q2012.org/ln_teamstandings.html
wget -N http://qms.q2012.org/ln_indstandings.html
wget -N http://qms.q2012.org/lx1_teamstandings.html
wget -N http://qms.q2012.org/lx1_indstandings.html
wget -N http://qms.q2012.org/lx2_teamstandings.html
wget -N http://qms.q2012.org/lx2_indstandings.html
wget -N http://qms.q2012.org/lx_indstandings.html
wget -N http://qms.q2012.org/ra_teamstandings.html
wget -N http://qms.q2012.org/ra_indstandings.html
wget -N http://qms.q2012.org/rb_teamstandings.html
wget -N http://qms.q2012.org/rb_indstandings.html
wget -N http://qms.q2012.org/10s_teamstandings.html
wget -N http://qms.q2012.org/10s_indstandings.html
wget -N http://qms.q2012.org/koh_teamstandings.html
wget -N http://qms.q2012.org/koh_indstandings.html
wget -N http://qms.q2012.org/jff_teamstandings.html
wget -N http://qms.q2012.org/jff_indstandings.html
wget -N http://qms.q2012.org/td_teamstandings.html
wget -N http://qms.q2012.org/td_indstandings.html

# overwrite lx1, lx2, dx1, dx2
cp -a dx_indstandings.html dx1_indstandings.html
cp -a dx_indstandings.html dx2_indstandings.html
cp -a lx_indstandings.html lx1_indstandings.html
cp -a lx_indstandings.html lx2_indstandings.html

cd ../../scripts

rvm use 1.8.7

ruby stats_parser.rb dn
ruby stats_parser.rb dx1
ruby stats_parser.rb dx2
ruby stats_parser.rb ln
ruby stats_parser.rb lx1
ruby stats_parser.rb lx2
ruby stats_parser.rb ra
ruby stats_parser.rb rb
ruby stats_parser.rb 10s
ruby stats_parser.rb koh
ruby stats_parser.rb jff
ruby stats_parser.rb td
