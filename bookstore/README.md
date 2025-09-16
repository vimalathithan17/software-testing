This folder contains a minimal Flask demo online bookstore used for load testing with JMeter.

Using pipenv (recommended):

1. Install pipenv (if you don't have it):

   pip install pipenv

2. From the repository root run:

   pipenv install --dev
   pipenv shell

3. Run the app (pipenv shell active):

   python app.py

The app will create a local SQLite DB `bookstore.db` in this folder and run on http://0.0.0.0:5001

JMeter:
- A JMeter test plan is provided as `bookstore_test_plan.jmx`. Open it in JMeter, set the target URL to http://localhost:5001 and run. Use "View Results Tree" listener to see responses.