module ParticipantRegistrationsHelper

  def display_sharing_info(page, text)
    page.show 'extra_users_info'
    page.replace_html 'extra_users_info', '<span class="notice">' + text + '</span>'
    page.delay(5) do
      page.visual_effect(:Fade, "extra_users_info")
    end
  end

  def display_sharing_error(page, text)
    page.show 'extra_users_info'
    page.replace_html 'extra_users_info', '<span class="error">' + text + '</span>'
    page.delay(5) do
      page.visual_effect(:Fade, "extra_users_info")
    end
  end

  def chicago_airlines
    ['Aer Lingus',
     'AeroMexico',
     'Air Canada',
     'Air Canada Jazz',
     'Air Choice One',
     'Air France',
     'Air India',
     'Air Tran',
     'Alaska Airlines',
     'Alitalia C.A.I.',
     'All Nippon',
     'American Airlines and American Connection',
     'American Eagle',
     'Asiana Airlines',
     'Branson Air Express',
     'British Airways',
     'Cathay Pacific Airways',
     'Cayman Airways',
     'Copa Airlines',
     'Delta Airlines',
     'Delta and Delta Shuttle',
     'Etihad Airways',
     'Frontier Airlines',
     'Iberia Airlines',
     'Japan Airlines (JAL)',
     'Jet Blue',
     'KLM Royal Dutch',
     'Korean Air',
     'LOT Polish Airlines',
     'Lufthansa',
     'Mexicana',
     'Northwest Airlines',
     'Porter Airlines',
     'Royal Jordanian',
     'Scandinavian Arlines (SAS)',
     'Skywest Airlines',
     'Southwest Airlines',
     'Spirit Airlines',
     'SWISS',
     'TACA Airlines',
     'Turkish Airlines',
     'United Airlines and United Express',
     'US Airways',
     'USA 3000',
     'Virgin America',
     'Virgin Atlantic Airways',
     'Volaris Airlines']
  end

  # show text displaying how many of an extra we've bought
  # if we haven't bought any we return an empty string
  def show_bought_extra(extra)
    text = ""
    if @participant_registration.bought_extra?(extra)
      text = "<br/>You have already purchased #{@participant_registration.count_bought_extra(extra)}"
    end
    text
  end

  def registration_amount_due(participant_registration)
    registration_fee = participant_registration.registration_fee
    paid_amount = participant_registration.paid_registration_amount * 100
    registration_discount = participant_registration.registration_discount ? participant_registration.registration_discount : 0
    payment_remaining = (registration_fee - paid_amount - registration_discount) / 100
    return "$#{payment_remaining}.00"
  end

  def extras_amount_due(participant_registration)
    registration_fee = participant_registration.registration_fee
    paid_amount = participant_registration.paid_registration_amount * 100
    registration_discount = participant_registration.registration_discount ? participant_registration.registration_discount : 0
    payment_remaining = (registration_fee - paid_amount - registration_discount) / 100
    return "$#{payment_remaining}.00"
  end

  def describe_payment(payment)
    participant_registration = payment.participant_registration
    is_core_staff = participant_registration.core_staff?
    is_small_child = participant_registration.small_child?

    text = ''
    registration_text = ''
    detail_text = ''

    bought_breakfast = false
    bought_lunch = false

    # loop through our payments to find out when we purchased each meal on monday
    # this is a total hack, but i'm pretty sure this is the best way to handle it.
    # boo on me.
    meals_bought_together = false
    breakfast_bought_first = false
    lunch_bought_first = false
    # if we're core staff or a child we dont care about the price
    if !is_core_staff and !is_small_child
      payment.participant_registration.payments.each do |other_payment|
        if !meals_bought_together and !breakfast_bought_first and !lunch_bought_first
          bought_breakfast = false
          bought_lunch = false
          other_payment.details.each do |key,detail|
            if key == 'breakfast_monday'
              bought_breakfast = true
            end

            if key == 'lunch_monday'
              bought_lunch = true
            end
          end
        
          if bought_breakfast and bought_lunch
            meals_bought_together = true
          elsif bought_breakfast
            breakfast_bought_first = true
          elsif bought_lunch
            lunch_bought_first = true
          end
        end
      end
    end

    payment_text = '<strong>' + payment.created_at.strftime("%m.%d.%Y %I:%M %p") + ' - ' + payment.amount.to_s + '</strong><br/>'
    payment.details.each do |key,detail|
      if key == 'registration_amount' and detail != 0
        if detail.to_i == payment.participant_registration.registration_fee
          registration_text = 'Full Registration Payment ($' + (detail / 100).to_s + '.00), '
        elsif detail.to_i < 0
          registration_text = 'Refund (-$' + ((0-detail) / 100).to_s + '.00), '
        else
          registration_text = 'Partial Registration Payment ($' + (detail / 100).to_s + '.00), '
        end
      end

      if key == 'housing_sunday'
        if is_core_staff or is_small_child
          detail_text += ' Housing Sunday (No Charge), '
        else
          detail_text += ' Housing Sunday ($8.00), '
        end
      end

      if key == 'housing_saturday'
        if is_core_staff or is_small_child
          detail_text += ' Housing Saturday (No Charge), '
        else
          detail_text += ' Housing Saturday ($8.00), '
        end
      end

      if key == 'breakfast_monday'
        if is_core_staff or is_small_child
          detail_text += ' Breakfast Monday (No Charge), '
        else
          detail_text += ' Breakfast Monday ($5.00), '
        end
      end

      if key == 'lunch_monday'
        if is_core_staff or is_small_child
          detail_text += ' Lunch Monday (No Charge), '
        else
          detail_text += ' Lunch Monday ($6.00), '
        end
      end

      if key == 'need_arrival_shuttle'
        if is_core_staff or is_small_child
          detail_text += ' Arrival Shuttle (No Charge), '
        else
          detail_text += ' Arrival Shuttle ($3.00), '
        end
      end

      if key == 'need_departure_shuttle'
        if is_core_staff or is_small_child
          detail_text += ' Departure Shuttle (No Charge), '
        else
          detail_text += ' Departure Shuttle ($3.00), '
        end
      end

      if key == 'num_extra_group_photos'
        detail_text += detail.to_s + ' Extra Group Photo(s) ($' + (detail * 2).to_s + '.00), '
      end

      if key == 'num_dvd'
        detail_text += detail.to_s + ' DVD Highlight Video(s) ($' + (detail * 10).to_s + '.00), '
      end

      if key == 'num_extra_youth_small_shirts'
        detail_text += detail.to_s + ' Extra Youth Small Shirt(s) ($' + (detail * 10).to_s + '.00), '
      end

      if key == 'num_extra_youth_medium_shirts'
        detail_text += detail.to_s + ' Extra Youth Medium Shirt(s) ($' + (detail * 10).to_s + '.00), '
      end

      if key == 'num_extra_youth_large_shirts'
        detail_text += detail.to_s + ' Extra Youth Large Shirt(s) ($' + (detail * 10).to_s + '.00), '
      end

      if key == 'num_extra_small_shirts'
        detail_text += detail.to_s + ' Extra Small Shirt(s) ($' + (detail * 10).to_s + '.00), '
      end

      if key == 'num_extra_medium_shirts'
        detail_text += detail.to_s + ' Extra Medium Shirt(s) ($' + (detail * 10).to_s + '.00), '
      end

      if key == 'num_extra_large_shirts'
        detail_text += detail.to_s + ' Extra Large Shirt(s) ($' + (detail * 10).to_s + '.00), '
      end

      if key == 'num_extra_xlarge_shirts'
        detail_text += detail.to_s + ' Extra X-Large Shirt(s) ($' + (detail * 10).to_s + '.00), '
      end

      if key == 'num_extra_2xlarge_shirts'
        detail_text += detail.to_s + ' Extra 2X-Large Shirt(s) ($' + (detail * 15).to_s + '.00), '
      end

      if key == 'num_extra_3xlarge_shirts'
        detail_text += detail.to_s + ' Extra 3X-Large shirt(s) ($' + (detail * 15).to_s + '.00), '
      end

      if key == 'num_extra_4xlarge_shirts'
        detail_text += detail.to_s + ' Extra 4X-Large shirt(s) ($' + (detail * 15).to_s + '.00), '
      end

      if key == 'num_extra_5xlarge_shirts'
        detail_text += detail.to_s + ' Extra 5X-Large Shirt(s) ($' + (detail * 15).to_s + '.00), '
      end
      
      if key == 'num_sv_tickets'
        detail_text += detail.to_s + ' Splash Valley Ticket(s) ($' + (detail * 6).to_s + '.00), '
      end
      
      if key == 'sv_transportation'
        if !payment.details['num_sv_tickets'].nil? and payment.details['num_sv_tickets'] > 0
          detail_text += ' Splash Valley Transportation ($' + (payment.details['num_sv_tickets'] * 1).to_s + '.00), '
        end
      end
    end
    if registration_text != ''
      text = payment_text + registration_text + detail_text
    else
      text = payment_text + detail_text
    end
    text.chop!.chop!
  end
end