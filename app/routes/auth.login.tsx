// routes/login.tsx
import { ActionFunctionArgs, json, redirect, LoaderFunctionArgs } from '@remix-run/node'
import { getSession, sessionStorage } from '~/utils/session.server'
import { createServerSupabaseClient } from '~/utils/supabaseClient.server'
import { Form, useActionData } from '@remix-run/react'

export async function action({ request }: ActionFunctionArgs) {
  const form = await request.formData()
  const email = form.get('email') as string
  const password = form.get('password') as string

  const supabase = createServerSupabaseClient()
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  if (error || !data.session) {
    return json({ error: error?.message || 'Invalid credentials' }, { status: 401 })
  }

  const session = await getSession(request)
  session.set('access_token', data.session.access_token)

  return redirect('/dashboard', {
    headers: {
      'Set-Cookie': await sessionStorage.commitSession(session),
    },
  })
}

export async function loader({ request }: LoaderFunctionArgs) {
  const session = await getSession(request)
  if (session.has('access_token')) return redirect('/dashboard')
  return json({})
}

export default function LoginPage() {
  const actionData = useActionData<typeof action>()

  return (
    <div style={{ maxWidth: 400, margin: 'auto' }}>
      <h1>Login</h1>
      {actionData?.error && (
        <p style={{ color: 'red' }}>{actionData.error}</p>
      )}

      <Form method="post">
        <div>
          <label>Email</label>
          <input name="email" type="email" required />
        </div>

        <div>
          <label>Password</label>
          <input name="password" type="password" required />
        </div>

        <button type="submit">Sign In</button>
      </Form>
    </div>
  )
}
