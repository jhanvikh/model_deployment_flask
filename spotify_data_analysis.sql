create database spotify_df;
USE spotify_db;
-- create table
DROP TABLE IF EXISTS cleaned_dataset;
CREATE TABLE cleaned_dataset (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- EDA
select * from cleaned_dataset;
select count(distinct artist) from cleaned_dataset;
select distinct Album_type from cleaned_dataset;
select max(Duration_min) from cleaned_dataset;
select min(Duration_min) from cleaned_dataset;
select Track from cleaned_dataset where Duration_min=0;

-- Retrieve the names of all tracks that have more than 1 billion streams.
select * from cleaned_dataset 
where Stream> 1000000000;

-- List all albums along with their respective artists.
select Album,Artist from cleaned_dataset
order by 1;

-- Get the total number of comments for tracks where licensed = TRUE.
select sum(Comments) from cleaned_dataset where Licensed="true";

-- Find all tracks that belong to the album type single.
select Track from cleaned_dataset 
where Album_type='single';

-- Count the total number of tracks by each artist.
select Artist,count(Track) from cleaned_dataset 
group by Artist;

-- Calculate the average danceability of tracks in each album.
select avg(Danceability),Album from cleaned_dataset 
group by Album;

-- Find the top 5 tracks with the highest energy values.
select Track,max(Energy) from cleaned_dataset
group by 1
order by 2 desc
limit 5;

-- List all tracks along with their views and likes where official_video = TRUE.
select Track,sum(Views),sum(Likes) from cleaned_dataset
where official_video='true'
group by 1
order by 2 desc;

-- For each album, calculate the total views of all associated tracks.
select Album,Track,sum(Views) from cleaned_dataset
group by 1,2
order by 3 desc;

-- Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * 
FROM (
    SELECT 
        Track,
        COALESCE(SUM(CASE WHEN most_playedon = 'Youtube' THEN stream END), 0) AS streamed_on_youtube,
        COALESCE(SUM(CASE WHEN most_playedon = 'Spotify' THEN stream END), 0) AS streamed_on_spotify
    FROM cleaned_dataset
    GROUP BY 1
) AS t1
WHERE streamed_on_spotify > streamed_on_youtube;

-- Find the top 3 most-viewed tracks for each artist using window functions.
SELECT *
FROM (
    SELECT 
        Artist, 
        Track, 
        Views, 
        RANK() OVER (PARTITION BY Artist ORDER BY Views DESC) AS view_rank
    FROM cleaned_dataset
) AS ranked_tracks
WHERE view_rank <= 3;

-- Write a query to find tracks where the liveness score is above the average.
SELECT Track, Artist, Liveness
FROM cleaned_dataset
WHERE Liveness > (SELECT AVG(Liveness) FROM cleaned_dataset);

-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH album_energy AS (
    SELECT 
        Album, 
        MAX(Energy) AS max_energy, 
        MIN(Energy) AS min_energy
    FROM cleaned_dataset
    GROUP BY Album
)
SELECT Album, max_energy, min_energy, (max_energy - min_energy) AS energy_difference
FROM album_energy;



