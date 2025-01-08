require 'telegram/bot'

# Получаем токен напрямую из переменных окружения
token = ENV['TELEGRAM_BOT_TOKEN']
if token.nil? || token.empty?
  puts "ERROR: Token not found in environment variables!"
  puts "Please set TELEGRAM_BOT_TOKEN in Railway Variables"
  exit 1
end

puts "Starting bot..."

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
      'My answer: It is certain',
      'My answer: Reply hazy, try again',
      'My answer: Don\'t count on it',
      'My answer: It is decidedly so',
      'My answer: Ask again later',
      'My answer: My reply is no',
      'My answer: Without a doubt',
      'My answer: Better not tell you now',
      'My answer: My sources say no',
      'My answer: Yes definitely',
      'My answer: Cannot predict now',
      'My answer: Outlook not so good',
      'My answer: You may rely on it',
      'My answer: Concentrate and ask again',
      'My answer: Very doubtful',
      'My answer: As I see it, yes',
      'My answer: Most likely',
      'My answer: Outlook good',
      'My answer: Yes',
      'My answer: Signs point to yes'
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
      'Мой ответ: Бесспорно',
      'Мой ответ: Попробуй спросить позже',
      'Мой ответ: Даже не думай',
      'Мой ответ: Определённо да',
      'Мой ответ: Спроси снова',
      'Мой ответ: Мой ответ - нет',
      'Мой ответ: Несомненно',
      'Мой ответ: Лучше не говорить',
      'Мой ответ: Мои источники говорят нет',
      'Мой ответ: Однозначно да',
      'Мой ответ: Сейчас не могу предсказать',
      'Мой ответ: Перспективы не очень хорошие',
      'Мой ответ: Можешь быть уверен в этом',
      'Мой ответ: Сконцентрируйся и спроси снова',
      'Мой ответ: Весьма сомнительно',
      'Мой ответ: Как я вижу, да',
      'Мой ответ: Вероятнее всего',
      'Мой ответ: Хорошие перспективы',
      'Мой ответ: Да',
      'Мой ответ: Знаки говорят да'
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
      'Răspunsul meu: Este cert',
      'Răspunsul meu: Răspuns neclar, încearcă din nou',
      'Răspunsul meu: Nu conta pe asta',
      'Răspunsul meu: Este în mod decisiv așa',
      'Răspunsul meu: Întreabă din nou mai târziu',
      'Răspunsul meu: Răspunsul meu este nu',
      'Răspunsul meu: Fără îndoială',
      'Răspunsul meu: Mai bine să nu-ți spun acum',
      'Răspunsul meu: Sursele mele spun nu',
      'Răspunsul meu: Da, cu siguranță',
      'Răspunsul meu: Nu pot prezice acum',
      'Răspunsul meu: Perspectivele nu sunt bune',
      'Răspunsul meu: Te poți baza pe asta',
      'Răspunsul meu: Concentrează-te și întreabă din nou',
      'Răspunsul meu: Foarte îndoielnic',
      'Răspunsul meu: După cum văd eu, da',
      'Răspunsul meu: Cel mai probabil',
      'Răspunsul meu: Perspectivele sunt bune',
      'Răspunsul meu: Da',
      'Răspunsul meu: Semnele indică da'
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


