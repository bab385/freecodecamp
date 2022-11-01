#!/bin/bash

# use this to access postgres throughout file
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# check if there are any arguments provided
if [[ $1 ]]
then
  # check if the argument is a number
  re='^[0-9]+$'
  if [[ $1 =~ $re ]]
  then
    # if argument is number
    ATOMIC_NUMBER=$($PSQL "SELECT * FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number=$1")
    # check to see if it found anything in the database
    if [[ -z $ATOMIC_NUMBER ]]
    then
      # print this if it didn't find anything
      echo "I could not find that element in the database."
    else
      # print this if it found the element in the db
      echo "$ATOMIC_NUMBER" | sed 's/|/ /g' | while read TYPE_ID ATOM_NUM SYMBOL ELEMENT_NAME MELT_POINT BOIL_POINT ATOM_MASS TYPE
      do
        echo -e "The element with atomic number $ATOM_NUM is $ELEMENT_NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOM_MASS amu. $ELEMENT_NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
      done
    fi
  else
    # if argument is not a number, check both the symbol and the name
    SYMBOL=$($PSQL "SELECT * FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE symbol='$1'")
    NAME=$($PSQL "SELECT * FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE name='$1'")
    # if both are blank, could not find element in the db
    if [[ -z $SYMBOL && -z $NAME ]]
    then
      # print this out if nothing is found
      echo "I could not find that element in the database."
    else
      # if symbol has something in it, use it
      if ! [[ -z $SYMBOL ]]
      then
        echo "$SYMBOL" | sed 's/|/ /g' | while read TYPE_ID ATOM_NUM SYMBOL ELEMENT_NAME MELT_POINT BOIL_POINT ATOM_MASS TYPE
        do
          echo -e "The element with atomic number $ATOM_NUM is $ELEMENT_NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOM_MASS amu. $ELEMENT_NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
        done
      fi
      # if name has something in it, use it
      if ! [[ -z $NAME ]]
      then
        echo "$NAME" | sed 's/|/ /g' | while read TYPE_ID ATOM_NUM SYMBOL ELEMENT_NAME MELT_POINT BOIL_POINT ATOM_MASS TYPE
        do
          echo -e "The element with atomic number $ATOM_NUM is $ELEMENT_NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOM_MASS amu. $ELEMENT_NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
        done
      fi
    fi
  fi
else
  # if no arguments are provided
  echo -e "Please provide an element as an argument."
fi