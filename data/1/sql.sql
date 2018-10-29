/* Author : wzcboss@qq.com
   Create : 2018.09.13
 */

/* No counts result return */
USE soft
SET NOCOUNT ON

/*declare variables*/
DECLARE @authorId varchar(50),
        @authorFirstName varchar(50),
        @authorLastName varchar(50),
        @output varchar(80),
        @bookTitle varchar(80)

PRINT '-------- Authors report --------'

/* authors's information*/
DECLARE authors_cursor CURSOR FOR
SELECT au_id, au_fname, au_lname
FROM authors
ORDER BY au_id

OPEN authors_cursor

/* Do while loop*/
/* get authors's information*/
FETCH NEXT FROM authors_cursor
INTO @authorId, @authorFirstName, @authorLastName


WHILE @@FETCH_STATUS = 0 /* get authors*/
BEGIN

   PRINT ''
   SELECT @output = '----- Books by Author: ' +
      @authorFirstName + ' ' + @authorLastName

   PRINT @output

  /* a inner cursor to find out books titles written by @authorId */
   DECLARE titles_cursor CURSOR FOR
   SELECT titles.title
   FROM titleauthor , titles
   WHERE titleauthor.title_id = titles.title_id AND
   titleauthor.au_id = @authorId

   OPEN titles_cursor
   FETCH NEXT FROM titles_cursor INTO @bookTitle

  /* no books */
   IF @@FETCH_STATUS <> 0
      PRINT '      Can''t find any books.'

  /* not only one book */
   WHILE @@FETCH_STATUS = 0
   BEGIN

      SELECT @output = '      ' + @bookTitle
      PRINT @output
      FETCH NEXT FROM titles_cursor INTO @bookTitle

   END

  /* this  @authorId has been traversed */
   CLOSE titles_cursor
   DEALLOCATE titles_cursor

   /* Get the next author */
   FETCH NEXT FROM authors_cursor
   INTO @authorId, @authorFirstName, @authorLastName
END

/* release memory */
CLOSE authors_cursor
DEALLOCATE authors_cursor