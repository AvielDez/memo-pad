import { redirect } from "@remix-run/node";
import { destroySession, getSession } from "../utils/session.server";


async function logout(request: Request) {
  const session = await getSession(request);
  return redirect("/auth/login", {
    headers: {
      "Set-Cookie": await destroySession(session),
    },
  });
}

export const action = async ({ request }: { request: Request }) => logout(request);
export const loader = async ({ request }: { request: Request }) => logout(request);
