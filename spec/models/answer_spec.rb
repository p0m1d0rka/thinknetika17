require 'rails_helper'

RSpec.describe Answer, type: :model do
  let!(:answer) { create(:answer) }
  let!(:user) { create(:user) }
  let!(:vote_up) { create(:vote, :up, user: user, voteable: answer) }
  let(:answer2) { create(:answer) }

  it { should belong_to :question }
  it { should belong_to :user }
  it { should have_many(:attachments).dependent(:destroy) }
  it { should have_many(:votes).dependent(:destroy) }
  it { should have_many(:comments).dependent(:destroy) }
  it { should validate_presence_of :body }

  it { should accept_nested_attributes_for :attachments }
  
  context 'setting answer to be best' do 
    before { @question = create :question_with_answers }

    it 'have only 1 best answer' do 
      @question.answers.each do |a|
        a.set_best
      end
      expect(@question.answers.bests.count).to eq 1
    end

    it 'set best answer' do 
      answer = @question.answers.first
      answer.set_best
      expect(answer.is_best?).to eq true
    end
  end

  it_behaves_like 'voteable'

end
