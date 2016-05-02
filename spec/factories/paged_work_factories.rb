FactoryGirl.define do

  #Create a paged_work object
  factory :paged_work, class: PagedWork do
    title ["Paged Work Object"]
    creator ["Factory Girl"]
    depositor "user@example.com"
    edit_users ["user@example.com"]
    #author "Factory Girl"
  end

end
