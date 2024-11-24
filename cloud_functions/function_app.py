import os
import mysql.connector
import json
import azure.functions as func
import logging
import datetime

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="get_expenses", methods=['GET'])
def get_expenses(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('HTTP GET request received for get_expenses.')

    # Retrieve MySQL connection parameters from environment variables
    host = os.environ.get('DB_HOST')
    user = os.environ.get('DB_USER')
    password = os.environ.get('DB_PASSWORD')
    database = os.environ.get('DB_DATABASE')

    if not all([host, user, password, database]):
        logging.error("MySQL connection parameters are not fully set in environment variables.")
        return func.HttpResponse(
            "Database connection settings are incomplete.",
            status_code=500
        )

    try:
        # Establish a connection to the MySQL database
        conn = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database
        )

        cursor = conn.cursor(dictionary=True)

        # Execute a query to retrieve all expenses
        query = "SELECT * FROM Expenses"
        cursor.execute(query)
        results = cursor.fetchall()

        cursor.close()
        conn.close()

        if results:
            # Convert the query results to JSON
            response_body = json.dumps(results, default=str)
            return func.HttpResponse(
                response_body,
                mimetype="application/json",
                status_code=200
            )
        else:
            return func.HttpResponse(
                "No expenses found.",
                status_code=404
            )

    except mysql.connector.Error as err:
        logging.error(f"MySQL Error: {err}")
        return func.HttpResponse(
            "Database error occurred.",
            status_code=500
        )
    except Exception as e:
        logging.error(f"Unexpected Error: {e}")
        return func.HttpResponse(
            "An unexpected error occurred.",
            status_code=500
        )
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


@app.route(route="add_expense", methods=['POST'])
def add_expense(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('HTTP POST request received for add_expense.')

    # Retrieve MySQL connection parameters from environment variables
    host = os.environ.get('DB_HOST')
    user = os.environ.get('DB_USER')
    password = os.environ.get('DB_PASSWORD')
    database = os.environ.get('DB_DATABASE')

    if not all([host, user, password, database]):
        logging.error("MySQL connection parameters are not fully set in environment variables.")
        return func.HttpResponse(
            "Database connection settings are incomplete.",
            status_code=500
        )

    conn = None  # Initialize connection variable
    cursor = None
    try:
        # Parse the request body to extract the expense data
        req_body = req.get_json()
        if not req_body:
            return func.HttpResponse(
                "Request body is empty.",
                status_code=400
            )

        # Extract fields from request body
        user_id = req_body.get('userId')
        amount = req_body.get('amount')
        category_id = req_body.get('categoryId')
        description = req_body.get('description')
        receipt_url = req_body.get('receiptUrl') # Optional field
        date = req_body.get('date')
        created_at = req_body.get('createdAt') 

        # Validate required fields
        if not all([user_id, amount, category_id, description, date, created_at]):
            return func.HttpResponse(
                "Request body is missing required fields.",
                status_code=400
            )

        # Establish a connection to the MySQL database
        conn = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database
        )

        cursor = conn.cursor()

        # Prepare the SQL query
        query = """
            INSERT INTO Expenses (
                userId, amount, categoryId, description, receiptUrl, date, createdAt
            ) VALUES (%s, %s, %s, %s, %s, %s, %s)
        """

        # Execute the query
        cursor.execute(query, (
            user_id, amount, category_id,
            description, receipt_url, date, created_at
        ))
        conn.commit()

        return func.HttpResponse(
            "Expense added successfully.",
            status_code=201
        )

    except mysql.connector.Error as err:
        logging.error(f"MySQL Error: {err}")
        return func.HttpResponse(
            "Database error occurred.",
            status_code=500
        )
    except Exception as e:
        logging.error(f"Unexpected Error: {e}")
        return func.HttpResponse(
            "An unexpected error occurred.",
            status_code=500
        )
    finally:
        # Ensure the cursor and connection are closed
        if cursor is not None:
            cursor.close()
        if conn is not None and conn.is_connected():
            conn.close()


@app.route(route="get_categories", methods=['GET'])
def get_categories(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('HTTP GET request received for get_categories.')

    # Retrieve MySQL connection parameters from environment variables
    host = os.environ.get('DB_HOST')
    user = os.environ.get('DB_USER')
    password = os.environ.get('DB_PASSWORD')
    database = os.environ.get('DB_DATABASE')

    if not all([host, user, password, database]):
        logging.error("MySQL connection parameters are not fully set in environment variables.")
        return func.HttpResponse(
            "Database connection settings are incomplete.",
            status_code=500
        )

    try:
        # Establish a connection to the MySQL database
        conn = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database
        )

        cursor = conn.cursor(dictionary=True)

        # Execute a query to retrieve all categories
        query = "SELECT * FROM Categories"
        cursor.execute(query)
        results = cursor.fetchall()

        cursor.close()
        conn.close()

        if results:
            # Convert the query results to JSON
            response_body = json.dumps(results, default=str)
            return func.HttpResponse(
                response_body,
                mimetype="application/json",
                status_code=200
            )
        else:
            return func.HttpResponse(
                "No categories found.",
                status_code=404
            )

    except mysql.connector.Error as err:
        logging.error(f"MySQL Error: {err}")
        return func.HttpResponse(
            "Database error occurred.",
            status_code=500
        )
    except Exception as e:
        logging.error(f"Unexpected Error: {e}")
        return func.HttpResponse(
            "An unexpected error occurred.",
            status_code=500
        )
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


# TODO: TEST THIS FUNCTION
@app.route(route="add_receipt", methods=['POST'])
def add_receipt(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('HTTP POST request received for add_receipt.')

    # Retrieve MySQL connection parameters from environment variables
    host = os.environ.get('DB_HOST')
    user = os.environ.get('DB_USER')
    password = os.environ.get('DB_PASSWORD')
    database = os.environ.get('DB_DATABASE')

    if not all([host, user, password, database]):
        logging.error("MySQL connection parameters are not fully set in environment variables.")
        return func.HttpResponse(
            "Database connection settings are incomplete.",
            status_code=500
        )

    try:
        # Establish a connection to the MySQL database
        conn = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database
        )

        cursor = conn.cursor()

        # Parse the request body to extract the receipt data
        req_body = req.get_json()
        if not req_body:
            return func.HttpResponse(
                "Request body is empty.",
                status_code=400
            )

        # Extract fields from request body
        expense_id = req_body.get('expenseId')
        receipt_url = req_body.get('receiptUrl')
        created_at = datetime.datetime.now().isoformat()

        # Validate required fields
        if not all([expense_id, receipt_url, created_at]):
            return func.HttpResponse(
                "Request body is missing required fields.",
                status_code=400
            )
        
        # TODO: Retrieve the expense from the database to ensure it exists, then create a new row in the Receipts table with the receipt URL and the current timestamp.

        # Prepare the SQL query
        query = "UPDATE Expenses SET receiptUrl = %s WHERE id = %s"

        # Execute the query
        cursor.execute(query, (receipt_url, expense_id))
        conn.commit()

        return func.HttpResponse(
            "Receipt added successfully.",
            status_code=201
        )
    
    except mysql.connector.Error as err:
        logging.error(f"MySQL Error: {err}")
        return func.HttpResponse(
            "Database error occurred.",
            status_code=500
        )
    except Exception as e:
        logging.error(f"Unexpected Error: {e}")
        return func.HttpResponse(
            "An unexpected error occurred.",
            status_code=500
        )
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# TODO: TEST THIS FUNCTION
@app.route(route="delete_expense", methods=['DELETE'])
def delete_expense(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('HTTP DELETE request received for delete_expense.')

    # Retrieve MySQL connection parameters from environment variables
    host = os.environ.get('DB_HOST')
    user = os.environ.get('DB_USER')
    password = os.environ.get('DB_PASSWORD')
    database = os.environ.get('DB_DATABASE')

    if not all([host, user, password, database]):
        logging.error("MySQL connection parameters are not fully set in environment variables.")
        return func.HttpResponse(
            "Database connection settings are incomplete.",
            status_code=500
        )

    try:
        # Establish a connection to the MySQL database
        conn = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database
        )

        cursor = conn.cursor()

        # Parse the request body to extract the expense ID
        req_body = req.get_json()
        if not req_body:
            return func.HttpResponse(
                "Request body is empty.",
                status_code=400
            )

        # Extract the expense ID from the request body
        expense_id = req_body.get('expenseId')
        if not expense_id:
            return func.HttpResponse(
                "Request body is missing required fields.",
                status_code=400
            )

        # Prepare the SQL query
        query = "DELETE FROM Expenses WHERE id = %s"

        # Execute the query
        cursor.execute(query, (expense_id,))
        conn.commit()

        return func.HttpResponse(
            "Expense deleted successfully.",
            status_code=200
        )

    except mysql.connector.Error as err:
        logging.error(f"MySQL Error: {err}")
        return func.HttpResponse(
            "Database error occurred.",
            status_code=500
        )
    except Exception as e:
        logging.error(f"Unexpected Error: {e}")
        return func.HttpResponse(
            "An unexpected error occurred.",
            status_code=500
        )
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()