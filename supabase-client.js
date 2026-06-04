// Supabase client initialization (global for the app)
const SUPABASE_URL = 'https://figfwywciaeypwvzpskq.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_evTgJaCL3D4t05kNjdnVEQ_Rpb5MpFn';

window.supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
	auth: {
		persistSession: true,
		autoRefreshToken: true,
		detectSessionInUrl: false,
	},
});

window.ensureSupabaseSession = async function ensureSupabaseSession() {
	if (!window.supabaseClient) {
		return { ok: false, error: new Error('Supabase client not initialized.') };
	}

	try {
		const { data: sessionData, error: sessionError } = await window.supabaseClient.auth.getSession();
		if (sessionError) return { ok: false, error: sessionError };
		if (sessionData?.session) return { ok: true, session: sessionData.session };

		const { data, error } = await window.supabaseClient.auth.signInAnonymously();
		if (error) return { ok: false, error };
		return { ok: true, session: data?.session || null };
	} catch (error) {
		return { ok: false, error };
	}
};
