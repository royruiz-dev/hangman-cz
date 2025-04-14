// URL endpoint t fetch word data from API (e.g., a list of nouns)
var url = "/nouns";

// Initializes string to store response from REST API
// Used to select a random word for the game
var wordBank = "";

// Stores selected word returned from REST API
var secretWord;

var guess;  //assigned to innerText property where it reads the string value within 'alphabet' class when executing doGuess()
var valid;  //assigned to boolean return from validateGuess(). This boolean value tells us whether the guess being passed is valid for the game.

// Initializes arrays for correct and incorrect guesses
// Incorrect guesses are displayed in the UI; correct ones are used for debugging
var wrongBin, correctBin = new Array;

// To track incorrect guesses, remaining guesses, and game status
// These variables are reset in resetGame()
var count, status, guessesAllowed;

// Used to track current state of secret word,
// Helps validate whether the user has completed guessing the secret word
var display = "";
