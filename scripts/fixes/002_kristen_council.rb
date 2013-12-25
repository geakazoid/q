#!/usr/bin/env ../../script/runner

# set audit user
user = User.find(1)

# make kristen council a volunteer and reset her complete status
Audit.as_user(user) do
  pr = ParticipantRegistration.find(19)
  pr.registration_type = 'volunteer'
  pr.paid = false
  pr.registration_fee = 7500
  pr.registration_code = 'VA9TXG7F'
  pr.discount_in_cents = 0
  pr.breakfast_monday = true
  pr.lunch_monday = true
  pr.housing_sunday = true
  pr.extras_fee = 2000
  pr.save

  # remove kristen's core staff payment
  payment = Payment.find(13)
  payment.destroy
end