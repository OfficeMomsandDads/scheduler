# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build :user }

  it 'has a valid factory' do
    expect(user.valid?).to be(true)
  end

  it 'restricts destroy when announcements exist' do
    user.save!
    ann = create(:announcement, author: user)

    expect { user.destroy }.to change(user.errors, :count).by(1)
    expect { user.reload }.not_to raise_error

    ann.destroy

    expect { user.destroy }.not_to raise_error
    expect { user.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe '.menu' do
    it 'returns a menu' do
      user.save!

      result = described_class.menu

      expect(result).to eql([[user.to_s, user.id]])
    end
  end

  describe '.volunteerable' do
    let!(:volunteer) { create :user, role: 'volunteer' }
    let!(:coordinator) { create :user, role: 'coordinator' }
    let!(:social_worker) { create :user, role: 'social_worker' }

    it 'returns a list of users that are volunteers or coordinators' do
      expect(described_class.volunteerable)
        .to contain_exactly(volunteer, coordinator)
      expect(described_class.volunteerable).not_to include(social_worker)
    end
  end

  describe '{role}?' do
    it 'checks the role' do
      expect(user.volunteer?).to eq(true)
    end
  end

  describe '#at_least_one_office' do
    it 'adds an error if no office is associated' do
      user.offices.clear
      expect(user.valid?).to be(false)
      expect(user.errors.full_messages.first)
        .to eq('At least one office assignment is required')
    end
  end

  describe '#at_least_one_notification_preference' do
    it 'adds an error if no notification preference is selected' do
      user.receive_email_notifications = false
      user.receive_sms_notifications = false
      expect(user.valid?).to be(false)
      expect(user.errors.full_messages.first)
        .to eq('At least one notification preference is required')
    end
  end

  describe '#name' do
    context 'when first & last name are present' do
      it 'returns first & last name' do
        expect(user.name).to eq('Test User')
      end
    end

    context 'when first & last name are nil' do
      it 'returns email address' do
        user.assign_attributes(first_name: nil, last_name: nil)
        expect(user.name).to eq(user.email)
      end
    end
  end

  describe '.exclude_blockouts' do
    subject { described_class.exclude_blockouts(*time.values) }

    let(:time) { { start_at: 1.day.from_now, end_at: 1.day.from_now + 1.hour } }

    context 'when user has no blockouts' do
      let!(:user) { create :user }

      it 'includes the user' do
        expect(subject).to include(user)
      end
    end

    context 'when user has blockouts with overlap' do
      let(:user) { build :user }
      let!(:blockout) { create :blockout, user: user, **time }

      it 'excludes the user' do
        expect(subject).not_to include(user)
      end
    end

    context 'when user has blockouts with no overlap' do
      let(:user) { build :user }
      let!(:blockout) do
        create(:blockout,
               user:     user,
               start_at: 1.hour.from_now,
               end_at:   2.hours.from_now)
      end

      it 'includes the user' do
        expect(subject).to include(user)
      end
    end
  end

  describe '.speaks_language' do
    subject { described_class.speaks_language(language) }

    let(:language) { create :language }

    it 'includes primary and secondary speakers' do
      primary_speaker   = create :user, first_language: language
      secondary_speaker = create :user, second_language: language
      expect(subject).to include(primary_speaker, secondary_speaker)
    end
  end

  describe '.coordinators' do # scope test
    it 'supports named scope coordinators' do
      expect(described_class.coordinators).to all(be_a(described_class))
    end
  end

  describe '.social_workers' do # scope test
    it 'supports named scope social_workers' do
      expect(described_class.limit(3).social_workers)
        .to all(be_a(described_class))
    end
  end

  describe '.volunteers' do # scope test
    it 'supports named scope volunteers' do
      expect(described_class.volunteers).to all(be_a(described_class))
    end
  end

  describe '.schedulers' do # scope test
    it 'supports named scope schedulers' do
      expect(described_class.schedulers).to all(be_a(described_class))
    end
  end

  describe '.with_phone' do # scope test
    it 'supports named scope with_phone' do
      expect(described_class.limit(3).with_phone).to all(be_a(described_class))
    end
  end

  describe '.announceable' do # scope test
    let(:unverified_user) { create(:user, verified: false) }

    it 'supports named scope announceable' do
      user.save!

      result = described_class.announceable

      expect(result).to all(be_a(described_class))
      expect(result).not_to include(unverified_user)
      expect(result).to include(user)
    end
  end

  context 'when reporting' do
    let(:lang1) { create(:language, name: 'Lang1') }
    let(:lang2) { create(:language, name: 'Lang2') }
    let(:lang3) { create(:language, name: 'Lang3') }
    let(:race1) { create(:race, name: 'Race1') }
    let(:race2) { create(:race, name: 'Race2') }
    let(:race3) { create(:race, name: 'Race3') }

    let(:wa_address1) { build(:address, :wa) }
    let(:wa_address2) { build(:address, :wa, county: 'Lewis') }
    let(:wa_office1) do
      create(:wa_office, address: wa_address1).tap { wa_address1.save! }
    end
    let(:wa_office2) do
      create(:wa_office, address: wa_address2).tap { wa_address2.save! }
    end
    let(:or_office) { create(:or_office) }

    let(:wa_sw1) { create(:user, role: 'social_worker', offices: [wa_office1]) }
    let(:wa_sw2) { create(:user, role: 'social_worker', offices: [wa_office2]) }
    let(:or_sw) { create(:user, role: 'social_worker', offices: [or_office]) }
    let(:admin) { create :user, role: 'admin' }
    let(:coordinator) { create :user, role: 'coordinator' }
    let(:wa_user1) do
      create(:user,
             offices:         [wa_office1],
             race:            race1,
             first_language:  lang1,
             second_language: lang2)
    end
    let(:wa_user2) do
      create(:user, offices: [wa_office2], race: race1, first_language: lang2)
    end
    let(:wa_user3) do
      create(:user,
             offices:         [wa_office2],
             race:            race2,
             first_language:  lang3,
             second_language: lang2)
    end
    let(:or_user) do
      create(:user, offices: [or_office], race: race3, first_language: lang2)
    end

    let(:wa_need1) do
      create(:need_with_shifts,
             user:               wa_sw1,
             children_count:     1,
             expected_duration:  60,
             office:             wa_office1,
             preferred_language: lang1,
             start_at: Time.zone.now.yesterday)
    end
    let(:wa_need2) do
      create(:need_with_shifts,
             user:               wa_sw2,
             children_count:     2,
             expected_duration:  240,
             office:             wa_office2,
             preferred_language: lang1,
             start_at: Time.zone.now.yesterday)
    end
    let(:wa_need3) do
      create(:need_with_shifts,
             user:               wa_sw2,
             children_count:     7,
             expected_duration:  120,
             office:             wa_office2,
             preferred_language: lang1,
             start_at: Time.zone.now.yesterday)
    end
    let!(:unmet_wa_need) do
      create(:need_with_shifts,
             user:               wa_sw2,
             children_count:     2,
             expected_duration:  120,
             office:             wa_office2,
             preferred_language: lang3,
             start_at: Time.zone.now.yesterday)
    end
    let(:or_need) do
      create(:need_with_shifts,
             user:               or_sw,
             children_count:     3,
             expected_duration:  120,
             office:             or_office,
             preferred_language: lang2,
             start_at: Time.zone.now.yesterday)
    end

    before do
      or_need.shifts.first.update(user: or_user)
      wa_need1.shifts.first.update(user: wa_user1)
      wa_need2.shifts.find_each { |s| s.update!(user_id: wa_user2.id) }
      wa_need3.shifts.first.update(user: wa_user3)
      wa_need3.shifts.last.update(user: wa_user2)
    end

    describe '.total_volunteer_hours_by_user' do
      let(:volunteer) { create :user, role: 'volunteer' }

      it 'raises an error when a user is neither an admin or coordinator' do
        expect { described_class.total_volunteer_hours_by_user(volunteer, nil, nil) }
          .to raise_error(RuntimeError, "#{volunteer} does not have the proper permissions")
      end

      context 'as an admin' do
        it 'returns the total volunteer hours grouped by office' do
          expect(described_class.total_volunteer_hours_by_user(admin, nil, nil))
            .to eql([or_user.id, or_user.first_name, or_user.last_name] => 1.0, [wa_user1.id, wa_user1.first_name, wa_user1.last_name] => 1.0, [wa_user2.id, wa_user2.first_name, wa_user2.last_name] => 5.0, [wa_user3.id, wa_user3.first_name, wa_user3.last_name] => 1.0)
        end
      end

      context 'as a coordinator' do
        before do
          coordinator.offices << or_office
        end

        it 'returns data scoped by users offices' do
          expect(described_class.total_volunteer_hours_by_user(coordinator, nil, nil))
            .to eql([or_user.id, or_user.first_name, or_user.last_name] => 1)
        end
      end

      context 'with a date range' do
        it 'returns the total hours filtered by dates' do
          expect(described_class.total_volunteer_hours_by_user(admin, 'Jan 1, 2010', 'Feb 2, 2030'))
            .to eql([or_user.id, or_user.first_name, or_user.last_name] => 1.0, [wa_user1.id, wa_user1.first_name, wa_user1.last_name] => 1.0, [wa_user2.id, wa_user2.first_name, wa_user2.last_name] => 5.0, [wa_user3.id, wa_user3.first_name, wa_user3.last_name] => 1.0)

          expect(described_class.total_volunteer_hours_by_user(admin, nil, (Time.zone.now - 2.days).strftime('%b %e, %Y')))
            .to be_empty

          expect(described_class.total_volunteer_hours_by_user(admin, 'Jan 1, 2010', nil))
            .to eql([or_user.id, or_user.first_name, or_user.last_name] => 1.0, [wa_user1.id, wa_user1.first_name, wa_user1.last_name] => 1.0, [wa_user2.id, wa_user2.first_name, wa_user2.last_name] => 5.0, [wa_user3.id, wa_user3.first_name, wa_user3.last_name] => 1.0)
        end

        it 'does not use office\'s needs that are out of range' do
          or_need.update(start_at: 1.month.from_now)

          expect(described_class.total_volunteer_hours_by_user(admin, nil, Time.zone.now.strftime('%b %e, %Y')))
            .to eql([wa_user1.id, wa_user1.first_name, wa_user1.last_name] => 1.0, [wa_user2.id, wa_user2.first_name, wa_user2.last_name] => 5.0, [wa_user3.id, wa_user3.first_name, wa_user3.last_name] => 1.0)
        end
      end
    end

    describe '.total_volunteers_by_spoken_language' do
      let(:volunteer) { create :user, role: 'volunteer' }
      let!(:need) { create :need, user: volunteer, start_at: Time.zone.now.yesterday }

      it 'raises an error when a user is neither an admin or coordinator' do
        expect { described_class.total_volunteers_by_spoken_language(volunteer, nil, nil) }
          .to raise_error(RuntimeError, "#{volunteer} does not have the proper permissions")
      end

      context 'as an admin' do
        it 'returns the total volunteer hours grouped by office' do
          expect(described_class.total_volunteers_by_spoken_language(admin, nil, nil))
            .to eql('English' => 1)
        end
      end

      context 'as a coordinator' do
        before do
          coordinator.offices << or_office
        end

        it 'returns data scoped by users offices' do
          expect(described_class.total_volunteers_by_spoken_language(coordinator, nil, nil))
            .to be_empty
        end
      end

      context 'with a date range' do
        it 'returns the total hours filtered by dates' do
          expect(described_class.total_volunteers_by_spoken_language(admin, 'Jan 1, 2010', 'Feb 2, 2030'))
            .to eql('English' => 1)

          expect(described_class.total_volunteers_by_spoken_language(admin, nil, (Time.zone.now - 2.days).strftime('%b %e, %Y')))
            .to be_empty

          expect(described_class.total_volunteers_by_spoken_language(admin, 'Jan 1, 2010', nil))
            .to eql('English' => 1)
        end

        it 'does not use office\'s needs that are out of range' do
          or_need.update(start_at: 1.month.from_now)

          expect(described_class.total_volunteers_by_spoken_language(admin, nil, Time.zone.now.strftime('%b %e, %Y')))
            .to eql('English' => 1)
        end
      end
    end
  end

  describe '#at_least_one_age_range' do
    it 'at_least_one_age_range' do
      user = described_class.new

      user.at_least_one_age_range

      expect(user.errors[:base])
        .to include('At least one age range selection is required')
    end
  end

  describe '#scheduler?' do
    it 'scheduler?' do
      result = user.scheduler?

      expect(result).to be false
    end
  end

  describe '#notifiable?' do
    it 'returns false if user does not have a phone' do
      user.phone = nil

      result = user.notifiable?

      expect(result).to be false
    end

    it 'returns true if user has a phone' do
      result = user.notifiable?

      expect(result).to be true
    end
  end

  describe '#volunteerable?' do
    it 'volunteerable?' do
      user   = described_class.new
      result = user.volunteerable?

      expect(result).to be false
    end
  end

  describe '.notifiable' do # scope test
    it 'supports named scope notifiable' do
      result = described_class.notifiable

      expect(result).to all(be_a(described_class))
    end

    it 'does not include deactivated users' do
      user = create :user, deactivated: true

      expect(User.notifiable).not_to include(user)
    end
  end

  describe '#to_s' do
    before do
      user.first_name = 'Santa'
      user.last_name  = 'Claus'
    end

    it 'to_s' do
      result = user.to_s

      expect(result).to eql('Santa Claus')
    end
  end

  describe '#role_display' do
    it 'returns a string' do
      expect(user.role_display).to be_a_kind_of(String)
    end

    it 'return the correct string' do
      user.role = 'social_worker'
      expect(user.role_display).to eq('Child Welfare Worker')
    end

    context 'when the translation is not found' do
      it 'return the titleize titleized' do
        user.role = 'this_role_does_not_exist'
        expect(user.role_display).to eq('This Role Does Not Exist')
      end
    end
  end

  describe 'before_save :check_phone_verification' do
    let(:user) { create(:user, verified: true) }

    it 'unverifies a user when their phone number changes' do
      expect(user.verified?).to be true
      user.save!
      expect(user.verified?).to be true
      user.phone = '4155551212'
      user.save!
      expect(user.verified?).to be false
    end
  end

  describe '#e164_phone' do
    it 'returns phone number in E.164 format' do
      expect(user.phone).to eq('(360) 610-7089')
      expect(user.e164_phone).to eq('+13606107089')
    end
  end

  describe '#office_notification_ids' do
    let!(:office2) { create(:office) }
    let!(:office_user2) do
      create(:office_user, user: user, office: office2, send_notifications: true)
    end

    it 'returns office ids where office_user has send_notifications set to true' do
      expect(user.office_notification_ids).to eq([office2.id])
    end
  end

  describe '#office_notification_ids=' do
    let(:office2) { create(:office) }
    let(:office_user1) { user.office_users.first }
    let!(:office_user2) { create(:office_user, user: user, office: office2) }

    it 'sets send_notifications to true for office_users with passed office ids' do
      expect(office_user1.send_notifications?).to be false
      expect(office_user2.send_notifications?).to be false
      user.office_notification_ids = [office2.id.to_s]
      expect(office_user1.reload.send_notifications?).to be false
      expect(office_user2.reload.send_notifications?).to be true
    end
  end
end
