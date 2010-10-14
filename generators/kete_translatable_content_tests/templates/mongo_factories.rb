#Usings topic types because they are translatable and have multiple fields
Factory.define :topic_type do |t|
  #make the name random. should install faker, but only need this one.
  t.sequence(:name){ |n| "name#{n}"}
  t.description 'spam'
end
