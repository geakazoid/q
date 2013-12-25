#!/usr/bin/env ../../script/runner

# set audit user
user = User.find(1)

# make lydia hutchinson a quizzer instead of a family registration
Audit.as_user(user) do
  pr = ParticipantRegistration.find(268)
  pr.registration_type = 'quizzer'
  pr.save
end