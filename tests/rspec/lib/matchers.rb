# Include these into your rspec for basic testing

# This is needed for rss feed parsing
require 'rss'

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
RSpec::Matchers::define :have_mixed_content do
  match do |page|
    page.driver.network_traffic.each do |request|
        # sorry, quick and dirty to see what we get:
        request.response_parts.uniq(&:url).each do |response|
            # Check if any of the urls has mixed content
             return true if response.url.start_with?("http://")
        end
    end
    return false
  end

  failure_message_when_negated do |page|
    errors = []
    page.driver.network_traffic.each do |request|
        # sorry, quick and dirty to see what we get:
        request.response_parts.uniq(&:url).each do |response|
            # Check if any of the urls has mixed content
             errors.push(response.url) if response.url.start_with?("http://")
        end
    end
    "Expected https:// in following requests: \n#{errors.join("\n")}"
  end
end

# Gzip check

# 404 check

# Checks that all assets in the page are https
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
    "Expected not to have any 404 requests but founded these: \n#{errors.join("\n")}"
  end
end
