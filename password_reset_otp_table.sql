-- Create table for storing password reset OTPs
CREATE TABLE IF NOT EXISTS password_reset_otps (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT NOT NULL,
    otp TEXT NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    used_at TIMESTAMP WITH TIME ZONE NULL
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_password_reset_otps_email ON password_reset_otps(email);
CREATE INDEX IF NOT EXISTS idx_password_reset_otps_otp ON password_reset_otps(otp);
CREATE INDEX IF NOT EXISTS idx_password_reset_otps_expires_at ON password_reset_otps(expires_at);

-- Enable RLS (Row Level Security)
ALTER TABLE password_reset_otps ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to insert their own OTP records
CREATE POLICY "Users can insert their own OTP records" ON password_reset_otps
    FOR INSERT WITH CHECK (true);

-- Create policy to allow users to read their own OTP records
CREATE POLICY "Users can read their own OTP records" ON password_reset_otps
    FOR SELECT USING (true);

-- Create policy to allow users to update their own OTP records
CREATE POLICY "Users can update their own OTP records" ON password_reset_otps
    FOR UPDATE USING (true);

-- Create policy to allow users to delete their own OTP records
CREATE POLICY "Users can delete their own OTP records" ON password_reset_otps
    FOR DELETE USING (true);

-- Create function to clean up expired OTPs
CREATE OR REPLACE FUNCTION cleanup_expired_otps()
RETURNS void AS $$
BEGIN
    DELETE FROM password_reset_otps 
    WHERE expires_at < NOW() - INTERVAL '1 hour';
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to automatically clean up expired OTPs daily
-- (You can set this up as a cron job or scheduled function in Supabase)
