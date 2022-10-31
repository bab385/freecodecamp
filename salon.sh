#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n ~~~~ Salon Appointments ~~~~\n"
echo -e "We offer the following services:"
AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")

MAIN_MENU() {
  # show user available services
  echo "$AVAILABLE_SERVICES" | sed 's/|/ /' | while read SERVICE_ID SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  echo -e "\nPlease choose a service by entering a number:"
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # check to see if service exists
  if [[ -z $SERVICE_NAME ]]
  # send to main menu
  then
    echo -e "\nThat service is not offered here."
    MAIN_MENU
  # if service exists
  else
    # get phone number
    echo -e "\nPlease provide your phone number:"
    read CUSTOMER_PHONE
    # look up customer by phone number
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if customer does not exist
    if [[ -z $CUSTOMER_ID ]]
    then
      # add new customer
      echo -e "\nYou must be a new customer. Please provide your name:"
      read CUSTOMER_NAME
      # add customer to list
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    else
      # customer already exists
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
    fi
    echo -e "\nThank you $CUSTOMER_NAME. What time would you like your appointment for $SERVICE_NAME?"
    read SERVICE_TIME
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    # send to main menu
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU