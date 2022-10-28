
greetings = [
  'Hello, dear friend. Put your question...',
  "Buenos dias, amigo. Let's try to find answer...",
  'Hi. Want You want to ask?' ]

answers = [
  'It is certain',
  'Reply hazy, try again',
  'Don’t count on it',
  'It is decidedly so',
  'Ask again later',
  'My reply is no',
  'Without a doubt',	
  'Better not tell you now',
  'My sources say no',
  'Yes definitely	',
  'Cannot predict now',
  'Outlook not so good',
  'You may rely on it',
  'Concentrate and ask again',
  'Very doubtful',
  'As I see it, yes',
  'Most likely',
  'Outlook good',
  'Yes',
  'Signs point to yes']

  puts greetings.sample
  sleep 2 #wait 2 second after greetings

  puts "Aks me and press 'Enter' (shake the ball)"
  answ = gets.strip
  
  if answ == ""
  	puts answers.sample
  end


