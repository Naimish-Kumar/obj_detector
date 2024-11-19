
# Expense Tracker App

A full-stack expense tracking application built with modern technologies to help users manage their finances.

## Technologies Used

### Frontend
- React.js
- Redux for state management
- Material-UI for styling
- Chart.js for expense visualization
- Axios for API calls

### Backend
- Node.js
- Express.js
- MongoDB for database
- JWT for authentication
- Bcrypt for password hashing

## Features
- User authentication (signup/login)
- Add/Edit/Delete expenses
- Categorize expenses
- Filter expenses by date/category
- Visual representation of expenses through charts
- Monthly/yearly expense summaries
- Export expense reports
- Responsive design for mobile and desktop

## Installation

1. Clone the repository

git clone https://github.com/yourusername/expense-tracker.git


2. Install dependencies for backend

cd backend
npm install


3. Install dependencies for frontend

cd frontend
npm install


4. Set up environment variables
Create a .env file in the backend directory with:

MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
PORT=5000


5. Run the application

# Start backend server
cd backend
npm start

# Start frontend development server
cd frontend
npm start


## API Endpoints

### Authentication
- POST /api/auth/register - Register new user
- POST /api/auth/login - Login user

### Expenses
- GET /api/expenses - Get all expenses
- POST /api/expenses - Create new expense
- PUT /api/expenses/:id - Update expense
- DELETE /api/expenses/:id - Delete expense

## Database Schema

### User Schema
- username (String)
- email (String)
- password (String)
- createdAt (Date)

### Expense Schema
- title (String)
- amount (Number)
- category (String)
- date (Date)
- description (String)
- userId (ObjectId)

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)
