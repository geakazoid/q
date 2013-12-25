/* update participant registration total based upon selected options */
function update_participant_total() {
    if (!form_is_loaded) {
        return;
    }

    var registration_type = $('participant_registration_registration_type');
    var age_group = $('participant_registration_most_recent_grade').value;
    var prices = $$('.item_price');
    var counts = $$('.item_count');
    var registration_fee = 0;
    var registration_total = 0;
    var extras_total = 0;
    var extras_fee = 0;
    var total = 0;

    /* prices hard coded for now */
    if (registration_type.value == 'coach' || registration_type.value == 'quizzer') {
        registration_total = 175;
    } else if (registration_type.value == 'exhibitor') {
        registration_total = 300;
    } else if (registration_type.value == 'guest' || registration_type.value == 'family') {
        registration_total = 175;
    } else if (registration_type.value == 'official' || registration_type.value == 'volunteer') {
        registration_total = 75;
    }
    
    /* check for global registration code */
    $('discount_text').hide();
    var registration_code = $('participant_registration_registration_code').value;
    if (registration_code == 'GQ2A4FK5') {
        $('discount_text').innerHTML = "You apply for the global participant discount.";
        $('discount_text').show();
        registration_total = 90;
    }

    /* participant (coaches and quizzers) options */
    if (registration_type.value == 'coach' || registration_type.value == 'quizzer') {
        if ($('participant_registration_participant_housing_meals_only').checked) {
            registration_total -= 50;
        }
        if ($('participant_registration_participant_housing_none').checked) {
            registration_total -= 125;
        }
    }

    /* housing options - only check if this is displayed */
    if ($('housing_details').visible()) {
        var housing_sunday = $('participant_registration_housing_sunday');
        var housing_saturday = $('participant_registration_housing_saturday');

        if (housing_sunday.checked && !bought_housing_sunday && age_group != 'Child Age 3 and Under') {
            extras_total += 8;
        }
        if (housing_saturday.checked && !bought_housing_saturday && age_group != 'Child Age 3 and Under') {
            extras_total += 8;
        }
    }

    /* flying options - only check if actually flying */
    if ($('flying_details').visible()) {
        var arrival_shuttle = $('participant_registration_need_arrival_shuttle');
        var departure_shuttle = $('participant_registration_need_departure_shuttle');

        if (arrival_shuttle.checked && !bought_arrival_shuttle && registration_type.value != 'exhibitor' && age_group != 'Child Age 3 and Under') {
            extras_total += 3;
        }
        if (departure_shuttle.checked && !bought_departure_shuttle && registration_type.value != 'exhibitor' && age_group != 'Child Age 3 and Under') {
            extras_total += 3;
        }
    }

    /* meal options - only check if this is displayed */
    if ($('meals_details').visible()) {
        var breakfast_monday = $('participant_registration_breakfast_monday');
        var lunch_monday = $('participant_registration_lunch_monday');
        var meal_extras = 0;

        if (breakfast_monday.checked && !bought_breakfast_monday) {
            meal_extras += 5;
        }
        if (lunch_monday.checked && !bought_lunch_monday) {
            meal_extras += 6;
        }
        if (age_group != 'Child Age 3 and Under') {
            extras_total += meal_extras;
        }
    }

    /* figure out family discounts if applicable */
    if (registration_type.value == 'family') {
        var family_registrations_count = $('family_registrations_count');

        if (family_registrations_count.value > 6) {
            $('family_discount_7_plus').show();
            registration_total -= 45;
        }
        if (family_registrations_count.value == 6) {
            $('family_discount_7').show();
            registration_total -= 75;
        } else if (family_registrations_count.value >= 4) {
            $('family_discount_5').show();
            registration_total -= 40;
        } else if (family_registrations_count.value == 3) {
            $('family_discount_4').show();
            registration_total -= 55;
        } else if (family_registrations_count.value == 2) {
            $('family_discount_3').show();
            registration_total -= 105;
        } else {
            $('family_discount_none').show();
        }
    }

    /* exhibitor details if applicable */
    if (registration_type.value == 'exhibitor') {
        var school = $('participant_registration_school_id');

        if (school.value != '') {
            paid_status = $('school_paid_' + school.value).value;
            
            if (paid_status == 'true') {
                registration_total = 175;
                if ($('participant_registration_exhibitor_housing_off_campus_with_meals').checked) {
                    registration_total -= 95;
                }
                if ($('participant_registration_exhibitor_housing_off_campus_without_meals').checked) {
                    registration_total -= 175;
                }
            }
        }
    }

    /* reduce price to zero if registration type is core staff */
    if (registration_type.value == 'core_staff') {
        registration_total = 0;
        extras_total = 0;
    }

    /* reduce price to zero if registration is for a child 3 and under */
    if (age_group == 'Child Age 3 and Under') {
        registration_total = 0;
    }

    /* additional items */
    for (i = 0; i < prices.length; i++) {
        extras_total += prices[i].value * counts[i].value;
    }
    
    /* splash valley transportation */
    if ($('participant_registration_sv_transportation').checked) {
        if ($('participant_registration_num_sv_tickets').value > 0) {
            extras_total += $('participant_registration_num_sv_tickets').value * 1; 
        }
    }

    /* store our registration_fee and original extras total */
    registration_fee = registration_total;
    extras_fee = extras_total;

    /* see if we're skipping extras for now */
    var skip_extras = false;
    if ($('skip_extras').checked) {
        skip_extras = true;
        extras_total = 0;
    }

    /* subtract our discount */
    registration_total -= registration_discount();
    extras_total -= extras_discount();

    /* don't allow for a negative registration total */
    if (registration_total < 0) {
        registration_total = 0;
    }

    /* don't allow for a negative extras total */
    if (extras_total < 0) {
        extras_total = 0;
    }

    /* show the correct payment message (and update payment amounts for already bought items) */
    var full_fee_not_paid = $('full_fee_not_paid');
    var full_fee_paid_has_extras = $('full_fee_paid_has_extras');
    var partial_fee_not_paid = $('partial_fee_not_paid');
    var partial_last_payment = $('partial_last_payment');
    var zero_balance = $('zero_balance');
    var breakdown = $('breakdown');
    var submit_payment = $('submit_payment');
    var update_registration = $('update_registration');
    var payment_details = $('payment_details');

    full_fee_not_paid.hide();
    full_fee_paid_has_extras.hide();
    partial_fee_not_paid.hide();
    partial_last_payment.hide();
    zero_balance.hide();
    breakdown.hide();
    submit_payment.hide();
    update_registration.hide();
    payment_details.hide();

    if (!paid_full_registration_fee) {
        if (registration_type.value == 'quizzer' || registration_type.value == 'coach') {
            /* reduce registration amount by what's already been paid */
            registration_total -= paid_registration_amount;
        
            if (registration_total < 100) {
                partial_last_payment.show();
            } else {
                partial_fee_not_paid.show();
                payment_details.show();
            }
            submit_payment.show();
            breakdown.show();
        } else {
            full_fee_not_paid.show();
            submit_payment.show();
            breakdown.show();
        }
    }
      
    if (paid_full_registration_fee && !skip_extras && extras_fee > 0) {
        full_fee_paid_has_extras.show();
        submit_payment.show();
        breakdown.show();
        registration_total = 0;
    /* this is a hack - shame on me */  
    } else if (paid_full_registration_fee && (($('participant_registration_breakfast_monday').disabled == false && $('participant_registration_breakfast_monday').checked) || 
                                       ($('participant_registration_lunch_monday').disabled == false && $('participant_registration_lunch_monday').checked) ||
                                       ($('participant_registration_housing_sunday').disabled == false && $('participant_registration_housing_sunday').checked) ||
                                       ($('participant_registration_housing_saturday').disabled == false && $('participant_registration_housing_saturday').checked))) {
        full_fee_paid_has_extras.show();
        submit_payment.show();
        registration_total = 0;  
    } else if (paid_full_registration_fee && (extras_fee == 0 || skip_extras)) {
        zero_balance.show();
        update_registration.show();
        registration_total = 0;
    }

    /* update fees */
    if (!paid_any_registration_fee) {
        $('participant_registration_registration_fee').value = registration_fee * 100;
    }
    $('participant_registration_extras_fee').value = extras_fee * 100;


    /* display option to skip extras if we have some */
    /* only provide this option to quizzers, coaches, volunteers, and officials */
    $('ask_about_extras').hide();
    if (registration_type.value == 'quizzer' || registration_type.value == 'coach' || registration_type.value == 'volunteer' || registration_type.value == 'official') {
        if (extras_fee > 0) {
            $('ask_about_extras').show();
        }
    }

    total = registration_total + extras_total;

    $('participant_registration_submit').value = 'Submit Payment';
    if (total == 0) {
        $('participant_registration_submit').value = 'Submit Registration';
    }

    $('registration_amount').value = registration_total * 100;
    $('extras_amount').value = extras_total * 100;
    $('participant_registration_extras_fee').value = extras_fee * 100;
    $('payment_amount').value = total * 100;
    $('total_amount').innerHTML = formatAsMoney(total);
    $('registration_total_amount').innerHTML = formatAsMoney(registration_total);

    /* generate our payment breakdown */
    generate_breakdown();
}

/* update participant registration form based upon the type of registration chosen. */
function update_registration_type() {
    var text = '';
    var registration_type = $('participant_registration_registration_type').value;
    var registration_info = $('registration_info');
    var registration_code = $('registration_code');
    var team_selection = $('team_selection');
    var family_discount = $('family_discount');
    var team_coach_description = $('team_coach_description');
    var team_quizzer_description = $('team_quizzer_description');
    var exhibitor_housing_details = $('exhibitor_housing_details');
    var exhibitor_details = $('exhibitor_details');
    var participant_housing_details = $('participant_housing_details');
    var housing_details = $('housing_details');
    var meals_details = $('meals_details');
    var breakfast_monday_price = $('breakfast_monday_price');
    var lunch_monday_price = $('lunch_monday_price');
    var housing_sunday_price = $('housing_sunday_price');
    var housing_saturday_price = $('housing_saturday_price');
    var floor_fan_price = $('floor_fan_price');
    var pillow_price = $('pillow_price');
    var arrival_shuttle_price = $('arrival_shuttle_price');
    var departure_shuttle_price = $('departure_shuttle_price');

    registration_code.hide();
    team_selection.hide();
    family_discount.hide();
    exhibitor_housing_details.hide();
    exhibitor_details.hide();
    participant_housing_details.hide();
    housing_details.show();
    meals_details.show();
    breakfast_monday_price.innerHTML = '$5';
    lunch_monday_price.innerHTML = '$6';
    housing_sunday_price.innerHTML = '$8';
    housing_saturday_price.innerHTML = '$8';
    arrival_shuttle_price.innerHTML = '$3'
    departure_shuttle_price.innerHTML = '$3'
    
    switch (registration_type) {
        case 'quizzer':
            text = 'The registration fee for a quizzer is $175.00. ';
            if (!paid_any_registration_fee) {
                text += 'If you have a registration code please enter it below.'
            }
            registration_info.innerHTML = text;
            team_selection.show();
            team_quizzer_description.show();
            team_coach_description.hide();
            update_participant_housing();
            update_participant_housing();
            registration_code.show();
            break;
        case 'coach':
            text = 'The registration fee for a coach is $175.00. ';
            if (!paid_any_registration_fee) {
                text += 'If you have a registration code please enter it below.'
            }
            registration_info.innerHTML = text;
            team_selection.show();
            team_coach_description.show();
            team_quizzer_description.hide();
            update_participant_housing();
            registration_code.show();
            break;
        case 'official':
            text = 'The registration fee for an official is $75.00. ';
            if (!paid_any_registration_fee) {
                text += 'You will need a registration code in order to complete this type of registration.'
            }
            registration_info.innerHTML = text;
            registration_code.show();
            break;
        case 'volunteer':
            text = 'The registration fee for a volunteer is $75.00. ';
            if (!paid_any_registration_fee) {
                text += 'You will need a registration code in order to complete this type of registration.'
            }
            registration_info.innerHTML = text;
            registration_code.show();
            break;
        case 'family':
            registration_info.innerHTML = 'The registration fee for a family member is $175.00.';
            if ($('participant_registration_most_recent_grade').value != 'Child Age 3 and Under') {
                family_discount.show();
            }
            break;
        case 'guest':
            text = 'The registration fee for a guest is $175.00. ';
            if (!paid_any_registration_fee) {
                text += 'If you have a registration code please enter it below.'
            }
            registration_info.innerHTML = text;
            registration_code.show();
            break;
        case 'exhibitor':
            registration_info.innerHTML = 'The registration fee for an exhibitor is $300.00 for the first participant from a school and $175.00 for each participant thereafter.';
            exhibitor_housing_details.show();
            exhibitor_details.show();
            update_school_paid_status();
            update_exhibitor_housing();
            arrival_shuttle_price.innerHTML = 'No Charge';
            departure_shuttle_price.innerHTML = 'No Charge';
            break;
        case 'core_staff':
            text = 'There is no registration fee for core staff. ';
            if (!paid_any_registration_fee) {
                text += 'You will need a registration code in order to complete this type of registration.';
            }
            registration_info.innerHTML = text;
            registration_code.show();
            breakfast_monday_price.innerHTML = 'No Charge';
            lunch_monday_price.innerHTML = 'No Charge';
            housing_sunday_price.innerHTML = 'No Charge';
            housing_saturday_price.innerHTML = 'No Charge';
            arrival_shuttle_price.innerHTML = 'No Charge';
            departure_shuttle_price.innerHTML = 'No Charge';
            break;
    }

    /* extra stuff for children under 3 */
    if ($('participant_registration_most_recent_grade').value == 'Child Age 3 and Under') {
        breakfast_monday_price.innerHTML = 'No Charge';
        lunch_monday_price.innerHTML = 'No Charge';
        housing_sunday_price.innerHTML = 'No Charge';
        housing_saturday_price.innerHTML = 'No Charge';
        arrival_shuttle_price.innerHTML = 'No Charge';
        departure_shuttle_price.innerHTML = 'No Charge';
    }

    update_participant_total();
}

/* check for a small child and modify a few things if this is true */
function check_for_small_child() {
    var guardian_field = $('guardian_field');
    var most_recent_grade = $('participant_registration_most_recent_grade');
    
    if (most_recent_grade.value == 'Child Age 3 and Under' || most_recent_grade.value == 'Child Age 4-12') {
        guardian_field.show();
    } else {
        guardian_field.hide();
    }

    /* update registration type (in case we're a child under 3) */
    update_registration_type();
}

/* update the total on the team registration page */
function update_team_total() {
    var divisions = $$('.division');
    var district = $('district');
    var district_registrations = 0;
    var total = 0.00;
    var discount_price = 0.00;

    for (i = 0; i < divisions.length; i++) {
        var division_id = divisions[i].options[divisions[i].selectedIndex].value;
        if (division_id != '') {
            total += division_array[division_id]['price'];

            /* check for a district registration */
            if (division_array[division_id]['type'] == 'district') {
                district_registrations++;
            }
        }
    }

    /* if skip_discount is set we don't bother with checking for discounts
     * this is only active for one user at the moment
     * this is a hack and should be removed when it isn't needed anymore */
    if (district_registrations > 0 && !skip_discount) {
        /* make sure we have a district */
        if (district.options[district.selectedIndex].value != '') {
            /* find the number of already registered district teams */
            var num_registrations = parseInt($('num_registrations').innerHTML);
            /* see if user applies for a discount */
            var discounted_count = 0;
            if (num_registrations >= 2) {
                discounted_count = district_registrations;
            } else if (num_registrations == 1) {
                discounted_count = district_registrations - 1;
            } else {
                discounted_count = district_registrations - 2;
            }
            if (discounted_count < 0) {
                discounted_count = 0;
            }
            discount_price = discounted_count * 15;
            if (discounted_count > 0) {
                var discount_text = 'Your registration applies for a discount. Lucky You!<br/>';
                discount_text += 'After 2 district team registrations, each further registration is subject to a $15 discount.<br/><br/>';
                discount_text += discounted_count + ' team(s) apply for this discount for a total discount of $' + discount_price + '.';
                $('discount').innerHTML = discount_text;
            } else {
                $('discount').innerHTML = '';
            }
        }
    } else {
        /* no district teams selected */
        $('discount').innerHTML = '';
    }
	
    $('total_amount').innerHTML = formatAsMoney(total - discount_price);
    
    $('submit_register').value = 'Submit And Pay';
    $('commit_action').value = 'payment_action';
    if (total == 0) {
        $('submit_register').value = 'Submit Registration';
        $('commit_action').value = 'registration_action';
    }
}

/* format a number as money */
function formatAsMoney(mnt) {
    mnt -= 0;
    mnt = (Math.round(mnt*100))/100;
    var amount = (mnt == Math.floor(mnt)) ? mnt + '.00'
    : ( (mnt*10 == Math.floor(mnt*10)) ?
        mnt + '0' : mnt);
    amount += '';
    x = amount.split('.');
    x1 = x[0];
    x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1))
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
    return "$" + x1 + x2;
}

/* fill in information from users account on official and team registration pages */
function fill_information() {
    $('first_name').value = user_first_name;
    $('last_name').value = user_last_name;
    $('phone').value = user_phone;
    $('email').value = user_email;
    change_select_by_value('district',user_district);
}

/* show a specific travel detail section */
function travel_details(type) {
    if (type == 'flying') {
        $('driving_details').hide();
        $('flying_details').show();
    } else if (type == 'driving') {
        $('flying_details').hide();
        $('driving_details').show();
    } else {
        $('flying_details').hide();
        $('driving_details').hide();
    }

    /* update participant total (we may not be flying anymore) */
    update_participant_total();
}

/* show the correct travel details section when the form is first loaded */
function update_travel_details() {
    if ($('participant_registration_travel_type_flying').checked) {
        travel_details('flying')
    }
    if ($('participant_registration_travel_type_driving').checked) {
        travel_details('driving')
    }
    if ($('participant_registration_travel_type_unknown').checked) {
        travel_details('unknown')
    }
}

/* see if the chosen school has paid their school registration fee */
function check_school_paid_status(school_id) {
    if ($('participant_registration_registration_type').value == 'exhibitor') {
        var school = $('school_paid_' + school_id);

        if (school != null) {
            paid_status = school.value;

            if (paid_status == 'false') {
                $('school_registration_unpaid').show();
                $('school_registration_paid').hide();
            } else {
                $('school_registration_paid').show();
                $('school_registration_unpaid').hide();
            }

            /* update participant total */
            update_participant_total();
        }
    }
}

/* show correct school registration fee details when the form is first loaded */
function update_school_paid_status() {
    check_school_paid_status($('participant_registration_school_id').value);
}

/* toggle views depending on whether an exhibitor needs housing or not */
function exhibitor_housing(type) {
    if (type == 'on_campus') {
        $('housing_details').show();
        $('meals_details').show();
    } else if (type == 'off_campus_with_meals') {
        $('housing_details').hide();
        $('meals_details').show();
    } else if (type == 'off_campus_without_meals') {
        $('housing_details').hide();
        $('meals_details').hide();
    }

    /* update participant total */
    update_participant_total();
}

/* show the correct exhibitor housing sections when the form is first loaded */
function update_exhibitor_housing() {
    if ($('participant_registration_exhibitor_housing_on_campus').checked) {
        exhibitor_housing('on_campus');
    }
    if ($('participant_registration_exhibitor_housing_off_campus_with_meals').checked) {
        exhibitor_housing('off_campus_with_meals');
    }
    if ($('participant_registration_exhibitor_housing_off_campus_without_meals').checked) {
        exhibitor_housing('off_campus_without_meals');
    }
}

/* toggle views depending on whether a participant needs housing or not */
function participant_housing(type) {
    if (type == 'meals_and_housing') {
        $('housing_details').show();
        $('meals_details').show();
    } else if (type == 'meals_only') {
        $('housing_details').hide();
        $('meals_details').show();
    } else {
        $('housing_details').hide();
        $('meals_details').hide();
    }

    /* update participant total */
    update_participant_total();
}

/* show the correct participant housing sections when the form is first loaded */
function update_participant_housing() {
    if ($('participant_registration_participant_housing_meals_and_housing').checked) {
        exhibitor_housing('meals_and_housing');
    }
    if ($('participant_registration_participant_housing_meals_only').checked) {
        exhibitor_housing('meals_only');
    }
    if ($('participant_registration_participant_housing_none').checked) {
        exhibitor_housing('none');
    }
}

/* disable various form elements so they can't be modified */
function disable_elements() {
    if (paid_any_registration_fee) {
        /* do the disabling */
        $('participant_registration_registration_type').disable();
        $('participant_registration_participant_housing_meals_and_housing').disable();
        $('participant_registration_participant_housing_meals_only').disable();
        $('participant_registration_participant_housing_none').disable();
        $('participant_registration_exhibitor_housing_on_campus').disable();
        $('participant_registration_exhibitor_housing_off_campus_with_meals').disable();
        $('participant_registration_exhibitor_housing_off_campus_without_meals').disable();
        $('participant_registration_school_id').disable();

        /* we're actually going to hide the registration code and disable it */
        $('registration_code').hide();
        $('participant_registration_registration_code').disable();
    }

    if (bought_housing_sunday) {
        $('participant_registration_housing_sunday').disable();
        $('participant_registration_housing_sunday').checked = true;
        $('housing_sunday_price').innerHTML = 'Purchased';
    }

    if (bought_housing_saturday) {
        $('participant_registration_housing_saturday').disable();
        $('participant_registration_housing_saturday').checked = true;
        $('housing_saturday_price').innerHTML = 'Purchased';
    }

    if (bought_breakfast_monday) {
        $('participant_registration_breakfast_monday').disable();
        $('participant_registration_breakfast_monday').checked = true;
        $('breakfast_monday_price').innerHTML = 'Purchased';
    }

    if (bought_lunch_monday) {
        $('participant_registration_lunch_monday').disable();
        $('participant_registration_lunch_monday').checked = true;
        $('lunch_monday_price').innerHTML = 'Purchased';
    }

    if (bought_arrival_shuttle) {
        $('participant_registration_need_arrival_shuttle').disable();
        $('participant_registration_need_arrival_shuttle').checked = true;
        $('arrival_shuttle_price').innerHTML = 'Purchased';
    }

    if (bought_departure_shuttle) {
        $('participant_registration_need_departure_shuttle').disable();
        $('participant_registration_need_departure_shuttle').checked = true;
        $('departure_shuttle_price').innerHTML = 'Purchased';
    }
}

/* generate a breakdown of things being paid for */
function generate_breakdown() {
    var breakdown = $('breakdown');
    var registration_type = $('participant_registration_registration_type');
    var registration_type_name = registration_type.options[registration_type.selectedIndex].text;
    var registration_fee = $('participant_registration_registration_fee').value;
    var extras_amount = $('extras_amount').value;
    var extras_fee = $('participant_registration_extras_fee').value;

    var discount_for_registration = registration_discount();
    var discount_for_extras = extras_discount();
    var discount = discount_for_registration + discount_for_extras;

    var text = '';

    /* header */
    text = '<table class="breakdown"><tr><th>Item</th><th>Amount</th></tr>';

    if (registration_type_name != '- Select -' && !paid_full_registration_fee) {
        text += '<tr><td>Registration Fee: ' + registration_type_name + '</td><td style="text-align: right;">' + formatAsMoney(registration_fee / 100) + '</td></tr>';
        if (paid_any_registration_fee) {
            text += '<tr><td>Previous Registration Payments</td><td style="text-align: right;">-' + formatAsMoney(paid_registration_amount) + '</td></tr>';
        }
    }

    if (extras_fee > 0 && !$('skip_extras').checked) {
        text += '<tr><td>Extras</td><td style="text-align: right;">' + formatAsMoney(extras_fee / 100) + '</td></tr>';
    }

    if (discount_for_registration > 0 && !paid_full_registration_fee) {
        text += '<tr><td>Registration Discount</td><td style="text-align: right;">-' + formatAsMoney(discount_for_registration) + '</td></tr>';
    }

    if (extras_fee > 0 && discount_for_extras > 0) {
        if (discount_for_extras > extras_fee / 100) {
            discount_for_extras = extras_fee / 100;
        }
        text += '<tr><td>Extras Discount</td><td style="text-align: right;">-' + formatAsMoney(discount_for_extras) + '</td></tr>';
    }

    text += '<tr><td style="font-weight: bold;">Total</td><td style="font-weight: bold; text-align: right;">' + $('total_amount').innerHTML + '</td></tr>'

    text += '</table>';

    breakdown.innerHTML = text;
}

/* reset our registration code. this happens when changing registration types */
function reset_registration_code() {
    /* only reset the registration code if it's not the first time */
    if (form_is_loaded) {
        $('participant_registration_registration_code').value = '';
    }
}

function check_registration_code() {
    var registration_code = $('participant_registration_registration_code').value;
    if (registration_code == 'CQ9E3TP8') {
        $('participant_housing_details').show();
    } else {
        $('participant_housing_details').hide();
        $('participant_registration_participant_housing_meals_and_housing').checked = true;
        participant_housing('meals_and_housing');
    }
}

function convert_money(number) {
    re = /\.\d\d$/g;
    /* remove digits from the end (these should be zero zero anyways) */
    number = number.replace(re, "");
    re = /^\$|,/g;
    /* remove "$" and "," */
    return number.replace(re, "");
}

function registration_discount() {
    if (new_record) {
        return 0;
    }
    var registration_fee = convert_money($('participant_registration_registration_fee').value);
    var discount = convert_money($('participant_registration_discount').value) * 100;
    var left_to_pay = 0;
    var registration_discount = 0;
    if (discount > 0) {
        left_to_pay = registration_fee - paid_registration_amount * 100;
        if (discount > left_to_pay) {
            registration_discount = left_to_pay;
        } else {
            registration_discount = discount;
        }
    }
    return registration_discount / 100;
}

function extras_discount() {
    if (new_record) {
        return 0;
    }
    var registration_fee = convert_money($('participant_registration_registration_fee').value);
    var discount = convert_money($('participant_registration_discount').value) * 100;
    var left_to_pay = 0;
    var extras_discount = 0;
    if (discount > 0) {
        left_to_pay = registration_fee - paid_registration_amount * 100;
        if (discount > left_to_pay) {
            extras_discount = discount - left_to_pay;
            if (discount > paid_extras_amount * 100) {
                extras_discount = extras_discount - paid_extras_amount * 100;
            } else {
                extras_discount = 0;
            }
        } else {
            extras_discount = 0;
        }
    }
    return extras_discount / 100;
}

function change_select_by_value(dom_id, value) {
    var sb = $(dom_id);
    if (sb != null) {
    	for (var i = 0; i < sb.options.length; i++) {
    		if (sb.options[i].value == value) {
    			if (sb.selectedIndex != i) {
    				sb.selectedIndex = i;
    			}
    			break;
    		}
    	}
    }
}

/* check the division being selected on the team registration page.
 * if it's the regional team selection we show a required code text field */
function check_regional_selection() {
	found = false;
	allNodes = $$("select.division");
	for(i = 0; i < allNodes.length; i++) {
	    division = allNodes[i];
	    if (division.options[division.selectedIndex].value == 5) {
	        found = true;
	    }
	    if (division.options[division.selectedIndex].value == 6) {
            found = true;
        }
	}

	if (found) {
		$('regional_code').show();
	} else {
		$('regional_code').hide();
	}
}
