import { redirect } from "next/navigation";

// PAPIRO — Central Única de Questões (fase de fusão): a UI que vivia aqui
// foi incorporada à aba "Sessão personalizada" de /questoes (ver
// components/questoes/SessaoPersonalizadaBusca.tsx). Esta rota continua
// existindo por compatibilidade (links/favoritos antigos) e só redireciona
// — Server Component puro, sem "use client", sem depender de sessão do
// navegador; redirect() do App Router funciona antes de qualquer auth
// check local. Nunca aponta para si mesma, então não há risco de loop.
export default function BuscarQuestoes() {
  redirect("/questoes?modo=personalizada");
}
