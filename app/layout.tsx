import "./globals.css";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "LeadFlow Outreach CRM",
  description: "Private lead outreach command center",
};

export default function RootLayout({ children }: Readonly<{children: React.ReactNode}>) {
  return <html lang="en"><body>{children}</body></html>;
}