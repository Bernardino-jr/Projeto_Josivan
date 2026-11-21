import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { supabase } from './config/supabase';
import authRoutes from './routes/authRoutes';
import materialRoutes from './routes/materialRoutes';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3333;

app.use(cors());
app.use(express.json());

app.get('/api/health', (_req: Request, res: Response) => {
  res.status(200).json({
    status: 'online',
    projeto: 'Repositório Colaborativo ADS - UNINASSAU',
    bancoConectado: Boolean(supabase),
    timestamp: new Date().toISOString(),
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/materiais', materialRoutes);

app.listen(PORT, () => {
  console.log(`🚀 Servidor Back-end rodando na porta ${PORT}`);
});