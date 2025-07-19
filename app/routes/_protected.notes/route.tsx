// any loader (e.g. root or dashboard)
import { LoaderFunctionArgs, redirect, json } from '@remix-run/node'
import { useLoaderData } from '@remix-run/react'
import { getSession } from '~/utils/session.server'
import { createServerSupabaseClient } from '~/utils/supabaseClient.server'

export async function loader({ request }: LoaderFunctionArgs) {
  const session = await getSession(request)
  const accessToken = session.get('access_token')

  if (!accessToken) return redirect('/auth/login')

  const supabase = createServerSupabaseClient(accessToken)
  const { data: { user }, error } = await supabase.auth.getUser()

  if (error || !user) return redirect('/login')

  return json({ user }) 
}


export default function Notes() {
  const { user } = useLoaderData<typeof loader>()

  return (
    <div>
      <h1>Notes</h1>
      <p>Hello {user.email}</p>
      {/* Add more notes content here */}
    </div>
  )
}