# Chess

https://epeters95.github.io/chess


Version: Pre-Alpha

Hosted on: Render https://chess-wpj4.onrender.com

Source: [Frontend client (Github Pages)](https://github.com/epeters95/chess/tree/gh-pages) | [Server + backend](https://github.com/epeters95/chess/tree/master)

API docs: https://epeters95.github.io/chess/Swagger%20UI.html

This is a demo of an API-only Rails app enabling users to play a game of chess via API with a computer or player. Github pages display an interface with plain javascript and css assets working as a front-end client.   It uses PostgreSQL for storage, connects to a microservice to use the Stockfish Python library, and includes several features:
- Play as both teams
- Play Stockfish at Easy, Medium, or Hard
- Play a live game with a friend via shared access code
- Game history and move replaying
- Upload a PGN file to import a famous game to the game history page

To play someone using matchmaking, follow these steps:

1. First, click 'New Live Game' and enter a name under a chosen team
2. Send the code to a friend for them to search using 'Enter Code' and 'Find Game'
3. Wait for the friend to enter their name and submit and the game will begin
