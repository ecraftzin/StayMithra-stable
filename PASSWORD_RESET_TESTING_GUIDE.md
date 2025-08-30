# 🔧 Password Reset Authentication Issue - Testing Guide

## 🎯 Current Issue
When clicking "Update Password", you get: **"Auth session missing"**

This happens because the authentication token from the email link isn't being properly handled.

## 🔍 Step-by-Step Testing Process

### Step 1: Test the Debug Page
1. **Open the debug page**: `http://192.168.29.241:8000/debug.html`
2. **Check what it shows** - this will help us understand the issue

### Step 2: Test Password Reset Flow with Debug
1. **Request password reset** from your mobile app
2. **Check your email** for the reset link
3. **Copy the reset link** from the email
4. **Replace `reset-password.html` with `debug.html`** in the link
5. **Open the modified link** in your mobile browser
6. **Check what the debug page shows**

### Step 3: Analyze the Results

The debug page will show:
- ✅ **URL Information**: What parameters are in the link
- ✅ **Session Status**: Whether authentication is working
- ✅ **Logs**: Step-by-step what's happening

## 🔧 Expected Results & Solutions

### If the debug page shows "No session":
**Problem**: The email link doesn't contain authentication tokens
**Solution**: Update Supabase redirect URL configuration

### If the debug page shows authentication tokens but no session:
**Problem**: Token parsing or session setting is failing
**Solution**: Fix the token handling in the HTML page

### If the debug page shows session but password update fails:
**Problem**: Session is valid but password update API call is failing
**Solution**: Check Supabase user permissions

## 🚀 Quick Test Commands

### Test 1: Check if server is accessible
```bash
# On mobile browser
http://192.168.29.241:8000/debug.html
```

### Test 2: Manual session test
1. Go to debug page
2. Click "🔄 Refresh Session"
3. Click "🔑 Test Password Update"
4. Check the logs

## 🔍 Common Issues & Fixes

### Issue 1: "Auth session missing"
**Cause**: Email link doesn't contain proper authentication tokens
**Fix**: 
```javascript
// The email link should contain these parameters:
#access_token=xxx&refresh_token=xxx&type=recovery
```

### Issue 2: "Invalid or expired reset link"
**Cause**: Token has expired or is malformed
**Fix**: Request a new password reset

### Issue 3: "Session error"
**Cause**: Supabase configuration issue
**Fix**: Check Supabase site URL and redirect settings

## 📱 Mobile Testing Steps

1. **Open StayMithra app** on your phone
2. **Go to "Forgot Password"**
3. **Enter your email**
4. **Tap "Reset Password"**
5. **Check email on your phone**
6. **Long-press the reset link** → Copy link
7. **Paste in mobile browser** and modify:
   - Change: `reset-password.html`
   - To: `debug.html`
8. **Open the debug link**
9. **Check what it shows**

## 🔧 Debugging Checklist

- [ ] Server running at `192.168.29.241:8000`
- [ ] Debug page accessible from mobile
- [ ] Password reset email received
- [ ] Email link contains authentication tokens
- [ ] Debug page shows session information
- [ ] Session can be established
- [ ] Password update API works

## 📋 What to Report

After testing, please share:

1. **Debug page URL info** (what parameters are in the email link)
2. **Session status** (authenticated or not)
3. **Error messages** from the logs
4. **Screenshots** of the debug page

## 🎯 Next Steps Based on Results

### If tokens are missing from email link:
- Update Supabase redirect URL configuration
- Check email template settings

### If tokens are present but session fails:
- Fix token parsing in HTML
- Update session handling code

### If session works but password update fails:
- Check Supabase user permissions
- Update password update API call

## 🚨 Emergency Fallback

If nothing works, we can implement a **token-based approach**:
1. Generate a secure token in the app
2. Store it in database with user ID
3. Send token in email instead of Supabase link
4. Verify token on web page
5. Update password directly via database

The debug page will help us identify exactly where the issue is occurring! 🔍
