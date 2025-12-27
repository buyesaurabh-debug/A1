# Splitwise Clone - Expense Sharing Application

A Ruby on Rails 6.1 web application for splitting expenses with friends and groups, featuring Devise authentication, Bootstrap 5 styling, and PostgreSQL database.

## Overview

This is a Splitwise-like expense sharing application featuring:
- User registration and login via Devise
- Group management with admin controls
- Expense tracking with split options (equal/custom)
- Balance calculation showing who owes whom
- Settlement recording between users
- Dashboard with financial overview
- Email notifications via ActionMailer
- Real-time notifications via ActionCable
- Bootstrap 5 UI with responsive design

## Tech Stack

- **Ruby**: 3.2.2
- **Rails**: 6.1.7
- **Database**: PostgreSQL (Replit integrated)
- **Authentication**: Devise
- **Frontend**: Bootstrap 5, jQuery, Slim templates, jGrowl notifications
- **Asset Pipeline**: Webpacker 5
- **Real-time**: ActionCable WebSockets
- **Email**: ActionMailer

## Project Structure

```
app/
├── assets/          # Stylesheets and static assets
├── channels/        # ActionCable channels (notifications, groups)
├── controllers/     # Rails controllers
│   ├── dashboard_controller.rb
│   ├── groups_controller.rb
│   ├── expenses_controller.rb
│   ├── settlements_controller.rb
│   └── friends_controller.rb
├── javascript/      # JavaScript packs and channels
│   └── channels/    # ActionCable JS consumers
├── mailers/         # Email templates
│   └── group_mailer.rb
├── models/          # ActiveRecord models
│   ├── user.rb
│   ├── group.rb
│   ├── group_membership.rb
│   ├── expense.rb
│   ├── expense_participant.rb
│   └── settlement.rb
├── services/        # Service objects
│   ├── balance_service.rb
│   └── notification_service.rb
└── views/           # Slim and ERB templates
config/              # Rails configuration
db/                  # Database migrations and schema
```

## Key Features

### Groups (Priority 0)
- Create groups with name
- Admin can add/remove members
- Email invitations for non-registered users

### Expenses (Priority 1)
- Add expenses with description, amount, tax
- Split equally among participants
- Custom split amounts
- Track who paid

### Balance Calculation (Priority 1)
- BalanceService calculates net balances
- Shows who owes whom and how much
- Considers both expenses and settlements

### Dashboard (Priority 2)
- Total balance overview
- Friends you owe / who owe you
- Recent expenses
- Quick access to groups

### Settlements (Priority 3)
- Record payments between users
- Reduces outstanding balances
- Notes for payment details

### Notifications (Priority 4)
- Email notifications for:
  - Group invitations
  - Member added to group
  - New expenses
  - Settlements
- Real-time notifications via ActionCable

## Running the Application

The Rails server runs on port 5000:
```bash
bundle exec rails server -b 0.0.0.0 -p 5000
```

## Environment Variables

- `DATABASE_URL` - PostgreSQL connection string (auto-configured)
- `NODE_OPTIONS=--openssl-legacy-provider` - Required for Webpack 4 with Node.js 17+
- `SMTP_ADDRESS` - SMTP server for email (optional)
- `SMTP_PORT` - SMTP port (default: 587)
- `SMTP_USERNAME` - SMTP username
- `SMTP_PASSWORD` - SMTP password

## Database Models

- **User**: Devise authentication, name, mobile_number
- **Group**: name, admin (creator)
- **GroupMembership**: joins users to groups
- **Expense**: description, total_amount, tax, payer_id, group_id
- **ExpenseParticipant**: user_id, expense_id, share_amount
- **Settlement**: from_user_id, to_user_id, amount, note, group_id

## Deployment

Configured for Replit autoscale deployment with:
- Build: `bundle install && assets precompile && db:migrate`
- Run: Puma web server on port 5000

## Recent Changes

- 2025-12-27: Complete Splitwise clone implementation
  - Priority 0: Groups and memberships
  - Priority 1: Expenses, splits, and balance calculation
  - Priority 2: Dashboard and friends page
  - Priority 3: Settlements
  - Priority 4: Email notifications (ActionMailer) and real-time notifications (ActionCable)
  - Fixed settlement sign calculation in BalanceService
  - Fixed ActionCable authentication for Devise/Warden sessions
