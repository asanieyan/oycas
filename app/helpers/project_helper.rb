module ProjectHelper

#  def get_guid_by_student_id(student_id)
#    temp = Student.find(student_id).guid rescue temp = nil
#    return temp
#  end
#
#  def get_name_by_student_id(student_id)
#    temp = Student.find(student_id) rescue temp = nil
#    if temp != nil then
#      return temp.first_name.to_s + " " + temp.last_name.to_s
#    else
#      return nil
#    end
#  end
#
#  def get_name_by_guid(guid)
#    student = Student.find(:first, :conditions => ['guid=?',guid])
#    return student.first_name + " " + student.last_name
#  end

  def format_datetime(dateobj)
    if dateobj != nil then
      return dateobj.strftime("%I:%M%p").downcase + " " + dateobj.strftime("%B %d, %Y")
    else
      return nil
    end
  end

  def format_datetime_notime(dateobj)
    if dateobj != nil then
      return dateobj.strftime("%B %d, %Y")
    else
      return nil
    end
  end


def last_of_month( arg = Time.now )
    year = ( arg.is_a? Fixnum ) ? Time.now.year : arg.year
    mon  = ( arg.is_a? Fixnum ) ? arg : ( arg.mon rescue Time.now.mon )
    
    raise ArgumentError unless mon.between?( 1, 12 )

    begin; Date.new year, mon, mday ||= 31
    rescue ArgumentError; mday -= 1; retry
    end
  end

end
