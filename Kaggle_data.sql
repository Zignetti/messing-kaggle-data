-- objective to clean messing data from kaggle 

SELECT * FROM kaggle.dirty;

-- create a copy of the table for safe manipulation

create table clean
like dirty;

insert into clean
select *
from dirty;

-- inspect the number rows and colummns in the dataset
-- number of rows

select count(*) as numOfRows
from clean;

-- the table has 18rows

-- number of columns
select count(*) as numOfColumns
from information_schema.columns
where table_name='clean';
-- the table has 11 columns

-- check for null values
select count(*) as missing,
count(if(`rank` is null or `rank`='',1,null)) as rankMissing,
count(if(peak is null or peak='',1,null)) as peakMissing,
count(if(all_time_peak is null or all_time_peak='',1,null)) as missingAllTimePeak,
count(if(actualGross is null or actualGross='',1,null)) as missingActualGross,
count(if(adjustedGross2022 is null or adjustedGross2022='',1,null)) as missingAgj,
count(if(artist is null or artist='',1,null)) as missingArtist,
count(if(tourtitle is null or tourtitle='',1,null)) as missingTitle,
count(if(year is null or year='',1,null)) as missingYear,
count(if(shows is null or shows='',1,null)) as missingShows,
count(if(averageGross is null or averageGross='',1,null)) as missingAvgGross,
count(if(`ref.` is null or `ref.`='',1,null)) as missingRef
from clean;

-- results shows a total of 18 rows missing. 9 from peak and 12 from all time peak column.

-- feature engineering. drop the two column since there are no further information on them

alter table clean
drop column peak;

alter table clean
drop column all_time_peak;

-- check for misspelling, whitespacing and other non regular expression
 -- rank column:remove inconsitent ranking
 
 select 
  ROW_NUMBER() OVER (ORDER BY CAST(REPLACE(REPLACE(adjustedGross2022, '$', ''), ',', '') AS DECIMAL) DESC) AS new_rank
from clean;

-- clean the actualGross column: remove the $, and set as decimal number

select  cast(replace(replace(actualGross,'$',''),',','') as decimal(15,2)) as actual_gross
from clean;

-- clean the adjustedGross2022 column: remove the $, and set as decimal number

select  cast(replace(replace(adjustedGross2022,'$',''),',','') as decimal(15,2)) as adjusted_gross_2022
from clean;

-- artist column: remove non regular expression Å©, Ã©
select replace(replace(artist,'Ã','e'),'©','') as artist_name
from clean;


-- tourtile column: remove 'â€',[4],[a],* ¡'[21]'


select replace(replace(replace(replace(replace(replace(replace(tourtitle,'â',''),'€',''),'[4]',''),'[a]',''),'¡',''),'*',''),'[21]','') as tour_title
from clean;

-- break the year into start and end

select regexp_substr(year, '[0-9]{4}') as start_year,
	   regexp_substr(year,'[0-9]{4}$') as end_year
from clean;

-- show column: remove the whitespace

SELECT trim(Shows)
FROM clean
WHERE Shows NOT REGEXP '^[0-9]+$';

SELECT
  CAST(Shows AS UNSIGNED) AS countShows
FROM clean
WHERE Shows REGEXP '^[0-9]+$';

-- column average gross: remove $,
select  cast(replace(replace(averageGross,'$',''),',','') as decimal(15,2)) as avg_gross
from clean;

-- ref. column: remove []
select replace(replace(`ref.`,'[',''),']','') as ref
from clean;

-- automate the cleaning process

create table cleanTable as 
select
	ROW_NUMBER() OVER (ORDER BY CAST(REPLACE(REPLACE(adjustedGross2022, '$', ''), ',', '') AS DECIMAL) DESC) AS new_rank,
	cast(replace(replace(actualGross,'$',''),',','') as decimal(15,2)) as actual_gross,
    cast(replace(replace(adjustedGross2022,'$',''),',','') as decimal(15,2)) as adjusted_gross_2022,
    replace(replace(artist,'Ã','e'),'©','') as artist_name,
    replace(replace(replace(replace(replace(replace(replace(tourtitle,'â',''),'€',''),'[4]',''),'[a]',''),'¡',''),'*',''),'[21]','') as tour_title,
    regexp_substr(year, '[0-9]{4}') as start_year,
	regexp_substr(year,'[0-9]{4}$') as end_year,
    CAST(Shows AS UNSIGNED) AS countShows,
    cast(replace(replace(averageGross,'$',''),',','') as decimal(15,2)) as avg_gross,
    replace(replace(`ref.`,'[',''),']','') as ref
FROM clean;

    

select * from cleanTable;





