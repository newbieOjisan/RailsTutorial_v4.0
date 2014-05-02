require 'spec_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do

      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe "micropost count" do
    before do
      FactoryGirl.create(:micropost,user: user,content: "Dolor sit amet")
      visit root_path
    end

    it { should have_content("#{user.microposts.count} micropost") }
    it { should_not have_content("#{user.microposts.count} microposts") }
    describe "with 2 microposts" do
      before do
        FactoryGirl.create(:micropost,user: user,content: "Lorem ipsum")
        visit root_path
      end

      it { should have_content("#{user.microposts.count} microposts") }
    end
  end

  describe "pagination" do
    before do
      40.times { FactoryGirl.create(:micropost, user: user) }
      visit root_path
    end
    after { Micropost.delete_all }

    it { should have_selector('div.pagination') }

    it "should list each micropost" do
      user.microposts.paginate(page: 1).each do |micropost|
        expect(page).to have_selector('li', text: micropost.content)
      end
    end
  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end
  end

  describe "another user's page" do
    let(:another_user) { FactoryGirl.create(:user) }
    before do
      FactoryGirl.create(:micropost,user: another_user,content: "oh")
      visit user_path(another_user)
    end
    it "microposts without delete links" do
      another_user.microposts.each do |micropost|
        page.should_not have_link('delete',href: micropost_path(micropost))
      end
    end
  end
end
