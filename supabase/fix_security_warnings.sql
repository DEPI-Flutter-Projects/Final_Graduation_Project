-- Fix "Function Search Path Mutable" security warnings
-- This script explicitly sets the search_path for functions to 'public'

-- Fix handle_new_user function
ALTER FUNCTION public.handle_new_user() SET search_path = public;

-- Fix update_updated_at_column function
ALTER FUNCTION public.update_updated_at_column() SET search_path = public;
