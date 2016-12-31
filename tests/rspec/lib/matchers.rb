# Include these into your rspec for basic testing

# This is needed for rss feed parsing
require 'rss'
# We want to parse mixed content errors straight from the html
require 'nokogiri'

RSpec::Matchers::define :have_title do |text|
  match do |page|
    Capybara.string(page.body).has_selector?('title', text: text)
  end
end

RSpec::Matchers::define :have_css do
  match do |page|
    page.body.include? ".css" or page.body.include? "<style>"
  end
end

RSpec::Matchers::define :have_js do
  match do |page|
    page.body.include? ".js" or page.body.include? "<script>"
  end
end

RSpec::Matchers::define :have_status_of do |any_of_codes|
  match do |page|
    any_of_codes.include? page.status_code
  end

  failure_message_when_negated do |page|
    "Expected #{page.status_code} to be one one of: #{any_of_codes.join(",")}"
  end
end

RSpec::Matchers::define :have_id do |id|
  match do |page|
    page.body.include? id
  end
end

# Custom matcher to check if rss feed is valid and has link
RSpec::Matchers::define :have_rss_link do |link|
  match do |page|
    feed =  RSS::Parser.parse(page.body)
    feed.channel.link.include? link
  end
end

# Checks that all assets in the page are https
# The trick is that phantomjs is too clever to even load those so network traffic won't help us
# We check them manually by parsing the html
# The problem with this approach is that it won't detect mixed content errors made by stylesheets or javascript
RSpec::Matchers::define :have_mixed_content do
  match do |page|
    document = Nokogiri::HTML( page.html )

    # Check mixed content from scripts and images
    document.css('script, img').each { |el| return true if el["src"] and el["src"].start_with? 'http://' }

    # Check mixed content from picture element sources
    document.css('picture source').each { |el| return true if el["srcset"] and el["srcset"].start_with? 'http://' }

    # Check mixed content from stylesheets
    document.css('link').each { |el|
        return true if el["rel"] and el["rel"] == "stylesheet" and el["href"] and el["href"].start_with? 'http://'
    }

    return false
  end

  failure_message_when_negated do |page|
    document = Nokogiri::HTML( page.html )
    errors = []
    document.css('script, img').each { |el| errors.push(el["src"]) if el["src"] and el["src"].start_with? 'http://' }

    document.css('picture source').each { |el| errors.push(el["src"]) if el["srcset"] and el["srcset"].start_with? 'http://' }

    document.css('link').each { |el|
        errors.push(el["src"]) if el["rel"] and el["rel"] == "stylesheet" and el["href"] and el["href"].start_with? 'http://'
    }
    "Expected not to have mixed content but following requests didn't use https: \n\n#{errors.map{|w| "- #{w}"}.join("\n")}\n\n"+'-'*10
  end
end

# Gzip check

# 404 check
RSpec::Matchers::define :have_missing_assets do
  match do |page|
    page.driver.network_traffic.each do |request|
        request.response_parts.uniq(&:url).each do |response|
            # Check if any of the urls has mixed content
             return true if response.status == 404
        end
    end
    return false
  end

  failure_message_when_negated do |page|
    errors = []
    page.driver.network_traffic.each do |request|
        request.response_parts.uniq(&:url).each do |response|
            # Check if any of the urls has mixed content
             errors.push(response.url) if response.status == 404
        end
    end
    "Expected not to have any 404 requests but these were missing: \n\n#{errors.map{|w| "- #{w}"}.join("\n")}\n\n"+'-'*10
  end
end
