require 'rails_helper'

describe ReviewsController do
  context 'without authentication' do
    it 'fails' do
      get "/reviews.json"
      expect(response).to be_forbidden
    end
  end

  context 'as a regular user' do
    before { sign_in(Fabricate(:user)) }

    it 'fails' do
      get "/reviews.json"
      expect(response).to be_forbidden
    end
  end

  context 'as a moderator' do
    before { sign_in(Fabricate(:moderator)) }

    it 'returns the queued posts' do
      get "/reviews.json"
      expect(response.status).to eq(200)
    end
  end

  context 'as an admin' do
    before { sign_in(Fabricate(:admin)) }

    it 'returns the queued posts' do
      get "/reviews.json"
      expect(response.status).to eq(200)
    end
  end
end
