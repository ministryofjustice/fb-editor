FactoryBot.define do
  factory :announcement do
    created_by { build(:user) }
    title { 'News' }
    content { 'This is a [test announcement](https://example.com)' }
    date_from { Date.current }
  end
end
