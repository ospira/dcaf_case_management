require 'test_helper'

class FulfillmentTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @pt_1 = create :patient, name: 'Susan Smith'
    @fulfillment = @pt_1.fulfillment
    @fulfillment.created_by = @user
    @fulfillment.reload
  end

  describe 'validations' do
    it 'should be able to build an object' do
      assert @fulfillment.valid?
    end

    %w(created_by).each do |field|
      it "should enforce presence of #{field}" do
        @fulfillment[field.to_sym] = nil
        refute @fulfillment.valid?
      end
    end
  end

  describe 'mongoid attachments' do
    it 'should have timestamps from Mongoid::Timestamps' do
      [:created_at, :updated_at].each do |field|
        assert @fulfillment.respond_to? field
        assert @fulfillment[field]
      end
    end

    it 'should respond to history methods' do
      assert @fulfillment.respond_to? :history_tracks
      assert @fulfillment.history_tracks.count > 0
    end

    it 'should have accessible userstamp methods' do
      assert @fulfillment.respond_to? :created_by
      assert @fulfillment.created_by
    end
  end

  describe 'methods' do
    it 'should cleanly display gestation at procedure date if present' do
      @fulfillment.gestation_at_procedure = nil
      refute @fulfillment.gestation_at_procedure_display

      @fulfillment.gestation_at_procedure = '7'
      assert_equal '7 weeks', @fulfillment.gestation_at_procedure_display
    end
  end
end
