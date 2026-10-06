#! /bin/bash

if [[ $1 == "test" ]]
then
  DATABASE_NAME="worldcup_test"
else
  DATABASE_NAME="worldcup"
fi

PSQL="psql --username=freecodecamp --dbname=$DATABASE_NAME -t --no-align -c"

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear existing data to avoid duplicates when re-running
echo $($PSQL "TRUNCATE TABLE games, teams;")

# Read games.csv line by line (skipping the header)
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # 1. Get winner_id from teams table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    # If winner doesn't exist, insert them
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams: $WINNER
      fi
      # Retrieve the newly inserted winner_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # 2. Get opponent_id from teams table
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    # If opponent doesn't exist, insert them
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams: $OPPONENT
      fi
      # Retrieve the newly inserted opponent_id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # 3. Insert the game record using the fetched IDs
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into games: $YEAR, $ROUND, $WINNER_ID vs $OPPONENT_ID
    fi
  fi
done