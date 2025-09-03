-- Fix Google OAuth user profile data
-- Run this in your Supabase SQL Editor to fix existing Google OAuth users

-- Update the trigger function to properly handle Google OAuth data
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, username, full_name, avatar_url, is_verified)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', ''),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', NEW.raw_user_meta_data->>'picture'),
    COALESCE((NEW.raw_user_meta_data->>'email_verified')::boolean, NEW.email_confirmed_at IS NOT NULL, false)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update existing users who might be missing Google profile data
UPDATE public.users 
SET 
  full_name = COALESCE(
    auth_users.raw_user_meta_data->>'full_name', 
    auth_users.raw_user_meta_data->>'name',
    users.full_name
  ),
  avatar_url = COALESCE(
    auth_users.raw_user_meta_data->>'avatar_url',
    auth_users.raw_user_meta_data->>'picture',
    users.avatar_url
  ),
  is_verified = COALESCE(
    (auth_users.raw_user_meta_data->>'email_verified')::boolean,
    auth_users.email_confirmed_at IS NOT NULL,
    users.is_verified
  ),
  updated_at = NOW()
FROM auth.users AS auth_users
WHERE users.id = auth_users.id
  AND (
    users.full_name IS NULL OR users.full_name = '' OR
    users.avatar_url IS NULL OR
    users.is_verified = false
  )
  AND auth_users.raw_user_meta_data IS NOT NULL;

-- Create or replace function to sync user profile data from auth metadata
CREATE OR REPLACE FUNCTION public.sync_user_profile_from_auth()
RETURNS void AS $$
BEGIN
  UPDATE public.users 
  SET 
    full_name = COALESCE(
      auth_users.raw_user_meta_data->>'full_name', 
      auth_users.raw_user_meta_data->>'name',
      users.full_name
    ),
    avatar_url = COALESCE(
      auth_users.raw_user_meta_data->>'avatar_url',
      auth_users.raw_user_meta_data->>'picture',
      users.avatar_url
    ),
    is_verified = COALESCE(
      (auth_users.raw_user_meta_data->>'email_verified')::boolean,
      auth_users.email_confirmed_at IS NOT NULL,
      users.is_verified
    ),
    updated_at = NOW()
  FROM auth.users AS auth_users
  WHERE users.id = auth_users.id
    AND auth_users.raw_user_meta_data IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Call the sync function to update existing users
SELECT public.sync_user_profile_from_auth();
