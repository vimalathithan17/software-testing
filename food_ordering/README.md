This folder contains a minimal Flask demo food-ordering site used for JMeter load testing.

Using pipenv (recommended):

1. Install pipenv if needed:

   pip install pipenv

2. From the repository root run:

   pipenv install --dev
   pipenv shell

3. Run the app:

   python app.py

The app will create a local SQLite DB `food.db` in this folder and run on http://0.0.0.0:5002

JMeter:
- Open `food_test_plan.jmx` in JMeter, set the target host/port to localhost:5002 and run. Add View Results Tree and Graph Results listeners to view outputs.