// lib/supabaseClient.ts
import { createClient } from '@supabase/supabase-js'
import { Database } from '../../lib/schemas/supabase'
import { env } from './env.server'

export const supabaseClient = createClient<Database>(
  env.API_URL,
  env.GraphQL_URL
)

export const createServerSupabaseClient = (accessToken?: string) => {
  return createClient<Database>(
    env.API_URL,
    env.Anon_Key,
    {
      global: {
        headers: accessToken
        ? { Authorization: `Bearer ${accessToken}` }
        : undefined,
      },
    }
  )
}
