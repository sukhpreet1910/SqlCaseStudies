import pandas as pd 
from sqlalchemy import create_engine 

conn_string = 'postgresql://postgres:sukh@localhost/datascience'
db = create_engine(conn_string)
conn = db.connect()

files = ['artist', 'canvas_size', 'image_link', 'museum_hours', 'museum', 'product_size', 'subject', 'work']

df = pd.read_csv('/Users/sukhsodhi/Desktop/DS_DA/SQL/CaseStudies/dataScienceSalaries/salaries.csv')
df.to_sql('salaries', con = conn, if_exists='replace', index=False)