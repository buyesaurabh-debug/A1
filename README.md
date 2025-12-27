# Splitwise Clone - Expense Sharing Application

A Ruby on Rails 6.1 web application for splitting expenses with friends and groups. Track shared costs, calculate balances, and settle debts easily.

## Features

- **User Authentication**: Sign up, login, logout with Devise
- **Groups**: Create groups and invite members by email
- **Expenses**: Add expenses and split them equally or with custom amounts
- **Balance Calculation**: See who owes whom and how much
- **Settlements**: Record payments to settle debts
- **Real-time Notifications**: Get instant updates via WebSockets
- **Email Notifications**: Receive emails for invitations, expenses, and settlements

---

## Local Development Setup

### Prerequisites

- Ruby 3.2.2 (or 3.0.0+)
- Node.js 12.13.1+ (18+ recommended)
- PostgreSQL 12+
- Bundler gem
- Yarn or npm

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd splitwise-clone
```

### Step 2: Install Ruby Dependencies

```bash
gem install bundler
bundle install
```

### Step 3: Install JavaScript Dependencies

```bash
yarn install
# or
npm install
```

### Step 4: Configure Environment Variables

Create a `.env` file in the root directory (or export these variables):

```bash
# Database (required)
DATABASE_URL=postgresql://username:password@localhost:5432/splitwise_development

# Node.js (required for Webpack 4 with Node 17+)
export NODE_OPTIONS=--openssl-legacy-provider

# Email (optional - for sending emails)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

### Step 5: Setup Database

```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# (Optional) Seed with sample data
rails db:seed
```

### Step 6: Start the Server

```bash
bundle exec rails server -b 0.0.0.0 -p 5000
```

Visit `http://localhost:5000` in your browser.

---

## Project Structure and New Files Created

### Models (`app/models/`)

| File | Purpose |
|------|---------|
| `user.rb` | User authentication with Devise. Has associations to groups, expenses, and settlements. Includes `display_name` method for UI. |
| `group.rb` | **NEW** - Expense group with name and admin. Uses callbacks to auto-add admin as member. Has methods like `member?`, `add_member`, `remove_member`. |
| `group_membership.rb` | **NEW** - Join table linking users to groups. Ensures unique membership per user/group. |
| `expense.rb` | **NEW** - Expense record with description, amount, tax. Belongs to group and payer (user). |
| `expense_participant.rb` | **NEW** - Tracks each user's share of an expense. Links expenses to participating users. |
| `settlement.rb` | **NEW** - Payment record between two users. Tracks who paid whom and how much. |

### Controllers (`app/controllers/`)

| File | Purpose |
|------|---------|
| `dashboard_controller.rb` | **UPDATED** - Main dashboard showing total balance, groups, recent expenses, and friends summary. |
| `groups_controller.rb` | **NEW** - CRUD for groups. Handles add/remove members. Only admins can modify groups. |
| `expenses_controller.rb` | **NEW** - CRUD for expenses. Handles equal and custom splits among participants. |
| `settlements_controller.rb` | **NEW** - Records settlements between users within a group. |
| `friends_controller.rb` | **NEW** - Shows expense history with a specific friend across all shared groups. |

### Services (`app/services/`)

| File | Purpose |
|------|---------|
| `balance_service.rb` | **NEW** - Core business logic for calculating balances. Computes who owes whom by analyzing expenses and settlements. Methods: `balance_for`, `you_owe`, `owed_to_you`, `debts_for`, `credits_for`. |
| `notification_service.rb` | **NEW** - Broadcasts real-time notifications via ActionCable when expenses, settlements, or members are added. |

### Mailers (`app/mailers/`)

| File | Purpose |
|------|---------|
| `group_mailer.rb` | **NEW** - Sends email notifications for: invitations to non-registered users, member additions, new expenses, and settlements. |

### Email Templates (`app/views/group_mailer/`)

| File | Purpose |
|------|---------|
| `invitation.html.slim` / `.text.slim` | **NEW** - Email template for inviting new users to join the app and a group. |
| `member_added.html.slim` / `.text.slim` | **NEW** - Notification when someone is added to a group. |
| `new_expense.html.slim` / `.text.slim` | **NEW** - Notification about new expenses in a group. |
| `new_settlement.html.slim` / `.text.slim` | **NEW** - Notification when a settlement is recorded. |

### ActionCable Channels (`app/channels/`)

| File | Purpose |
|------|---------|
| `application_cable/connection.rb` | **UPDATED** - Authenticates WebSocket connections using Devise/Warden session. |
| `notifications_channel.rb` | **NEW** - Personal notification channel for each user. Broadcasts individual updates. |
| `group_channel.rb` | **NEW** - Group-specific channel. Broadcasts updates to all group members. |

### JavaScript Channels (`app/javascript/channels/`)

| File | Purpose |
|------|---------|
| `consumer.js` | Creates ActionCable consumer for WebSocket connection. |
| `notifications_channel.js` | **NEW** - Subscribes to personal notifications. Shows jGrowl toast on new messages. |
| `group_channel.js` | **NEW** - Subscribes to group updates when viewing a group page. |

### Views (`app/views/`)

| Directory | Purpose |
|-----------|---------|
| `dashboard/index.html.slim` | **UPDATED** - Dashboard view showing balance summary and quick links. |
| `groups/` | **NEW** - Group list, show, new, edit views. Includes member management modal. |
| `expenses/` | **NEW** - Expense list, show, new, edit views. Includes split type selection. |
| `settlements/` | **NEW** - Settlement creation form with balance hints. |
| `friends/show.html.slim` | **NEW** - Friend page showing shared expenses. |
| `layouts/_top_nav_bar.html.slim` | **UPDATED** - Navigation bar with Dashboard, Groups links. |
| `devise/sessions/new.html.slim` | **UPDATED** - Sign in page with link to sign up page. |

### Configuration Files

| File | Purpose |
|------|---------|
| `config/routes.rb` | **UPDATED** - Defines all application routes including nested resources for expenses and settlements. |
| `config/database.yml` | PostgreSQL configuration using DATABASE_URL. |
| `config/environments/development.rb` | **UPDATED** - ActionMailer and ActionCable configuration for Replit. |
| `config/cable.yml` | ActionCable adapter configuration (async for development). |

### Database Migrations (`db/migrate/`)

| Migration | Purpose |
|-----------|---------|
| `create_groups` | **NEW** - Creates groups table with name and admin reference. |
| `create_group_memberships` | **NEW** - Creates join table for users and groups. |
| `create_expenses` | **NEW** - Creates expenses with description, amount, tax, payer, and group. |
| `create_expense_participants` | **NEW** - Creates participant shares for expenses. |
| `create_settlements` | **NEW** - Creates settlements with from_user, to_user, amount, note, and group. |

---

## How It Works

### Balance Calculation Logic

The `BalanceService` calculates balances using this formula:

```
balance = (what you paid for others) - (your share of expenses) + (settlements you made) - (settlements you received)
```

- **Positive balance**: Others owe you money
- **Negative balance**: You owe others money
- **Zero balance**: All settled up

### Expense Splitting

1. **Equal Split**: Total amount divided equally among selected participants
2. **Custom Split**: Manually enter each person's share

---

## Testing the Application

1. **Sign Up**: Visit `/users/sign_in` and click the "Sign up" link, or go directly to `/users/sign_up`
2. **Create a Group**: Click "New Group" from the dashboard
3. **Add Members**: Use the "Add Member" button (enter email of existing users)
4. **Add Expenses**: Create expenses and choose split type (equal or custom)
5. **Check Balances**: View who owes whom on the group page
6. **Settle Up**: Record payments when debts are paid

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| Backend | Ruby on Rails 6.1 |
| Database | PostgreSQL |
| Authentication | Devise |
| Frontend | Bootstrap 5, jQuery, Slim templates |
| Assets | Webpacker 5 |
| Real-time | ActionCable (WebSockets) |
| Email | ActionMailer |
| Notifications UI | jGrowl |

---

## Troubleshooting

### Webpack/Node.js Issues
If you see OpenSSL errors with Node 17+:
```bash
export NODE_OPTIONS=--openssl-legacy-provider
```

### Database Connection
Verify PostgreSQL is running:
```bash
pg_isready
```

### ActionCable Not Connecting
- Ensure you're logged in
- Check browser console for WebSocket errors
- Verify `config.action_cable.disable_request_forgery_protection = true` in development

### Emails Not Sending
- Configure SMTP settings in `.env`
- Or add `letter_opener` gem for development email preview

---

## Deployment

### Replit Deployment
The app is configured for Replit autoscale deployment:
- **Build**: `bundle install && rails assets:precompile && rails db:migrate`
- **Run**: `bundle exec rails server -b 0.0.0.0 -p 5000`

### Heroku Deployment
```bash
heroku create
heroku addons:create heroku-postgresql:hobby-dev
git push heroku main
heroku run rails db:migrate
```

---

## License

MIT License
#   A 2  
 