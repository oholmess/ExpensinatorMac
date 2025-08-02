import os
import mysql.connector
import json
import azure.functions as func
import logging
import datetime
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)


def get_db_connection():
    # Implement your DB connection logic here
    # Return a connection object or None if fails
    host = os.environ.get('DB_HOST')
    user = os.environ.get('DB_USER')
    password = os.environ.get('DB_PASSWORD')
    database = os.environ.get('DB_DATABASE')

    if not all([host, user, password, database]):
        logging.error("MySQL connection parameters are not fully set in environment variables.")
        return None

    try:
        conn = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database
        )
        return conn
    except mysql.connector.Error as err:
        logging.error(f"MySQL Error: {err}")
        return None
    except Exception as e:
        logging.error(f"Unexpected Error: {e}")
        return None


@app.route(route="get_expenses", methods=['GET'])
def get_expenses(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('HTTP GET request received for get_expenses.')

    conn = get_db_connection()
    if not conn:
        return func.HttpResponse("Database connection error.", status_code=500)

    try:
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
    conn = None  # Initialize connection variable
    cursor = None

    conn = get_db_connection()
    if not conn:
        return func.HttpResponse("Database connection error.", status_code=500)

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


@app.route(route="update_expenses", methods=['PUT'])
def update_expenses(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('HTTP PUT request received for update_expenses.')

    conn = get_db_connection()
    if not conn:
        return func.HttpResponse("Database connection error.", status_code=500)

    try:
        req_body = req.get_json()
        if not req_body:
            return func.HttpResponse("Request body is empty.", status_code=400)
        
        oldExpenseIDs = req_body.get("oldExpenseIDs")
        newExpenses = req_body.get("newExpenses")

        if not oldExpenseIDs or not isinstance(oldExpenseIDs, list):
            return func.HttpResponse("oldExpenseIDs must be a list.", status_code=400)
        
        if not newExpenses or not isinstance(newExpenses, list):
            return func.HttpResponse("newExpenses must be a list.", status_code=400)
        
        if len(oldExpenseIDs) != len(newExpenses):
            return func.HttpResponse("oldExpenseIDs and newExpenses must have the same length.", status_code=400)

        cursor = conn.cursor()
        query = """
        UPDATE Expenses
        SET userId = %s, amount = %s, categoryId = %s, description = %s, receiptUrl = %s, date = %s, createdAt = %s
        WHERE expenseId = %s
        """

        for i, old_id in enumerate(oldExpenseIDs):
            exp = newExpenses[i]
            
            # Extract fields from the new expense object. These keys must match the JSON structure sent by the client.
            userId = exp["userId"]
            amount = exp["amount"]            # Ensure amount is numeric
            categoryId = exp["categoryId"]
            description = exp["description"]
            receiptUrl = exp.get("receiptUrl", None)
            date = exp["date"]                # Expecting string in "yyyy-MM-dd HH:mm:ss", no parsing needed if stored as string
            createdAt = exp["createdAt"]      # Same formatting expectation as above
            
            cursor.execute(query, (userId, amount, categoryId, description, receiptUrl, date, createdAt, old_id))

        conn.commit()

        return func.HttpResponse("Expenses updated successfully.", status_code=200)
    except mysql.connector.Error as err:
        logging.error(f"MySQL Error: {err}")
        return func.HttpResponse("Database error occurred.", status_code=500)
    except Exception as e:
        logging.error(f"Unexpected Error: {e}")
        return func.HttpResponse("An unexpected error occurred.", status_code=500)
    finally:
        conn.close()


@app.route(route="get_categories", methods=['GET'])
def get_categories(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('HTTP GET request received for get_categories.')

    conn = get_db_connection()
    if not conn:
        return func.HttpResponse("Database connection error.", status_code=500)

    try:
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

    # Establish a connection to the MySQL database
    conn = get_db_connection()
    if not conn:
        return func.HttpResponse("Database connection error.", status_code=500)

    try:
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


@app.route(route="delete_expenses", methods=['DELETE'])
def delete_expenses(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('HTTP DELETE request received for delete_expenses.')

    conn = None
    cursor = None

    # Establish a connection to the MySQL database
    conn = get_db_connection()
    if not conn:
        return func.HttpResponse("Database connection error.", status_code=500)

    try:
        # Parse the request body
        req_body = req.get_json()
        if not req_body:
            return func.HttpResponse(
                "Request body is empty.",
                status_code=400
            )

        cursor = conn.cursor()

        query = "DELETE FROM Expenses WHERE expenseId = %s"

        if isinstance(req_body, list):
            # Handle multiple expenses
            for expense in req_body:
                expense_id = expense.get('expenseId')
                if not expense_id:
                    return func.HttpResponse(
                        "One of the expense objects is missing 'expenseId' field.",
                        status_code=400
                    )
                cursor.execute(query, (expense_id,))
            conn.commit()
            return func.HttpResponse(
                "All specified expenses deleted successfully.",
                status_code=200
            )

        else:
            # Handle a single expense
            expense_id = req_body.get('expenseId')
            if not expense_id:
                return func.HttpResponse(
                    "Request body is missing required fields.",
                    status_code=400
                )

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
        # Ensure the cursor and connection are closed
        if cursor is not None:
            cursor.close()
        if conn is not None and conn.is_connected():
            conn.close()



@app.route(route="upload_receipt_to_blob", methods=['POST'])
def upload_receipt_to_blob(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('HTTP POST request received for upload_receipt_to_blob.')

    account_name = os.environ.get('BLOB_ACCOUNT_NAME')
    account_key = os.environ.get('BLOB_ACCOUNT_KEY')
    container_name = os.environ.get('BLOB_CONTAINER_NAME')

    if not all([account_name, account_key, container_name]):
        logging.error("Missing Blob Storage environment variables.")
        return func.HttpResponse("Blob Storage configuration is incomplete.", status_code=500)

    filename = req.params.get('filename')
    if not filename:
        filename = "receipt-" + datetime.datetime.now().isoformat() + ".png"

    image_data = req.get_body()
    if not image_data:
        return func.HttpResponse("No image data received.", status_code=400)

    try:
        blob_service_client = BlobServiceClient(
            account_url=f"https://{account_name}.blob.core.windows.net",
            credential=account_key
        )
        container_client = blob_service_client.get_container_client(container_name)

        blob_client = container_client.get_blob_client(filename)
        blob_client.upload_blob(image_data, overwrite=True)

        # Construct the blob URL
        blob_url = f"https://{account_name}.blob.core.windows.net/{container_name}/{filename}"
        response_body = {
            "message": "Receipt uploaded successfully",
            "blobUrl": blob_url
        }

        return func.HttpResponse(
            json.dumps(response_body),
            status_code=201,
            mimetype="application/json"
        )

    except Exception as e:
        logging.error(f"Unexpected Error: {e}")
        return func.HttpResponse("An unexpected error occurred on the server.", status_code=500)
