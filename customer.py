import easygui
import mysql.connector
cnx = mysql.connector.connect(user='admin', password='1Sw9#Aj119&q',
                              host='cs423project2019fall.cluster-c3cnrrte9qrk.us-east-2.rds.amazonaws.com',
                              database='cs_project')
not_logged_in_id = 0
login_customer_id = not_logged_in_id

def login(email, given_password):
	success = False
	query = ("SELECT password, customerID, tombstone" 
		"FROM Account"
		"WHERE emailAddress = %s")
	csr = cnx.cursor()
	csr.execute(query, (email))
	for (password, customer_id, tombstone) in csr:
		if (given_password == password & tombstone != True):
			login_customer_id = customer_id
			success = True
	csr.close()
	return success

def register(given_first_name, given_middle_name, given_last_name, given_birthday, given_email, given_password):
	success = False
	check_existing_account = ("SELECT Email"
		"FROM customer"
		"WHERE emailAddress = %s")
	csr = cnx.cursor()
	csr.execute(check_existing_account, (email))
	for (email) in csr:
		if (email == given_email):
			return success

	create_customer = ("INSERT INTO Customer"
		"(firstName, middleName, lastName, birthDate, emailAddress, password)"
		"VALUES (%s, %s, %s, %s, %s, %s)")
	csr.execute(create_customer, (given_first_name, given_middle_name, given_last_name, given_birthday, given_email, given_password))
	login_customer_id = csr.lastrowid

	create_account = ("INSERT INTO Account"
		"(maxCredit, usedCredit, customerID"
		"VALUES (%s, %s, %s)")
	csr.execute(create_account, (0,0, login_customer_id))
	cnx.commit()
	csr.close()
	success = True
	return success

def update_address():

def update_phone(old_phone, updated_phone):
	success = False
	update_phone_query = ("UPDATE Phone"
		"SET phoneNumber = %s"
		"WHERE customer_id = %s"
		"AND phoneNumber = %s")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(update_phone_query, (updated_phone, login_customer_id, old_phone))
		success = TRUE
		csr.close()
	return success

def update_name(new_first_name, new_middle_name, new_last_name):
	success = False
	update_name_query = ("UPDATE Customer"
		"SET firstName = %s, middleName = %s, last_name = %s"
		"WHERE customer_id = %s")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(update_name_query, (new_first_name, new_middle_name, new_last_name, login_customer_id))
		success = TRUE
		csr.close()
	return success

def update_email(new_email):
	success = False
	update_name_query = ("UPDATE Customer"
		"SET emailAddress = %s"
		"WHERE customer_id = %s")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(update_name_query, (new_email, login_customer_id))
		success = TRUE
		csr.close()
	return success

def delete_account():
	success = False
	delete_account = ("UPDATE customer"
		"SET tombstone = TRUE"
		"WHERE customer_id = %s")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(delete_account, (login_customer_id))
		success = TRUE
		logout()
		csr.close()
	return success

def logout():
	login_customer_id = not_logged_in_id

