import type { MetaFunction } from "@remix-run/node";

export const meta: MetaFunction = () => {
  return [
    { title: "Memo Pad" },
    { name: "description", content: "Welcome to Memo Pad!" },
  ];
};

export default function Index() {
  return (
    <div>
      <h1>This will be a redirect to /auth/login</h1>
    </div>
  );
};
