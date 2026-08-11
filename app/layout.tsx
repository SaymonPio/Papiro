import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  metadataBase: new URL("https://papiro-policial.saymon-fariaspio.chatgpt.site"),
  title: "Papiro | Preparação inteligente para concursos policiais",
  description:
    "Transforme seu edital em um plano inteligente de estudos, acompanhe seu desempenho e prepare-se para a prova e o TAF.",
  openGraph: {
    title: "Papiro | Sua rota até a farda",
    description: "Cronograma inteligente para concursos policiais.",
    images: [{ url: "/og.png", width: 1774, height: 887, alt: "Papiro — Sua rota até a farda" }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Papiro | Sua rota até a farda",
    description: "Cronograma inteligente para concursos policiais.",
    images: ["/og.png"],
  },
  icons: {
    icon: "/favicon.svg",
    shortcut: "/favicon.svg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="pt-BR">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
