# HEAD MKT App — Guia de Deploy Completo

## RESUMO DOS PASSOS
1. Configurar Supabase (banco de dados)
2. Criar produtos no Stripe
3. Fazer deploy no Vercel
4. Configurar variáveis de ambiente
5. Configurar webhook do Stripe
6. Conectar domínio da Hostinger (opcional)

---

## PASSO 1 — SUPABASE (banco de dados)

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto (bywhpjlwyanredyiqwfl)
3. No menu lateral, clique em **SQL Editor**
4. Clique em **New Query**
5. Cole TODO o conteúdo do arquivo `supabase-schema.sql`
6. Clique em **Run** (ou Ctrl+Enter)
7. Deve aparecer "Success. No rows returned" — está correto!

**Configurar Storage (para fotos de perfil):**
1. No menu lateral, clique em **Storage**
2. Confirme que o bucket "avatars" foi criado (pelo SQL)
3. Se não aparecer, clique em "+ New Bucket" → nome: avatars → Public: SIM

**Configurar Auth (para login com Google):**
1. No menu lateral: **Authentication → Providers**
2. Ative o Google e coloque suas credenciais OAuth (se quiser login com Google)
3. Em **Authentication → URL Configuration**, adicione:
   - Site URL: https://seu-app.vercel.app
   - Redirect URLs: https://seu-app.vercel.app/app.html

---

## PASSO 2 — STRIPE (pagamentos)

1. Acesse: https://dashboard.stripe.com
2. Vá em **Products → Add product**

**Produto 1 — Plano Mensal:**
- Name: HEAD MKT Mensal
- Price: R$80,00 / month (BRL)
- Tipo: Recurring
- Copie o **Price ID** (começa com price_...)

**Produto 2 — Plano Anual:**
- Name: HEAD MKT Anual
- Price: R$768,00 / year (BRL)
- Tipo: Recurring
- Copie o **Price ID** (começa com price_...)

Anote os dois Price IDs — você vai precisar na Vercel.

---

## PASSO 3 — VERCEL (deploy)

**Opção A — Via interface web (mais fácil):**
1. Acesse: https://vercel.com/new
2. Clique em "Import Git Repository"
3. Conecte sua conta GitHub e selecione: `dudasant0s-ops/head-mkt-app`
4. Clique em **Deploy**

**Opção B — Via terminal (se tiver Node instalado):**
```bash
cd "HEAD IMOBILIÁRIA/head-mkt-app"
npm install -g vercel
vercel --prod
```

Após o deploy, anote a URL do app (ex: head-mkt-app.vercel.app)

---

## PASSO 4 — VARIÁVEIS DE AMBIENTE (Vercel)

1. Na Vercel, vá em seu projeto → **Settings → Environment Variables**
2. Adicione uma por uma:

| Nome | Valor |
|------|-------|
| SUPABASE_URL | https://bywhpjlwyanredyiqwfl.supabase.co |
| SUPABASE_SERVICE_KEY | (cole aqui sua chave sb_secret_... do Supabase) |
| STRIPE_SECRET_KEY | sk_test_51TYwuFGYjl2FFQcSPS8Fw... (sua chave secreta) |
| STRIPE_PRICE_MONTHLY | price_XXXX (Price ID do plano mensal) |
| STRIPE_PRICE_ANNUAL | price_XXXX (Price ID do plano anual) |
| STRIPE_WEBHOOK_SECRET | whsec_XXXX (preencher após passo 5) |
| VAPID_PUBLIC_KEY | 5s4b1h5jWXM1vQHhfhQQ1mzURG8TOR6neI1YtBpUC8YWpZdQKBD-m6P_cprB9xjj4dhFb0ORycdGZ3J1xzfUWw |
| VAPID_PRIVATE_KEY | Ai9oZR0arEYf8hUj0JLqZvQrzYbuzkE5XgcZ8N90VVOhRANCAATmzhvWHmNZczW9AeF-FBDWbNREbxM5Hqd4jVi0GlQLxhall1AoEP6bo_9ymsH3GOPh2EVvQ5HJx0ZncnXHN9Rb |
| VAPID_EMAIL | dudasants8@gmail.com |

3. Após adicionar todas → clique em **Redeploy**

---

## PASSO 5 — WEBHOOK DO STRIPE

1. No Stripe: **Developers → Webhooks → Add endpoint**
2. Endpoint URL: `https://SEU-APP.vercel.app/api/webhook`
3. Events to send: selecione:
   - `checkout.session.completed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_failed`
   - `invoice.payment_succeeded`
4. Clique em **Add endpoint**
5. Copie o **Signing secret** (whsec_...)
6. Volte na Vercel → cole o valor em `STRIPE_WEBHOOK_SECRET`
7. Redeploy novamente

---

## PASSO 6 — DOMÍNIO HOSTINGER (opcional)

1. Compre o domínio na Hostinger (ex: headmkt.com.br)
2. Na Vercel → projeto → **Settings → Domains**
3. Adicione seu domínio
4. A Vercel vai mostrar os DNS records a configurar
5. Na Hostinger → DNS → adicione os records que a Vercel indicou
6. Aguarde até 48h para propagar (geralmente <1h)

---

## PASSO 7 — TESTAR

1. Acesse seu app: https://seu-app.vercel.app
2. Faça login com dudasants8@gmail.com
3. Confirme que entrou direto no dashboard (sem paywall)
4. Teste criar um lead, tarefa e nota
5. Teste as notificações: habilite nas configurações
6. No mobile: abra no Safari (iOS) ou Chrome (Android) → "Adicionar à tela de início"

---

## MODO TESTE vs PRODUÇÃO

Atualmente está em **modo teste** do Stripe.
- Cartão de teste: `4242 4242 4242 4242` / qualquer data futura / qualquer CVV
- Para ir a produção: troque as chaves sk_test_ por sk_live_ no Stripe

---

## ESTRUTURA DO PROJETO

```
head-mkt-app/
├── public/
│   ├── index.html      ← Landing page
│   ├── login.html      ← Login / Cadastro
│   ├── app.html        ← Dashboard principal (protegido)
│   ├── manifest.json   ← PWA manifest
│   └── sw.js           ← Service Worker (offline + push)
├── api/
│   ├── create-checkout.js  ← Cria sessão de pagamento Stripe
│   ├── webhook.js          ← Recebe eventos do Stripe
│   └── send-push.js        ← Envia push notifications
├── supabase-schema.sql ← Schema do banco de dados
├── vercel.json         ← Configuração de deploy
├── package.json        ← Dependências Node.js
└── .gitignore
```

---

## SUPORTE

Problemas? Verifique:
- Vercel logs: dashboard.vercel.com → seu projeto → Deployments → Functions
- Supabase logs: supabase.com → seu projeto → Logs
- Stripe events: dashboard.stripe.com → Developers → Events
