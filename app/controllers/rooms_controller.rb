class RoomsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, :with => false

  skip_before_filter :verify_authenticity_token, :only => :auto_complete_for_room

  def auto_complete_for_room
    typed = ''
    params['participant_registration'].each do |key,value|
      id = key
      typed = value['room']
    end

    @rooms = Array.new
    unless params['building_id'].blank? or typed.blank?
      sql = "select room,count(room) as count from participant_registrations where building_id = #{params['building_id']} and room like '%#{typed}%' group by room;"
      r = ActiveRecord::Base.connection.execute(sql)

      r.each_hash do |row|
        @rooms.push(row)
      end
    end
  end
end