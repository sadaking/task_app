require 'rails_helper'
RSpec.describe 'タスク管理機能', type: :system do

  before do

    @user = FactoryBot.create(:user)
    @task = FactoryBot.create(:task, title: 'task', content: 'submit task', deadline: '2020-05-23　00:00:00 ', status: '完了', priority: '高', user: @user)
    @label = FactoryBot.create(:label)
    FactoryBot.create(:labeling, task:@task, label:@label)
    @second_task = FactoryBot.create(:task, title: 'new_task',content: 'difficult task', deadline: '2020-05-24 00:00:00', status: '着手中',priority: '中', user: @user)
  end

  def login
    visit new_session_path
    fill_in 'session_email', with: @user.email
    fill_in 'session_password', with: @user.password
    click_on "ログイン"
  end


  describe 'タスク一覧画面' do
    context 'タスクを作成した場合' do
      it '作成済みのタスクが表示される' do
        sleep 0.5
        login
        visit tasks_path
        expect(page).to have_content 'task'
        expect(page).to have_content 'new_task'
      end
    end
    context '複数のタスクを作成した場合' do
      it 'タスクが作成日時の降順に並んでいる' do
        login
        visit tasks_path
        task_list = all('.task_row')
        expect(task_list[0]).to have_content 'new_task'
        expect(task_list[1]).to have_content 'task'
      end
    end

    context '終了期限（期日)でソートした場合' do
      it 'タスクが終了期限の降順に並んでいること' do
        sleep 0.5
        login
        visit tasks_path
        click_on '終了期限でソートする'
        task_list = all('.task_deadline')
        expect(task_list[0]).to have_content '2020年05月24日'
        expect(task_list[1]).to have_content '2020年05月23日'
      end
    end

    context '優先順位でソートした場合' do
      it 'タスクが優先順位の降順に並んでいること' do
        sleep 0.5
        login
        visit tasks_path
        click_on '優先順位でソートする'
        task_list = all('.task_priority')
        expect(task_list[0]).to have_content '高'
        expect(task_list[1]).to have_content '中'
      end
    end

    context 'scopeメソッドで検索をした場合' do
      it "scopeメソッドでタイトル検索ができる" do
        login
        visit tasks_path
        fill_in 'title', with: 'new_task'
        click_on '検索する'
        expect(page).to have_content 'new_task'
      end
      it "scopeメソッドでステータス検索ができる" do
        login
        visit tasks_path
        select '着手中', from: "status"
        click_on '検索する'
        expect(page).to have_content '着手中'
      end

      it "scopeメソッドでタイトルとステータスの両方が検索できる" do
        login
        visit tasks_path
        fill_in 'title', with: 'new_task'
        select '着手中', from: "status"
        click_on '検索する'
        expect(page).to have_content 'new_task'
        expect(page).to have_content '着手中'
      end
    end


    context "ラベル検索で絞り込みをかけた場合" do
      it "ラベル検索でタスクが絞られる" do
        sleep 0.5
        login
        visit tasks_path
        select "Self study", from:"label_id"
        click_on "検索する"
        task_list = all(".task_label")
        expect(task_list[0]).to have_content "Self study"
      end
    end
  end

  describe 'タスク登録画面' do
    context '必要項目を入力して、createボタンを押した場合' do
      it 'データが保存される' do
        sleep 0.5
        login
        visit new_task_path
        fill_in 'タスク名', with: '万葉課題'
        fill_in 'タスク詳細', with: '万葉課題の提出'
        fill_in '終了期限', with: '2020/05/23'
        select '完了', from: "task_status"
        select '高', from: "task_priority"
        check "Self study"
        click_on "登録する"
        expect(page).to have_content '万葉課題の提出'
      end
    end
  end

  describe 'タスク詳細画面' do
     context '任意のタスク詳細画面に遷移した場合' do
       it '該当タスクの内容が表示されたページに遷移する' do
         task_id = FactoryBot.create(:task, title: 'dive_text', content: 'submit task', deadline: '2020-05-23', user: @user)
         login
         visit task_path(task_id)
         expect(page).to have_content 'dive_text', 'submit task'
       end
     end
  end
end
