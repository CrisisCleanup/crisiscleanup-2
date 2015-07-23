require 'rails_helper'
require 'spec_helper'

RSpec.describe Form, type: :model do
    describe "associations" do
      it { should belong_to :legacy_event }
    end

end