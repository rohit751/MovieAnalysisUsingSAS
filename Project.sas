/**************************************************************
 *
 *                    LOADING DATA
 *
 **************************************************************/

LIBNAME Project 'R:\SAS\Project' ;

PROC IMPORT OUT = Project.Movies DATAFILE = "R:\SAS\Project\Movies.xlsx" DBMS = xlsx REPLACE ;
	SHEET = "Sheet1" ;
	GETNAMES = YES ;
RUN ;
QUIT ;


/**************************************************************
 *
 *      DATA PRE-PROCESSING: MANIPULATION & CLEANING
 *
 **************************************************************/

DATA work.Movies ;
	SET Project.Movies (drop = Movie) ;
	IF CMISS(Director) THEN DELETE ;
	IF CMISS(Year) THEN DELETE ;
RUN ;


/*
 * Replace the special characters in the names of the people
 * to maintain consistency such that their name is identical
 * for all their movies.
 */

DATA work.Movies ;
	ID = _N_ ;
	SET work.Movies ;

	Director = tranwrd(Director, 'á','a');
	Director = tranwrd(Director, 'é','e');
	Director = tranwrd(Director, 'ó','o');
	Director = tranwrd(Director, 'å','a');
	Director = tranwrd(Director, 'ö','o');
	Director = tranwrd(Director, 'ñ','n');
	Director = tranwrd(Director, 'ø','o');
	Director = tranwrd(Director, 'ç','c');
	Director = tranwrd(Director, 'í','i');
	Director = tranwrd(Director, 'ô','o');
	Director = tranwrd(Director, 'Ô','O');
	Director = tranwrd(Director, 'ò','e');
	Director = tranwrd(Director, 'ë','e');
	Director = tranwrd(Director, 'ð','o');
	Director = tranwrd(Director, '�','A');
	Director = tranwrd(Director, 'Ó','O');

	Actor_1 = tranwrd(Actor_1, 'á','a');
	Actor_1 = tranwrd(Actor_1, 'é','e');
	Actor_1 = tranwrd(Actor_1, 'ó','o');
	Actor_1 = tranwrd(Actor_1, 'å','a');
	Actor_1 = tranwrd(Actor_1, 'ö','o');
	Actor_1 = tranwrd(Actor_1, 'ñ','n');
	Actor_1 = tranwrd(Actor_1, 'ø','o');
	Actor_1 = tranwrd(Actor_1, 'ç','c');
	Actor_1 = tranwrd(Actor_1, 'í','i');
	Actor_1 = tranwrd(Actor_1, 'ô','o');
	Actor_1 = tranwrd(Actor_1, 'Ô','O');
	Actor_1 = tranwrd(Actor_1, 'ò','e');
	Actor_1 = tranwrd(Actor_1, 'ë','e');
	Actor_1 = tranwrd(Actor_1, 'ð','o');
	Actor_1 = tranwrd(Actor_1, '�','A');
	Actor_1 = tranwrd(Actor_1, 'Ó','O');

	Actor_2 = tranwrd(Actor_2, 'á','a');
	Actor_2 = tranwrd(Actor_2, 'é','e');
	Actor_2 = tranwrd(Actor_2, 'ó','o');
	Actor_2 = tranwrd(Actor_2, 'å','a');
	Actor_2 = tranwrd(Actor_2, 'ö','o');
	Actor_2 = tranwrd(Actor_2, 'ñ','n');
	Actor_2 = tranwrd(Actor_2, 'ø','o');
	Actor_2 = tranwrd(Actor_2, 'ç','c');
	Actor_2 = tranwrd(Actor_2, 'í','i');
	Actor_2 = tranwrd(Actor_2, 'ô','o');
	Actor_2 = tranwrd(Actor_2, 'Ô','O');
	Actor_2 = tranwrd(Actor_2, 'ò','e');
	Actor_2 = tranwrd(Actor_2, 'ë','e');
	Actor_2 = tranwrd(Actor_2, 'ð','o');
	Actor_2 = tranwrd(Actor_2, '�','A');
	Actor_2 = tranwrd(Actor_2, 'Ó','O');

	Actor_3 = tranwrd(Actor_3, 'á','a');
	Actor_3 = tranwrd(Actor_3, 'é','e');
	Actor_3 = tranwrd(Actor_3, 'ó','o');
	Actor_3 = tranwrd(Actor_3, 'å','a');
	Actor_3 = tranwrd(Actor_3, 'ö','o');
	Actor_3 = tranwrd(Actor_3, 'ñ','n');
	Actor_3 = tranwrd(Actor_3, 'ø','o');
	Actor_3 = tranwrd(Actor_3, 'ç','c');
	Actor_3 = tranwrd(Actor_3, 'í','i');
	Actor_3 = tranwrd(Actor_3, 'ô','o');
	Actor_3 = tranwrd(Actor_3, 'Ô','O');
	Actor_3 = tranwrd(Actor_3, 'ò','e');
	Actor_3 = tranwrd(Actor_3, 'ë','e');
	Actor_3 = tranwrd(Actor_3, 'ð','o');
	Actor_3 = tranwrd(Actor_3, '�','A');
	Actor_3 = tranwrd(Actor_3, 'Ó','O');

RUN ;

/* Creating an index variable for reference. */
PROC DATASETS LIBRARY = work ;
	MODIFY Movies ;
	INDEX CREATE ID / UNIQUE;
RUN ;


/* 
 * Transforming necessary variables to more reasonable type.
 */
PROC FORMAT ;
	value $ColorFMT 'Color'				= '1'
					'Black and White'	= '0'
					' Black and White'	= '0' ;
RUN ;

DATA work.Movies ;
	SET work.Movies ;
	FORMAT Color $ColorFMT. ;
RUN ;


/* 
 * Generating binary indicator variables for each type of the Genres.
 */
DATA work.Movies  (drop = x genre var1-var20 Genres);
	SET work.Movies  ;
	Action		= 0 ;
	Adventure	= 0 ;
	Animation	= 0 ;
	Biography	= 0 ;
	Comedy		= 0 ;
	Crime		= 0 ;
	Documentary	= 0 ;
	Drama		= 0 ;
	Family		= 0 ;
	Fantasy		= 0 ;
	History		= 0 ;
	Horror		= 0 ;
	Music		= 0 ;
	Mystery		= 0 ;
	Romance		= 0 ;
	SciFi		= 0 ;
	Sport		= 0 ;
	Thriller	= 0 ;
	War			= 0 ;
	Western		= 0 ;
	Other		= 0 ;

	length var1-var20 $15. ;
	ARRAY genre(*)$ var1-var20;
	x = 1 ;
	DO WHILE (scan(Genres, x, "|") ne "") ;
		genre(x) = scan(Genres, x, "|") ;
		IF compare("Action", genre(x)) EQ 0 THEN Action = 1 ;
		ELSE IF compare("Adventure", genre(x)) EQ 0 THEN Adventure = 1 ;
		ELSE IF compare("Animation", genre(x)) EQ 0 THEN Animation = 1 ;
		ELSE IF compare("Biography", genre(x)) EQ 0 THEN Biography = 1 ;
		ELSE IF compare("Comedy", genre(x)) EQ 0 THEN Comedy	= 1 ;
		ELSE IF compare("Crime", genre(x)) EQ 0 THEN Crime = 1 ;
		ELSE IF compare("Documentary", genre(x)) EQ 0 THEN Documentary = 1 ;
		ELSE IF compare("Drama", genre(x)) EQ 0 THEN Drama = 1 ;
		ELSE IF compare("Family", genre(x)) EQ 0 THEN Family	= 1 ;
		ELSE IF compare("Fantasy", genre(x)) EQ 0 THEN Fantasy = 1 ;
		ELSE IF compare("History", genre(x)) EQ 0 THEN History = 1 ;
		ELSE IF compare("Horror", genre(x)) EQ 0 THEN Horror	= 1 ;
		ELSE IF compare("Musical", genre(x)) EQ 0 THEN Music = 1 ;
		ELSE IF compare("Music", genre(x)) EQ 0 THEN Music = 1 ;
		ELSE IF compare("Mystery", genre(x)) EQ 0 THEN Mystery = 1 ;
		ELSE IF compare("Romance", genre(x)) EQ 0 THEN Romance = 1 ;
		ELSE IF compare("Sci-Fi", genre(x)) EQ 0 THEN SciFi = 1 ;
		ELSE IF compare("Sport", genre(x)) EQ 0 THEN Sport = 1 ;
		ELSE IF compare("Thriller", genre(x)) EQ 0 THEN Thriller = 1 ;
		ELSE IF compare("War", genre(x)) EQ 0 THEN War = 1 ;
		ELSE IF compare("Western", genre(x)) EQ 0 THEN Western = 1 ;
		ELSE Other = 1 ;
		x+1 ;
	END ;
	OUTPUT ;
RUN;

/*
 * Replace missing numerical variables with their medians.
 */

DATA TEMP_DATA1 ;
	/* Separate the numerical variables. */
	SET Work.Movies (KEEP = Budget Gross Duration Movie_FB_Likes
						Director_FB_Likes Actor1_FB_Likes
						Actor2_FB_Likes Actor3_FB_Likes
						Cast_Total_FB_Likes Critic_Reviews
						User_Reviews Voted_Users Faces_in_poster) ;
RUN ;

DATA TEMP_DATA2 ;
	SET Work.Movies (DROP = Budget Gross Duration Movie_FB_Likes
						Director_FB_Likes Actor1_FB_Likes
						Actor2_FB_Likes Actor3_FB_Likes
						Cast_Total_FB_Likes Critic_Reviews
						User_Reviews Voted_Users Faces_in_poster) ;
RUN ;

PROC STDIZE DATA = work.TEMP_DATA1 OUT = work.TEMP_DATA1 REPONLY MISSING = MEDIAN ;
	/* Replace the missing values from the separated numerical data. */
RUN ;

DATA Work.Movies ;
	/* Combine the imputed numerical variables with the rest of the data. */
	SET TEMP_DATA2 ;
	SET TEMP_DATA1 ;
RUN ;

PROC DELETE DATA = TEMP_DATA1 - TEMP_DATA2 ;
RUN ;
QUIT ;

/*
 * Replace missing categorical variables with their mode.
 */

PROC FREQ DATA = work.Movies ;
	TABLE Language Country Content_Rating Aspect_Ratio ;
RUN ;

DATA Work.Movies ;
	SET Work.Movies ;
	IF Language eq '' THEN Language = 'English';
	IF Country eq '' THEN Country = 'USA';
	IF Content_Rating eq '' THEN Content_Rating = 'R';
	IF Aspect_Ratio eq '' THEN Aspect_Ratio = '2.35';
	IF Actor_1 eq '' THEN Actor_1 = 'Robert De Niro';
	IF Actor_2 eq '' THEN Actor_2 = 'Morgan Freeman';
	IF Actor_3 eq '' THEN Actor_3 = 'John Heard';
RUN ;

/*
 * Discritizing the dependent variable
 */

DATA work.Movies ;
	set work.Movies ;
	LENGTH Score_Rating $13 ;
	IF IMDB_Score LE 5 THEN Score_Rating = "Poor" ;
	ELSE IF IMDB_Score GT 5 AND IMDB_Score LE 6 THEN Score_Rating = "Below Average" ;
	ELSE IF IMDB_Score GT 6 AND IMDB_Score LE 7 THEN Score_Rating = "Above Average" ;
	ELSE IF IMDB_Score GT 7  THEN  Score_Rating= "Good" ;
RUN ;

/**************************************************************
 *
 *                  STATISTICAL ANALYSIS
 *
 **************************************************************/

ODS PDF FILE = 'R:\SAS\Project\Project_Output.pdf' ;
/**************************************************************
 * Distribution of the Dependent variable
 **************************************************************/

PROC UNIVARIATE DATA = work.Movies ;
	TITLE3 "Distribution of IMDB Score" ;
	VAR IMDB_Score ;
	HISTOGRAM / NORMAL ;
	QQPLOT ;
RUN ;
TITLE ;

PROC FREQ DATA = work.Movies ;
	TITLE3 "IMDB Rating Frequency" ;
	TABLE Score_Rating / NOCUM ;
RUN ;
TITLE ;



/**************************************************************
 * Analysis of Genre types
 **************************************************************/

DATA work.Genre  (KEEP = genre count Rating);
	SET Project.Movies (KEEP = Genres) ;
	SET work.Movies (KEEP = Score_Rating) ;
	x = 1 ;
	DO WHILE (scan(Genres, x, "|") ne "") ;
		genre = scan(Genres, x, "|") ;
		genre = strip(genre) ;
		Rating = Score_Rating ;
		count = 1 ;
		OUTPUT ;
		x+1 ;
	END ;
RUN;

PROC SORT DATA = work.Genre ;
	BY genre ;
RUN ;

PROC GCHART DATA = work.Genre ;
	TITLE3 "Genre Type Frequency" ;
	HBAR genre /SUMVAR = count TYPE = SUM;
	PATTERN COLOR = BLACK ;
RUN ;
TITLE ;

PROC GCHART DATA = work.Genre ;
	WHERE Rating = "Good" ;
	TITLE3 "Genre Type Frequency for Good Movies" ;
	HBAR genre /SUMVAR = count TYPE = SUM ;
	PATTERN COLOR = BLACK ;
RUN ;
TITLE ;

PROC FREQ DATA = work.Movies ;
	WHERE Action = 1;
	TITLE3 "Distribution of Genre - Action" ;
	TABLE Score_Rating / NOCUM ;
RUN ;
TITLE ;

PROC FREQ DATA = work.Movies ;
	WHERE Comedy = 1;
	TITLE3 "Distribution of Genre - Comedy" ;
	TABLE Score_Rating / NOCUM ;
RUN ;
TITLE ;

PROC FREQ DATA = work.Movies ;
	WHERE Drama = 1;
	TITLE3 "Distribution of Genre - Drama" ;
	TABLE Score_Rating / NOCUM ;
RUN ;
TITLE ;

PROC FREQ DATA = work.Movies ;
	WHERE Romance = 1;
	TITLE3 "Distribution of Genre - Romance" ;
	TABLE Score_Rating / NOCUM ;
RUN ;
TITLE ;

PROC FREQ DATA = work.Movies ;
	WHERE Thriller = 1;
	TITLE3 "Distribution of Genre - Thriller" ;
	TABLE Score_Rating / NOCUM ;
RUN ;
TITLE ;


/**************************************************************
 * Analysis of Directors
 **************************************************************/

PROC FREQ DATA = work.Movies NOPRINT ;
	/* USA */
	WHERE Score_Rating = "Good" AND Country = "USA" ;
	TABLES Director / NOCUM NOFREQ OUT = Usa_top_directors;
RUN ;

PROC SORT DATA = Usa_top_directors ;
	BY DESCENDING Count ;
RUN ;

PROC GCHART DATA = Usa_top_directors ;
	WHERE COUNT > 7 ;
	TITLE3 "Top Directors - USA" ;
	HBAR Director / SUMVAR = Count TYPE = SUM ;
	PATTERN COLOR = BLACK ;
RUN ;

PROC FREQ DATA = work.Movies NOPRINT ;
	/* UK */
	WHERE Score_Rating = "Good" AND Country = "UK" ;
	TABLES Director / NOCUM NOFREQ OUT = Uk_top_directors;
RUN ;

PROC SORT DATA = Uk_top_directors ;
	BY DESCENDING Count ;
RUN ;

PROC GCHART DATA = Uk_top_directors ;
	WHERE COUNT > 2 ;
	TITLE3 "Top Directors - UK" ;
	HBAR Director / SUMVAR = Count TYPE = SUM ;
	PATTERN COLOR = BLACK ;
RUN ;

PROC FREQ DATA = work.Movies NOPRINT ;
	/* ALL COUNTRIES */
	WHERE Score_Rating = "Good" ;
	TABLES Director / NOCUM NOFREQ OUT = Top_directors;
RUN ;

PROC SORT DATA = Top_directors ;
	BY DESCENDING Count ;
RUN ;

PROC GCHART DATA = Top_directors ;
	WHERE COUNT > 6 ;
	TITLE3 "Top Directors" ;
	HBAR Director / SUMVAR = Count TYPE = SUM ;
	PATTERN COLOR = BLACK ;
RUN ;

PROC SORT DATA = Movies ;
	BY Year ;
RUN ;

GOPTIONS RESET = ALL ;
SYMBOL COLOUR = GREEN INTERPOL = JOIN VALUE = DOT
		POINTLABEL = (HEIGHT=10PT '#Year');
PROC GPLOT DATA = Movies ;
	WHERE Director = "Steven Spielberg" ;
	TITLE3 "Steven Spielberg" ;
	PLOT IMDB_Score*Year ;
RUN ;
TITLE ;

PROC GPLOT DATA = Movies ;
	WHERE Director = "Martin Scorsese" ;
	TITLE3 "Martin Scorsese" ;
	PLOT IMDB_Score*Year ;
RUN ;
TITLE ;

PROC GPLOT DATA = Movies ;
	WHERE Director = "Clint Eastwood" ;
	TITLE3 "Clint Eastwood" ;
	PLOT IMDB_Score*Year;
RUN ;
TITLE ;

PROC GPLOT DATA = Movies ;
	WHERE Director = "Woody Allen" ;
	TITLE3 "Woody Allen" ;
	PLOT IMDB_Score*Year ;
RUN ;
TITLE ;

PROC GPLOT DATA = Movies ;
	WHERE Director = "Peter Jackson" ;
	TITLE3 "Peter Jackson" ;
	PLOT IMDB_Score*Year ;
RUN ;
TITLE ;

PROC GPLOT DATA = Movies ;
	WHERE Director = "Christopher Nolan" ;
	TITLE3 "Christopher Nolan" ;
	PLOT IMDB_Score*Year ;
RUN ;
TITLE ;

PROC GPLOT DATA = Movies ;
	WHERE Director = "David Fincher" ;
	TITLE3 "David Fincher" ;
	PLOT IMDB_Score*Year ;
RUN ;
TITLE ;
GOPTIONS RESET = ALL ;

/**************************************************************
 * Analysis of Actors
 **************************************************************/

DATA ACTORS (KEEP = Actor Rating) ;
	SET Movies (KEEP = Actor_1 Actor_2 Actor_3 IMDB_Score) ;
	Actor = Actor_1 ;
	Rating = IMDB_Score ;
	OUTPUT ;
	Actor = Actor_2 ;
	Rating = IMDB_Score ;
	OUTPUT ;
	Actor = Actor_3 ;
	Rating = IMDB_Score ;
	OUTPUT ;
RUN ;

PROC FREQ DATA = Actors NOPRINT ;
	TABLE Actor / NOCUM NOFREQ OUT = Top_Actors;
RUN ;

PROC SORT DATA = Top_Actors ;
	BY DESCENDING COUNT ;
RUN ;

PROC GCHART DATA = Top_Actors ;
	WHERE COUNT > 28 ;
	TITLE3 "Top 20 Most Frequent Actors" ;
	HBAR Actor / SUMVAR = Count TYPE = SUM ;
	PATTERN COLOR = BLACK ;
RUN ;
TITLE ;

PROC TEMPLATE ;
  DEFINE STATGRAPH HEATMAP ;
	BEGINGRAPH ;
	  ENTRYTITLE "Actor & Movie Rating" ;
	  LAYOUT OVERLAY / XAXISOPTS = (LABEL = "IMDB Movie Rating") ;
		HEATMAP Y = Actor X = Rating / NAME = "HEATMAP" 
				NXBINS = 10 XBINSTART = 1 XBINSIZE = 1 ;
		CONTINUOUSLEGEND "HEATMAP" /TITLE = "Count" LOCATION = OUTSIDE ;
	  ENDLAYOUT ;
	ENDGRAPH ;
  END ;
RUN ;
 
PROC SGRENDER DATA = Actors TEMPLATE = HEATMAP ;
	WHERE Actor IN ("Robert De Niro" "Morgan Freeman" "Johnny Depp"
					"Bruce Willis" "Matt Damon" "Steve Buscemi"
					"Bill Murray" "Brad Pitt" "John Heard"
					"Liam Neeson" "Nicolas Cage" "Denzel Washington"
					"Will Ferrell" "J.K. Simmons" "Anthony Hopkins"
					"Harrison Ford" "Scarlett Johansson" "Jim Broadbent"
					"Robert Downey Jr." "Tom Cruise" "Christian Bale") ;
RUN;


/**************************************************************
 * Aspect Ratio vs IMDB Score : Two sample T-test
 **************************************************************/

PROC FREQ DATA = work.Movies ;
	TITLE3 "Frequency of Aspect Ratio" ;
	TABLE Aspect_Ratio / NOCUM ;
RUN ;
TITLE ;

PROC MEANS DATA = work.Movies ;
	WHERE Aspect_Ratio = 1.85 ;
	VAR IMDB_Score ;
	TITLE3 "Statistics of IMDB Score - Aspect Ratio: 1.85" ;
RUN ;
TITLE ;

PROC MEANS DATA = work.Movies ;
	WHERE Aspect_Ratio = 2.35 ;
	VAR IMDB_Score ;
	TITLE3 "Statistics of IMDB Score - Aspect Ratio: 2.35" ;
RUN ;
TITLE ;

PROC TTEST DATA = work.Movies ;
	WHERE Aspect_Ratio IN (1.85 2.35) ;
	TITLE3 "TTEST - Aspect Ratio" ;
	CLASS Aspect_Ratio ;
	VAR IMDB_Score ;
RUN ;
QUIT ;
TITLE ;


/**************************************************************
 * Content Rating vs IMDB Score : One-Way Anova
 **************************************************************/

PROC FREQ DATA = work.Movies ;
	TITLE3 "Frequency of Content Rating" ;
	TABLE Content_Rating / NOCUM ;
RUN ;
TITLE ;

PROC UNIVARIATE DATA = work.movies ;
	WHERE Content_Rating IN ('R') ;
	TITLE3 "Distribution of IMDB Score for Movies with Content Rating: R" ;
	VAR IMDB_Score ;
	HISTOGRAM / NORMAL ;
RUN ;
QUIT ;
TITLE ;

PROC UNIVARIATE DATA = work.movies ;
	WHERE Content_Rating IN ('PG-13') ;
	TITLE3 "Distribution of IMDB Score for Movies with Content Rating: PG-13" ;
	VAR IMDB_Score ;
	HISTOGRAM / NORMAL ;
RUN ;
QUIT ;
TITLE ;

PROC UNIVARIATE DATA = work.movies ;
	WHERE Content_Rating IN ('PG') ;
	TITLE3 "Distribution of IMDB Score for Movies with Content Rating: PG" ;
	VAR IMDB_Score ;
	HISTOGRAM / NORMAL ;
RUN ;
QUIT ;
TITLE ;

PROC ANOVA DATA = work.Movies ;
	WHERE Content_Rating IN ('R' 'PG-13' 'PG') ;
	TITLE3 "One-way Analysis of Variance - IMDB Score vs Content Rating" ;
	CLASS Content_Rating ;
	MODEL IMDB_Score = Content_Rating ;
	MEANS Content_Rating / SCHEFFE ;
RUN ;
QUIT ;
TITLE ;


/**************************************************************
 * LINEAR MODEL: Quantitative IVs and the Dependent variable.
 **************************************************************/

PROC CORR DATA = work.Movies ;
	VAR IMDB_Score Budget Duration Movie_FB_Likes
		Director_FB_Likes Actor1_FB_Likes
		Actor2_FB_Likes Actor3_FB_Likes
		Cast_Total_FB_Likes Faces_in_poster ;
RUN ;

PROC SGSCATTER DATA = Movies ;
	WHERE Cast_Total_FB_Likes < 150000 AND
			Director_FB_Likes < 1000 ;
	TITLE3 "Dependent Variable vs Independent Variables" ;
	PLOT IMDB_Score * (Duration Cast_Total_FB_Likes
					Director_FB_Likes Faces_in_poster) /
					ROWS = 4 COLUMNS = 1 ;
RUN ;
GOPTIONS RESET = ALL ;

PROC REG DATA = work.Movies plots=(diagnostics(stats=ALL) CooksD (label) ObservedByPredicted);
	MODEL IMDB_Score =  Action Adventure Animation
						Biography Comedy Crime
						Documentary Drama Family
						Fantasy History Horror Music
						Mystery Romance SciFi Sport
						Thriller War Western Other 
						Duration Director_FB_Likes
						Cast_Total_FB_Likes Faces_in_poster / selection=forward VIF ;
RUN  ;
QUIT ;

PROC REG DATA = work.Movies plots=(diagnostics(stats=ALL) CooksD (label) ObservedByPredicted);
	WHERE ID NOT IN (27 278 600 1125 1869 2780 3404 4606) ;
	MODEL IMDB_Score =  Action Adventure Animation
						Biography Comedy Crime
						Documentary Drama Family
						Fantasy History Horror Music
						Mystery Romance SciFi Sport
						Thriller War Western Other 
						Duration Director_FB_Likes
						Cast_Total_FB_Likes Faces_in_poster / SELECTION = FORWARD VIF ;
RUN  ;
QUIT ;

DATA Movies ;
	SET Movies ;
	Success = 0 ;
	IF IMDB_Score GE 7 THEN Success = 1 ;
RUN ;

PROC LOGISTIC DATA = Movies DESCENDING ;
	MODEL Success = Action Adventure Animation
					Biography Comedy Crime
					Documentary Drama Family
					Fantasy History Horror Music
					Mystery Romance SciFi Sport
					Thriller War Western Other 
					Duration Director_FB_Likes
					Cast_Total_FB_Likes Faces_in_poster /
					SELECTION = FORWARD CTABLE PPROB = (0 TO 1 BY .1)
					LACKFIT RISKLIMITS OUTROC = ROC ;
RUN ;
QUIT ;

/*
PROC HPLOGISTIC DATA = Movies ;
	PARTITION FRACTION (VALIDATE = 0.4) ;
	MODEL Success(EVENT = '1') = Action Adventure Animation
					Biography Comedy Crime
					Documentary Drama Family
					Fantasy History Horror Music
					Mystery Romance SciFi Sport
					Thriller War Western Other 
					Duration Director_FB_Likes
					Cast_Total_FB_Likes Faces_in_poster /
					LACKFIT OUTROC = ROC ;
RUN ;
QUIT ;
*/

ODS PDF CLOSE ;
