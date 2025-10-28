-- =================================================
-- SUPABASE STORAGE POLICIES FOR REMY
-- =================================================
-- Run this AFTER creating the "journal-photos" bucket
-- Dashboard: https://pwyweperbipjdisrkoio.supabase.co
-- Go to: SQL Editor → New Query → Paste this → Run
-- =================================================

-- IMPORTANT: First create the bucket in the UI!
-- 1. Go to Storage in Supabase Dashboard
-- 2. Click "New bucket"
-- 3. Name: journal-photos
-- 4. Make it Private
-- 5. Click Save
-- 6. THEN run this SQL

-- =================================================
-- Storage Policies for journal-photos bucket
-- =================================================

-- Allow users to upload their own photos
CREATE POLICY "Users can upload own photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'journal-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Allow users to view their own photos
CREATE POLICY "Users can view own photos"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'journal-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Allow users to delete their own photos
CREATE POLICY "Users can delete own photos"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'journal-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- =================================================
-- SETUP COMPLETE!
-- =================================================
-- Your storage is now secure. Users can only access
-- their own photos stored in their user folder.
--
-- Photos are stored as: userId/entryId.jpg
-- Example: a1b2c3d4-e5f6-7890-abcd-ef1234567890/photo.jpg
-- =================================================
