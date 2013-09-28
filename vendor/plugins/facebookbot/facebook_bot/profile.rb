#Handles all profile-related functionality.
module FacebookProfile
  #This method will update your profile information.
  #Type is the type of profile update you're doing. It's a string.
  #Here's the list of 'em:: basic, contact, personal, education, work, courses.
  #Params is a Hash. Which keys and values you give it depend on the type.
  #The values of the Hash are arrays of information you would like
  #inserted into your profile. The keys can be one or more of the following:
  #==Basic Profile Updates
  #sex::                  0 for no sex listed, 1 for female, 2 for male.
  #meeting_sex1::         Interested in meeting women? 'on' or nil.
  #meeting_sex2::         Interested in meeting men? 'on' or nil.
  #relationship::         '1' if Single, '2' if In a Relationship,
  #                       '3' if In an Open Relationship, '4' if Married,
  #                       '5' if Engaged, '6' if It's Complicated.
  #meeting_for1::         Looking for friendship? 'on' or nil.
  #meeting_for2::         Looking for dating? 'on' or nil.
  #meeting_for3::         Looking for a relationship? 'on' or nil.
  #meeting_for4::         Looking for random play? 'on' or nil.
  #meeting_for5::         Looking for whatever you can get? 'on' or nil.
  #birthday_month::       -1 for no month selected, otherwise '1' through '12'
  #birthday_day::         '1' through '31'
  #birthday_visibility::  '1' if 'Show my full birthday',
  #                       '2' if 'Show only month & day',
  #                       '3' if 'Dont show my birthday'
  #hometown::             String
  #hometown_region::      Integer, See State Chart. This is only if the
  #                       hometown_country is United States (398), 
  #                       otherwise don't set a hometown_region.
  #hometown_country::     Integer, See Country Chart.
  #political::            '0' for none, '1' if Very Liberal, '2' if Liberal,
  #                       '3' if Moderate, '4' if Conservative, 
  #                       '5' if Very Conservative, '6' if Apathetic,
  #                       '7' if Libertarian, '8' if Other
  #religion_name::        String
  #Example:
  #  fb.add_profile_info('basic',{'meeting_sex1' => 'on',
  #                               'meeting_sex2' => 'on',
  #                               'relationship' => rand(6)+1,
  #                               'meeting_for1' => 'on',
  #                               'meeting_for2' => 'on',
  #                               'meeting_for3' => 'on',
  #                               'meeting_for4' => 'on',
  #                               'meeting_for5' => 'on',
  #                               'birthday_month' => rand(12)+1,
  #                               'birthday_day' => rand(28)+1,
  #                               'hometown' => random.item('CITY'),
  #                               'hometown_region' => rand(50)+1,
  #                               'hometown_country' => 398,
  #                               'political' => rand(9),
  #                               'religion_name' => random.item('RELIGION')}.random_pairs)
  #==Contact Profile Updates
  #
  #sn_0::                 String. This is for editing existing screennames.
  #                       Can also do sn_1, sn_2, etc. It won't accept
  #                       a sn_X without a corresponding sn_serv_X.
  #new_sn_0::             String. This is for adding screennames. Can also do
  #                       new_sn_1, new_sn_2, new_sn_3, new_sn_4. It won't
  #                       accept a new_sn_X without a corresponding sn_serv_X.
  #sn_serv_0::            '1' if AIM, '4' if Google Talk, '6' if Skype,
  #                       '5' if Windows Live,  '7' if Yahoo, '2' if Gadu-Gadu,
  #                       '3' if ICQ. Can also do sn_serv_1, sn_serv_2,
  #                       sn_serv_3, sn_serv_4.
  #mobile::               String
  #other_phone::          String
  #school_mailbox::       String
  #residence_name::       String
  #room::                 String
  #address::              String
  #city::                 String
  #region::               Integer, See State Chart.
  #country::              Integer, See Country Chart.
  #zip::                  String
  #website::              String, can be more than one separated by \n
  #Examples:
  #  fb.add_profile_info('contact', {'mobile' => random.phone_number,
  #                                 'other_phone' => random.phone_number,
  #                                 'school_mailbox' => rand(4030),
  #                                 'room' => rand(32),
  #                                 'city' => random.item('CITY'),
  #                                 'region' => rand(50)+1,
  #                                 'zip' => random.zip_code}.random_pairs(5,10))
  #
  #  fb.add_profile_info('contact',{'new_sn_0' => 'XXXstunta43',
  #                               'sn_serv_0' => rand(7)+1})
  #
  #==Personal Profile Updates
  #
  #NOTE: For this one, the keys provided are merged randomly with
  #existing information via comma-separation. Quote and about_me
  #are overwritten, not appended to.
  #
  #clubs::                Array
  #interests::            Array
  #music::                Array
  #tv::                   Array
  #movies::               Array
  #books::                Array
  #quote::                String
  #about_me::             String
  #Examples:
  #  fb.add_profile_info 'personal', {'clubs' => ['running', 'talking'],
  #                                   'interests' => ['eating'],
  #                                   'quote' => 'i love FacebookBot'}
  #
  #  fb.add_profile_info('personal',{'interests' => random.item('INTEREST'),
  #                                   'music' => random.item('BAND'),
  #                                   'tv' => random.item('TVSHOW'),
  #                                   'movies' => random.item('MOVIE'),
  #                                   'books' => random.item('BOOK'),
  #                                   'clubs' => random.item('ACTIVITY'),
  #                                   'quote' => random.item('QUOTE')}.random_pair)
  #
  #==Education Profile Updates
  #
  #This one is a little funky. Because you can choose up to five schools
  #you've attended, this allows for a whole lot of query string options.
  #Below, you'll see I put in X's where one of the numbers 0, 1, 2, 3, or 4
  #should go. If you want to show you've attended more than one school,
  #just pass keys education_1_school_name, education_2_school_name, etc. etc.
  #
  #education_X_school_name::  String. X should be replaced with 0-4.
  #education_X_year::         String or Integer. X should be replaced with 0-4.
  #education_X_school_type::  '' for nothing, '1' for College,
  #                           '2' for Graduate School.
  #                           X should be replaced with 0-4.
  #education_X_concentrationY_name::  String. You should replace X with 0-4
  #                                   and Y with 0-2. You can only select
  #                                   up to three concentrations per school.
  #highschool::               String
  #
  #==State Chart
  #
  #These state codes are used throughout facebook, I guess:
  #Alabama:: 1
  #Alaska:: 2
  #Arizona:: 3
  #Arkansas:: 4
  #California:: 5
  #Colorado:: 6
  #Connecticut:: 7
  #Delaware:: 8
  #District Of Columbia:: 9
  #Florida:: 10
  #Georgia:: 11
  #Guam:: 65
  #Hawaii:: 12
  #Idaho:: 13
  #Illinois:: 14
  #Indiana:: 15
  #Iowa:: 16
  #Kansas:: 17
  #Kentucky:: 18
  #Louisiana:: 19
  #Maine:: 20
  #Maryland:: 21
  #Massachusetts:: 22
  #Michigan:: 23
  #Minnesota:: 24
  #Mississippi:: 25
  #Missouri:: 26
  #Montana:: 39
  #Nebraska:: 40
  #Nevada:: 41
  #New Hampshire:: 42
  #New Jersey:: 43
  #New Mexico:: 44
  #New York:: 45
  #North Carolina:: 46
  #North Dakota:: 47
  #Ohio:: 48
  #Oklahoma:: 49
  #Oregon:: 50
  #Pennsylvania:: 51
  #Puerto Rico:: 52
  #Rhode Island:: 53
  #South Carolina:: 54
  #South Dakota:: 55
  #Tennessee:: 56
  #Texas:: 57
  #Utah:: 58
  #Vermont:: 59
  #Virginia:: 60
  #Washington:: 61
  #West Virginia:: 62
  #Wisconsin:: 63
  #Wyoming:: 64
  #
  #==Country Chart
  #
  #Here's a helpful country chart:
  #United States:: 398
  #Canada:: 326
  #England:: 327
  #Scotland:: 228
  #Wales:: 288
  #Abuja:: 302
  #Afghanistan:: 233
  #Akrotiri:: 399
  #Albania:: 320
  #Algeria:: 400
  #American Samoa:: 221
  #Andorra:: 401
  #Angola:: 234
  #Anguilla:: 402
  #Antarctica:: 403
  #Antigua:: 278
  #APO:: 190
  #Argentina:: 135
  #Armenia:: 404
  #Aruba:: 284
  #Ashmore and Cartier Islands:: 405
  #Australia:: 111
  #Austria:: 81
  #Azerbaijan:: 213
  #Bahrain:: 174
  #Bangladesh:: 165
  #Barbados:: 208
  #Belarus:: 112
  #Belgium:: 72
  #Belize:: 176
  #Benin:: 406
  #Bermuda:: 181
  #Bhutan:: 407
  #Bolivia:: 132
  #Bosnia and Herzegovina:: 236
  #Botswana:: 177
  #Brazil:: 122
  #British Virgin Islands:: 290
  #Brunei:: 144
  #Bulgaria:: 369
  #Burkina Faso:: 235
  #Burundi:: 385
  #Cambodia:: 188
  #Cameroon:: 209
  #Cape Verde:: 215
  #Cayman Islands:: 211
  #Côte d'Ivoire:: 470
  #Central African Republic:: 408
  #Chad:: 409
  #Channel Islands:: 468
  #Chile:: 118
  #China:: 91
  #Colombia:: 310
  #Comoros:: 410
  #Costa Rica:: 162
  #Croatia:: 297
  #Cuba:: 227
  #Curacao:: 102
  #Cyprus:: 106
  #Czech Republic:: 175
  #Democratic Republic Congo:: 411
  #Denmark:: 99
  #Djibouti:: 412
  #Dominica:: 287
  #Dominican Republic:: 145
  #East Timor:: 413
  #Ecuador:: 160
  #Egypt:: 121
  #El Salvador:: 195
  #Equatorial Guinea:: 414
  #Eritrea:: 395
  #Estonia:: 466
  #Ethiopia:: 168
  #Falkland Islands:: 416
  #Faroe Islands:: 417
  #Federated States of Micronesia:: 464
  #Fiji:: 418
  #Finland:: 200
  #France:: 84
  #French Guiana:: 419
  #French Polynesia:: 420
  #Gabon:: 312
  #Georgia:: 368
  #Germany:: 79
  #Ghana:: 85
  #Gibraltar:: 422
  #Greece:: 128
  #Greenland:: 423
  #Grenada:: 390
  #Guam:: 65
  #Guatemala:: 138
  #Guinea:: 424
  #Guinea-Bissau:: 425
  #Guyana:: 170
  #Haiti:: 226
  #Honduras:: 169
  #Hong Kong:: 69
  #Hungary:: 153
  #Iceland:: 285
  #India:: 68
  #Indonesia:: 166
  #Iran:: 232
  #Iraq:: 231
  #Ireland:: 178
  #Isle Of Man:: 469
  #Israel:: 136
  #Italy:: 86
  #Jamaica:: 77
  #Japan:: 75
  #Jordan:: 146
  #Kazakhstan:: 87
  #Kenya:: 67
  #Kiribati:: 426
  #Kuwait:: 110
  #Kyrgyzstan:: 427
  #Laos:: 472
  #Latvia:: 281
  #Lebanon:: 98
  #Lesotho:: 428
  #Liberia:: 429
  #Libya:: 430
  #Liechtenstein:: 431
  #Lithuania:: 271
  #Luxembourg:: 183
  #Macau:: 432
  #Macedonia:: 197
  #Madagascar:: 433
  #Malawi:: 251
  #Malaysia:: 103
  #Maldives:: 434
  #Mali:: 435
  #Malta:: 436
  #Marshall Islands:: 437
  #Martinique:: 438
  #Mauritania:: 439
  #Mauritius:: 143
  #Mexico:: 109
  #Moldova:: 294
  #Monaco:: 204
  #Mongolia:: 440
  #Montenegro:: 473
  #Morocco:: 74
  #Mozambique:: 441
  #Myanmar:: 94
  #Namibia:: 229
  #Nauru:: 442
  #Nepal:: 120
  #Netherlands:: 147
  #Netherlands Antilles:: 372
  #New Zealand:: 90
  #Nicaragua:: 105
  #Niger:: 393
  #Nigeria:: 149
  #North Korea:: 444
  #Northern Ireland:: 217
  #Northern Mariana Islands:: 182
  #Norway:: 76
  #Oman:: 164
  #Pakistan:: 141
  #Palau:: 358
  #Palestine:: 421
  #Panama:: 124
  #Papua New Guinea:: 311
  #Paraguay:: 203
  #Peru:: 95
  #Philippines:: 83
  #Poland:: 89
  #Portugal:: 142
  #Qatar:: 154
  #Republic of the Congo:: 445
  #Romania:: 119
  #Russia:: 78
  #Rwanda:: 446
  #Saint Kitts and Nevis:: 447
  #Saint Vincent and the Grenadines:: 448
  #Samoa:: 449
  #San Marino:: 450
  #Sao Tome and Principe:: 451
  #Saudi Arabia:: 104
  #Senegal:: 201
  #Serbia:: 286
  #Seychelles:: 452
  #Sierra Leone:: 453
  #Singapore:: 70
  #Slovakia:: 212
  #Slovenia:: 295
  #Solomon Islands:: 454
  #Somalia:: 455
  #South Africa:: 161
  #South Korea:: 88
  #Spain:: 114
  #Sri Lanka:: 158
  #St. Lucia:: 364
  #Sudan:: 299
  #Suriname:: 456
  #Swaziland:: 194
  #Sweden:: 148
  #Switzerland:: 80
  #Syria:: 163
  #Taiwan:: 97
  #Tajikistan:: 397
  #Tanzania:: 155
  #Thailand:: 73
  #The Bahamas:: 130
  #The Gambia:: 303
  #Togo:: 457
  #Tonga:: 458
  #Trinidad and Tobago:: 167
  #Tunisia:: 139
  #Turkey:: 82
  #Turkmenistan:: 459
  #Tuvalu:: 460
  #Uganda:: 202
  #Ukraine:: 219
  #United Arab Emirates:: 123
  #Uruguay:: 159
  #US Virgin Islands:: 131
  #Uzbekistan:: 113
  #Vanuatu:: 461
  #Vatican City:: 462
  #Venezuela:: 100
  #Vietnam:: 186
  #Western Sahara:: 463
  #Yemen:: 206
  #Zambia:: 192
  #Zimbabwe:: 151
  def add_profile_info type, params
    login
    
    updated = params.keys

    id_info = get_profile_info type
    
    #some little nice fixes for people like you
    if type == 'contact'
      (0..4).each do |x|
        #are we trying to give sn's when we dont have them? gotta add new_!
        if params.has_key?("sn_#{x}") && !id_info.has_key?("sn_#{x}")
          params["new_sn_#{x}"] = params["sn_#{x}"]
        end
      end
    end
    
    # merge randomly id_info with params
    id_info.each_key do |id|
      if params[id]
        params[id] = [params[id]] if params[id].class != Array # convert to array if necessary
      
        #the only comma separated ones are personal, except for quote and about_me
        if type == 'personal' && id != 'quote' && id != 'about_me'
          id_info[id] = id_info[id][0].split(", ").merge_randomly(params[id])
        else
          id_info[id] = params[id] #overwrite
        end
      end
    end
    
    #build the query string
    query = build_profile_query_string type, id_info
    
    #post it!
    req = @http.post2("/editprofile.php?#{type}", query, @opts[:headers])
    
    if req.code.to_i == 200
      puts "Successfully updated '#{updated.join("','")}' in #{type} profile."
    else
      log req
    end
  end
  
  #Removes profile information. Takes the same arguments as add_profile_info,
  #more or less. You pass it the type (one of: basic, contact, personal,
  #education, work, courses) and an array of the items you want removed from
  #your profile.
  #  fb.remove_profile_info 'basic', ['meeting_sex1','meeting_for1']
  def remove_profile_info type, keys
    login
    updated = keys
    id_info = get_profile_info type
    
    #remove the keys specified
    id_info.delete_if {|id, value| keys.include?(id) }
    
    #build the query string
    query = build_profile_query_string type, id_info
    
    #post it!
    req = @http.post2("/editprofile.php?#{type}", query, @opts[:headers])
    if req.code.to_i == 200
      puts "Successfully removed '#{updated.join("','")}' from #{type} profile."
    else
      log req
    end
  end
  
  #Get all the profile information of given type. This works by grabbing
  #all the form information. easy peasy lemon squeezy!
  #Supported types:: basic, contact, personal, education, work, courses.
  def get_profile_info type
    login
    elements = {}
    doc = hpricot_get_url "/editprofile.php?#{type}"
    
    #search for all form elements on the page
    doc.search("//form[@id='profile_form']//input[@name!='']") do |input|
      name = input.attributes['name']
      elements[name] = [] if elements[name].nil?
      #checked checkbox?
      if input.attributes.include?('checked')
        elements[name] << 'on'
      elsif input.attributes['value'] #regular ol' input box
        elements[name] << input.attributes['value']
      end
    end
    
    doc.search("//form[@id='profile_form']//select") do |select|
      name = select.attributes['name']
      elements[name] = []

      #facebook uses javascript to fill in the state, for some stupid reason.
      if name =~ /region/ && doc.to_s =~ /editor_two_level_set_subselector\("two_level_hometown_region", "(\d+)"\);/
        elements[name] << $1
      else
        select.search("option") do |option|
          elements[name] << option.attributes['value'] if option.attributes.include?('selected')
        end
      end
    end
    
    doc.search("//form[@id='profile_form']//textarea") do |textarea|
      elements[textarea.attributes['name']] = [textarea.inner_html]
    end
    
    elements
  end
  
  private
  
  #Builds a query string for submitting profile information, given a type
  #and the id_info hash. Used internally only, I can't see a reason you'd
  #want to use this function.
  def build_profile_query_string type, id_info
    query = []
    id_info.each do |key,values|
      #if we have more than one value for personal, comma separate
      if type == 'personal' && values.length > 1
        query << "#{key}=#{values.join(', ')}"
      elsif values.length > 1 # we have an querystring array
        values.each do |v|
          query << "#{key}[]=#{v}"
        end
      else # standard ol' stuff
        query << "#{key}=#{values[0]}"
      end
    end
    query.join("&")
  end
end
