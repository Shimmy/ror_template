# Use Ruby 3.3 as the base image
FROM ruby:3.3

# Install essential Linux packages including libyaml-dev
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    git \
    curl \
    postgresql-client \
    libyaml-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN npm install -g yarn

# Set working directory for the template files
WORKDIR /template

# Copy all template files (template.rb and related files/directories)
COPY . .

# Install Rails 8
RUN gem install rails -v 8.0.0

# Create a directory for the new application
WORKDIR /app

# Set up entrypoint script with improved error handling
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Generate a new Rails application using the template\n\
if [ ! -f "/app/myApp/config/application.rb" ]; then\n\
  echo "Creating new Rails application with template..."\n\
  cd /app\n\
  rails new myApp -m /template/template.rb\n\
fi\n\
\n\
# Change to the app directory\n\
cd /app/myApp\n\
\n\
# Remove a potentially pre-existing server.pid\n\
rm -f /app/myApp/tmp/pids/server.pid\n\
\n\
# Then exec the container'\''s main process\n\
exec "$@"' > /usr/bin/entrypoint.sh

RUN chmod +x /usr/bin/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# Expose the port the app runs on
EXPOSE 3000

# Start the Rails server by default
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
