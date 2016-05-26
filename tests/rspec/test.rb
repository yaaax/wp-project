##
# This file includes Rspec tests for WordPress
##

# Use preconfigured poltergeist/phantomjs rules and load WP class
require_relative 'lib/config.rb'

# Good list about Capybara commands can be found in: https://gist.github.com/zhengjia/428105
# This can help you getting tests up and running more faster.

### Begin tests ###

describe "WordPress: #{WP.siteurl} - ", :type => :request, :js => true do

  subject { page }

  describe "Frontpage" do

    before do
      visit WP.siteurl('/')
    end

    # 200 Means OK
    it "should have healthy status code 200" do
      expect(page).to have_status_of [200]
    end

    it "should include stylesheets" do
      expect(page).to have_css
    end

    it "should includes javascript" do
      expect(page).to have_js
    end

  end

  # Check that rss feed is working
  describe "RSS-feed" do
    before do
      visit WP.siteurl('/?feed=rss2')
    end

    it "should be valid rss and have link to itself" do
      expect(page).to have_rss_link WP.siteurl('')
    end
  end

  # Check that WordPress login works
  describe "wp-login" do

    before do
      visit WP.siteurl('/wp-login.php')
    end

    it "has login form" do
      expect(page).to have_id "wp-submit"
    end

    # Only run these if we could create a test user
    if WP.user?
      it "after succesfully login user should see WordPress adminbar" do
        within("#loginform") do
          fill_in 'log', :with => WP.user.username
          fill_in 'pwd', :with => WP.user.password
        end
        click_button 'wp-submit'
        # Should obtain cookies and be able to visit /wp-admin
        expect(page).to have_id "wpadminbar"
      end
    end

  end

end
