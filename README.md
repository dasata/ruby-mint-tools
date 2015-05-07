# ruby-mint-tools
A collection of tools written in Ruby to better manage Mint data. These tools are initially intended to:

1. Import transaction data from Mint into a local Postgresql database.
2. Provide aggregate reporting on that transaction data.
3. Create and manage budgets that extend multiple months into the future (one of the current limitations of Mint, IMO). 

These tools are very much a work in progress and are also my first attempts at learning Ruby and Rails so for you more experienced folks, you will likely notice strange organization or coding patterns as I work out the kinks. Feedback is very much appreciated.

# why?
I like using Mint.com to manage my transaction history. What I don't like doing is managing my budget through the site. It doesn't provide much in the way of forecasting budgets over multiple months in the future. So my goal with this project is to leverage the power of Mint to plan my financial future by creating some more advanced budgeting tools that I can later reconcile with the transactions Mint pulls in. 
