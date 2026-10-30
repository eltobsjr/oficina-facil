// Ambiente fixo para os testes: nunca depende (nem lê) o .env real. Valores fictícios.
process.env['NODE_ENV'] = 'test';
process.env['DATABASE_URL'] = 'postgresql://teste:teste@localhost:5432/teste';
process.env['SUPABASE_URL'] = 'https://projeto-ficticio.supabase.co';
process.env['CORS_ORIGINS'] = 'https://app.exemplo.com.br';
process.env['RATE_LIMIT_ESCRITA_POR_MINUTO'] = '3';
