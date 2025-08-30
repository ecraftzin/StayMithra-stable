# 📱 Mobile Password Reset Setup Instructions

## 🎯 Problem Fixed
The issue was that `localhost:8000` only works on your computer, not on your mobile phone. Now the server is configured to be accessible from any device on your network.

## ✅ Current Configuration
- **Server IP**: `192.168.29.241:8000`
- **Supabase Site URL**: Updated to `http://192.168.29.241:8000`
- **AuthService**: Updated to use network IP address
- **Server**: Configured to accept connections from any device

## 🚀 How to Test Password Reset on Mobile

### Step 1: Make Sure Server is Running
1. Open terminal/command prompt
2. Navigate to your project directory
3. Run: `node web/server.js`
4. You should see:
   ```
   Server running at:
     Local:    http://localhost:8000
     Network:  http://192.168.29.241:8000
   
   📱 For mobile access, use: http://192.168.29.241:8000
   ```

### Step 2: Test Network Access
1. On your mobile phone, open browser
2. Go to: `http://192.168.29.241:8000`
3. You should see the StayMithra password reset page

### Step 3: Test Password Reset Flow
1. Open your StayMithra app on mobile
2. Go to "Forgot Password"
3. Enter your email address
4. Tap "Reset Password"
5. Check your email for the reset link
6. Tap the reset link in the email
7. It should open the password reset page in your mobile browser
8. Enter your new password and confirm
9. Tap "Update Password"

## 🔧 Important Notes

### Network Requirements
- Your mobile phone and computer must be on the **same WiFi network**
- Your computer's firewall should allow connections on port 8000
- If it doesn't work, try temporarily disabling Windows Firewall

### Firewall Configuration (if needed)
1. Open Windows Defender Firewall
2. Click "Allow an app or feature through Windows Defender Firewall"
3. Click "Change Settings" → "Allow another app"
4. Browse to Node.js or add port 8000

### Alternative: Use Your Phone's Hotspot
If WiFi doesn't work:
1. Enable hotspot on your phone
2. Connect your computer to the phone's hotspot
3. Get the new IP address: `ipconfig`
4. Update the IP in the configuration

## 🌐 For Production Deployment

When you're ready to deploy to production:

1. **Deploy to a hosting service** (Netlify, Vercel, etc.)
2. **Update Supabase site URL** to your production domain
3. **Update AuthService** redirect URL to production URL

Example production URLs:
- Netlify: `https://staymithra-reset.netlify.app`
- Vercel: `https://staymithra-reset.vercel.app`

## 🔍 Troubleshooting

### "This site can't be reached" on mobile
- Check if both devices are on same WiFi
- Try accessing `http://192.168.29.241:8000` directly in mobile browser
- Check Windows Firewall settings
- Restart the server

### Email link doesn't work
- Make sure server is running
- Check Supabase site URL is correct
- Verify AuthService redirect URL matches

### Password reset page shows error
- Check browser console for errors
- Verify Supabase configuration
- Make sure the reset link hasn't expired

## 📞 Quick Test Commands

Test server accessibility:
```bash
# From your computer
curl http://192.168.29.241:8000

# From mobile browser
http://192.168.29.241:8000
```

## ✅ Success Indicators

You'll know it's working when:
1. ✅ Mobile browser can access `http://192.168.29.241:8000`
2. ✅ Password reset email contains the correct IP address
3. ✅ Clicking email link opens the reset page on mobile
4. ✅ Password update works and redirects to app

The password reset functionality is now **fully configured for mobile access**! 🎉
