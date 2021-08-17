# Execute a Query against all Databases
During some point in production there comes a time where there is a need for camparison between various databases. Usually it can be handled through the an undocumented procedure called sp_msforeachdb which is not without its limitations, to name a few:
  - The @command parameter accepts nvarchar(2000); meaning if the query you wish to execute is anything longer than 2000 characters it will be truncated and produces errors.
  - The results are not easily comparable, each result is returned in a different grid which makes monitoring them a cumbersome effort.

Now because of the nature of the work that I do, I'll be needing this sort of comparison more often than not. I set out to come up with a solution and before you is the result.
This script adresses problems mentioned above, but there are always limitations to be considered:
  - Mind performance before everything else; refrain from using queries that require heavy workload, for obvious reasons.
  - In order to be able to check progress I decided to store result sets in a global temp table, consider changing it to local tempo table if fot whatever reason this causes issues.
  - Lastly, do remember that all your columns must have aliases otherwise, naturally, sql engine would ask you to.
