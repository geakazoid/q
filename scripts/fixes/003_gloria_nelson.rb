#!/usr/bin/env ../../script/runner

# set audit user
user = User.find(1)

# fix gloria nelson's guest registrations
Audit.as_user(user) do
  pr = ParticipantRegistration.find(262)
  payment = pr.payments.new
  payment.amount_in_cents = -4000
  details = Hash.new
  details['registration_amount'] = -4000
  payment.details = details
  payment.save
  pr.registration_fee = 13000
  pr.save

  pr = ParticipantRegistration.find(263)
  payment = pr.payments.new
  payment.amount_in_cents = -4000
  details = Hash.new
  details['registration_amount'] = -4000
  payment.details = details
  payment.save
  pr.registration_fee = 13000
  pr.save

  pr = ParticipantRegistration.find(264)
  payment = pr.payments.new
  payment.amount_in_cents = -4000
  details = Hash.new
  details['registration_amount'] = -4000
  payment.details = details
  payment.save
  pr.registration_fee = 13000
  pr.save
end