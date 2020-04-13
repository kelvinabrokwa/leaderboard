from setuptools import setup


setup(
    name='leaderboard',
    version='0.0.1',
    description='A leaderboard application',
    author='Kelvin Abrokwa-Johnson',
    author_email='kelvinabrokwa@gmail.com',
    packages=['leaderboard'],
    install_requires=[
        'Flask',
        'flask-cors',
        'flask-json',
        'Flask-SQLAlchemy',
        'google-cloud-secret-manager',
        'pg8000',
        'psycopg2',
        'SQLAlchemy',
    ]
)