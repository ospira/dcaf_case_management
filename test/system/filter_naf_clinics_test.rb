require 'application_system_test_case'

# Confirm that the naf filter checkbox works
class FilterNafClinicsTest < ApplicationSystemTestCase
  before do
    @user = create :user, role: :cm
    @naf_clinic = create :clinic, name: 'NAF Accepted', accepts_naf: true
    @nonnaf_clinic = create :clinic, name: 'No NAF here', accepts_naf: false
    @patient = create :patient
    log_in_as @user
    visit edit_patient_path @patient
    has_text? 'First and last name' # wait until page loads
    click_link 'Abortion Information'
  end

  describe 'filtering to just NAF clinics' do
    it 'should filter to only NAF clinics when box is checked' do
      assert has_select? 'patient_clinic_id', with_options: [@naf_clinic.name,
                                                             @nonnaf_clinic.name]

      check 'Enable only NAF clinics'
      wait_for_ajax
      options_with_filter = find('#patient_clinic_id').all('option')
                                                      .map { |opt| { name: opt.text, disabled: opt['disabled'] } }

      assert_equal 'true', options_with_filter.find { |x| x[:name] == @nonnaf_clinic.name }[:disabled]
      assert_equal 'false', options_with_filter.find { |x| x[:name] == @naf_clinic.name }[:disabled]

      # try to select and watch it not work
      select @nonnaf_clinic.name, from: 'patient_clinic_id'
      assert_equal '', find('#patient_clinic_id').value
    end
  end
end
