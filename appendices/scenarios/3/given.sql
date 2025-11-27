CREATE TABLE Foodtrucks (  
  foodtruck_id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  cuisine TEXT NOT NULL,
  operating_day INTEGER NOT NULL -- 0=Monday, 1=Tuesday, ..., 6=Sunday
);

INSERT INTO Foodtrucks (name, cuisine, operating_day) VALUES
  ('Taco Express','Mexican',0);