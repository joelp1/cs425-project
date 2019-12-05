import easygui as g
import mysql.connector
import datetime
import sys
cnx = mysql.connector.connect(user='admin', password='1Sw9#Aj119&q',
                              host='cs423project2019fall.cluster-c3cnrrte9qrk.us-east-2.rds.amazonaws.com',
                              database='cs_project')

not_logged_in_id = 0
login_customer_id = not_logged_in_id

def login(email, given_password):
	success = False
	query = ("SELECT password, customerID, tombstone FROM Customer WHERE emailAddress = %(email)s")
	csr = cnx.cursor()
	csr.execute(query, {"email":email})
	for (password, customer_id, tombstone) in csr:
		g.msgbox(customer_id)
		if ((given_password == password) & (bool(tombstone) != True)):
			login_customer_id = customer_id
			success = True
	csr.close()
	return success

def get_customer_id():
	return login_customer_id

def register(given_first_name, given_middle_name, given_last_name, given_birthday, given_email, given_password):
	success = False
	check_existing_account = ("SELECT * FROM Customer WHERE emailAddress = %(email)s")

	given_birthday = fixBirthday(given_birthday)

	csr = cnx.cursor()
	csr.execute(check_existing_account, {"email": given_email})

	for (email) in csr:
		if (email == given_email):
			return success

	create_customer = ("INSERT INTO Customer(firstName, middleName, lastName, birthDate, emailAddress, password) VALUES (%(first)s, %(mid)s, %(last)s, %(bday)s, %(email)s, %(pw)s)")
	d = {"first":given_first_name, "mid":given_middle_name, "last":given_last_name, "bday":given_birthday, "email":given_email, "pw":given_password}
	csr.execute(create_customer, d)
	login_customer_id = csr.lastrowid

	create_account = ("INSERT INTO Account(customerID, maxCredit, balance, mpr) VALUES (%(id)s, %(max)s, %(balance)s, %(mpr)s)")
	csr.execute(create_account, {"max":0,"balance":0, "id":login_customer_id, "mpr":0.0})
	cnx.commit()
	csr.close()
	success = True
	return success

def update_address():
	# CODE STILL NEEDS TO BE IMPLEMENTED
	return

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
	update_name_query = ("UPDATE Customer SET emailAddress = %(newEmail)s WHERE customer_id = %(id)s")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(update_name_query, {"newEmail":new_email, "id":login_customer_id})
		success = True
		csr.close()
	return success

def delete_account():
	success = False
	delete_account = ("UPDATE Customer SET tombstone = TRUE WHERE customer_id = %s")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(delete_account, (login_customer_id))
		success = TRUE
		logout()
		csr.close()
	return success

def logout():
	login_customer_id = not_logged_in_id

def display():
	csr = cnx.cursor()
	string = ""
	csr.execute("SELECT * FROM Customer")
	for entry in csr:
		string += str(entry) + "\n\n"
	string = string.strip()
	csr.close()
	g.msgbox(string)

def administrative_delete(id): # permanently deletes account
	csr = cnx.cursor()
	csr.execute("DELETE FROM Account WHERE customerID = %(id)s", {"id":id})
	csr.execute("DELETE FROM Customer WHERE customerID = %(id)s", {"id":id})
	csr.close()

def fixBirthday(bday):
	return datetime.date(int(bday[-4:]),int(bday[0:2]),int(bday[3:5]))

# ********************************************************************************************************************
# Driver Functions
# ********************************************************************************************************************

def mainMenu():
	# welcomes the user and gives them the option to login and prompts them for an action
	input = g.buttonbox("Welcome to the OSJPNT Electonic Vendor Service!", "Welcome!", ('Login', "Guest", "Create An Account", "Quit"))

	if input == "Login":
		msg = "Please enter your email address."
		title = "Login"

		userEmail = g.enterbox(msg, title)

		msg = "Please surrender your password"
		userPassword = g.passwordbox(msg, title)

		login(userEmail, userPassword)

	elif input == "Guest":
		login_cust_id = 99999
		display()
	elif input == "Create An Account":

		# box text
		msg = "Please give us your personal data that we totally will not sell"
		title = "Register Account"
		fieldValues = []
		fieldNames = ["First Name", "Middle Name", "Last Name", "Birthday", "Email", "Password"]
		fieldValues = g.multenterbox(msg, title, fieldNames)

		# checks for blanks, repeat until all fields submitted
		while 1:
		    if fieldValues == None: break
		    errmsg = ""
		    
		    for i in range(len(fieldNames)):
		    	if fieldValues[i].strip() == "":
		    		errmsg = errmsg + ('"%s" is a required field.\n\n' % fieldNames[i])

		    if errmsg == "": break # no problems found

		    fieldValues = g.multenterbox(errmsg, title, fieldNames, fieldValues)

		register(fieldValues[0], fieldValues[1], fieldValues[2], fieldValues[3], fieldValues[4], fieldValues[5])
		g.msgbox("Your account is now registered. Redirecting you back to the main menu.")
		mainMenu()
	else:
		sys.exit()

def menu(name):
	msg = "Welcome %s! What would you like to do?" % name
	title = "Home"
	options = ["Account Management", "View Transaction History", "Shop", "Logout", "Quit"]

	input = g.buttonbox(msg, title, options)

# ********************************************************************************************************************
# Driver
# ********************************************************************************************************************

csr = cnx.cursor()
csr.execute("INSERT INTO Customer(customerID, firstName, middleName, lastName, birthDate, emailAddress, password) VALUES (%(id)s, %(fn)s, %(mn)s, %(ln)s, %(b)s, %(e)s, %(p)s)",
	{"id":99999,"fn":"Guest","mn":"","ln":"","b":"","e":"","p":"password"})
csr.close()
mainMenu()

