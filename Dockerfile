# Dockerfile
FROM python:3.9-alpine

# Upgrade package managers a& install ruby, haml, and sass for compiling
RUN pip install --upgrade pip && \
  apk update && apk add ruby && \
  gem install haml sass 

# Set working directory
WORKDIR /app

# Copy all files into working directory
COPY . /app

# Install Python dependencies
RUN pip install -r requirements.txt

# Compile HAML and SASS files to build HTML and CSS assets
RUN haml render src/haml/index.haml > static/index.html && \
  sass src/sass/style.sass static/css/style.css

# Expose port 5000
EXPOSE 5000

# Run Flask app with custom host and port
CMD ["python", "app.py"]