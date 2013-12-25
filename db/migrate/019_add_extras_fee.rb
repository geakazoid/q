class AddExtrasFee < ActiveRecord::Migration
  def self.up
    # add extras fee to participant registrations
    add_column :participant_registrations, :extras_fee, :integer, :default => 0

    # update our extras fee column for each user in the database
    ParticipantRegistration.all.each do |participant_registration|
      extras_total = 0

      if participant_registration.housing_sunday? and !participant_registration.bought_extra?('housing_sunday') and participant_registration.most_recent_grade != 'Child Age 3 and Under'
        extras_total += 10;
      end
      if participant_registration.housing_saturday? and !participant_registration.bought_extra?('housing_saturday') and participant_registration.most_recent_grade != 'Child Age 3 and Under'
        extras_total += 10;
      end
      if participant_registration.need_floorfan? and !participant_registration.bought_extra?('need_floorfan')
        extras_total += 12;
      end
      if participant_registration.need_pillow? and !participant_registration.bought_extra?('need_pillow')
        extras_total += 8;
      end

      if participant_registration.need_arrival_shuttle? and !participant_registration.bought_extra?('need_arrival_shuttle') and participant_registration.registration_type != 'exhibitor' and participant_registration.most_recent_grade != 'Child Age 3 and Under'
        extras_total += 3;
      end
      if participant_registration.need_departure_shuttle? and !participant_registration.bought_extra?('need_departure_shuttle') and participant_registration.registration_type != 'exhibitor' and participant_registration.most_recent_grade != 'Child Age 3 and Under'
        extras_total += 3;
      end

      meal_extras = 0;

      if participant_registration.breakfast_monday? and participant_registration.lunch_monday? and !participant_registration.bought_extra?('breakfast_monday') && !participant_registration.bought_extra?('lunch_monday')
        meal_extras = 10;
      elsif participant_registration.breakfast_monday? and !participant_registration.bought_extra?('breakfast_monday')
        meal_extras = 5;
      elsif participant_registration.lunch_monday? and !participant_registration.bought_extra?('lunch_monday')
        meal_extras = 6;
      end

      if participant_registration.most_recent_grade != 'Child Age 3 and Under'
        extras_total += meal_extras;
      end

      # are we an exhibitor?
      if participant_registration.registration_type == 'exhibitor'
        school = participant_registration.school

        if !school.nil?
          extras_total += 300 unless school.paid?
        end
      end

      if participant_registration.registration_type == 'core_staff'
        extras_total = 0;
      end

      extras_total += (2 * participant_registration.num_extra_group_photos) if !participant_registration.num_extra_group_photos.blank?
      extras_total += (17 * participant_registration.num_dvd) if !participant_registration.num_dvd.blank?
      extras_total += (10 * participant_registration.num_extra_youth_small_shirts) if !participant_registration.num_extra_youth_small_shirts.blank?
      extras_total += (10 * participant_registration.num_extra_youth_medium_shirts) if !participant_registration.num_extra_youth_medium_shirts.blank?
      extras_total += (10 * participant_registration.num_extra_youth_large_shirts) if !participant_registration.num_extra_youth_large_shirts.blank?
      extras_total += (10 * participant_registration.num_extra_small_shirts) if !participant_registration.num_extra_small_shirts.blank?
      extras_total += (10 * participant_registration.num_extra_medium_shirts) if !participant_registration.num_extra_medium_shirts.blank?
      extras_total += (10 * participant_registration.num_extra_large_shirts) if !participant_registration.num_extra_large_shirts.blank?
      extras_total += (10 * participant_registration.num_extra_xlarge_shirts) if !participant_registration.num_extra_xlarge_shirts.blank?
      extras_total += (15 * participant_registration.num_extra_2xlarge_shirts) if !participant_registration.num_extra_2xlarge_shirts.blank?
      extras_total += (15 * participant_registration.num_extra_3xlarge_shirts) if !participant_registration.num_extra_3xlarge_shirts.blank?
      extras_total += (15 * participant_registration.num_extra_4xlarge_shirts) if !participant_registration.num_extra_4xlarge_shirts.blank?
      extras_total += (15 * participant_registration.num_extra_5xlarge_shirts) if !participant_registration.num_extra_5xlarge_shirts.blank?

      # update our extras fee and save the participant registration
      participant_registration.extras_fee = extras_total * 100
      participant_registration.save
    end
  end

  def self.down
    # remove extras fee from participant registrations
    remove_column :participant_registrations, :extras_fee
  end
end