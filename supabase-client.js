// Supabase client initialization (global for the app)
const SUPABASE_URL = 'https://figfwywciaeypwvzpskq.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_evTgJaCL3D4t05kNjdnVEQ_Rpb5MpFn';

window.supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
