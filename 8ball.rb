require 'telegram/bot'
require 'dotenv'

# Load environment variables from .env file and verify path
puts "Current directory: #{Dir.pwd}"
puts "Loading .env file..."
Dotenv.load(File.join(__dir__, '.env'))

# Add debug output to verify token
token = ENV['TELEGRAM_BOT_TOKEN']
if token.nil? || token.empty?
  puts "ERROR: Token not found in .env file!"
  puts "Please make sure .env file exists and contains TELEGRAM_BOT_TOKEN"
  exit 1
end

puts "Starting bot with token: #{token}"

# В начале файла добавим константу для клавиатуры выбора языка
LANGUAGE_KEYBOARD = [
  [
    Telegram::Bot::Types::KeyboardButton.new(text: '🇬🇧 English'),
    Telegram::Bot::Types::KeyboardButton.new(text: '🇷🇺 Русский'),
    Telegram::Bot::Types::KeyboardButton.new(text: '🇷🇴 Română')
  ]
].freeze

# Messages in both languages
MESSAGES = {
  en: {
    greetings: [
      'Hello, dear friend. Ask your question...',
      'Hi! What would you like to know?',
      'Greetings! What troubles you?'
    ],
    answers: [
      'It is certain',
      'Reply hazy, try again',
      'Don\'t count on it',
      'It is decidedly so',
      'Ask again later',
      'My reply is no',
      'Without a doubt',
      'Better not tell you now',
      'My sources say no',
      'Yes definitely',
      'Cannot predict now',
      'Outlook not so good',
      'You may rely on it',
      'Concentrate and ask again',
      'Very doubtful',
      'As I see it, yes',
      'Most likely',
      'Outlook good',
      'Yes',
      'Signs point to yes'
    ],
    shake_button: '🎱 Shake the Magic 8 Ball 🎱',
    language_button: '🌐 Switch Language',
    ask_question: 'Ask your question and press the "Shake" button!',
    select_language: '🌐 Select language / Выберите язык / Alegeți limba'
  },
  ru: {
    greetings: [
      'Здравствуй, дорогой друг. Задай свой вопрос...',
      'Привет! Что ты хочешь узнать?',
      'Приветствую! Что тебя беспокоит?'
    ],
    answers: [
      'Бесспорно',
      'Попробуй спросить позже',
      'Даже не думай',
      'Определённо да',
      'Спроси снова',
      'Мой ответ - нет',
      'Несомненно',
      'Лучше не говорить',
      'Мои источники говорят нет',
      'Однозначно да',
      'Сейчас не могу предсказать',
      'Перспективы не очень хорошие',
      'Можешь быть уверен в этом',
      'Сконцентрируйся и спроси снова',
      'Весьма сомнительно',
      'Как я вижу, да',
      'Вероятнее всего',
      'Хорошие перспективы',
      'Да',
      'Знаки говорят да'
    ],
    shake_button: '🎱 Встряхнуть магический шар 🎱',
    language_button: '🌐 Сменить язык',
    ask_question: 'Задай свой вопрос и нажми кнопку "Встряхнуть"!',
    select_language: '🌐 Select language / Выберите язык / Alegeți limba'
  },
  ro: {
    greetings: [
      'Bună, dragă prietene. Pune-ți întrebarea...',
      'Salut! Ce vrei să știi?',
      'Bună ziua! Ce te frământă?'
    ],
    answers: [
      'Este cert',
      'Răspuns neclar, încearcă din nou',
      'Nu conta pe asta',
      'Este în mod decisiv așa',
      'Întreabă din nou mai târziu',
      'Răspunsul meu este nu',
      'Fără îndoială',
      'Mai bine să nu-ți spun acum',
      'Sursele mele spun nu',
      'Da, cu siguranță',
      'Nu pot prezice acum',
      'Perspectivele nu sunt bune',
      'Te poți baza pe asta',
      'Concentrează-te și întreabă din nou',
      'Foarte îndoielnic',
      'După cum văd eu, da',
      'Cel mai probabil',
      'Perspectivele sunt bune',
      'Da',
      'Semnele indică da'
    ],
    shake_button: '🎱 Scutură bila magică 8 🎱',
    language_button: '🌐 Schimbă limba',
    ask_question: 'Pune întrebarea și apasă butonul "Scutură"!',
    select_language: '🌐 Select language / Выберите язык / Alegeți limba'
  }
}

def create_keyboard(language)
  kb = [
    [Telegram::Bot::Types::KeyboardButton.new(text: MESSAGES[language][:shake_button])],
    [Telegram::Bot::Types::KeyboardButton.new(text: MESSAGES[language][:language_button])]
  ]
  Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, resize_keyboard: true)
end

# Store user language preferences
user_languages = {}

def show_language_selection(message, bot, current_language)
  markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
    keyboard: LANGUAGE_KEYBOARD,
    resize_keyboard: true
  )

  bot.api.send_message(
    chat_id: message.chat.id,
    text: MESSAGES[current_language][:select_language],
    reply_markup: markup
  )
end

begin
  Telegram::Bot::Client.run(token) do |bot|
    # Verify bot connection first
    begin
      puts "Attempting to connect to Telegram API..."
      response = bot.api.get_me.to_h  # Convert response to hash
      
      if response && response[:id]
        bot_name = response[:first_name]
        bot_username = response[:username]
        puts "Bot connected successfully!"
        puts "Name: #{bot_name}"
        puts "Username: @#{bot_username}"
      else
        puts "Failed to get bot information. Response: #{response.inspect}"
        exit 1
      end
    rescue => e
      puts "Failed to connect to bot: #{e.message}"
      puts "Full error: #{e.inspect}"
      puts e.backtrace
      exit 1
    end
    
    puts "Starting message listener..."
    puts "Bot is ready to receive messages!"
    puts "Use @magic8ballmd_bot in Telegram"
    
    bot.listen do |message|
      begin
        next unless message.is_a?(Telegram::Bot::Types::Message)
        user_id = message.from.id
        user_languages[user_id] ||= :en
        current_language = user_languages[user_id]

        case message.text
        when '/start'
          show_language_selection(message, bot, current_language)
        when '🇬🇧 English'
          user_languages[user_id] = :en
          bot.api.send_message(
            chat_id: message.chat.id,
            text: MESSAGES[:en][:greetings].sample,
            reply_markup: create_keyboard(:en)
          )
        when '🇷🇺 Русский'
          user_languages[user_id] = :ru
          bot.api.send_message(
            chat_id: message.chat.id,
            text: MESSAGES[:ru][:greetings].sample,
            reply_markup: create_keyboard(:ru)
          )
        when '🇷🇴 Română'
          user_languages[user_id] = :ro
          bot.api.send_message(
            chat_id: message.chat.id,
            text: MESSAGES[:ro][:greetings].sample,
            reply_markup: create_keyboard(:ro)
          )
        when MESSAGES[:en][:language_button], MESSAGES[:ru][:language_button], MESSAGES[:ro][:language_button]
          show_language_selection(message, bot, current_language)
        when MESSAGES[:en][:shake_button], MESSAGES[:ru][:shake_button], MESSAGES[:ro][:shake_button]
          bot.api.send_message(
            chat_id: message.chat.id,
            text: MESSAGES[current_language][:answers].sample,
            reply_markup: create_keyboard(current_language)
          )
        end
      rescue => e
        puts "Error processing message: #{e.message}"
        puts e.backtrace
      end
    end
  end
rescue Telegram::Bot::Exceptions::ResponseError => e
  puts "Telegram Bot Error: #{e.message}"
  puts "Please verify your token and make sure the bot is active"
rescue => e
  puts "Unexpected error: #{e.message}"
  puts e.backtrace
end


