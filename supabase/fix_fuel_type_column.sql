-- Fix fuel_type column type in user_vehicles table
-- It was incorrectly set as integer, but needs to be text to store values like 'Petrol 95'

ALTER TABLE public.user_vehicles 
ALTER COLUMN fuel_type TYPE text USING fuel_type::text;
