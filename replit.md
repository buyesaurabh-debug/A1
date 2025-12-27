# BE Assignment Junior 1

A Ruby on Rails 6.1 web application with Devise authentication, Bootstrap 5 styling, and PostgreSQL database.

## Overview

This is a user authentication application featuring:
- User registration and login via Devise
- Bootstrap 5 UI with floating labels
- PostgreSQL database
- Webpacker for JavaScript assets

## Tech Stack

- **Ruby**: 3.2.2
- **Rails**: 6.1.7
- **Database**: PostgreSQL (Replit integrated)
- **Authentication**: Devise
- **Frontend**: Bootstrap 5, jQuery, Slim templates
- **Asset Pipeline**: Webpacker 5

## Project Structure

```
app/
├── assets/          # Stylesheets and static assets
├── controllers/     # Rails controllers (Static, Devise)
├── javascript/      # JavaScript packs and channels
├── models/          # ActiveRecord models (User)
├── views/           # Slim and ERB templates
config/              # Rails configuration
db/                  # Database migrations and schema
```

## Key Files

- `config/database.yml` - PostgreSQL connection via DATABASE_URL
- `config/routes.rb` - Application routes with Devise
- `app/models/user.rb` - User model with Devise modules
- `app/controllers/static_controller.rb` - Main application controller

## Running the Application

The Rails server runs on port 5000:
```bash
bundle exec rails server -b 0.0.0.0 -p 5000
```

## Environment Variables

- `DATABASE_URL` - PostgreSQL connection string (auto-configured)
- `NODE_OPTIONS=--openssl-legacy-provider` - Required for Webpack 4 with Node.js 17+

## Database

Uses Replit's integrated PostgreSQL database. Migrations:
- `devise_create_users` - Creates users table with Devise fields
- `add_basic_field_to_user` - Adds name and mobile_number fields

## Deployment

Configured for Replit autoscale deployment with:
- Build: `bundle install && assets precompile && db:migrate`
- Run: Puma web server on port 5000

## Recent Changes

- 2025-12-27: Initial Replit setup
  - Updated Ruby version to 3.2.2
  - Added logger gem for Ruby 3.2 compatibility
  - Configured hosts.clear for development and production
  - Set up PostgreSQL with Replit database
  - Configured Webpacker with legacy OpenSSL provider
