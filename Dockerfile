# Stage 1: Build assets
FROM ruby:alpine AS builder

WORKDIR /build
RUN gem install haml sass

COPY ./src .

# Compile HAML and SASS files to build HTML and CSS assets
RUN mkdir -p static/css && \
  haml render haml/index.haml > static/index.html && \
  sass /build/sass/style.sass /build/static/css/style.css

# Stage 2: Flask app
FROM python:3.9-alpine

WORKDIR /app
COPY . /app

# Install Python dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy HTML and CSS assets from builder stage 
COPY --from=builder /build/static/ /app/static/

# Expose port 5000 and run Flask app
EXPOSE 5000
CMD ["python", "app.py"]