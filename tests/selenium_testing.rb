require 'selenium-webdriver'
require_relative '../pages/landing_page'

# setup
options = Selenium::WebDriver::Chrome::Options.new
driver = Selenium::WebDriver.for :chrome, options: options
monkeytype = MonkeyType.new(driver)

# go to site
monkeytype.visit
monkeytype.cookies.reject

# wait for initial words
monkeytype.wait_until_words_loaded
log "Initial words loaded"

initial_active = monkeytype.word_field.active_word
words = monkeytype.word_field.words

log "Initial active word: \"#{initial_active}\""
log "Initial word list: #{words}"

# change mode to 25 words
monkeytype.nav_bar.switch_to_words_mode
monkeytype.nav_bar.word_count_button("25")
monkeytype.wait_until_words_change(initial_active)

new_active = monkeytype.word_field.active_word
new_words = monkeytype.word_field.words

log "New words loaded"
log "New active word: \"#{new_active}\""
log "New word list: #{new_words}"
log "Active mode: #{monkeytype.nav_bar.mode_buttons.active_mode}"
log "Word count: #{new_words.length}"

# try a different mode
log "Switching to punctuation mode"
monkeytype.nav_bar.switch_to_punctuation_mode
monkeytype.wait_until_words_loaded
punct_active = monkeytype.word_field.active_word
punct_words = monkeytype.word_field.words

log "Punctuation mode words loaded"
log "Active word: \"#{punct_active}\""
log "Word list: #{punct_words}"
log "Active mode: #{monkeytype.nav_bar.mode_buttons.active_mode}"
log "Word count: #{punct_words.length}"

new_count = "10"
log "Switching to word count: #{new_count}"
old_word = monkeytype.word_field.active_word
monkeytype.nav_bar.word_count_button(new_count)
monkeytype.wait_until_words_change(old_word)
monkeytype.wait_until_words_loaded

words = monkeytype.word_field.words
actual_count = words.length
mode_value = monkeytype.nav_bar.mode_buttons.active_mode


log "New active word: \"#{monkeytype.word_field.active_word}\""
log "Word list: #{words}"
log "Active mode: #{mode_value}"
log "Word count: #{actual_count}"


log "Finished testing [end of script]"
puts "press enter to exit..."
gets


