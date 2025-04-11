// Runs function once DOM content is fully loaded
document.addEventListener('DOMContentLoaded', function() {

// Sets up a click event listener on 'newGame' element to start a new game when clicked
  document.getElementById('newGame').addEventListener('click',initializeNewGame);

// 'letters' is a collection of elements associated to the 'alphabet' class
  var letters = document.getElementsByClassName('alphabet');

// Attaches a click event listener to each letter, running doGuess() on user click
  Array.prototype.map.call(letters,function(x) {
    x.addEventListener('click', doGuess);
  });

// Fetches a word from server when content is loaded
  fetchWord();
});
