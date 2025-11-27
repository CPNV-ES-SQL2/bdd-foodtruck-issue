CREATE TABLE Foodtrucks (  
  foodtruck_id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
);

CREATE TABLE Foodtruck_Cuisines (
  foodtruck_id INTEGER NOT NULL,
  cuisine TEXT NOT NULL,
  PRIMARY KEY (foodtruck_id, cuisine, operating_day),
  FOREIGN KEY (foodtruck_id) REFERENCES Foodtrucks(foodtruck_id)
);

CREATE TABLE Foodtruck_OperatingDays (
  foodtruck_id INTEGER NOT NULL,
  operating_day INTEGER NOT NULL, -- 0=Monday, 1=Tuesday, ..., 6=Sunday
  PRIMARY KEY (foodtruck_id, operating_day),
  FOREIGN KEY (foodtruck_id) REFERENCES Foodtrucks(foodtruck_id)
);

INSERT INTO Foodtrucks (name) VALUES
  ('Taco Express');

INSERT INTO Foodtruck_Cuisines (foodtruck_id, cuisine) VALUES
  (1, 'Mexican');

INSERT INTO Foodtruck_OperatingDays (foodtruck_id, operating_day) VALUES
  (1, 0);