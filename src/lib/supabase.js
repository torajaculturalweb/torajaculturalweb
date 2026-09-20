import { createClient } from '@supabase/supabase-js'

// Publishable credentials untuk project Supabase Toraja Pusaka.
// Publishable key aman digunakan pada aplikasi browser karena akses data
// tetap dibatasi oleh Row Level Security (RLS) di Supabase.
const url = 'https://yilroxvhlyxiuufujilc.supabase.co'
const key = 'sb_publishable_803Gj-DZnu1SvcldHBZ37Q_yYt_cb08'

function validSupabaseUrl(value) {
  try {
    const parsed = new URL(value)
    return parsed.protocol === 'https:' && parsed.hostname.endsWith('.supabase.co')
  } catch {
    return false
  }
}

const hasRealKey = Boolean(key && !key.includes('YOUR_') && !key.includes('xxxxxxxx'))
export const isConfigured = validSupabaseUrl(url) && hasRealKey
export const configurationError = !url || !key
  ? 'Environment variable Supabase belum diisi.'
  : !validSupabaseUrl(url)
    ? 'VITE_SUPABASE_URL tidak valid. Gunakan URL HTTPS yang berakhiran .supabase.co.'
    : !hasRealKey
      ? 'VITE_SUPABASE_ANON_KEY masih berupa placeholder.'
      : ''

let client = null
if (isConfigured) {
  try {
    client = createClient(url, key)
  } catch (error) {
    console.error('Supabase gagal diinisialisasi:', error)
  }
}

export const supabase = client
