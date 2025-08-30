# StayMithra Password Reset Web Page

This directory contains the web-based password reset functionality for the StayMithra mobile app.

## Files

- `reset-password.html` - The main password reset page
- `server.js` - Node.js server to serve the HTML file
- `server.py` - Python server alternative
- `package.json` - Node.js dependencies and scripts

## Quick Setup

### Option 1: Node.js Server (Recommended)

1. Make sure you have Node.js installed
2. Navigate to the web directory:
   ```bash
   cd web
   ```
3. Start the server:
   ```bash
   npm start
   ```
4. The server will run at `http://localhost:8000`

### Option 2: Python Server

1. Make sure you have Python 3 installed
2. Navigate to the web directory:
   ```bash
   cd web
   ```
3. Start the server:
   ```bash
   python server.py
   ```
4. The server will run at `http://localhost:8000`

### Option 3: Static File Hosting

You can also host the `reset-password.html` file on any static file hosting service like:
- Netlify
- Vercel
- GitHub Pages
- Firebase Hosting

## Configuration

### Update Supabase Configuration

Make sure to update the Supabase site URL to point to your hosted domain:

1. Go to your Supabase dashboard
2. Navigate to Authentication > Settings
3. Update the "Site URL" to your domain (e.g., `https://yourdomain.com`)

### Update Redirect URL in App

In your Flutter app, update the `resetPasswordForEmail` redirect URL in `lib/services/auth_service.dart`:

```dart
redirectTo: 'https://yourdomain.com/reset-password.html'
```

## How It Works

1. User requests password reset from the mobile app
2. Supabase sends an email with a reset link
3. User clicks the link, which opens the web page
4. User enters new password on the web page
5. Password is updated via Supabase API
6. User is redirected back to the mobile app

## Deployment

### Netlify (Recommended)

1. Create a new site on Netlify
2. Upload the `reset-password.html` file
3. Update the site URL in Supabase settings

### Vercel

1. Create a new project on Vercel
2. Upload the web directory
3. Deploy and update the site URL in Supabase settings

### Custom Server

Deploy the Node.js server to any cloud provider like:
- Heroku
- Railway
- DigitalOcean
- AWS

## Testing

1. Start the local server
2. Update the redirect URL in your app to `http://localhost:8000/reset-password.html`
3. Test the password reset flow
4. Once working, deploy to production and update the URL

## Security Notes

- The HTML page uses HTTPS for all Supabase communications
- Password reset tokens are handled securely by Supabase
- The page validates password strength and confirmation
- CORS headers are properly configured
