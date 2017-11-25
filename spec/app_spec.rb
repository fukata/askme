require File.expand_path '../spec_helper.rb', __FILE__

describe "app" do
  context "should allow accessing the home page" do
    it do
      get '/'
      expect(last_response).to be_ok
    end
  end

  describe "/api/questions" do
    describe "create" do
      subject { post '/api/questions', params, sessions }
      context "successful" do
        let(:user) { FactoryBot.create(:user) }
        let(:sessions) { {user: {id: user.id, username: user.username}} }
        let(:params) { {
          to_username: user.username,
          comment: "hogehoge",
        } }
        it do
          subject
          api_data = JSON.parse(last_response.body, symbolize_names: true)
          expect(api_data[:status]).to eq 'successful'

          user.reload
          expect(user.questions.count).to eq 1
          question = user.questions.last
          expect(question.comment).to eq 'hogehoge'
        end
      end

      context "failed" do
        let(:user) { FactoryBot.create(:user) }
        let(:sessions) { {user: {id: user.id, username: user.username}} }
        let(:params) { {
          to_username: user.username,
          comment: "",
        } }
        it do
          subject
          api_data = JSON.parse(last_response.body, symbolize_names: true)
          expect(api_data[:status]).to eq 'failed'

          user.reload
          expect(user.questions.count).to eq 0
        end
      end
    end
  end
end
