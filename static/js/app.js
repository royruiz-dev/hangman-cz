// Handles response from server once XMLHttpRequest is complete and status is successful
// If the server is not responding, it calls blockScreen() and game is not started
function reqListener() {
  if (this.readyState === 4) {
    if (this.status === 200) {
      wordBank = JSON.parse(this.responseText);
      initializeNewGame();
    }
    else blockScreen();
  }
}

// Displays an error overlay when server fails to respond
function blockScreen() {
  var item = document.getElementById('errorOverlay');
  item.style.display = "block";
}

// Makes an asynchronous REST call to fetch word data using XMLHttpRequest
function fetchWord() {
  var xhttp = new XMLHttpRequest();
  xhttp.open("GET", url , true);
  xhttp.addEventListener("load", reqListener);
  xhttp.addEventListener("error", blockScreen);
  xhttp.addEventListener("abort", blockScreen);
  xhttp.send(null);
}

// Selects a random word from wordBank array
function randomizeWord() {
  var index = Math.floor(Math.random() * wordBank.length);
  return wordBank[index];
}
// // This is then used as a comparison to the secretWord string and verify whether game is completed or not.

// Initializes a string of underscores based on the secret word length to track progress
// The display value is also shown in the console for debugging purposes
function displayInitialize() {
  var display = "";

  for (i=0; i<secretWord.length; i++) display+="_";
  return display;
}

// Displays underscores representing the 'unguessed' letters of the secret word
function displayUnderscores() {
  var word = document.getElementById('wordChallenge');
  var displayBlanks = secretWord.replace(/./g,"<div class='letterBox'></div> ")
  word.innerHTML = displayBlanks;
}

// Displays the hangman image based on the number of incorrect guesses
function displayHangman(count) {
    var list = document.getElementsByClassName('hangmanDude')[0];
    list.getElementsByTagName('img')[count-1].style.display = "block";
}

// Displays the guessed letter in the correct position of the secret word
function displayString(secretWord, guess) {
  var letterBoxes = document.getElementsByClassName('letterBox');
  for (i=0; i<secretWord.length; i++) {
    if (secretWord.toUpperCase().charAt(i) === guess) {
      letterBoxes[i].innerHTML = guess;
      display = display.substr(0,i) + guess + display.substr(i+1);
    }
  }
  return display;
}

// Adds the correct guessed letter to the correctBin array for debugging
function rightGuess(guess) {
  correctBin.push(guess);
}

// Displays list of incorrect guessed letters
function wrongGuess(wrongBin) {
  var wrongBucket = document.getElementById('wrongGuesses');
  var displayWrongGuesses = wrongBin.map(function(x){return "<div class='wrongLetter'>" + x + "</div>"}).join(', ');
  wrongBucket.innerHTML = "<b>Failed Guesses:</b> " + displayWrongGuesses;
}

// Displays number of remaining guesses
function guessesRemaining(count){
  var guessesLeft = document.getElementById('guessesLeft');
  guessesLeft.innerHTML = "<b>Attempts Left:</b> <div class='guessCount'>" + (guessesAllowed - count) + "</div>";
}

// Validates the guessed letter has not been used before (either correct or incorrect)
function validateGuess(guess, correctBin, wrongBin, secretWord) {
  if (!guess.match(/^[a-zA-Z]$/)) return false; // Ensures the guess is a valid letter
  else if (!/[a-zA-Z]/.test(secretWord)) return false; // Checks secret word is not empty
  else if (correctBin.indexOf(guess) > -1 || wrongBin.indexOf(guess) > -1) return false; // Ensures letter has not been guessed before
  else return true;
}

// Checks game status: (1) if user or computer has won, or (2) if game is still ongoing
function gameStatus(count, display, secretWord) {
  if (count >= guessesAllowed) return -1; // Computer wins
  else if (display === secretWord.toUpperCase()) return 1; // User wins
  else return 0; // Game continues
}

// Displays 'PLAYER WINS!' message when user wins
function userWins() {
  var winner = document.getElementById('gameWinner');
  winner.innerHTML = "PLAYER WINS!";
  winner.style.display = 'flex'; // Makes the winner message visible
}

// Displays 'SECRET KEEPER WINS!' message when computer wins
function userLoses() {
  var winner = document.getElementById('gameWinner');
  winner.innerHTML = "SECRET KEEPER WINS!";
  winner.style.display = 'flex'; // Makes the winner message visible
}

// Resets necessary values for a new game and clears previous game data from the DOM
function resetGame() {
  status = 0;
  count = 0;
  correctBin = [];
  wrongBin = [];
  display = "";
  guessesAllowed = 6;

  guessesRemaining(count);
  document.getElementById('gameWinner').innerHTML = "";
  document.getElementById('wrongGuesses').innerHTML = "";
  document.getElementById('wordChallenge').innerHTML = "";

  // Hide the winner display
  var winner = document.getElementById('gameWinner');
  winner.style.display = 'none';

  // Hides hangman images
  for (i=0; i<guessesAllowed; i++) {
    var list = document.getElementsByClassName('hangmanDude')[0];
    list.getElementsByTagName('img')[i].style.display = "none";
  }
}

// Initializes a new game by resetting the game and selecting a new word
function initializeNewGame() {
  resetGame();
  secretWord = randomizeWord();
  display = displayInitialize();
  displayUnderscores();
}

// Handles the 'guessing' process during the game, checking if guess is correct or incorrect
function doGuess() {
  if (status !=0 ) return;  // Prevents guessing once games has ended

  guess = this.innerText;
  valid = validateGuess(guess, correctBin, wrongBin, secretWord);

  if (valid) {
    if (secretWord.toUpperCase().indexOf(guess) > -1) {
      rightGuess(guess, correctBin);
      display = displayString(secretWord, guess);
    }
    else {
      count+=1;
      wrongBin.push(guess);

      wrongGuess(wrongBin);
      guessesRemaining(count);
      displayHangman(count);
    }
  status = gameStatus(count, display, secretWord); // Stores status value
  }

  // Used for debugging purposes and logs the game status
  consoleOutput(display, secretWord, wrongBin, correctBin, count, status);

  if (status == 1) userWins();
  else if (status == -1) userLoses();
}

// Game information logs relevant for debugging
function consoleOutput(display, secretWord, wrongBin, correctBin, count, status) {
  console.log("Display is: "+ display);
  console.log("Secret word is: " + secretWord);
  console.log("Wrong Guesses: " + wrongBin);
  console.log("Correct Guesses: " + correctBin);
  console.log("Misses: " + count);
  console.log("Status: " + status);
}
