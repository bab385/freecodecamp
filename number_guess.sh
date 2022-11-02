#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# random number generator from 1 to 1000
SECRET_NUMBER=$(($(($RANDOM%1000))+1))

# look for username in db
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")

# if user does not exist
if [[ -z $USER_ID ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  # user already exists
  # get stats for existing user
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guess_count) FROM games WHERE user_id = $USER_ID")
  # if [[ GAMES_PLAYED = 1 ]]
  # then
  #   GAME_CHAR="game"
  # else
  #   GAME_CHAR="games"
  # fi
  # if [[ $BEST_GAME = 1 ]]
  # then
  #   GAME_CHAR="guess"
  # else
  #   GAME_CHAR="guesses"
  # fi
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# adding the game here
# establish variable to change in while loop
NUMBER_OF_GUESSES=1

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

if [[ $GUESS = $SECRET_NUMBER ]]
then
  if [[ -z $USER_ID ]]
  then
    USER_INSERT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
  fi
  GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guess_count) VALUES($USER_ID, $NUMBER_OF_GUESSES)")

  #print out the final result of the game
  echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
else
  # loop until the guess is correct
  while [ $GUESS != $SECRET_NUMBER ]
  do
    # if guess is not an integer
    re='^[0-9]+$'
    if ! [[ $GUESS =~ $re ]]
    then 
      echo "That is not an integer, guess again:"
      read GUESS
    else
      # guess must be an integer
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
      # is guess less than the secret number
      if [[ $GUESS < $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
        read GUESS
      # is guess greater than the secret number
      elif [[ $GUESS > $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
        read GUESS
      fi
    fi
  done
  if [[ -z $USER_ID ]]
  then
    USER_INSERT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
  fi
  GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guess_count) VALUES($USER_ID, $NUMBER_OF_GUESSES)")

  #print out the final result of the game
  echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
fi



