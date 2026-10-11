import { IBM_Plex_Sans } from "next/font/google";
import "./painel.css";

const ibmPlexSans = IBM_Plex_Sans({
  variable: "--font-ibm-plex-sans",
  subsets: ["latin"],
  weight: "variable",
  display: "swap",
});

export default function PainelLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return <div className={ibmPlexSans.variable}>{children}</div>;
}
