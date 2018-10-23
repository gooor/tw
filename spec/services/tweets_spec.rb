require_relative '../../services/tweets'

require 'rainbow/refinement'
using Rainbow

describe Services::Tweets do

  context "validating options" do

    it "shouldn't throw error on empty date" do
      expect { described_class.new(filter_since: nil, filter_until: nil) }.not_to raise_error
     end

    it "should throw error on invalid dates" do
     expect { described_class.new(filter_since: '2018-11-99', filter_until: nil) }.to raise_error(Services::IncorrectDatesError)
     expect { described_class.new(filter_since: nil, filter_until: '2018-11-44') }.to raise_error(Services::IncorrectDatesError)
     expect { described_class.new(filter_since: '2018-11-11', filter_until: '2018-11-44') }.to raise_error(Services::IncorrectDatesError)
     expect { described_class.new(filter_since: 'dummy text', filter_until: '2018-11-44') }.to raise_error(Services::IncorrectDatesError)
     expect { described_class.new(filter_since: '11-11-2018', filter_until: nil) }.to raise_error(Services::IncorrectDatesError)
    end

  end

  context "calling twitter api" do
    subject do
      described_class.new
    end

    context 'get friends' do
      before do
        VCR.turn_on!
        VCR.use_cassette 'twitter/friends' do
          @response = subject.send(:friends)
        end
      end

      it 'gets list of friends' do
        expect(@response.to_a.length).to eq 3
        expect(subject.send(:friends_screen_names)).to match_array ["FIVBVolleyball", "JavaScriptDaily", "nodejs"]
      end
    end

    context 'with results' do
      before do
        VCR.turn_on!
        VCR.use_cassette 'twitter/search_response' do
          @response = subject.get
          @final_response = @response.map(&:to_s).join("\n")
        end
      end

      it "is correcty formatted" do
        expect(@response.length).to eq 3
        expect(@final_response).to start_with 'FIVBVolleyball'.green.bold
        expect(@final_response).to include 'http://Code.xyz'
        expect(@final_response).not_to include 'https://twitter.com'
        expect{ Date.parse @final_response.split("\n")[1] }.not_to raise_error

      end
    end

    
  end
end