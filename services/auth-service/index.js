require('dotenv').config();
const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const mysql = require('mysql2/promise');

const app = express();
app.use(express.json());

const db = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// User registration with password hashing
app.post('/register', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  try {
    const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length > 0) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert the user into the database
    await db.query('INSERT INTO users (email, password) VALUES (?, ?)', [email, hashedPassword]);

    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

// User login with password validation
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  try {
    const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const user = rows[0];

    // Compare hashed password
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Generate a JWT token
    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1d' });
    res.status(200).json({ message: 'Login successful', token });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

app.listen(process.env.PORT, () => {
  console.log(`Auth service running on port ${process.env.PORT}`);
});


/**  Description
This code defines a basic authentication service for a microservices-based system using Node.js and Express.js. It includes the following key features:

1. User Registration (POST /register)
======================================
Functionality: Allows new users to register by providing an email and password.

Steps:
=====
Input Validation: Ensures both email and password are provided.
User Existence Check: Queries the MySQL database to verify if the email is already registered.
Password Hashing: Uses the bcrypt library to hash the user's password for secure storage.
Database Storage: Saves the user's email and hashed password into the users table.

Response:
201: User registered successfully.
400: User already exists or input is invalid.
500: Internal server error.

2. User Login (POST /login)
===========================
Functionality: Authenticates users by validating their email and password.

Steps:
======
Input Validation: Ensures both email and password are provided.
User Existence Check: Queries the MySQL database to find the user by email.
Password Validation: Compares the provided password with the stored hashed password using bcrypt.compare.
JWT Token Generation: If the password matches, generates a JSON Web Token (JWT) with the user's ID as the payload.

Response:
200: Login successful; returns a JWT token.
401: Invalid credentials (e.g., incorrect password).
404: User not found.
500: Internal server error.

3. Security Features
====================
Password Hashing: The bcrypt library ensures passwords are securely hashed before being stored in the database.
JWT Authentication: The jsonwebtoken library generates a secure token for authenticated sessions, expiring after one day (1d).

Environment Variables:
Database Credentials: Managed through a .env file for security.
JWT Secret: Used to sign and verify tokens, stored securely in the .env file.

4. Database Integration
=======================
Uses the mysql2 library with a connection pool for efficient database operations.
Interacts with a MySQL database to store and retrieve user information.

How to Use
Register a User:
Send a POST request to /register with the user's email and password.
Password is hashed and stored in the database.
Login a User:
Send a POST request to /login with the user's email and password.
If credentials are valid, a JWT token is returned.
Dependencies
The following libraries are used:

express: Web framework for handling HTTP requests.
bcrypt: For hashing and comparing passwords.
mysql2: For MySQL database integration.
dotenv: For managing environment variables.
jsonwebtoken: For generating and validating JWT tokens. **/