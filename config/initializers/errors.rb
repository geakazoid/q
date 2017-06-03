class ActiveRecord::Errors
  def full_messages
    full_messages = []

    @errors.each_key do |attr|
      @errors[attr].each do |msg|
        next if msg.nil?

        if attr == "base" || msg =~ /^[[:upper:]]/
          full_messages << msg
        else
          # this is a hack, but i don't know of a better way to do this at the moment
          if (attr == "teams.name")
            attr = "team name"
          end
          if (attr == "teams.division")
            attr = "division"
          end
          full_messages << @base.class.human_attribute_name(attr) + " " + msg.to_s
        end
      end
    end
    full_messages
  end
end