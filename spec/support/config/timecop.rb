require 'timecop'

RSpec.configure do |config|
  config.before(:each) do
    Timecop.freeze(Time.local(2013))
  end

  config.after(:each) do
    Timecop.return
  end
end
