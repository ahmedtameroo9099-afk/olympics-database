sql
-- Create the database with three files
CREATE DATABASE olympics

ON PRIMARY
(
    NAME = 'olympics_data',
    FILENAME = 'C:\Data\olympics.mdf',
    SIZE = 20MB,
    FILEGROWTH = 10MB
),

FILEGROUP secondary_fg
(
    NAME = 'olympics_secondary',
    FILENAME = 'C:\Data\olympics.ndf',
    SIZE = 10MB,
    FILEGROWTH = 5MB
)

LOG ON
(
    NAME = 'olympics_log',
    FILENAME = 'C:\Data\olympics.ldf',
    SIZE = 10MB,
    FILEGROWTH = 5MB
);
GO


-- Use the database
USE olympics;
GO

-- COUNTRIES
CREATE TABLE country (
    country_id INT IDENTITY(1,1) PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

-- SPORTS
CREATE TABLE sport (
    sport_id INT IDENTITY(1,1) PRIMARY KEY,
    sport_name VARCHAR(100) NOT NULL UNIQUE
);

-- OLYMPIC GAMES
CREATE TABLE games (
    games_id INT IDENTITY(1,1) PRIMARY KEY,
    game_year SMALLINT NOT NULL UNIQUE CHECK (game_year BETWEEN 1896 AND 2200),
    host_city VARCHAR(100) NOT NULL,
    host_country_id INT NOT NULL,
    FOREIGN KEY (host_country_id) REFERENCES country(country_id)
);

-- ATHLETES
CREATE TABLE athlete (
    athlete_id INT IDENTITY(1,1) PRIMARY KEY,
    athlete_name VARCHAR(100) NOT NULL,
    date_of_birth DATE
);

-- ATHLETE PARTICIPATION
CREATE TABLE athlete_games (
    athlete_id INT NOT NULL,
    games_id INT NOT NULL,
    country_id INT NOT NULL,
    PRIMARY KEY (athlete_id, games_id),
    FOREIGN KEY (athlete_id) REFERENCES athlete(athlete_id),
    FOREIGN KEY (games_id) REFERENCES games(games_id),
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

-- COACHES
CREATE TABLE coach (
    coach_id INT IDENTITY(1,1) PRIMARY KEY,
    coach_name VARCHAR(100) NOT NULL,
    country_id INT NOT NULL,
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

-- ATHLETE-COACH
CREATE TABLE athlete_coach (
    athlete_id INT NOT NULL,
    coach_id INT NOT NULL,
    PRIMARY KEY (athlete_id, coach_id),
    FOREIGN KEY (athlete_id) REFERENCES athlete(athlete_id),
    FOREIGN KEY (coach_id) REFERENCES coach(coach_id)
);

-- REFEREES
CREATE TABLE referee (
    referee_id INT IDENTITY(1,1) PRIMARY KEY,
    referee_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    sport_id INT NOT NULL,
    country_id INT NOT NULL,
    FOREIGN KEY (sport_id) REFERENCES sport(sport_id),
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

-- EVENTS
CREATE TABLE event (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    games_id INT NOT NULL,
    sport_id INT NOT NULL,
    event_name VARCHAR(150) NOT NULL,
    gender_category VARCHAR(30) NOT NULL,
    event_date DATE NOT NULL,
    FOREIGN KEY (games_id) REFERENCES games(games_id),
    FOREIGN KEY (sport_id) REFERENCES sport(sport_id),
    UNIQUE (games_id, sport_id, event_name, gender_category)
);

-- RESULTS
CREATE TABLE result (
    event_id INT NOT NULL,
    athlete_id INT NOT NULL,
    score DECIMAL(12,3),
    rank_position INT,
    medal VARCHAR(10),
    PRIMARY KEY (event_id, athlete_id),
    FOREIGN KEY (event_id) REFERENCES event(event_id),
    FOREIGN KEY (athlete_id) REFERENCES athlete(athlete_id),
    CHECK (rank_position IS NULL OR rank_position > 0),
    CHECK (medal IS NULL OR medal IN ('gold', 'silver', 'bronze'))
);

-- EVENT REFEREES
CREATE TABLE event_referee (
    event_id INT NOT NULL,
    referee_id INT NOT NULL,
    PRIMARY KEY (event_id, referee_id),
    FOREIGN KEY (event_id) REFERENCES event(event_id),
    FOREIGN KEY (referee_id) REFERENCES referee(referee_id)
);

-- SPONSORS
CREATE TABLE sponsor (
    sponsor_id INT IDENTITY(1,1) PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL UNIQUE,
    home_country_id INT,
    FOREIGN KEY (home_country_id) REFERENCES country(country_id)
);

-- EVENT SPONSORSHIP
CREATE TABLE event_sponsor (
    event_id INT NOT NULL,
    sponsor_id INT NOT NULL,
    amount DECIMAL(12,2),
    PRIMARY KEY (event_id, sponsor_id),
    FOREIGN KEY (event_id) REFERENCES event(event_id),
    FOREIGN KEY (sponsor_id) REFERENCES sponsor(sponsor_id),
    CHECK (amount IS NULL OR amount >= 0)
);

-- ORGANIZERS
CREATE TABLE organizer (
    organizer_id INT IDENTITY(1,1) PRIMARY KEY,
    organizer_name VARCHAR(100) NOT NULL,
    organizer_email VARCHAR(150)
);

-- UNIQUE INDEX on organizer_email
CREATE UNIQUE INDEX ux_organizer_email
    ON organizer(organizer_email)
    WHERE organizer_email IS NOT NULL;

-- EVENT ORGANIZERS
CREATE TABLE event_organizer (
    event_id INT NOT NULL,
    organizer_id INT NOT NULL,
    PRIMARY KEY (event_id, organizer_id),
    FOREIGN KEY (event_id) REFERENCES event(event_id),
    FOREIGN KEY (organizer_id) REFERENCES organizer(organizer_id)
);

-- TICKETS
CREATE TABLE ticket (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT NOT NULL,
    price DECIMAL(10,2) CHECK (price >= 0),
    quantity INT CHECK (quantity >= 0),
    FOREIGN KEY (event_id) REFERENCES event(event_id)
);
GO
