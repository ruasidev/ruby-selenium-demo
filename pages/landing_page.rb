NotFound = Selenium::WebDriver::Error::NoSuchElementError

def log(msg)
  timestamp = "[#{Time.now.strftime('%H:%M:%S')}]"
  formatted = "\e[32m#{timestamp} #{msg}\e[0m"
  plain = "#{timestamp} #{msg}"

  puts formatted
  File.open("selenium_log.txt", "a") { |f| f.puts plain }
end

class MonkeyType
  URL = "https://www.monkeytype.com"

  def initialize(driver)
    @driver = driver
    log "Launching driver..."
  end

  def visit
    @driver.navigate.to URL
    log "Navigating to #{URL}"
  end

  def wait_until_words_loaded(timeout: 5)
    log "Waiting for words to load..."
    Selenium::WebDriver::Wait.new(timeout: timeout).until do
      !word_field.blurred? && word_field.words.any?
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      false
    end
  end

  def wait_until_words_change(prev_text, timeout: 5)
    Selenium::WebDriver::Wait.new(timeout: timeout).until do
      current = word_field.active_word
      current && current != prev_text
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      false
    end
  end

  def cookies
    Cookies.new(find(:class, "modal"))
  rescue NotFound
    nil
  end

  def nav_bar
    NavBar.new(find(:css, "#testConfig > div:nth-child(1)"))
  end

  def word_field
    WordField.new(find(:id, "words"))
  end

  private

  def find(by, value)
    @driver.find_element(by => value)
  end
end

class Cookies
  def initialize(scope)
    @scope = scope
  end

  def accept = click(:class, "acceptAll", "Accepted cookies")
  def reject = click(:class, "rejectAll", "Declined cookies")
  def open_settings = click(:class, "openSettings", "Opening settings")

  private

  def click(by, value, msg)
    el = @scope.find_element(by => value)
    el.click if el
    log msg
    true
  rescue NotFound
    false
  end
end

class NavBar
  def initialize(scope)
    @scope = scope
  end

  def switch_to_words_mode
    click(:css, 'button[mode="words"]', "Switched to words mode")
  end

  def switch_to_punctuation_mode
    click(:class, 'punctuationMode', "Switched to punctuation mode")
  end

  def word_count_button(count, timeout: 5)
    Selenium::WebDriver::Wait.new(timeout: timeout).until do
      btn = @scope.find_element(css: "button[wordcount='#{count}']")
      btn if btn.displayed? && btn.enabled?
    end.click
    log "Clicked word count: #{count}"
  rescue NotFound, Selenium::WebDriver::Error::TimeoutError => e
    log "Failed to click word count: #{e.message}"
    nil
  end

  def mode_buttons
    WordCountModes.new(@scope.find_element(class: "wordCount"))
  rescue NotFound
    nil
  end

  private

  def click(by, value, msg)
    @scope.find_element(by => value).click
    log msg
  rescue NotFound
    nil
  end
end

class WordCountModes
  def initialize(scope)
    @scope = scope
  end

  def active_mode
    @scope.find_element(class: "active").text
  rescue NotFound
    "(none)"
  end
end

class WordField
  def initialize(scope)
    @scope = scope
  end

  def blurred?
    @scope.attribute("class").to_s.include?("blurred")
  end

  def active_word
    Word.new(@scope.find_element(class: "active")).text
  rescue NotFound
    nil
  end

  def words
    @scope.find_elements(class: "word").map(&:text)
  end
end

class Word
  def initialize(el)
    @el = el
  end

  def text
    @el.find_elements(tag_name: "letter").map { |l| l.text rescue "" }.join
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    "(stale)"
  end

  def inspect
    text
  end
end
