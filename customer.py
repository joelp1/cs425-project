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
		if ((given_password == password) & (bool(tombstone) != True)):
			global login_customer_id 
			login_customer_id = customer_id
			success = True
	csr.close()
	return success

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

def add_address(newCountry, newState, city, zipCode, street, aNumber, unit = None):
	success = False
	d = {"country":newCountry,"state":newState,"city":city,"zip":zipCode,"street":street,"num":aNumber,"unit":unit}
	csr = cnx.cursor()
	csr.execute("INSERT INTO Address(country,aState,city,zipCode,street,aNumber,unit) VALUES (%(country)s,%(state)s,%(city)s,%(zip)s,%(street)s,%(num)s,%(unit)s)", d)
	csr.execute("SELECT addressID FROM Address WHERE (country=%(country)s AND aState=%(state)s AND city=%(city)s AND zipCode=%(zip)s AND street=%(street)s AND aNumber=%(num)s AND unit=%(unit)s) LIMIT 1",d)
	for entry in csr:
		aid = int(str(entry)[1:3])
	csr.execute("INSERT INTO Customer_Address(customerID,addressID) VALUES (%(cid)s,%(aid)s)", {"cid":login_customer_id,"aid":aid})
	cnx.commit()
	csr.close()
	success = True
	return success

def update_address(newCountry, newState, city, zipCode, street, aNumber, unit = None):
	success = False
	csr = cnx.cursor()
	csr.execute("SELECT addressID FROM Customer_Address WHERE customerID = %(custID)s", {"custID":login_customer_id})
	addressID = csr
	csr.execute("UPDATE Address(country,aState,city,zipCode,street,aNumber,unit)")
	return success

def add_phone(phone, phone_type):
	success = False
	if login_customer_id != not_logged_in_id:
		csr = cnx.cursor()
		csr.execute("INSERT INTO Phone(phoneNumber,phoneType,customerID) VALUES (%(phone)s, %(type)s, %(id)s)", {"phone":phone,"type":phone_type,"id":login_customer_id})
		csr.close()
		cnx.commit()
		success = True
	return success


def update_phone(old_phone, updated_phone, phone_type):
	success = False
	d = {"newPhone":updated_phone, "custID":login_customer_id, "oldPhone":old_phone, "phoneType":phone_type}

	check_old_entry = ("SELECT * FROM Phone WHERE (customerID = %(custID)s AND phoneNumber = %(oldPhone)s AND phoneType = %(phoneType)s)")
	csr = cnx.cursor()
	csr.execute(check_old_entry,d)
	result = ""
	for entry in csr:
		result += str(result)

	if result.strip() == "": # if entry not there, create new one
		if add_phone(updated_phone, phone_type):
			success = True

	else:
		update_phone_query = ("UPDATE Phone SET phoneNumber = %(newPhone)s WHERE (customerID = %(custID)s AND phoneNumber = %(oldPhone)s AND phoneType = %(phoneType)s)")
		if (login_customer_id != not_logged_in_id):
			csr.execute(update_phone_query, d)
			success = True
	csr.close()
	cnx.commit()
	return success

def update_name(new_first_name, new_middle_name, new_last_name):
	success = False
	update_name_query = ("UPDATE Customer SET firstName = %(fn)s, middleName = %(mn)s, lastName = %(ln)s WHERE customerID = %(id)s")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(update_name_query, {"fn":new_first_name, "mn":new_middle_name, "ln":new_last_name, "id":login_customer_id})
		success = True
		csr.close()
		cnx.commit()
	return success

def update_email(new_email):
	success = False
	update_name_query = ("UPDATE Customer SET emailAddress = %(newEmail)s WHERE customerID = %(id)s")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(update_name_query, {"newEmail":new_email, "id":login_customer_id})
		success = True
		csr.close()
		cnx.commit()
	return success

def update_password(new_password):
	success = False
	update_name_query = ("UPDATE Customer SET password = %(newPassword)s WHERE customerID = %(id)s")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(update_name_query, {"newPassword":new_password, "id":login_customer_id})
		success = True
		csr.close()
		cnx.commit()
	return success

def delete_account():
	success = False
	delete_account = ("UPDATE Customer SET tombstone = True WHERE customerID = %(id)s")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(delete_account, {"id":login_customer_id})
		success = True
		logout()
		csr.close()
		cnx.commit()
	return success

def logout():
	global login_customer_id
	login_customer_id = not_logged_in_id
	g.msgbox("You have successfully logged out. Now returning to the main menu.")
	mainMenu()

def display():
	csr = cnx.cursor()
	string = ""
	csr.execute("SELECT * FROM Phone")
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
	cnx.commit()

def fixBirthday(bday):
	return datetime.date(int(bday[-4:]),int(bday[0:2]),int(bday[3:5]))

# ********************************************************************************************************************
# Transaction Functions
# ********************************************************************************************************************

def search_product(product_name):
	search_query = ("SELECT * "
		"FROM Product"
		"WHERE name LIKE '%%%s%%'") ##### What is this
	csr = cnx.cursor()
	csr.execute(search_query, (product_name))
	products = []
	for product in csr:
		products.append(product)
	csr.close()
	return products

def search_bundles(bundle_name):
	search_query = ("SELECT * "
		"FROM Bundle a"
		"NATURAL JOIN Product_Bundle b"
		"NATURAL JOIN Product c"
		"WHERE a.description LIKE '%%%s%%'") ###### What is this
	csr = cnx.cursor()
	csr.execute(search_query, (bundle_name))
	bundles = []
	for bundle in csr:
		bundles.append(bundle)
	csr.close()
	return bundles

def check_stock(product_id):
	search_query = ("SELECT 'ONLINE', SUM(quantityAvailable) "
		"FROM Product"
		"NATURAL JOIN Stock"
		"NATURAL JOIN Warehouse"
		"WHERE a.productID = %(pid)s"
		"AND storeID IS NULL"
		"UNION"
		"SELECT storeName, quantityAvailable"
		"FROM Product a"
		"NATURAL JOIN Stock b"
		"NATURAL JOIN Warehouse c"
		"NATURAL JOIN Store"
		"WHERE a.productID = %(pid)s"
		"AND storeID IS NOT NULL")
	csr = cnx.cursor()
	csr.execute(search_query, {"pid":product_id})
	warehouses = []
	for warehouse in csr:
		warehouses.append(warehouse)
	csr.close()
	return warehouses

def qualify_purchase_store_credit(product_id, quantity):
	return credit_check(price_check(product_id, quantity))

def price_check(product_id, quantity):
	query = ("SELECT (sellingPrice * %(quant)s) AS total_price"
		"FROM Store_Product"
		"WHERE productID = %(pid)s"
		"AND storeID = 1")
	csr = cnx.cursor()
	csr.execute(query, {"pid":product_id, "quant":quantity})
	total_price = None
	for (price) in csr:
		total_price = price
	csr.close()
	return total_price


def credit_check(purchase_amount):
	query = ("SELECT balance, maxCredit"
		"FROM Accountl"
		"WHERE customerID = %(id)s")
	csr = cnx.cursor()
	csr.execute(query, {"id":login_customer_id})
	has_enough_credit = None
	for (balance, maxCredit) in csr:
		has_enough_credit = ((balance + purchase_amount) < maxCredit)
	csr.close()
	return has_enough_credit


def qualify_purchase_available_stock(product_id, wanted_quantity):
	query = ("SELECT sum(quantityAvailable) AS quantity"
		"FROM Product"
		"NATURAL JOIN Stock"
		"NATURAL JOIN Warehouse"
		"WHERE productID = %(id)s"
		"AND storeID IS NULL")
	csr = cnx.cursor()
	csr.execute(query, {"id":product_id})
	has_enough_quantity = None
	for (quantity) in csr:
		has_enough_quantity = (wanted_quantity < quantity)
	csr.close()
	return has_enough_quantity


def purchase_with_store_credit():
	transaction = ("DELIMITER $$"
		"CREATE PROCEDURE reduceStock("
		"IN stock VARCHAR(15), "
		"IN quantity INT"
		"OUT warehouse_mapping VARCHAR(150) DEFAULT '')"
		"BEGIN"
		"DECLARE available INT DEFAULT 0;"
		"DECLARE warehouse VARCHAR(15);"
		"DECLARE leftOver INT DEFAULT 0"
		"test_loop: LOOP"
		"IF (quantity = 0) THEN"
		"LEAVE test_loop;"
		"END IF;"
		"SELECT warehouseID, quantityAvailable"
		"INTO warehouse, available"
		"FROM Stock"
		"WHERE stockID = stock"
		"HAVING quantityAvailable = MAX(quantityAvailable);"
		"IF (available >= quantity) THEN"
		"SET leftOver = quantity - available;"
		"UPDATE Stock"
		"SET quantityAvailable = leftOver"
		"WHERE warehouseID = warehouse"
		"AND stockID = stock;"
		"SET warehouse_mapping = CONCAT(warehouse, ':', quantity, ',', warehouse_mapping);"
		"LEAVE test_loop;"
		"END IF;"
		"IF (available < quantity) THEN"
		"SET leftOver = 0;"
		"SET quantity = quantity - available;"
		"UPDATE Stock"
		"SET quantityAvailable = leftOver"
		"WHERE warehouseID = warehouse"
		"AND stockID = stock;"
		"SET warehouse_mapping = CONCAT(warehouse, ':', available, ',', warehouse_mapping);"
		"END IF;"
		"END LOOP;"
		"END$$"
		"DELIMITER ;"
)

def purchase_with_credit_card():
	return

def view_transaction_history():
	csr = cnx.cursor()
	transaction_history_query = ("SELECT orderID, trackingNumber, orderDate, shipDate, companyName, name FROM (Customer_Order NATURAL JOIN Shipper NATURAL JOIN Product_Order NATURAL JOIN Product) WHERE customerID = %(id)s")
	csr.execute(transaction_history_query, {"id":login_customer_id})
	string = ""
	for (orderID, trackingNumber, orderDate, shipDate, shipperName, productName) in csr:
		string += "Order ID: "+str(orderID)+"\nOrder Date: "+str(orderDate)+"\nShip Date: "+str(shipDate)
		string += "\nProduct Name: "+str(productName)+"\nShipment Company: "+str(shipperName)
		string += "\nTracking ID: "+str(trackingNumber) +"\n\n\n"
	if string.strip() == "":
		string = "You have no transaction history"
	csr.close()
	g.msgbox(string, "Transaction History")
	menu()

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

		if login(userEmail, userPassword):
			menu()
		else:
			g.msgbox("Failed login.")
			mainMenu()

	elif input == "Guest":
		login_cust_id = 0
		display()
		menu()

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
		g.msgbox("Your account is now registered.")
		login(fieldValues[4], fieldValues[5])

		menu()

	else:
		sys.exit()

def menu():
	msg = "Welcome! What would you like to do?"
	title = "Home"
	options = ["Account Management", "View Transaction History", "Shop", "Logout", "Quit"]

	input = g.buttonbox(msg, title, options)
	if input == "Account Management":
		if login_customer_id != not_logged_in_id:
			accountManagement()
		else:
			g.msgbox("You are not logged in. Please select another option.")
			menu()
	elif input == "Quit":
		sys.exit()
	elif input == "Logout":
		logout()
	elif input == "Shop":
		shop()
	else:
		if login_customer_id != not_logged_in_id:
			view_transaction_history()
		else:
			g.msgbox("You are not logged in. Please select another option.")
			menu()

def accountManagement():
	msg = "Welcome to Account Management. Please select an option."
	title = "Account Management"
	fieldNames = ["Update Name", "Update Email", "Update Password", "Update Phone", "Update Address", "Delete Account", "Go Back"]
	input = g.buttonbox(msg, title, fieldNames)

	if input == "Go Back":
		menu()

	elif input == "Delete Account":
		delete_account()

	elif input == "Update Phone":
		addOrUpdate = g.buttonbox("Please select one of the following:","Update Phone",("Add","Update","Cancel"))

		if addOrUpdate == "Cancel":
			accountManagement()
		elif addOrUpdate == "Add":
			msg = "Please fill out the form below."
			title = "New Phone"
			fieldValues = []
			fieldNames = ["Phone Number", "Phone Type"]
			fieldValues = g.multenterbox(msg, title, fieldNames)

			while 1:
				if fieldValues == None: break

				errmsg = ""
			
				for i in range(len(fieldNames)):
					if (fieldValues[i].strip() == ""):
						errmsg = errmsg + ('"%s" is a required field.\n\n' % fieldNames[i])

				if errmsg == "": break # no problems found

				fieldValues = g.multenterbox(errmsg, title, fieldNames, fieldValues)

			if add_phone(fieldValues[0],fieldValues[1]):
				g.msgbox("Phone successfully added.")
			else:
				g.msgbox("Unable to add phone. Returning to Account Management")
			accountManagement()
		else:
			msg = "Please fill out the form below."
			title = "Update Phone"
			fieldValues = []
			fieldNames = ["Old Phone", "New Phone", "Phone Type"]
			fieldValues = g.multenterbox(msg, title, fieldNames)

		# checks for blanks, repeat until all fields submitted
			while 1:
				if fieldValues == None: break
				errmsg = ""
			
				for i in range(len(fieldNames)):
					if (fieldValues[i].strip() == ""):
						errmsg = errmsg + ('"%s" is a required field.\n\n' % fieldNames[i])

				if errmsg == "": break # no problems found

				fieldValues = g.multenterbox(errmsg, title, fieldNames, fieldValues)

			if update_phone(fieldValues[0],fieldValues[1],fieldValues[2]):
				g.msgbox("Phone number successfully updated.")
			else:
				g.msgbox("Unable to update phone. Returning to Account Management")
			accountManagement()

	elif input == "Update Name":
		msg = "Please enter your updated name."
		title = "Update Name"
		fieldValues = []
		fieldNames = ["First Name", "Middle Name", "Last Name"]
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

		if update_name(fieldValues[0], fieldValues[1], fieldValues[2]):
			g.msgbox("Name successfully updated.", "Success!")
			accountManagement()
		else:
			g.msgbox("Name change unsuccessful. Returning to Account Management.")
			accountManagement()

	elif input == "Update Email":
		msg = "Please enter your new email address."
		title = "Change email"
		newEmail = g.enterbox(msg, title)

		if update_email(newEmail):
			g.msgbox("Email successfully updated.")
			accountManagement()
		else:
			g.msgbox("Unable to update email address. Returning to Account Management.")
			accountManagement()

	elif input == "Update Password":
		msg = "Please enter your new password."
		title = "Change password"
		newPassword = g.enterbox(msg, title)

		if update_password(newPassword):
			g.msgbox("Password successfully changed.")
			accountManagement()
		else:
			g.msgbox("Unable to update password. Returning to Account Management.")
			accountManagement()

	else: # update address
		addOrUpdate = g.buttonbox("Do you want to add or update an address?","Update Address", ("Add", "Update", "Cancel"))
		if addOrUpdate == "Cancel":
			accountManagement()

		msg = "Please give us your personal data that we totally will not sell"
		title = "Register Account"
		fieldValues = []
		fieldNames = ["Country", "State", "City", "Zip Code", "Street", "Street Number", "Unit"]
		fieldValues = g.multenterbox(msg, title, fieldNames)

		# checks for blanks, repeat until all fields submitted
		while 1:
			if fieldValues == None: break
			errmsg = ""
			
			for i in range(len(fieldNames)):
				if (fieldValues[i].strip() == "") & (i != 6):
					errmsg = errmsg + ('"%s" is a required field.\n\n' % fieldNames[i])

			if errmsg == "": break # no problems found

			fieldValues = g.multenterbox(errmsg, title, fieldNames, fieldValues)

		csr = cnx.cursor()
		csr.execute("SELECT * FROM Customer_Address WHERE customerID = %(id)s", {"id":login_customer_id})
		string = ""
		for entry in csr:
			string += entry
		csr.close()

		addressRegistered = False
		addressConnected = False

		if string.strip() == "": #add address if no address already registered
			if add_address(fieldValues[0],fieldValues[1],fieldValues[2],fieldValues[3],fieldValues[4],fieldValues[5],fieldValues[6]):
				g.msgbox("Address successfully added.")
			else:
				g.msgbox("Unable to add address. Returning to Account Management")
			accountManagement()
		else:
			if update_address(fieldValues[0],fieldValues[1],fieldValues[2],fieldValues[3],fieldValues[4],fieldValues[5],fieldValues[6]):
				g.msgbox("Address successfully updated.")
			else:
				g.msgbox("Unable to update address. Returning to Account Management.")
			accountManagement()

# ********************************************************************************************************************
# Driver
# ********************************************************************************************************************

mainMenu()