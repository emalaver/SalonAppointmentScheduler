PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # get services
  GET_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")

  echo "$GET_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  read SERVICE_ID_SELECTED

  MAX_SERVICE_ID=$($PSQL "SELECT max(service_id) FROM services")

  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-$(echo $MAX_SERVICE_ID)]+$ ]]
  then
	  MAIN_MENU "I could not find that service. What would you like today?"
  else
	  # get customer phone  
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if customer doesn't exist
    if [[ -z $CUSTOMER_ID ]]
    then
      # ask costumer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
    
      # insert customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    
      # get new customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi

    # get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")

    # get service name
    SERVICE_NAME_SET=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") 

    # get service time
    echo -e "\nWhat time would you like your$SERVICE_NAME_SET,$CUSTOMER_NAME?"
    read SERVICE_TIME
  
    # insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

    # show customer message
    echo -e "\nI have put you down for a$SERVICE_NAME_SET at $SERVICE_TIME,$CUSTOMER_NAME."
  fi
}

MAIN_MENU "Welcome to The reformatted beauty, how can I help you?"
