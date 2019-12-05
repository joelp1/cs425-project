import easygui
import mysql.connector
cnx = mysql.connector.connect(user='admin', password='1Sw9#Aj119&q',
                              host='cs423project2019fall.cluster-c3cnrrte9qrk.us-east-2.rds.amazonaws.com',
                              database='cs_project')
not_logged_in_id = 1
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
		"(maxCredit, usedCredit, mpr, customerID"
		"VALUES (%s, %s, %s, %s)")
	csr.execute(create_account, (0, 0, 0, login_customer_id))
	cnx.commit()
	csr.close()
	success = True
	return success

def update_address(address_id, new_country, new_aState, new_city, new_zip, new_street, new_aNumber, new_unit):
	success = False
	update_address_query = ("UPDATE Address"
		"SET country = %s, aState = %s, city = %s, zipCode = %s, street = %s, aNumber = %s, unit = %s"
		"WHERE address_id =  %s")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(update_address_query, (new_country, new_aState, new_city, new_zip, new_street, new_aNumber, new_unit, address_id))
		cnx.commit()
		success = True
		csr.close()
	return success

def add_address(new_address_id, new_country, new_aState, new_city, new_zip, new_street, new_aNumber, new_unit):
	success = False
	add_address_query = ("INSERT INTO Address"
		"(addressID, country, aState, city, zipCode, street, aNumber, unit)"
		"VALUES (%s, %s, %s, %s, %s, %s, %s, %s, )")
	add_customer_address_query = ("INSERT INTO Customer_Address"
		"(customerID, addressID)"
		"VALUES (%s, %s)")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(add_address_query, (new_address_id, jnew_country, new_aState, new_city, new_zip, new_street, new_aNumber, new_unit, address_id))
		csr.execute(add_customer_address_query, (new_address_id, login_customer_id))
		cnx.commit()
		success = True
		csr.close()
	return success

def update_phone(old_phone, updated_phone):
	success = False
	update_phone_query = ("UPDATE Phone"
		"SET phoneNumber = %s"
		"WHERE customer_id = %s"
		"AND phoneNumber = %s")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(update_phone_query, (updated_phone, login_customer_id, old_phone))
		cnx.commit()
		success = True
		csr.close()
	return success

def add_phone(phone, phone_id):
	success = False
	add_phone_query = ("INSERT INTO Phone"
		"(phoneNumber, phoneType, customerID"
		"VALUES (%s, %s, %s)")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(add_phone_query, (phone, phone_id, login_customer_id))
		cnx.commit()
		success = True
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
		cnx.commit()
		success = True
		csr.close()
	return success

def update_email(new_email):
	success = False
	update_email_query = ("UPDATE Customer"
		"SET emailAddress = %s"
		"WHERE customer_id = %s")
	if (login_customer_id != not_logged_in_id):
		csr = cnx.cursor()
		csr.execute(update_email_query, (new_email, login_customer_id))
		cnx.commit()
		success = True
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
		cnx.commit()
		success = True
		logout()
		csr.close()
	return success

def logout():
	login_customer_id = not_logged_in_id

def search_product(product_name):
	search_query = ("SELECT * "
		"FROM Product"
		"WHERE name LIKE '%%%s%%'")
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
		"WHERE a.description LIKE '%%%s%%'")
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
		"WHERE a.productID = %s"
		"AND storeID IS NULL"
		"UNION"
		"SELECT storeName, quantityAvailable"
		"FROM Product a"
		"NATURAL JOIN Stock b"
		"NATURAL JOIN Warehouse c"
		"NATURAL JOIN Store"
		"WHERE a.productID = %s"
		"AND storeID IS NOT NULL")
	csr = cnx.cursor()
	csr.execute(search_query, (product_id, product_id))
	warehouses = []
	for warehouse in csr:
		warehouses.append(warehouse)
	csr.close()
	return warehouses

def qualify_purchase_store_credit(product_id, quantity):
	return credit_check(price_check(product_id, quantity))

def price_check(product_id, quantity):
	query = ("SELECT (sellingPrice * %s) AS total_price"
		"FROM Store_Product"
		"WHERE productID = %s"
		"AND storeID = 1")
	csr = cnx.cursor()
	csr.execute(query, (product_id, quantity))
	total_price = None
	for (price) in csr:
		total_price = price
	csr.close()
	return total_price


def credit_check(purchase_amount):
	query = ("SELECT balance, maxCredit"
		"FROM Accountl"
		"WHERE customerID = %s")
	csr = cnx.cursor()
	csr.execute(query, (login_customer_id))
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
		"WHERE productID = %s"
		"AND storeID IS NULL")
	csr = cnx.cursor()
	csr.execute(query, (product_id))
	has_enough_quantity = None
	for (quantity) in csr:
		has_enough_quantity = (wanted_quantity < quantity)
	csr.close()
	return has_enough_quantity


def purchase_with_store_credit:
	

def purchase_with_credit_card

def get_purchase_history():





