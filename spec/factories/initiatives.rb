# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :initiative do
    title "MyText"
    content "MyText"
    erreicht "MyText"
    getan "MyText"
    user
    lat  50.75
    long 6.13
    visible true

    after(:build) do |model|
      model.categories << FactoryGirl.build(:category)
    end
  end
end
