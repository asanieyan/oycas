require File.dirname(__FILE__)+"/../lib/contacts"

login = ARGV[0]
password = ARGV[1]

p Contacts::Gmail.new("asanieyan", "mostafah").contacts.inspect
##
#p Contacts.new(:gmail, login, password).contacts
##
#p Contacts.new("gmail", login, password).contacts
##
#Contacts.guess(login, password).contacts
