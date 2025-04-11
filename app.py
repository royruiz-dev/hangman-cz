from flask import Flask, request
from wonderwords import RandomWord
import re

app = Flask(__name__)
r = RandomWord()

def get_random_words(count, min_length=4, max_length=10, categories=None):
  return r.random_words(
    count,                        # number of words to generate
    word_min_length=min_length,   # minimum length of each word
    word_max_length=max_length,   # maximum length of each word
    include_categories=categories # filter words by categories
  )

# Generate random words based on specified category
random_nouns = get_random_words(200, categories=["noun"])
clean_nouns = [word for word in random_nouns if re.match(r'^[A-Za-z]+$', word)]

@app.route('/nouns')
def get_nouns():
  print("Headers: ", request.headers)
  return clean_nouns

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=5000)