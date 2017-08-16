require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
let!(:question) { create(:question) }
let(:question_with_answers) { create(:question_with_answers) }
let(:answer) { create(:answer) }
let(:invalid_answer) { create(:invalid_answer) }

  describe 'GET #edit' do
    before { get :edit, params: { id: question_with_answers.answers.first, question_id: question_with_answers } }

    it 'assigns the requested answer to @answer' do 
      expect(assigns(:answer)).to eq question_with_answers.answers.first
    end

    it 'render edit view' do 
      expect(response).to render_template :edit
    end
  end

  describe 'POST #create' do 
    sign_in_user
    context 'with valid attributes' do 
      it 'saves the new answer in the db' do 
        expect { post :create, params: {question_id: question, answer: attributes_for(:answer), format: :js } }.to change(question.answers, :count).by(1)
      end

      it 'render create template' do 
        post :create, params: {question_id: question, answer: attributes_for(:answer), format: :js   }
        expect(response).to render_template 'create'
      end

      it 'have current_user as author' do 
        post :create, params: {question_id: question, answer: attributes_for(:answer), format: :js   }
        expect(assigns(:answer).user).to eq @user
      end
    end

    context 'with invalid attributes' do 
      it 'saves the new answer in the db' do 
        expect { post :create, params: {question_id: question, answer: attributes_for(:invalid_answer), format: :js   } }.to_not change(Answer, :count)
      end

      it 'render template question show view' do 
        post :create, params: {question_id: question, answer: attributes_for(:invalid_answer), format: :js   }
        expect(response).to render_template 'answers/create'
      end
    end
  end

  describe 'DELETE #destroy' do 
    context 'his own answer' do 
      sign_in_user
      before { question_with_answers.answers.first.update(user_id: @user.id) }

      it 'deletes question' do 
        expect { delete :destroy, params: { question_id: question_with_answers, id: question_with_answers.answers.first } }.to change(Answer, :count).by(-1) 
      end

      it 'redirect to parent question show' do 
        delete :destroy, params: { question_id: question_with_answers, id: question_with_answers.answers.first }
        expect(response).to redirect_to question_path(question_with_answers)
      end
    end

    context 'not his answer' do 
      sign_in_user

      it 'deletes question' do 
        question_with_answers
        expect { delete :destroy, params: { question_id: question_with_answers, id: question_with_answers.answers.first } }.to_not change(Answer, :count) 
      end

      it 'redirect to parent question show' do 
        delete :destroy, params: { question_id: question_with_answers, id: question_with_answers.answers.first }
        expect(response).to redirect_to question_path(question_with_answers)
      end      
    end
  end

  describe 'PATCH #update' do 
    sign_in_user
    let!(:answer) { create(:answer, question: question, user: @user) }

    context 'with valid attributes' do
      it 'assigns the requested answer to @answer' do 
        patch :update, params: { id: answer, question_id: question, answer: attributes_for(:answer), format: :js }
        expect(assigns(:answer)).to eq answer
      end

      it 'changes answer attributes' do 
        patch :update, params: { id: answer, question_id: question, answer: {body: 'body'}, format: :js } 
        answer.reload
        expect(answer.body).to eq 'body'
      end

      it 'render update template' do 
        patch :update, params: { id: answer, question_id: question, answer: attributes_for(:answer), format: :js }
        expect(response).to render_template :update
      end
    end

    context 'invalid attributes' do 
      before do
        @old_body = answer.body
        patch :update, params: { id: answer, question_id: question, answer: { body: nil }, format: :js }
      end

      it 'does not change answer attributes' do 
        answer.reload
        expect(answer.body).to eq @old_body
      end

      it 're-render edit view' do 
        expect(response).to render_template :update
      end
    end  

    context 'non-author try to update' do 
      let!(:user) { create(:user) }
      before do 
        answer.update(user_id: user.id)
        @old_body = answer.body
        patch :update, params: { id: answer, question_id: question, answer: { body: nil }, format: :js }        
      end

      it 'does not change answer attributes' do 
        answer.reload
        expect(answer.body).to eq @old_body
      end

      it 're-render edit view' do 
        expect(response).to render_template :update
      end      

      it 'have flash error message' do 
        expect(flash['alert']).to eq 'You dont have enough privilege'        
      end
    end  
  end

end
