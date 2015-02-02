ENV['RACK_ENV'] = 'test'

require 'spec_helper'
require_relative '../stuper-bowl'
require 'rspec'
require 'rack/test'

describe 'Stuper Bowl App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  let(:score_feed) { 'New%20England%2014%20Seattle%2017%20(boxscore)' }

  before { allow(Net::HTTP).to receive(:get).and_return(score_feed) }

  it 'routes everything to root' do
    get '/to-the-choppa'
    expect(last_response).to be_redirect
    follow_redirect!
    expect(last_request.path).to eq '/'
  end

  describe '#index' do
    before { get '/' }

    it "doesn't blow up" do
      get '/'
      expect(last_response).to be_ok
    end

    context 'when the game has not started yet' do
      let(:score_feed) {'New%20England%20at%20Seattle%20(preview)'}

      specify { expect(last_response.body).to match(/NO/) }
      specify { expect(last_response.body).not_to match(/red/) }
    end

    context 'when the game has started' do
      context 'when the score is tied' do
        let(:score_feed) {'New%20England%200%20Seattle%200%20(boxscore)'}

        specify { expect(last_response.body).to match(/NO/).and match(/red/) }
      end

      context 'when the cheaters are losing' do
        let(:score_feed) {'New%20England%2014%20Seattle%2017%20(boxscore)'}

        specify { expect(last_response.body).to match(/NO/).and match(/red/) }
      end

      context 'when the cheaters are winning' do
        let(:score_feed) {'New%20England%2014%20Seattle%2010%20(boxscore)'}

        specify { expect(last_response.body).to match(/YES/).and match(/red/) }
      end
    end

    context 'when the game has finished' do
      context 'when the cheaters lost' do
        let(:score_feed) {'New%20England%2028%20%20%20Seattle%2031%20(FINAL)'}

        specify { expect(last_response.body).to match(/NO/) }
        specify { expect(last_response.body).not_to match(/red/) }
      end

      context 'when the cheaters won' do
        let(:score_feed) {'New%20England%2028%20%20%20Seattle%2024%20(FINAL)'}

        specify { expect(last_response.body).to match(/YES/) }
        specify { expect(last_response.body).not_to match(/red/) }
      end
    end
  end
end
