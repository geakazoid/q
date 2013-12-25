#!/usr/bin/env ../../script/runner

# find one of Sara Christensen's district teams
# make it non discounted
# the price is already correct ($140)
team = Team.find(57)
team.discounted = false
team.save

# find one of Timothy Lee's district teams
# make it non discounted and change the price to $125
# we aren't making him pay the missing $15
team = Team.find(150)
team.discounted = false
team.amount_in_cents = 12500
team.save