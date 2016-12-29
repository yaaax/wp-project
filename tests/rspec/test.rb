##
# This file includes Rspec tests for WordPress
##

# Check /sitemap.xml
require 'sitemap-parser'

# Use preconfigured poltergeist/phantomjs rules
require_relative 'lib/config.rb'

# Helper for screenshots
def timestamp_filename(file)
  dir  = File.dirname(file)
  base = File.basename(file, ".*")
  time = Time.now.to_i  # or format however you like
  ext  = File.extname(file)
  File.join(dir, "#{base}_#{time}#{ext}")
end

# Good list about Capybara commands can be found in: https://gist.github.com/zhengjia/428105
# This can help you getting tests up and running more faster.

### Begin tests ###

describe "WordPress: #{WP.siteurl} -", :type => :request, :js => true do

  subject { page }

  describe "Frontpage" do

    before do
        visit WP.siteurl('/')
    end

    # 200 Means OK
    it "should have status code OK" do
        expect(page).to have_status_of [200]
    end

    it "should include stylesheets" do
        expect(page).to have_css
    end

    it "should includes javascript" do
        expect(page).to have_js
    end

    it "shouldn't have 404 requests", :missing_assets do
        expect(page).to_not have_missing_assets
    end

    if WP.https?
        it "shouldn't have any mixed content errors", :mixed_content do
            expect(page).to_not have_mixed_content
        end
    end

  end

  # Check that RSS feed is working
  # This is not working in WordPress 4.7 because of https://core.trac.wordpress.org/ticket/39141
  #describe "RSS-feed", :rss do
  #  before do
  #      visit WP.siteurl('/feed/')
  #  end

  #  it "should have valid rss feed which contains link to itself" do
  #      expect(page).to have_rss_link WP.siteurl('')
  #  end
  #end

  # Check that robots.txt is working
  describe "robots.txt", :robots do
    before do
        visit WP.siteurl('/robots.txt')
    end

    it "should have status code OK" do
        expect(page).to have_status_of [200]
    end

    it "shouldn't be empty" do
        expect(page.body).not_to be_empty
    end
  end

  # Check that we have valid Sitemaps
  #describe "Sitemaps", :sitemaps do
  #  it "should have status code OK" do
  #      visit WP.siteurl('/sitemap.xml')
  #      expect(page).to have_status_of [200]
  #  end
#
#  #  it "should contain at least one link" do
#  #      sitemaps = SitemapParser.new( WP.siteurl('/sitemap.xml'), {recurse: true} )
#  #      links = sitemaps.to_a
#  #      expect( links.size ).to be >= 1
#  #  end
  #end

  # Check that WordPress login works
  describe "wp-login" do

    before do
      visit WP.siteurl('/wp-login.php')
    end

    it "has login form", :login do
      expect(page).to have_id "loginform"
      expect(page).to have_id "wp-submit"
    end

    it "shouldn't have 404 requests", :missing_assets do
      expect(page).to_not have_missing_assets
    end

    if WP.https?
      it "shouldn't have any mixed content errors", :mixed_content do
        expect(page).to_not have_mixed_content
      end
    end

    # Only run these if we could create a test user
    if WP.user?
        context "login form" do

            it "should redirect to wp-admin after succesful login", :login do
                within("#loginform") do
                    fill_in 'log', :with => WP.user.username
                    fill_in 'pwd', :with => WP.user.password
                end
                click_button 'wp-submit'

                expect(page).to have_id "wpadminbar"
            end

        end
    end

  end
end
