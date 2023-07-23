#!/bin/bash

# My mumber guessing game for freecodecamp

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo -e "Enter your username:"
read USER_NAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USER_NAME'")

if [[ -z $USER_ID ]]
then
  # New user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) values('$USER_NAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USER_NAME'")
  echo -e "Welcome, $USER_NAME! It looks like this is your first time here."
else
  USER_RESULT=$($PSQL "SELECT count(*) cnt, min(guess_num) best_guess_num FROM users left join games using (user_id) WHERE name = '$USER_NAME'")
  echo "$USER_RESULT" | while read GAMES_PLAYED BAR BEST_GAME
  do
    echo -e "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=1

echo -e "Guess the secret number between 1 and 1000:"

RUN(){
  if [[ $1 ]]
  then
    echo -e "$1"
  fi
  read USER_GUESS
  # if input is not a number
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    RUN "That is not an integer, guess again:"
  fi

  if (( $USER_GUESS == $SECRET_NUMBER ))
  then
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, secret_number, guess_num,win_flag) values($USER_ID, $SECRET_NUMBER,$NUMBER_OF_GUESSES,true)")
    echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  else
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
    if (( $USER_GUESS > $SECRET_NUMBER ))
    then
      RUN "It's lower than that, guess again:"
    else
      RUN "It's higher than that, guess again:"
    fi
  fi 
}

RUN

