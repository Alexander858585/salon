#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=bikes --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?\n"

services=$($psql "SELECT * FROM services")

display_services() {
  # display services
  echo "$services" | while read service_id bar name
  do
    echo "$service_id) $name"
  done
}

half_program() {
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-5]$ ]]
  then
    main_program "I could not find that service. What would you like today?"
  else
    echo "Good choice!"
    service_name=$($psql "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    customer_name_pre=$($psql "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $customer_name_pre ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      insert_customer=$($psql "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      customer_name_pre=$CUSTOMER_NAME
    fi
    echo -e "\nName: $customer_name_pre"
    customer_id=$($psql "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo -e "\n$customer_id"
    echo -e  "\nWhat time would you like your $service_name, $customer_name_pre?"
    read SERVICE_TIME
    insert_appointment=$($psql "INSERT INTO appointments(customer_id, service_id, time) VALUES($customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $service_name at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

main_program() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  display_services
  half_program
}

main_program