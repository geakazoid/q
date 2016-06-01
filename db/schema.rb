# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 62) do

  create_table "Officials", :force => true do |t|
    t.integer  "user_id"
    t.integer  "creator_id"
    t.integer  "district_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "email"
    t.text     "roles"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "actions", :force => true do |t|
    t.integer  "round_id",                     :null => false
    t.integer  "question",                     :null => false
    t.integer  "action",                       :null => false
    t.string   "data",         :default => "", :null => false
    t.integer  "qm_team"
    t.integer  "seat"
    t.string   "identifier",   :default => "", :null => false
    t.integer  "quiz_team_id"
    t.integer  "quizzer_id"
    t.datetime "action_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "original"
  end

  add_index "actions", ["round_id", "question", "action"], :name => "index_actions_on_round_id_and_question_and_action", :unique => true

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "changes"
    t.integer  "version",        :default => 0
    t.datetime "created_at"
  end

  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "buildings", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "air_conditioned", :default => false
  end

  create_table "cvent_corrections", :id => false, :force => true do |t|
    t.text "correction_list"
  end

  create_table "districts", :force => true do |t|
    t.string  "name",         :default => ""
    t.string  "director",     :default => ""
    t.string  "email",        :default => ""
    t.string  "phone",        :default => ""
    t.string  "mobile_phone", :default => ""
    t.integer "region_id"
  end

  create_table "divisions", :force => true do |t|
    t.string  "name"
    t.integer "price_in_cents"
  end

  create_table "equipment", :force => true do |t|
    t.string   "equipment_type"
    t.integer  "equipment_registration_id"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.integer  "room_id"
  end

  create_table "equipment_registrations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "district_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
  end

  create_table "evaluations", :force => true do |t|
    t.string   "key"
    t.string   "sent_to_name"
    t.string   "sent_to_email"
    t.integer  "official_id"
    t.boolean  "complete"
    t.string   "name"
    t.integer  "district_id"
    t.string   "best_suited"
    t.text     "where_observed"
    t.string   "reading"
    t.text     "reading_explanation"
    t.string   "ruling"
    t.text     "ruling_explanation"
    t.string   "knowledge_material"
    t.text     "knowledge_material_explanation"
    t.string   "knowledge_ruling"
    t.text     "knowledge_ruling_explanation"
    t.string   "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "levels"
    t.string   "best_suited_level"
    t.text     "interpersonal_skills"
    t.text     "handles_conflict"
    t.text     "content_judge_utilization"
    t.text     "additional_comments"
  end

  create_table "housing_rooms", :force => true do |t|
    t.integer  "building_id"
    t.string   "number"
    t.string   "keycode",     :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ministry_projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "officials", :force => true do |t|
    t.integer  "user_id"
    t.integer  "creator_id"
    t.integer  "district_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "email"
    t.text     "roles"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "label"
    t.string   "title"
    t.string   "link"
    t.text     "body"
    t.boolean  "published",    :default => true
    t.boolean  "show_on_menu", :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participant_registration_users", :force => true do |t|
    t.integer  "participant_registration_id"
    t.integer  "user_id"
    t.boolean  "owner",                       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participant_registrations", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "promotion_agree"
    t.boolean  "hide_from_others"
    t.string   "registration_type"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "gender"
    t.string   "most_recent_grade"
    t.string   "home_phone"
    t.string   "mobile_phone"
    t.integer  "team1_id"
    t.integer  "team2_id"
    t.integer  "team3_id"
    t.string   "group_leader"
    t.string   "local_church"
    t.integer  "district_id"
    t.string   "shirt_size"
    t.string   "roommate_preference_1"
    t.string   "roommate_preference_2"
    t.string   "food_allergies"
    t.text     "food_allergies_details"
    t.string   "special_needs"
    t.text     "special_needs_details"
    t.string   "past_events_attended"
    t.boolean  "reminder"
    t.integer  "reminder_days"
    t.boolean  "paid",                           :default => false
    t.text     "audit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "travel_type"
    t.string   "arrival_airline"
    t.string   "airline_arrival_date"
    t.string   "airline_arrival_time"
    t.string   "airline_arrival_from"
    t.boolean  "need_arrival_shuttle",           :default => false
    t.string   "departure_airline"
    t.string   "airline_departure_date"
    t.string   "airline_departure_time"
    t.boolean  "need_departure_shuttle",         :default => false
    t.string   "driving_arrival_date"
    t.string   "driving_arrival_time"
    t.string   "registration_code"
    t.integer  "num_extra_group_photos"
    t.integer  "num_dvd"
    t.boolean  "housing_saturday"
    t.boolean  "housing_sunday"
    t.boolean  "breakfast_monday"
    t.boolean  "lunch_monday"
    t.boolean  "need_floorfan"
    t.boolean  "need_pillow"
    t.integer  "num_extra_small_shirts"
    t.integer  "num_extra_medium_shirts"
    t.integer  "num_extra_large_shirts"
    t.integer  "num_extra_xlarge_shirts"
    t.integer  "num_extra_2xlarge_shirts"
    t.integer  "num_extra_3xlarge_shirts"
    t.integer  "num_extra_4xlarge_shirts"
    t.integer  "num_extra_5xlarge_shirts"
    t.string   "guardian"
    t.integer  "school_id"
    t.string   "school_fax"
    t.string   "exhibitor_housing"
    t.string   "participant_housing"
    t.string   "arrival_flight_number"
    t.string   "departure_flight_number"
    t.integer  "registration_fee",               :default => 0
    t.string   "family_registrations"
    t.integer  "num_extra_youth_small_shirts"
    t.integer  "num_extra_youth_medium_shirts"
    t.integer  "num_extra_youth_large_shirts"
    t.string   "country"
    t.integer  "discount_in_cents"
    t.text     "discount_description"
    t.integer  "extras_fee",                     :default => 0
    t.integer  "building_id"
    t.string   "room"
    t.boolean  "medical_liability",              :default => false
    t.boolean  "background_check",               :default => false
    t.integer  "ministry_project_id"
    t.string   "ministry_project_group"
    t.string   "arrival_airport"
    t.string   "departure_airport"
    t.integer  "num_sv_tickets"
    t.boolean  "sv_transportation"
    t.boolean  "nazsafe",                        :default => false
    t.string   "confirmation_number"
    t.integer  "age"
    t.boolean  "understand_form_completion"
    t.boolean  "over_18"
    t.string   "group_leader_import"
    t.integer  "num_district_teams"
    t.integer  "num_local_teams"
    t.integer  "amount_ordered"
    t.integer  "amount_paid"
    t.integer  "amount_due"
    t.string   "emergency_contact_name"
    t.string   "emergency_contact_number"
    t.string   "emergency_contact_relationship"
    t.boolean  "airport_transportation"
    t.string   "guest_first_name"
    t.string   "guest_last_name"
    t.string   "group_leader_email"
    t.integer  "num_novice_district_teams"
    t.integer  "num_experienced_district_teams"
    t.integer  "num_novice_local_teams"
    t.integer  "num_experienced_local_teams"
    t.boolean  "linens"
    t.boolean  "pillow"
    t.boolean  "is_quizzer"
    t.boolean  "is_coach"
    t.boolean  "planning_on_coaching"
    t.boolean  "planning_on_officiating"
    t.boolean  "coaching_team"
    t.boolean  "coaching_team_2"
    t.string   "staying_off_campus"
  end

  create_table "participant_registrations_teams", :id => false, :force => true do |t|
    t.integer "participant_registration_id"
    t.integer "team_id"
  end

  create_table "participants", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "participant_registration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "passwords", :force => true do |t|
    t.integer  "user_id"
    t.string   "reset_code"
    t.datetime "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "team_registration_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "credit_card_number"
    t.string   "phone"
    t.string   "email"
    t.integer  "amount_in_cents"
    t.text     "response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country"
    t.integer  "participant_registration_id"
    t.text     "details"
  end

  create_table "quiz_divisions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quiz_teams", :force => true do |t|
    t.integer "quiz_division_id"
    t.string  "name"
    t.string  "pool"
    t.integer "rounds",           :default => 0
    t.integer "wins",             :default => 0
    t.integer "losses",           :default => 0
    t.integer "total_points",     :default => 0
    t.integer "rank",             :default => 0
    t.integer "manual_rank"
  end

  create_table "quizzers", :force => true do |t|
    t.integer "quiz_division_id"
    t.integer "quiz_team_id"
    t.string  "name"
    t.integer "total_rounds",                                   :default => 0
    t.integer "actual_rounds",                                  :default => 0
    t.integer "points",                                         :default => 0
    t.decimal "average",          :precision => 8, :scale => 2, :default => 0.0
    t.integer "total_correct",                                  :default => 0
    t.integer "total_errors",                                   :default => 0
    t.integer "rank",                                           :default => 0
  end

  create_table "regions", :force => true do |t|
    t.string "name",         :default => ""
    t.string "director",     :default => ""
    t.string "email",        :default => ""
    t.string "phone",        :default => ""
    t.string "mobile_phone", :default => ""
  end

  create_table "registerable_items", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "price_in_cents"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registration_items", :force => true do |t|
    t.integer  "participant_registration_id"
    t.integer  "registerable_item_id"
    t.integer  "count",                       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "rooms", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "round_quizzers", :force => true do |t|
    t.integer "round_id"
    t.integer "quizzer_id"
    t.integer "score",         :default => 0
    t.integer "total_correct", :default => 0
    t.integer "total_errors",  :default => 0
  end

  create_table "round_teams", :force => true do |t|
    t.integer "round_id"
    t.integer "quiz_team_id"
    t.integer "position"
    t.integer "place"
    t.integer "score"
  end

  create_table "rounds", :force => true do |t|
    t.integer "room_id"
    t.integer "quiz_division_id"
    t.string  "number"
    t.integer "questions",        :default => 0
    t.boolean "visible",          :default => true
    t.boolean "complete"
  end

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.boolean  "paid",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "seminar_registrations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "district_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "email"
    t.boolean  "seminar_1"
    t.string   "seminar_1_session"
    t.boolean  "seminar_2"
    t.string   "seminar_2_session"
    t.boolean  "seminar_3"
    t.string   "seminar_3_session"
    t.boolean  "seminar_4"
    t.string   "seminar_4_session"
    t.boolean  "seminar_5"
    t.string   "seminar_5_session"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "seminar_6"
    t.string   "seminar_6_session"
    t.boolean  "seminar_7"
    t.string   "seminar_7_session"
    t.boolean  "seminar_8"
    t.string   "seminar_8_session"
    t.boolean  "seminar_9"
    t.string   "seminar_9_session"
    t.boolean  "seminar_10"
    t.string   "seminar_10_session"
    t.boolean  "seminar_11"
    t.string   "seminar_11_session"
    t.boolean  "seminar_12"
    t.string   "seminar_12_session"
    t.boolean  "seminar_13"
    t.string   "seminar_13_session"
    t.boolean  "seminar_14"
    t.string   "seminar_14_session"
    t.boolean  "seminar_15"
    t.string   "seminar_15_session"
    t.boolean  "seminar_16"
    t.string   "seminar_16_session"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "statistics", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "body",       :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "team_registrations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "district_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "email"
    t.integer  "amount_in_cents"
    t.boolean  "paid",            :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "audit"
    t.string   "regional_code"
  end

  create_table "teams", :force => true do |t|
    t.integer  "team_registration_id"
    t.integer  "division_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount_in_cents"
    t.boolean  "discounted"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name",                                                      :null => false
    t.string   "last_name",                                                       :null => false
    t.string   "email",                     :limit => 100
    t.string   "phone"
    t.boolean  "communicate_by_email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token",            :limit => 40
    t.string   "activation_code",           :limit => 40
    t.string   "state",                                    :default => "passive", :null => false
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "district_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
