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
  describe "RSS-feed", :rss do
    before do
        visit WP.siteurl('/?feed=rss2')
    end

    it "should have valid rss feed which contains link to itself" do
        expect(page).to have_rss_link WP.siteurl('')
    end
  end

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
  describe "Sitemaps", :sitemaps do
    it "should have status code OK" do
        visit WP.siteurl('/sitemap.xml')
        expect(page).to have_status_of [200]
    end

    it "should contain at least one link" do
        sitemaps = SitemapParser.new( WP.siteurl('/sitemap.xml'), {recurse: true} )
        links = sitemaps.to_a
        expect( links.size ).to be >= 1
    end
  end

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

    # Check that WordPress admin works
    describe "wp-admin", :admin do

        # Generate random post title
        post_title = 'test-post-'.Time.now.to_i
        post_content = 'One morning, when Gregor Samsa woke from troubled dreams, he found himself transformed in his bed into a horrible vermin. He lay on his armour-like back, and if he lifted his head a little he could see his brown belly, slightly domed and divided by arches into stiff sections. The bedding was hardly able to cover it and seemed ready to slide off any moment. His many legs, pitifully thin compared with the size of the rest of him, waved about helplessly as he looked. "What\'s happened to me?" he thought. It wasn\'t a dream. His room, a proper human room although a little too small, lay peacefully between its four familiar walls. A collection of textile samples lay spread out on the table - Samsa was a travelling salesman - and above it there hung a picture that he had recently cut out of an illustrated magazine and housed in a nice, gilded frame. It showed a lady fitted out with a fur hat and fur boa who sat upright, raising a heavy fur muff that covered the whole of her lower arm towards the viewer. Gregor then turned to look out the window at the dull weather.'

        before do
            login( WP.siteurl('/wp-login.php'), WP.user )
        end

        context "new article" do

            it "can be created" do
                #page.save_screenshot( timestamp_filename( __dir__+'/images/after-login.png' ) )

                # Click posts menu
                first('#menu-posts > a').double_click

                #page.save_screenshot( timestamp_filename( __dir__+'/images/post-menu.png' ) )
                expect(page).to have_current_path( '/wp-admin/edit.php' )

                # Click new post
                first('h1 > .page-title-action').click

                #page.save_screenshot( timestamp_filename( __dir__+'/images/new-post.png' ) )
                expect(page).to have_current_path( '/wp-admin/post-new.php' )

                within('#post-body-content') do
                    fill_in 'post_title', :with => post_title
                    fill_in 'content', :with => post_content
                end
                #page.save_screenshot( timestamp_filename( __dir__+'/images/new-post-filled.png' ) )

                click_button 'publish'
                wait_for_ajax
            end

            # TODO: Capybara can't publish the post because of some WordPress ajax functionality

            it "can be trashed" do
                # Click posts menu
                first('#menu-posts > a').double_click

                #page.save_screenshot( timestamp_filename( __dir__+'/images/new-menu-draft.png' ) )

                # User should see the new post
                expect(page).to have_content( post_title )

                # Delete post
                click_link post_title
                first('#delete-action > a').click

                # Page shouldn't contain the deleted post anymore
                expect(page).not_to have_content( post_title )
            end
        end

    end

end
