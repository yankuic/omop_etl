CREATE FUNCTION udf_extract_numbers (
	@String varchar(max)
)
/*
Modified from https://stackoverflow.com/questions/14700214/how-to-extract-numbers-from-a-string-using-tsql#15092825
*/
RETURNS varchar(max)

BEGIN
DECLARE @integers varchar(max);
DECLARE @len INT

SET @len = LEN(@String)
SELECT @integers =
    CAST(( 
        SELECT 
            --Select only numeric and period (for decimal numbers) ascii characters.
            CASE 
                WHEN ( (ASCII(UPPER(SUBSTRING(@String, Number, 1))) BETWEEN 48 AND 57) OR 
                       (ASCII(UPPER(SUBSTRING(@String, Number, 1))) = 46) )
                THEN SUBSTRING(@String, Number, 1)
                ELSE ''
            END
        FROM
        ( 
            --Get list of numbers to reference string characters indexes.
            SELECT TOP (CASE WHEN @String IS NULL THEN 0 ELSE @len END)
                ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 ) ) AS Number
             FROM master.sys.all_columns a
             CROSS JOIN master.sys.all_columns b 
        ) AS n
        --use xml path to pivot the results into a row
        FOR XML PATH('') ) AS varchar(255)) 

RETURN @integers
END
