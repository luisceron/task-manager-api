require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user) { build(:user) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to validate_confirmation_of(:password) }
  it { is_expected.to allow_value('luis@ceron.com').for(:email) }
  it { is_expected.to validate_uniqueness_of(:auth_token) }

  describe '#info' do
    it 'returns email, created_at and a token' do
      user.save!
      allow(Devise).to receive(:friendly_token).and_return('abc123xyzTOKEN')

      expect(user.info).to eq("#{user.email} - #{user.created_at} - Token: #{Devise.friendly_token}")
    end
  end

  describe '#generate_authentication_token!' do
    it 'generates a unique auth token' do
      allow(Devise).to receive(:friendly_token).and_return('abc123xyzTOKEN')

      user.generate_authentication_token!

      expect(user.auth_token).to eq(Devise.friendly_token)
    end

    it 'generates another auth token when the current auth token already has been taken' do
      existing_user = create(:user, auth_token: 'abc123tokenxyz')
      allow(Devise).to receive(:friendly_token).and_return('abc123tokenxyz', 'abcXYZ123456789')

      user.generate_authentication_token!

      expect(user.auth_token).to_not eq('abc123tokenxyz')
      expect(user.auth_token).to     eq('abcXYZ123456789')
    end
  end

end
