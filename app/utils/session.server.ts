// lib/session.server.ts
import { createCookieSessionStorage } from '@remix-run/node'
import type { Session } from '@remix-run/node';

export const sessionStorage = createCookieSessionStorage({
  cookie: {
    name: '__session',
    secrets: ['your-secret'],
    sameSite: 'lax',
    path: '/',
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
  },
})


export const getSession = (request: Request) =>
  sessionStorage.getSession(request.headers.get('Cookie'));



export const destroySession = (session: Session) => {
  return sessionStorage.destroySession(session);
};
