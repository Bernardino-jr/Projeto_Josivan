import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey || supabaseUrl === 'sua_url_do_supabase_aqui') {
  console.warn('⚠️ AVISO: Credenciais do Supabase ainda não configuradas no arquivo .env');
}

export const supabase =
  supabaseUrl && supabaseKey && supabaseUrl.startsWith('http')
    ? createClient(supabaseUrl, supabaseKey)
    : null;